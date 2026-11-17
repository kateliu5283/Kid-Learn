import '../../models/lesson.dart';
import 'character_sets.dart';

/// 把課程裡的生字轉成手寫字庫。
CharacterSet? writingSetFor(Lesson lesson) {
  if (lesson.writingPractice.isEmpty) return null;
  final publisher = lesson.publisher?.label;
  final name = publisher == null ? lesson.title : '$publisher・${lesson.title}';
  return CharacterSet(
    id: 'hw-${lesson.id}',
    name: name,
    description: '本課生字 ${lesson.writingPractice.length} 個，可描寫、可評分',
    grade: lesson.grade,
    characters: [
      for (final glyph in lesson.writingPractice)
        CharacterItem(
          char: glyph.char,
          zhuyin: glyph.zhuyin,
          meaning: glyph.meaning,
          strokes: glyph.strokes,
        ),
    ],
  );
}

List<CharacterSet> writingSetsFor(Iterable<Lesson> lessons) {
  return [
    for (final lesson in lessons)
      if (writingSetFor(lesson) case final set?) set,
  ];
}
