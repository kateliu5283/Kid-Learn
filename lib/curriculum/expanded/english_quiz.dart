import '../../models/lesson.dart';
import '../../models/question.dart';

/// 依本課單字／例句產生英語測驗（取代通用課綱套話題）。
List<Question> englishQuizForUnit({
  required String lessonId,
  required String title,
  required List<VocabItem> vocabulary,
}) {
  final vocab = vocabulary
      .where((v) => v.term.trim().isNotEmpty && v.meaning.trim().isNotEmpty)
      .toList();

  if (vocab.length < 2) {
    return _fallbackQuiz(lessonId, title);
  }

  final questions = <Question>[];
  final n = vocab.length;

  // 1) 英 → 中：這個單字是什麼意思？
  final w0 = vocab[0];
  questions.add(
    Question(
      id: '$lessonId-q1',
      type: QuestionType.multipleChoice,
      prompt: '"${w0.term}" 的中文意思是？',
      options: _optionsWithCorrect(
        correct: w0.meaning,
        distractors: vocab.skip(1).map((v) => v.meaning).toList(),
        extras: _extraMeanings,
        seed: lessonId.hashCode + 1,
      ),
      correctIndex: 0, // reshuffled below
      explanation: '"${w0.term}" 是「${w0.meaning}」。',
    ),
  );

  // 2) 中 → 英：這個意思的英文是？
  final w1 = vocab[1 % n];
  questions.add(
    Question(
      id: '$lessonId-q2',
      type: QuestionType.multipleChoice,
      prompt: '「${w1.meaning}」的英文是？',
      options: _optionsWithCorrect(
        correct: w1.term,
        distractors: vocab.where((v) => v.term != w1.term).map((v) => v.term).toList(),
        extras: _extraTerms,
        seed: lessonId.hashCode + 2,
      ),
      correctIndex: 0,
      explanation: '「${w1.meaning}」的英文是 "${w1.term}"。',
    ),
  );

  // 3) 選出正確例句／句型（有例句時）
  final withExample = vocab.where((v) => (v.example ?? '').trim().isNotEmpty).toList();
  if (withExample.isNotEmpty) {
    final w2 = withExample[0];
    final blanked = _blankOutTerm(w2.example!, w2.term);
    questions.add(
      Question(
        id: '$lessonId-q3',
        type: QuestionType.multipleChoice,
        prompt: '哪個單字最適合填入？\n$blanked',
        options: _optionsWithCorrect(
          correct: w2.term,
          distractors: vocab.where((v) => v.term != w2.term).map((v) => v.term).toList(),
          extras: _extraTerms,
          seed: lessonId.hashCode + 3,
        ),
        correctIndex: 0,
        explanation: '完整句子：${w2.example}',
      ),
    );
  } else if (n >= 3) {
    final w2 = vocab[2];
    questions.add(
      Question(
        id: '$lessonId-q3',
        type: QuestionType.multipleChoice,
        prompt: '"${w2.term}" 的中文意思是？',
        options: _optionsWithCorrect(
          correct: w2.meaning,
          distractors: vocab.where((v) => v.term != w2.term).map((v) => v.meaning).toList(),
          extras: _extraMeanings,
          seed: lessonId.hashCode + 3,
        ),
        correctIndex: 0,
        explanation: '"${w2.term}" 是「${w2.meaning}」。',
      ),
    );
  }

  // 4) 辨識本課學過的單字
  final w3 = vocab[n >= 4 ? 3 : 0];
  final wrongPool = _extraTerms.where((t) => !_sameIgnoreCase(t, w3.term)).toList();
  questions.add(
    Question(
      id: '$lessonId-q4',
      type: QuestionType.multipleChoice,
      prompt: '下列哪個是本課「$title」學過的單字？',
      options: _optionsWithCorrect(
        correct: w3.term,
        distractors: wrongPool,
        extras: const ['notebook', 'soccer', 'rainbow'],
        seed: lessonId.hashCode + 4,
      ),
      correctIndex: 0,
      explanation: '"${w3.term}"（${w3.meaning}）是本課單字。',
    ),
  );

  // 將每題選項打散，並重算 correctIndex
  return [
    for (var i = 0; i < questions.length; i++)
      _shuffleQuestion(questions[i], seed: lessonId.hashCode + i * 17),
  ];
}

