import 'package:flutter_test/flutter_test.dart';
import 'package:kid_learn/curriculum/expanded/english_quiz.dart';
import 'package:kid_learn/curriculum/expanded/supplementary_domains.dart';
import 'package:kid_learn/models/lesson.dart';

void main() {
  test('english quiz uses vocab not curriculum meta prompts', () {
    final lessons = buildSupplementaryDomainLessons()
        .where((l) => l.subjectId == 'english')
        .toList();
    expect(lessons.length, 72);

    for (final l in lessons) {
      expect(l.questions, isNotEmpty);
      for (final q in l.questions) {
        expect(q.prompt.contains('自主行動'), isFalse, reason: l.id);
        expect(q.prompt.contains('主要在學什麼'), isFalse, reason: l.id);
        expect(q.options.length, 4);
        expect(q.correctIndex, inInclusiveRange(0, 3));
      }
    }

    final hello = lessons.firstWhere((l) => l.id == 'ex-en-1-1-1');
    expect(hello.questions.length, greaterThanOrEqualTo(3));
    final prompts = hello.questions.map((q) => q.prompt).join('\n');
    expect(prompts.contains('Hello') || prompts.contains('你好'), isTrue);
  });

  test('englishQuizForUnit builds en-zh and fill-blank items', () {
    final qs = englishQuizForUnit(
      lessonId: 't1',
      title: 'Colors 顏色',
      vocabulary: const [
        VocabItem(term: 'red', meaning: '紅色', example: 'The apple is red.'),
        VocabItem(term: 'blue', meaning: '藍色', example: 'The sky is blue.'),
        VocabItem(term: 'green', meaning: '綠色', example: 'The grass is green.'),
      ],
    );
    expect(qs.length, 4);
    expect(qs[0].prompt, contains('red'));
    expect(qs.any((q) => q.prompt.contains('______')), isTrue);
  });
}
