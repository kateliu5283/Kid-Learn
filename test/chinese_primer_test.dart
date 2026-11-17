import 'package:flutter_test/flutter_test.dart';
import 'package:kid_learn/curriculum/catalog.dart';
import 'package:kid_learn/curriculum/chinese/primer/hanlin_primer.dart';
import 'package:kid_learn/curriculum/chinese/primer/kangxuan_primer.dart';
import 'package:kid_learn/curriculum/chinese/primer/nani_primer.dart';
import 'package:kid_learn/curriculum/handwriting/lesson_writing.dart';
import 'package:kid_learn/models/lesson.dart';

void main() {
  test('國語首冊三版本課次、練習與測驗都齊', () {
    expect(kKangxuanPrimerLessons.map((l) => l.title).toList(), [
      '貓咪',
      '鵝寶寶',
      '河馬和河狸',
      '複習一',
      '笑嘻嘻',
      '翹翹板',
      '謝謝老師',
      '複習二',
      '龜兔賽跑',
      '拔蘿蔔',
      '動物狂歡會',
      '複習三',
    ]);
    expect(kHanlinPrimerLessons.map((l) => l.title).toList(), [
      '手拉手',
      '排一排',
      '來數數',
      '找一找',
      '統整活動一',
      '雨來了',
      '山坡上的學校',
      '值日生',
      '運動會',
      '做卡片',
      '統整活動二',
    ]);
    expect(kNaniPrimerLessons.map((l) => l.title).toList(), [
      '踢踏踢',
      '木馬',
      '晚安',
      '統整活動一',
      '紙飛機',
      '好漂亮',
      '剪刀石頭布',
      '統整活動二',
      '不來梅樂隊',
      '小蝌蚪找媽媽',
      '動物狂歡節',
      '統整活動三',
    ]);

    final primer = [
      ...kKangxuanPrimerLessons,
      ...kHanlinPrimerLessons,
      ...kNaniPrimerLessons,
    ];
    final ids = primer.map((l) => l.id).toSet();
    expect(ids.length, primer.length);

    for (final lesson in primer) {
      expect(lesson.subjectId, 'chinese');
      expect(lesson.grade, 1);
      expect(lesson.semester, Semester.first);
      expect(lesson.publisher, isNotNull);
      expect(lesson.questions.length, greaterThanOrEqualTo(20));
      expect(lesson.writingPractice.length, greaterThanOrEqualTo(4));
      expect(lesson.vocabulary, isNotEmpty);
      final prompts = lesson.questions.map((q) => q.prompt).toList();
      expect(prompts.toSet().length, prompts.length, reason: lesson.id);
      expect(lesson.objectives, isNotEmpty);
      expect(lesson.content.contains('本課符號'), isTrue, reason: lesson.id);
      for (final q in lesson.questions) {
        expect(q.options.length, 4, reason: '${lesson.id} ${q.id}');
        expect(q.options.toSet().length, 4, reason: q.prompt);
        expect(q.correctIndex, inInclusiveRange(0, 3), reason: q.id);
        expect(q.explanation, isNotNull);
      }
      for (final glyph in lesson.writingPractice) {
        expect(glyph.char.runes.length, 1, reason: lesson.id);
        expect(glyph.strokes, greaterThan(0));
        expect(glyph.zhuyin, isNotEmpty);
      }
    }

    final g1s1 = kLessons.where(
      (l) => l.subjectId == 'chinese' && l.grade == 1 && l.semester == Semester.first,
    );
    expect(g1s1.every((l) => l.publisher != null), isTrue);
    expect(g1s1.any((l) => l.title == '上學了'), isFalse);
  });

  test('每題正確答案都和注音、聲調、例句一致', () {
    final primer = [
      ...kKangxuanPrimerLessons,
      ...kHanlinPrimerLessons,
      ...kNaniPrimerLessons,
    ];
    for (final lesson in primer) {
      expect(lesson.questions.length, inInclusiveRange(20, 24), reason: lesson.id);
      for (final q in lesson.questions) {
        final answer = q.options[q.correctIndex];
        final explanation = q.explanation ?? '';
        final checked = _checkQuestion(q.prompt, answer, explanation, q.options);
        if (q.id.contains('-bank-')) {
          expect(checked, isTrue, reason: '${lesson.id} ${q.prompt}');
        }
      }
    }
  });

  test('生字筆畫符合教育部筆畫，並能轉成手寫字庫', () {
    const moe = {
      '一': 1, '七': 2, '人': 2, '八': 2, '下': 3, '大': 3, '子': 3, '小': 3,
      '也': 3, '三': 3, '中': 4, '天': 4, '木': 4, '日': 4, '月': 4, '王': 4,
      '文': 4, '五': 4, '公': 4, '四': 5, '去': 5, '可': 5, '用': 5, '衣': 6,
      '安': 6, '早': 6, '有': 6, '羊': 6, '吃': 6, '在': 6, '收': 6, '好': 6,
      '字': 6, '我': 7, '你': 7, '快': 7, '爸': 8, '來': 8, '兒': 8, '玩': 8,
      '拉': 8, '阿': 8, '怕': 8, '青': 8, '河': 8, '兔': 8, '飛': 9, '咪': 9,
      '是': 9, '很': 9, '音': 9, '英': 9, '為': 9, '風': 9, '唷': 10, '草': 10,
      '高': 10, '旁': 10, '家': 10, '笑': 10, '隻': 10, '翁': 10, '恩': 10,
      '紙': 10, '個': 10, '狸': 10, '崖': 11, '排': 11, '晚': 11, '魚': 11,
      '菜': 12, '跑': 12, '畫': 12, '登': 12, '雲': 12, '陽': 12, '喔': 12,
      '黑': 12, '媽': 13, '會': 13, '搖': 13, '園': 13, '圓': 13, '摸': 14,
      '誒': 14, '滴': 14, '踏': 15, '糖': 16, '貓': 16, '鴨': 16, '機': 16,
      '顆': 17, '聲': 17, '鵝': 18, '聽': 22,
    };

    final primer = [
      ...kKangxuanPrimerLessons,
      ...kHanlinPrimerLessons,
      ...kNaniPrimerLessons,
    ];
    for (final lesson in primer) {
      final chars = lesson.writingPractice.map((g) => g.char).toList();
      expect(chars.toSet().length, chars.length, reason: lesson.id);
      expect(lesson.content.contains('生字：${chars.join('、')}'), isTrue);
      for (final glyph in lesson.writingPractice) {
        expect(moe[glyph.char], glyph.strokes, reason: glyph.char);
        expect(glyph.zhuyin, isNot(contains(' ')));
      }
      final set = writingSetFor(lesson);
      expect(set, isNotNull);
      expect(set!.id, 'hw-${lesson.id}');
      expect(set.name, '${lesson.publisher!.label}・${lesson.title}');
      expect(set.characters.map((c) => c.char).toList(), chars);
      expect(
        set.characters.map((c) => c.strokes).toList(),
        lesson.writingPractice.map((g) => g.strokes).toList(),
      );
    }

    final grade1 = writingSetsFor(kLessons.where((l) => l.grade == 1));
    final withWriting = kLessons.where(
      (l) => l.grade == 1 && l.writingPractice.isNotEmpty,
    );
    expect(grade1.length, withWriting.length);
    expect(grade1.first.name, '康軒・貓咪');
    expect(
      writingSetsFor(kLessons.where((l) => l.grade == 2)),
      isEmpty,
    );
  });
}

