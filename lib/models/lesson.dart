import 'package:flutter/material.dart';
import 'question.dart';

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

  /// 關鍵字詞：國語用作生字、英語用作單字、數學用作名詞
  final List<VocabItem> vocabulary;

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
  });

  /// 顯示用的課綱標籤：例如「108 課綱 · 一上 第 3 單元」
  String get editionLabel {
    final sb = StringBuffer();
    if (track == CurriculumTrack.core) {
      sb.write('108 課綱');
    } else {
      sb.write(track.label);
    }
    if (semester != null) {
      sb.write(' · $grade${semester!.label}');
    }
    if (unit != null) {
      sb.write(' 第 $unit 單元');
    }
    return sb.toString();
  }
}
