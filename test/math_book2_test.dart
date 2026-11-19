import 'package:flutter_test/flutter_test.dart';
import 'package:kid_learn/curriculum/catalog.dart';
import 'package:kid_learn/curriculum/math/book2/hanlin_book.dart';
import 'package:kid_learn/curriculum/math/book2/kangxuan_book.dart';
import 'package:kid_learn/curriculum/math/book2/nani_book.dart';
import 'package:kid_learn/models/lesson.dart';
import 'package:kid_learn/models/lesson_block.dart';

void main() {
  test('數學一下三版本單元都齊', () {
    expect(kKangxuanMathBook2Lessons.map((l) => l.title).toList(), [
      '50 以內的數',
      '18 以內的加法',
      '圖形與分類',
      '18 以內的減法',
      '有多長',
      '100 以內的數',
      '認識錢幣',
      '二位數的加減',
      '幾月幾日星期幾',
    ]);
    expect(kNaniMathBook2Lessons.map((l) => l.title).toList(), [
      '數到 100',
      '18 以內的加法',
      '長度',
      '18 以內的減法',
      '圖形和形體',
      '幾月幾日',
      '錢幣',
      '二位數的加減',
      '做紀錄',
    ]);
    expect(kHanlinMathBook2Lessons.map((l) => l.title).toList(), [
      '20 以內的加法',
      '長度',
      '20 以內的減法',
      '100 以內的數',
      '形狀與形體',
      '數數看有多少元',
      '幾月幾日星期幾',
      '兩位數的加減法',
      '分類整理',
    ]);

    expect(kKangxuanMathBook2Lessons.first.editionLabel, '康軒 · 1下 第 1 單元');
    expect(kHanlinMathBook2Lessons[5].editionLabel, '翰林 · 1下 第 6 單元');
    expect(kNaniMathBook2Lessons.last.editionLabel, '南一 · 1下 第 9 單元');
    expect(kKangxuanMathBook2Lessons.first.id, 'cl-m-1-2-kx-u01');
    expect(kHanlinMathBook2Lessons.first.id, 'cl-m-1-2-hl-u01');
    expect(kNaniMathBook2Lessons.last.id, 'cl-m-1-2-ny-u09');

    final books = [
      ...kKangxuanMathBook2Lessons,
      ...kHanlinMathBook2Lessons,
      ...kNaniMathBook2Lessons,
    ];
    final ids = books.map((l) => l.id).toSet();
    expect(ids.length, books.length);

    for (final lesson in books) {
      expect(lesson.subjectId, 'math');
      expect(lesson.grade, 1);
      expect(lesson.semester, Semester.second);
      expect(lesson.publisher, isNotNull);
      expect(lesson.part, isNull);
      expect(lesson.unit, inInclusiveRange(1, 9));
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

    final publisherG1s2 = kLessons.where(
      (l) =>
          l.subjectId == 'math' &&
          l.grade == 1 &&
          l.semester == Semester.second &&
          l.publisher != null,
    );
    expect(publisherG1s2.length, 27);

    final core = kLessons.where((l) => l.id == 'cl-m-1-2-u1').toList();
    expect(core, hasLength(1));
    expect(core.single.title, '20 以內的數');
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
  final prev = RegExp(r'^(\d+) 的前一個數是多少？$').firstMatch(prompt);
  if (prev != null) {
    expect(answer, '${int.parse(prev.group(1)!) - 1}', reason: prompt);
  }
  final next = RegExp(r'^(\d+) 的後一個數是多少？$').firstMatch(prompt);
  if (next != null) {
    expect(answer, '${int.parse(next.group(1)!) + 1}', reason: prompt);
  }
  final tens = RegExp(r'^(\d+) 有幾個十？$').firstMatch(prompt);
  if (tens != null) {
    expect(answer, '${int.parse(tens.group(1)!) ~/ 10}', reason: prompt);
  }
  final ones = RegExp(r'^(\d+) 有幾個一？$').firstMatch(prompt);
  if (ones != null) {
    expect(answer, '${int.parse(ones.group(1)!) % 10}', reason: prompt);
  }
}
