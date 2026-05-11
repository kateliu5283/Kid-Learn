import '../models/lesson.dart';
import 'expanded/supplementary_domains.dart';
import 'expanded/math_upper_primary.dart';
import 'expanded/chinese_upper_primary.dart';

/// 108 課綱擴充：英語與社會、綜合 1～6 年級；自然 2～6 年級；數學 3～6 年級；國語 5～6 年級（皆含上下學期單元）。
final List<Lesson> kExpanded108Lessons = [
  ...buildSupplementaryDomainLessons(),
  ...buildMathUpperPrimaryLessons(),
  ...buildChineseUpperPrimaryLessons(),
];
