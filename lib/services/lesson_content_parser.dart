import '../models/lesson.dart';
import '../models/lesson_block.dart';
import 'lesson_teaching.dart';

/// 將課程 `content` 文字解析為圖文教學區塊。
class LessonContentParser {
  LessonContentParser._();

  static List<LessonBlock> blocksFor(Lesson lesson) {
    if (lesson.teachingBlocks.isNotEmpty) {
      return lesson.teachingBlocks;
    }
    final content = LessonTeaching.effectiveContent(lesson);
    return parse(content, title: lesson.title, summary: lesson.summary);
  }

  static final _emojiBullet = RegExp(
    r'^([\u{1F300}-\u{1FAFF}\u2600-\u27BF☀-⛿]|[^\s])[\s\uFE0F]*(.+?)(?:──|—|--|-)\s*(.+)$',
    unicode: true,
  );
  static final _arrowExample = RegExp(r'^(.+?)\s*[→➜➡]\s*(.+)$');
  static final _numberedStep = RegExp(r'^(\d+)[\.．、\)]\s*(.+)$');
  static final _phonicsPair = RegExp(r'^([ㄅ-ㄩ]{1,3})\s+(\S+)$');
  static final _emojiLine = RegExp(r'^[\u{1F300}-\u{1FAFF}\u2600-\u27BF]', unicode: true);

  static List<LessonBlock> parse(
    String content, {
    String? title,
    String? summary,
  }) {
    if (content.trim().isEmpty) {
      return [
        if (summary != null && summary.isNotEmpty)
          LessonBlock(kind: LessonBlockKind.intro, text: summary),
      ];
    }

    final blocks = <LessonBlock>[];
    final paragraphs = content.split(RegExp(r'\n\s*\n'));

    for (var i = 0; i < paragraphs.length; i++) {
      final para = paragraphs[i].trim();
      if (para.isEmpty) continue;

      final lines = para
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      if (lines.isEmpty) continue;

      // 注音對照：多行 ㄅ 不 格式，或單行空格分隔
      if (_isPhonicsBlock(lines)) {
        blocks.addAll(_parsePhonics(lines));
        continue;
      }

      // emoji 條列：☀️ 陽光──說明
      if (lines.every((l) => _emojiBullet.hasMatch(l) || _looksLikeBullet(l))) {
        for (final line in lines) {
          final b = _parseBulletLine(line);
          if (b != null) blocks.add(b);
        }
        continue;
      }

      // 箭頭範例
      if (lines.every((l) => _arrowExample.hasMatch(l))) {
        for (final line in lines) {
          final m = _arrowExample.firstMatch(line)!;
          blocks.add(LessonBlock(
            kind: LessonBlockKind.example,
            leading: m.group(1)!.trim(),
            text: m.group(2)!.trim(),
          ));
        }
        continue;
      }

      // 編號步驟
      if (lines.every((l) => _numberedStep.hasMatch(l))) {
        for (final line in lines) {
          final m = _numberedStep.firstMatch(line)!;
          blocks.add(LessonBlock(
            kind: LessonBlockKind.step,
            leading: m.group(1),
            text: m.group(2)!.trim(),
          ));
        }
        continue;
      }

      // 比較句（含 > < 或「比較多/少」）
      if (lines.length == 1 && _isCompareLine(lines.first)) {
        blocks.add(LessonBlock(
          kind: LessonBlockKind.compare,
          text: lines.first,
        ));
        continue;
      }

      // 單行短句 → 小標或導言
      if (lines.length == 1) {
        final line = lines.first;
        if (line.length <= 20 && !line.contains('。')) {
          blocks.add(LessonBlock(
            kind: i == 0 ? LessonBlockKind.intro : LessonBlockKind.heading,
            text: line,
          ));
        } else if (_emojiLine.hasMatch(line) && line.length < 60) {
          blocks.add(LessonBlock(
            kind: LessonBlockKind.tip,
            text: line,
          ));
        } else {
          blocks.add(LessonBlock(kind: LessonBlockKind.paragraph, text: line));
        }
        continue;
      }

      // 多行混合：第一行當標題，其餘當段落或條列
      if (lines.length >= 2 && lines.first.length <= 24) {
        blocks.add(LessonBlock(
          kind: LessonBlockKind.heading,
          text: lines.first.replaceAll('：', '').replaceAll(':', ''),
        ));
        for (var j = 1; j < lines.length; j++) {
          final b = _parseBulletLine(lines[j]) ??
              LessonBlock(kind: LessonBlockKind.paragraph, text: lines[j]);
          blocks.add(b);
        }
        continue;
      }

      // 預設：整段文字
      blocks.add(LessonBlock(
        kind: i == 0 ? LessonBlockKind.intro : LessonBlockKind.paragraph,
        text: lines.join('\n'),
      ));
    }

    return blocks;
  }

  static bool _isPhonicsBlock(List<String> lines) {
    if (lines.length == 1) {
      final parts = lines.first.split(RegExp(r'\s+'));
      if (parts.length >= 4 && parts.length.isEven) {
        return parts.where(_isBopomofo).length >= 2;
      }
    }
    return lines.where((l) => _phonicsPair.hasMatch(l)).length >=
        (lines.length + 1) ~/ 2;
  }

  static List<LessonBlock> _parsePhonics(List<String> lines) {
    final pairs = <LessonBlock>[];
    for (final line in lines) {
      if (_phonicsPair.hasMatch(line)) {
        final m = _phonicsPair.firstMatch(line)!;
        pairs.add(LessonBlock(
          kind: LessonBlockKind.phonics,
          leading: m.group(1),
          text: m.group(2)!,
        ));
      } else {
        // 單行多組：ㄅ 不 ㄆ 皮 ㄇ 毛
        final parts = line.split(RegExp(r'\s+'));
        for (var i = 0; i + 1 < parts.length; i += 2) {
          if (_isBopomofo(parts[i])) {
            pairs.add(LessonBlock(
              kind: LessonBlockKind.phonics,
              leading: parts[i],
              text: parts[i + 1],
            ));
          }
        }
      }
    }
    if (pairs.isEmpty) {
      return [LessonBlock(kind: LessonBlockKind.paragraph, text: lines.join('\n'))];
    }
    return pairs;
  }

  static bool _isBopomofo(String s) =>
      RegExp(r'^[ㄅ-ㄩ]+$').hasMatch(s);

  static bool _looksLikeBullet(String line) =>
      _emojiBullet.hasMatch(line) ||
      line.startsWith('•') ||
      line.startsWith('-') ||
      line.startsWith('－');

  static LessonBlock? _parseBulletLine(String line) {
    final m = _emojiBullet.firstMatch(line);
    if (m != null) {
      return LessonBlock(
        kind: LessonBlockKind.bullet,
        leading: m.group(1),
        title: m.group(2)!.trim(),
        text: m.group(3)!.trim(),
      );
    }
    if (line.startsWith('•') || line.startsWith('-') || line.startsWith('－')) {
      return LessonBlock(
        kind: LessonBlockKind.bullet,
        text: line.replaceFirst(RegExp(r'^[•\-－]\s*'), ''),
      );
    }
    return null;
  }

  static bool _isCompareLine(String line) =>
      line.contains('>') ||
      line.contains('<') ||
      line.contains('比較') ||
      line.contains('比 ') ||
      line.contains(' 比');
}
