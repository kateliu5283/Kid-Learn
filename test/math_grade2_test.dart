import 'package:flutter_test/flutter_test.dart';
import 'package:kid_learn/curriculum/catalog.dart';
import 'package:kid_learn/curriculum/math/book3/hanlin_book.dart';
import 'package:kid_learn/curriculum/math/book3/kangxuan_book.dart';
import 'package:kid_learn/curriculum/math/book3/nani_book.dart';
import 'package:kid_learn/curriculum/math/book4/hanlin_book.dart';
import 'package:kid_learn/curriculum/math/book4/kangxuan_book.dart';
import 'package:kid_learn/curriculum/math/book4/nani_book.dart';
import 'package:kid_learn/models/lesson.dart';
import 'package:kid_learn/models/lesson_block.dart';

void main() {
  test('數學二上二下三版本單元都齊', () {
    expect(kKangxuanMathBook3Lessons, hasLength(10));
    expect(kHanlinMathBook3Lessons, hasLength(10));
    expect(kNaniMathBook3Lessons, hasLength(10));
    expect(kKangxuanMathBook4Lessons, hasLength(10));
    expect(kHanlinMathBook4Lessons, hasLength(10));
    expect(kNaniMathBook4Lessons, hasLength(10));

    expect(kKangxuanMathBook3Lessons.first.editionLabel, '康軒 · 2上 第 1 單元');
    expect(kHanlinMathBook3Lessons.last.editionLabel, '翰林 · 2上 第 10 單元');
    expect(kNaniMathBook4Lessons.first.editionLabel, '南一 · 2下 第 1 單元');
    expect(kKangxuanMathBook3Lessons.first.id, 'cl-m-2-1-kx-u01');
    expect(kNaniMathBook4Lessons.last.id, 'cl-m-2-2-ny-u10');

    final books = [
      ...kKangxuanMathBook3Lessons,
      ...kHanlinMathBook3Lessons,
      ...kNaniMathBook3Lessons,
      ...kKangxuanMathBook4Lessons,
      ...kHanlinMathBook4Lessons,
      ...kNaniMathBook4Lessons,
    ];
    expect(books.map((l) => l.id).toSet().length, books.length);

    for (final lesson in books) {
      expect(lesson.subjectId, 'math');
      expect(lesson.grade, 2);
      expect(lesson.publisher, isNotNull);
      expect(lesson.unit, inInclusiveRange(1, 10));
      expect(lesson.questions.length, inInclusiveRange(20, 24),
          reason: lesson.id);
      expect(
        lesson.questions.where((q) => q.id.contains('-bank-')).length,
        greaterThanOrEqualTo(12),
        reason: lesson.id,
      );
      expect(lesson.objectives.length, greaterThanOrEqualTo(2));
      expect(lesson.keyPoints.length, greaterThanOrEqualTo(2));
      expect(lesson.vocabulary.length, greaterThanOrEqualTo(2));
      for (final vocab in lesson.vocabulary) {
        expect(vocab.example, contains(vocab.term), reason: lesson.id);
      }
      expect(lesson.teachingBlocks, isNotEmpty);
      expect(
        lesson.teachingBlocks.map((b) => b.kind).toSet(),
        containsAll([
          LessonBlockKind.intro,
          LessonBlockKind.example,
          LessonBlockKind.step,
          LessonBlockKind.tip,
        ]),
        reason: lesson.id,
      );
      final prompts = lesson.questions.map((q) => q.prompt).toList();
      expect(prompts.toSet().length, prompts.length, reason: lesson.id);
      for (final q in lesson.questions) {
        expect(q.options.length, 4, reason: q.prompt);
        expect(q.options.toSet().length, 4, reason: q.prompt);
        expect(q.correctIndex, inInclusiveRange(0, 3));
        expect(q.explanation, isNotNull);
        _checkEquation(q.prompt, q.options[q.correctIndex]);
      }
    }

    final publisher = kLessons.where(
      (l) => l.subjectId == 'math' && l.grade == 2 && l.publisher != null,
    );
    expect(publisher.length, 60);

    final core = kLessons.where((l) => l.id == 'cl-m-2-1-u1').toList();
    expect(core, hasLength(1));
    expect(core.single.publisher, isNull);

    final allIds = kLessons.map((l) => l.id).toList();
    expect(allIds.toSet().length, allIds.length);
  });
}

void _checkEquation(String prompt, String answer) {
  final add = RegExp(r'^(\d+) \+ (\d+) = \?$').firstMatch(prompt);
  if (add != null) {
    final expectSum = int.parse(add.group(1)!) + int.parse(add.group(2)!);
    expect(answer, '$expectSum', reason: prompt);
  }
  final sub = RegExp(r'^(\d+) - (\d+) = \?$').firstMatch(prompt);
  if (sub != null) {
    final a = int.parse(sub.group(1)!);
    final b = int.parse(sub.group(2)!);
    expect(a >= b, isTrue, reason: prompt);
    expect(answer, '${a - b}', reason: prompt);
  }
  final mul = RegExp(r'^(\d+) × (\d+) = \?$').firstMatch(prompt);
  if (mul != null) {
    final expectProduct = int.parse(mul.group(1)!) * int.parse(mul.group(2)!);
    expect(answer, '$expectProduct', reason: prompt);
  }
  final next = RegExp(r'^(\d+) 的後一個數是多少？$').firstMatch(prompt);
  if (next != null) {
    expect(answer, '${int.parse(next.group(1)!) + 1}', reason: prompt);
  }
}
