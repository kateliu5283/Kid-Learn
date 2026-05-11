import '../models/lesson.dart';
import 'chinese/chinese_lessons.dart';
import 'math/math_lessons.dart';
import 'science/science_g1_lessons.dart';
import 'expanded_curriculum.dart';

/// 全冊課程單元彙整：國語（1～4 年完整單元）、數學（1～2 年完整單元）、自然（小一完整單元），
/// 以及依 108 課綱補齊之擴充單元（英語、社會、綜合 1～6 年；自然 2～6 年；數學 3～6 年；國語 5～6 年；每學期 6 單元）。
final List<Lesson> kLessons = [
  ...kScienceG1Lessons,
  ...kChineseLessons,
  ...kMathLessons,
  ...kExpanded108Lessons,
];

/// 取得目前所有可用的課綱主題軸（依學科 + 年級 過濾）
List<CurriculumTrack> tracksFor({String? subjectId, int? grade}) {
  final set = <CurriculumTrack>{};
  for (final l in kLessons) {
    if (subjectId != null && l.subjectId != subjectId) continue;
    if (grade != null && l.grade != grade) continue;
    set.add(l.track);
  }
  final list = set.toList();
  list.sort((a, b) => a.index.compareTo(b.index));
  return list;
}

List<Lesson> lessonsFor(String subjectId, int grade) {
  return kLessons
      .where((l) => l.subjectId == subjectId && l.grade == grade)
      .toList();
}

List<Lesson> lessonsForSubject(String subjectId) {
  return kLessons.where((l) => l.subjectId == subjectId).toList();
}

Lesson? lessonById(String id) {
  try {
    return kLessons.firstWhere((l) => l.id == id);
  } catch (_) {
    return null;
  }
}

const List<String> kDailyQuotes = [
  '今天也要開開心心學習喔！',
  '失敗是成功之母，再試一次！',
  '閱讀是打開世界的鑰匙 🔑',
  '每一天，進步一點點！',
  '好習慣從今天開始養成 🌱',
  '相信自己，你可以的！',
];
