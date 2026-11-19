import 'package:flutter_test/flutter_test.dart';
import 'package:kid_learn/curriculum/catalog.dart';
import 'package:kid_learn/curriculum/chinese/book3/hanlin_book.dart';
import 'package:kid_learn/curriculum/chinese/book3/kangxuan_book.dart';
import 'package:kid_learn/curriculum/chinese/book3/nani_book.dart';
import 'package:kid_learn/curriculum/chinese/book4/hanlin_book.dart';
import 'package:kid_learn/curriculum/chinese/book4/kangxuan_book.dart';
import 'package:kid_learn/curriculum/chinese/book4/nani_book.dart';
import 'package:kid_learn/curriculum/handwriting/lesson_writing.dart';
import 'package:kid_learn/models/lesson.dart';

void main() {
  test('國語二上二下三版本十二課都齊', () {
    expect(kKangxuanBook3Lessons, hasLength(12));
    expect(kHanlinBook3Lessons, hasLength(12));
    expect(kNaniBook3Lessons, hasLength(12));
    expect(kKangxuanBook4Lessons, hasLength(12));
    expect(kHanlinBook4Lessons, hasLength(12));
    expect(kNaniBook4Lessons, hasLength(12));

    expect(kKangxuanBook3Lessons.first.title, '新學年新希望');
    expect(kKangxuanBook3Lessons.first.editionLabel, '康軒 · 2上 第三冊 第 1 課');
    expect(kHanlinBook3Lessons.last.editionLabel, '翰林 · 2上 第三冊 第 12 課');
    expect(kNaniBook4Lessons.first.editionLabel, '南一 · 2下 第四冊 第 1 課');
    expect(kKangxuanBook3Lessons.first.id, 'cl-c-2-1-kx-v3-01');
    expect(kNaniBook4Lessons.last.id, 'cl-c-2-2-ny-v4-12');

    final books = [
      ...kKangxuanBook3Lessons,
      ...kHanlinBook3Lessons,
      ...kNaniBook3Lessons,
      ...kKangxuanBook4Lessons,
      ...kHanlinBook4Lessons,
      ...kNaniBook4Lessons,
    ];
    expect(books.map((l) => l.id).toSet().length, books.length);

    for (final lesson in books) {
      expect(lesson.grade, 2, reason: lesson.id);
      expect(lesson.subjectId, 'chinese');
      expect(lesson.part, isNotNull);
      expect(lesson.questions.length, inInclusiveRange(20, 24),
          reason: lesson.id);
      expect(lesson.writingPractice.length, greaterThanOrEqualTo(8),
          reason: lesson.title);
      expect(lesson.objectives, isNotEmpty);
      expect(lesson.keyPoints, isNotEmpty);
      expect(lesson.vocabulary.length, greaterThanOrEqualTo(3));
      final passage = lesson.content.split('生字：').first;
      for (final glyph in lesson.writingPractice) {
        expect(passage.contains(glyph.char), isTrue,
            reason: '${lesson.title} ${glyph.char}');
        expect(glyph.strokes, greaterThan(0));
        expect(glyph.zhuyin, isNotEmpty);
      }
      expect(
        lesson.content.contains(
          '生字：${lesson.writingPractice.map((g) => g.char).join('、')}',
        ),
        isTrue,
        reason: lesson.id,
      );
      final prompts = lesson.questions.map((q) => q.prompt).toList();
      expect(prompts.toSet().length, prompts.length, reason: lesson.id);
      for (final q in lesson.questions) {
        expect(q.options.length, 4, reason: q.prompt);
        expect(q.options.toSet().length, 4, reason: q.prompt);
        expect(q.correctIndex, inInclusiveRange(0, 3));
        expect(q.explanation, isNotNull);
      }
      for (final vocab in lesson.vocabulary) {
        expect(vocab.example, contains(vocab.term), reason: lesson.id);
      }
      expect(writingSetFor(lesson), isNotNull);
    }

    final publisher = kLessons.where(
      (l) => l.subjectId == 'chinese' && l.grade == 2 && l.publisher != null,
    );
    expect(publisher.length, 72);

    final core = kLessons.where((l) => l.id == 'cl-c-2-1-u1').toList();
    expect(core, hasLength(1));
    expect(core.single.publisher, isNull);

    final allIds = kLessons.map((l) => l.id).toList();
    expect(allIds.toSet().length, allIds.length);
  });
}
