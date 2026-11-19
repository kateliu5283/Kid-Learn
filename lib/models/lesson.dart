import 'package:flutter/material.dart';
import 'question.dart';
import 'lesson_block.dart';

/// 108 課綱學習主題軸（與各學科自行定義的主軸對應）。
/// 用於分類與呈現，不綁定任何特定出版社教材。
enum CurriculumTrack {
  /// 對應課綱內容，基礎學習
  core('課綱', Color(0xFF1E88E5)),

  /// 延伸練習 / 跨領域素養
  extended('素養', Color(0xFF43A047)),

  /// 通用（一般練習題）
  general('一般', Color(0xFF757575));

  final String label;
  final Color color;
  const CurriculumTrack(this.label, this.color);
}

/// 學期
enum Semester {
  first('上'),
  second('下');

  final String label;
  const Semester(this.label);
}

/// 國小教科書版本。一、二年級的國語、數學會依版本分單元。
enum TextbookPublisher {
  kangxuan('康軒', 'kx'),
  hanlin('翰林', 'hl'),
  nani('南一', 'ny');

  final String label;
  final String code;
  const TextbookPublisher(this.label, this.code);
}

/// 國語冊別。首冊是注音；第一、二冊是一年級，第三、四冊是二年級。
enum TextbookPart {
  primer('首冊', 0),
  volumeOne('第一冊', 1),
  volumeTwo('第二冊', 2),
  volumeThree('第三冊', 3),
  volumeFour('第四冊', 4);

  final String label;
  final int order;
  const TextbookPart(this.label, this.order);
}

/// 關鍵字詞/生字：預習和複習時顯示
class VocabItem {
  final String term;
  final String meaning;
  final String? example;

  const VocabItem({
    required this.term,
    required this.meaning,
    this.example,
  });
}

/// 本課可以手寫的生字。
class WritingGlyph {
  final String char;
  final String zhuyin;
  final String meaning;
  final int strokes;

  const WritingGlyph({
    required this.char,
    required this.zhuyin,
    required this.meaning,
    required this.strokes,
  });
}

class Lesson {
  final String id;
  final String subjectId;
  final int grade;
  final String title;
  final String summary;
  final String content;
  final List<Question> questions;
  final int estimatedMinutes;
  final CurriculumTrack track;
  final Semester? semester;
  final int? unit;

  /// 學習目標：1-3 個簡短條列，預習時顯示
  final List<String> objectives;

  /// 重點整理：上完課的摘要卡
  final List<String> keyPoints;

  /// 關鍵字詞：國語生字、英語單字；數學等科目不在 UI 顯示字詞卡
  final List<VocabItem> vocabulary;

  /// 結構化圖文教學區塊；若為空則由 [content] 自動解析
  final List<LessonBlock> teachingBlocks;

  /// 教科書版本；未分版本的課綱單元為 null。
  final TextbookPublisher? publisher;

  /// 首冊或第一冊；未分冊的課綱單元為 null。
  final TextbookPart? part;

  /// 課次的顯示文字。有設值時取代「第 n 課」，例如入門課。
  final String? unitLabel;

  /// 本課生字，供手寫練習。
  final List<WritingGlyph> writingPractice;

  const Lesson({
    required this.id,
    required this.subjectId,
    required this.grade,
    required this.title,
    required this.summary,
    required this.content,
    required this.questions,
    this.estimatedMinutes = 10,
    this.track = CurriculumTrack.general,
    this.semester,
    this.unit,
    this.objectives = const [],
    this.keyPoints = const [],
    this.vocabulary = const [],
    this.teachingBlocks = const [],
    this.publisher,
    this.part,
    this.unitLabel,
    this.writingPractice = const [],
  });

  /// 顯示用標籤：例如「康軒 · 1上 首冊 第 3 課」或「108 課綱 · 1下 第 2 單元」
  String get editionLabel {
    final sb = StringBuffer();
    if (publisher != null) {
      sb.write(publisher!.label);
    } else if (track == CurriculumTrack.core) {
      sb.write('108 課綱');
    } else {
      sb.write(track.label);
    }
    if (semester != null) {
      sb.write(' · $grade${semester!.label}');
    }
    if (part != null) {
      sb.write(' ${part!.label}');
    }
    if (unitLabel != null) {
      sb.write(' $unitLabel');
    } else if (unit != null) {
      final unitWord = publisher != null && subjectId == 'chinese' ? '課' : '單元';
      sb.write(' 第 $unit $unitWord');
    }
    return sb.toString();
  }
}