List<Question> _fallbackQuiz(String lessonId, String title) {
  return [
    Question(
      id: '$lessonId-q1',
      type: QuestionType.multipleChoice,
      prompt: '學習英語時，哪個做法最有幫助？',
      options: ['多聽、多說、多練習本課單字', '只背答案不理解', '完全不開口', '跳過練習'],
      correctIndex: 0,
      explanation: '多聽、多說、多練習，最容易記住單字與句型。',
    ),
    Question(
      id: '$lessonId-q2',
      type: QuestionType.multipleChoice,
      prompt: '「$title」這一課，建議你怎麼複習？',
      options: ['跟著念單字並造句', '只看標題就好', '請別人代寫', '完全不做'],
      correctIndex: 0,
      explanation: '跟著念、用單字造句，複習效果最好。',
    ),
  ];
}

/// 產生 4 個選項：正確答案會先放在首位，稍後再打散。
List<String> _optionsWithCorrect({
  required String correct,
  required List<String> distractors,
  required List<String> extras,
  required int seed,
}) {
  final seen = <String>{correct.toLowerCase()};
  final picks = <String>[correct];

  for (final d in distractors) {
    if (picks.length >= 4) break;
    final key = d.toLowerCase();
    if (seen.contains(key) || d.trim().isEmpty) continue;
    seen.add(key);
    picks.add(d);
  }
  for (final e in extras) {
    if (picks.length >= 4) break;
    final key = e.toLowerCase();
    if (seen.contains(key) || e.trim().isEmpty) continue;
    seen.add(key);
    picks.add(e);
  }
  while (picks.length < 4) {
    picks.add('選項 ${picks.length + 1}');
  }
  return picks.take(4).toList();
}

Question _shuffleQuestion(Question q, {required int seed}) {
  final pairs = [
    for (var i = 0; i < q.options.length; i++) (q.options[i], i == q.correctIndex),
  ];
  // 穩定打散：依 seed 旋轉，再做 deterministic swap
  final rot = seed.abs() % pairs.length;
  final rotated = [...pairs.skip(rot), ...pairs.take(rot)];
  if (rotated.length >= 2 && seed.isOdd) {
    final tmp = rotated[0];
    rotated[0] = rotated[1];
    rotated[1] = tmp;
  }
  if (rotated.length >= 4 && (seed ~/ 3).isEven) {
    final tmp = rotated[2];
    rotated[2] = rotated[3];
    rotated[3] = tmp;
  }
  final correctIndex = rotated.indexWhere((p) => p.$2);
  return Question(
    id: q.id,
    type: q.type,
    prompt: q.prompt,
    options: rotated.map((p) => p.$1).toList(),
    correctIndex: correctIndex < 0 ? 0 : correctIndex,
    explanation: q.explanation,
    imageAsset: q.imageAsset,
  );
}

String _blankOutTerm(String sentence, String term) {
  final pattern = RegExp(RegExp.escape(term), caseSensitive: false);
  if (pattern.hasMatch(sentence)) {
    return sentence.replaceFirst(pattern, '______');
  }
  // 複合詞或大小寫不符時，在句末加空格提示
  return '$sentence\n（空格：______）';
}

bool _sameIgnoreCase(String a, String b) => a.toLowerCase() == b.toLowerCase();

const _extraMeanings = [
  '學校',
  '朋友',
  '開心',
  '跑步',
  '下雨',
  '吃飯',
  '睡覺',
  '書本',
];

const _extraTerms = [
  'banana',
  'window',
  'purple',
  'cookie',
  'tiger',
  'jacket',
  'subway',
  'pillow',
];
