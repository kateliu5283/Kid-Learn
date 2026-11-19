import 'package:flutter_test/flutter_test.dart';
import 'package:kid_learn/curriculum/catalog.dart';
import 'package:kid_learn/curriculum/math/book1/hanlin_book.dart';
import 'package:kid_learn/curriculum/math/book1/kangxuan_book.dart';
import 'package:kid_learn/curriculum/math/book1/nani_book.dart';
import 'package:kid_learn/models/lesson.dart';
import 'package:kid_learn/models/lesson_block.dart';

void main() {
  test('數學一上三版本單元都齊', () {
    expect(kKangxuanMathBookLessons.map((l) => l.title).toList(), [
      '10 以內的數',
      '比長短',
      '排順序、比多少',
      '分與合',
      '方盒、圓罐、球',
      '30 以內的數',
      '10 以內的加法',
      '10 以內的減法',
      '幾點鐘',
    ]);
    expect(kNaniMathBookLessons.map((l) => l.title).toList(), [
      '數到 10',
      '比長短',
      '分與合',
      '順序和多少',
      '數到 30',
      '加一加',
      '認識形狀',
      '減一減與加減應用',
      '讀鐘錶',
    ]);
    expect(kHanlinMathBookLessons.map((l) => l.title).toList(), [
      '10 以內的數',
      '比長短',
      '順序與多少',
      '分與合',
      '認識形狀',
      '10 以內的加法',
      '10 以內的減法',
      '30 以內的數',
      '時間',
    ]);

    expect(kKangxuanMathBookLessons.first.editionLabel, '康軒 · 1上 第 1 單元');
    expect(kHanlinMathBookLessons[5].editionLabel, '翰林 · 1上 第 6 單元');
    expect(kNaniMathBookLessons.last.editionLabel, '南一 · 1上 第 9 單元');

    final books = [
      ...kKangxuanMathBookLessons,
      ...kHanlinMathBookLessons,
      ...kNaniMathBookLessons,
    ];
    final ids = books.map((l) => l.id).toSet();
    expect(ids.length, books.length);

    for (final lesson in books) {
      expect(lesson.subjectId, 'math');
      expect(lesson.grade, 1);
      expect(lesson.semester, Semester.first);
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

    final g1s1 = kLessons.where(
      (l) =>
          l.subjectId == 'math' && l.grade == 1 && l.semester == Semester.first,
    );
    expect(g1s1.length, 27);
    expect(g1s1.every((l) => l.publisher != null), isTrue);
    expect(g1s1.any((l) => l.id == 'cl-m-1-1-u1'), isFalse);
    expect(g1s1.any((l) => l.title == '合起來和拿走'), isFalse);
    expect(g1s1.any((l) => l.title == '順序與位置'), isFalse);

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
  final split = RegExp(r'^(\d+) 分成 (\d+) 和幾？$').firstMatch(prompt);
  if (split != null) {
    final whole = int.parse(split.group(1)!);
    final part = int.parse(split.group(2)!);
    expect(whole >= part, isTrue, reason: prompt);
    expect(answer, '${whole - part}', reason: prompt);
  }
  final join = RegExp(r'^(\d+) 和 (\d+) 合起來是多少？$').firstMatch(prompt);
  if (join != null) {
    final sum = int.parse(join.group(1)!) + int.parse(join.group(2)!);
    expect(answer, '$sum', reason: prompt);
  }
  final tens = RegExp(r'^(\d+) 有幾個十？$').firstMatch(prompt);
  if (tens != null) {
    expect(answer, '${int.parse(tens.group(1)!) ~/ 10}', reason: prompt);
  }
  final ones = RegExp(r'^(\d+) 有幾個一？$').firstMatch(prompt);
  if (ones != null) {
    expect(answer, '${int.parse(ones.group(1)!) % 10}', reason: prompt);
  }
  final line =
      RegExp(r'^(\d+) 個人排一列，從後面數第 (\d+) 個，從前面數是第幾個？$').firstMatch(prompt);
  if (line != null) {
    final total = int.parse(line.group(1)!);
    final fromBack = int.parse(line.group(2)!);
    expect(answer, '第 ${total - fromBack + 1} 個', reason: prompt);
  }
  final hour = RegExp(r'^短針指 (\d+)、長針指 12，是幾點鐘？$').firstMatch(prompt);
  if (hour != null) {
    expect(answer, '${hour.group(1)} 點', reason: prompt);
  }
  final putIn = RegExp(r'^有 (\d+) 個，再放進 (\d+) 個，一共是多少？$').firstMatch(prompt);
  if (putIn != null) {
    final sum = int.parse(putIn.group(1)!) + int.parse(putIn.group(2)!);
    expect(answer, '$sum', reason: prompt);
  }
  final take = RegExp(r'^有 (\d+) 個，拿走 (\d+) 個，還剩多少？$').firstMatch(prompt);
  if (take != null) {
    final left = int.parse(take.group(1)!) - int.parse(take.group(2)!);
    expect(left >= 0, isTrue, reason: prompt);
    expect(answer, '$left', reason: prompt);
  }
  final dots = RegExp(r'^(●+) 有幾個？$').firstMatch(prompt);
  if (dots != null) {
    expect(answer, '${dots.group(1)!.length}', reason: prompt);
  }
}