bool _checkQuestion(
  String prompt,
  String answer,
  String explanation,
  List<String> options,
) {
  final readingParen = RegExp(r'（([^）]+)）').firstMatch(explanation);
  final statedReading = readingParen == null ? null : readingParen.group(1)!;

  final readingPrompt = RegExp(r'^「(.+)」的注音是哪一個？$').firstMatch(prompt);
  if (readingPrompt != null) {
    expect(explanation, contains('的注音是 $answer'));
    return true;
  }

  final whichChar = RegExp(r'^哪一個字念「(.+)」？$').firstMatch(prompt);
  if (whichChar != null) {
    expect(explanation, '${whichChar.group(1)} 是「$answer」。');
    return true;
  }

  final symbolInside = RegExp(r'^「(.+)」的注音裡，有哪一個符號？$').firstMatch(prompt);
  if (symbolInside != null) {
    expect(statedReading, isNotNull, reason: prompt);
    final bare = _bare(statedReading!);
    expect(bare.contains(answer), isTrue, reason: prompt);
    for (final option in options) {
      if (option == answer) continue;
      expect(bare.contains(option), isFalse, reason: '$prompt / $option');
    }
    return true;
  }

  final tone = RegExp(r'^「(.+)」是第幾聲？$').firstMatch(prompt);
  if (tone != null) {
    final readings = RegExp(r'[ㄅ-ㄩ]+[ˊˇˋ˙]*')
        .allMatches(explanation)
        .map((match) => match.group(0)!)
        .toList();
    expect(readings, isNotEmpty, reason: prompt);
    expect(answer, _toneName(readings.first), reason: '$prompt ${readings.first}');
    return true;
  }

  final initial = RegExp(r'^「(.+)」的聲母是？$').firstMatch(prompt);
  if (initial != null) {
    final readings = RegExp(r'[ㄅ-ㄩ]+[ˊˇˋ˙]*')
        .allMatches(explanation)
        .map((match) => match.group(0)!)
        .toList();
    expect(readings, isNotEmpty, reason: prompt);
    expect(_bare(readings.first).startsWith(answer), isTrue, reason: prompt);
    if (explanation.contains('聲母是')) {
      expect(explanation, contains('聲母是 $answer'));
    }
    return true;
  }

  final finalSound = RegExp(r'^本課裡，「(.+)」要練習的韻母是？$').firstMatch(prompt);
  if (finalSound != null) {
    expect(statedReading, isNotNull, reason: prompt);
    expect(explanation, contains('要練習的韻母是 $answer'));
    final bare = _bare(statedReading!);
    expect(bare.contains(answer), isTrue, reason: prompt);
    for (final option in options) {
      if (option == answer) continue;
      expect(bare.contains(option), isFalse, reason: '$prompt / $option');
    }
    return true;
  }

  final meaning = RegExp(r'^「(.+)」的意思最接近？$').firstMatch(prompt);
  if (meaning != null) {
    expect(explanation, contains(answer));
    expect(explanation, contains(meaning.group(1)));
    return true;
  }

  final sentence = RegExp(r'^哪一句用到了「(.+)」？$').firstMatch(prompt);
  if (sentence != null) {
    final term = sentence.group(1)!;
    expect(answer.contains(term), isTrue, reason: prompt);
    for (final option in options) {
      if (option == answer) continue;
      expect(option.contains(term), isFalse, reason: '$prompt / $option');
    }
    return true;
  }

  final statedInitial = RegExp(r'聲母是\s*([ㄅ-ㄩ]+)').firstMatch(explanation);
  if (statedInitial != null) {
    expect(answer, statedInitial.group(1), reason: prompt);
    return true;
  }
  final statedFinal = RegExp(r'韻母是\s*([ㄅ-ㄩ]+)').firstMatch(explanation);
  if (statedFinal != null) {
    expect(answer, statedFinal.group(1), reason: prompt);
    return true;
  }
  return false;
}

String _bare(String reading) => reading.replaceAll(RegExp(r'[ˊˇˋ˙]'), '');

String _toneName(String reading) {
  if (reading.contains('ˋ')) return '四聲';
  if (reading.contains('ˇ')) return '三聲';
  if (reading.contains('ˊ')) return '二聲';
  return '一聲';
}
