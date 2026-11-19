import '../../../models/lesson.dart';
import '../../../models/lesson_block.dart';
import '../../../models/question.dart';

/// 第一冊要學的生字。注音用這一課的讀法，筆畫用教育部標準字體。
class CharCue {
  final String char;
  final String zhuyin;
  final String meaning;
  final int strokes;

  const CharCue(this.char, this.zhuyin, this.meaning, this.strokes);
}

Question readerQ({
  required String prompt,
  required List<String> options,
  required int correctIndex,
  required String explanation,
}) {
  return Question(
    id: 'authored',
    type: QuestionType.multipleChoice,
    prompt: prompt,
    options: options,
    correctIndex: correctIndex,
    explanation: explanation,
  );
}

/// 國語各冊一課：自編短文、生字、語詞與測驗。
///
/// 課名與生字對齊 115 學年度公開字表；句子為小學堂自編，不摘錄課本原文。
/// 同一課若有同音字（例如「遊」和「游」），仍各自保留，題庫不再問「哪一個字念這個音」。
Lesson readerLesson({
  required TextbookPublisher publisher,
  required int unit,
  String? unitLabel,
  required String title,
  required String summary,
  required String passage,
  required List<CharCue> chars,
  required List<String> objectives,
  required List<String> keyPoints,
  required List<VocabItem> vocabulary,
  required List<String> practiceSteps,
  required String tip,
  required List<Question> questions,
  int estimatedMinutes = 12,
  int grade = 1,
  Semester semester = Semester.first,
  TextbookPart part = TextbookPart.volumeOne,
}) {
  if (chars.length < 4) {
    throw StateError('$title 的生字不足');
  }
  if (chars.map((c) => c.char).toSet().length != chars.length) {
    throw StateError('$title 有重複生字');
  }
  if (chars.map((c) => c.meaning).toSet().length != chars.length) {
    throw StateError('$title 有兩個生字解釋相同');
  }
  for (final c in chars) {
    if (c.char.runes.length != 1 || c.strokes <= 0 || c.zhuyin.isEmpty) {
      throw StateError('$title 的生字資料不完整：${c.char}');
    }
  }
  for (final vocab in vocabulary) {
    final example = vocab.example ?? '';
    if (!example.contains(vocab.term)) {
      throw StateError('$title 的例句沒有用到「${vocab.term}」');
    }
  }

  final code = publisher.code;
  final term = semester == Semester.second ? '2' : '1';
  final vol = switch (part) {
    TextbookPart.primer => 'p',
    TextbookPart.volumeOne => 'v1',
    TextbookPart.volumeTwo => 'v2',
    TextbookPart.volumeThree => 'v3',
    TextbookPart.volumeFour => 'v4',
  };
  final id = 'cl-c-$grade-$term-$code-$vol-${unit.toString().padLeft(2, '0')}';
  final writing = [
    for (final c in chars)
      WritingGlyph(
        char: c.char,
        zhuyin: c.zhuyin,
        meaning: c.meaning,
        strokes: c.strokes,
      ),
  ];
  final writingLine = writing.map((g) => g.char).join('、');
  final charLines = chars
      .map((c) => '${c.char}　${c.zhuyin}　${c.meaning}（${c.strokes} 畫）')
      .join('\n');
  final stepLines = [
    for (var i = 0; i < practiceSteps.length; i++)
      '${i + 1}. ${practiceSteps[i]}',
  ].join('\n');
  final vocabLines = vocabulary
      .map((v) => '${v.term}：${v.meaning}。${v.example ?? ''}')
      .join('\n');

  final authored = [
    for (var i = 0; i < questions.length; i++)
      Question(
        id: '$id-q${(i + 1).toString().padLeft(2, '0')}',
        type: questions[i].type,
        prompt: questions[i].prompt,
        options: questions[i].options,
        correctIndex: questions[i].correctIndex,
        explanation: questions[i].explanation,
      ),
  ];
  final quiz = _expandQuestions(
    lessonId: id,
    authored: authored,
    chars: chars,
    vocabulary: vocabulary,
  );

  final content = '''
$passage

生字：$writingLine
$charLines

語詞
$vocabLines

練習
$stepLines

$tip
'''
      .trim();

  return Lesson(
    id: id,
    subjectId: 'chinese',
    grade: grade,
    track: CurriculumTrack.core,
    semester: semester,
    unit: unit,
    unitLabel: unitLabel,
    publisher: publisher,
    part: part,
    title: title,
    summary: summary,
    estimatedMinutes: estimatedMinutes,
    objectives: objectives,
    keyPoints: keyPoints,
    vocabulary: vocabulary,
    content: content,
    questions: quiz,
    writingPractice: writing,
    teachingBlocks: [
      LessonBlock(kind: LessonBlockKind.intro, text: summary),
      const LessonBlock(kind: LessonBlockKind.heading, text: '練習課文'),
      LessonBlock(kind: LessonBlockKind.paragraph, text: passage),
      LessonBlock(
        kind: LessonBlockKind.heading,
        text: '生字　$writingLine',
      ),
      for (final c in chars)
        LessonBlock(
          kind: LessonBlockKind.phonics,
          leading: c.char,
          text: '${c.zhuyin}\n${c.meaning}・${c.strokes} 畫',
        ),
      const LessonBlock(kind: LessonBlockKind.heading, text: '語詞'),
      for (final v in vocabulary)
        LessonBlock(
          kind: LessonBlockKind.bullet,
          text: '${v.term}：${v.meaning}',
        ),
      const LessonBlock(kind: LessonBlockKind.heading, text: '練習'),
      for (var i = 0; i < practiceSteps.length; i++)
        LessonBlock(
          kind: LessonBlockKind.step,
          leading: '${i + 1}',
          text: practiceSteps[i],
        ),
      LessonBlock(kind: LessonBlockKind.tip, text: tip),
    ],
  );
}

String _toneName(String reading) {
  if (reading.contains('˙')) return '輕聲';
  if (reading.contains('ˋ')) return '四聲';
  if (reading.contains('ˇ')) return '三聲';
  if (reading.contains('ˊ')) return '二聲';
  return '一聲';
}

List<String>? _arrange(String correct, List<String> pool, String salt) {
  final distractors = <String>[];
  for (final item in pool) {
    if (item.isEmpty || item == correct || distractors.contains(item)) continue;
    distractors.add(item);
    if (distractors.length == 3) break;
  }
  if (distractors.length < 3) return null;
  final slot = salt.hashCode.abs() % 4;
  final options = List<String>.filled(4, '');
  options[slot] = correct;
  var j = 0;
  for (var i = 0; i < 4; i++) {
    if (i == slot) continue;
    options[i] = distractors[j++];
  }
  return options;
}

const _fillerSentences = [
  '小鴨在河邊游泳。',
  '老師請大家安靜。',
  '鉛筆放在鉛筆盒。',
  '哥哥騎腳踏車。',
  '雨後地上有水窪。',
  '妹妹把帽子戴好。',
];

const _extraMeanings = [
  '把書本撕掉',
  '只能在夜裡點的燈',
  '一種交通號誌',
  '把窗戶釘起來',
];

List<Question> _expandQuestions({
  required String lessonId,
  required List<Question> authored,
  required List<CharCue> chars,
  required List<VocabItem> vocabulary,
}) {
  final questions = [...authored];
  final seen = authored.map((q) => q.prompt).toSet();
  var n = 0;

  void add({
    required String prompt,
    required String correct,
    required List<String> pool,
    required String explanation,
  }) {
    if (questions.length >= 24 || !seen.add(prompt)) return;
    final options = _arrange(correct, pool, '$lessonId|$prompt');
    if (options == null) return;
    n++;
    questions.add(Question(
      id: '$lessonId-bank-${n.toString().padLeft(2, '0')}',
      type: QuestionType.multipleChoice,
      prompt: prompt,
      options: options,
      correctIndex: options.indexOf(correct),
      explanation: explanation,
    ));
  }

  final otherReadings = chars.map((c) => c.zhuyin).toList();
  final strokePool = [
    for (final c in chars) '${c.strokes} 畫',
    for (var i = 1; i <= 22; i++) '$i 畫',
  ];
  final meaningPool = [
    ...chars.map((c) => c.meaning),
    ...vocabulary.map((v) => v.meaning),
    ..._extraMeanings,
  ];
  const tones = ['一聲', '二聲', '三聲', '四聲', '輕聲'];

  for (final c in chars) {
    add(
      prompt: '「${c.char}」的注音是哪一個？',
      correct: c.zhuyin,
      pool: otherReadings,
      explanation: '${c.char}的注音是 ${c.zhuyin}。',
    );
  }
  for (final c in chars) {
    add(
      prompt: '「${c.char}」有幾畫？',
      correct: '${c.strokes} 畫',
      pool: strokePool,
      explanation: '${c.char}有 ${c.strokes} 畫。',
    );
  }
  for (final vocab in vocabulary) {
    add(
      prompt: '「${vocab.term}」的意思最接近？',
      correct: vocab.meaning,
      pool: meaningPool,
      explanation: '${vocab.term}：${vocab.meaning}。',
    );
  }
  for (final c in chars) {
    add(
      prompt: '「${c.char}」的意思最接近？',
      correct: c.meaning,
      pool: meaningPool,
      explanation: '${c.char}：${c.meaning}。',
    );
  }
  for (final c in chars) {
    final tone = _toneName(c.zhuyin);
    add(
      prompt: '「${c.char}」的聲調是？',
      correct: tone,
      pool: tones,
      explanation: '${c.char} 是 $tone（${c.zhuyin}）。',
    );
  }
  for (final c in chars) {
    final sameReading = chars.where((other) => other.zhuyin == c.zhuyin).length;
    if (sameReading != 1) continue;
    add(
      prompt: '哪一個字念「${c.zhuyin}」？',
      correct: c.char,
      pool: chars
          .where((other) => other.zhuyin != c.zhuyin)
          .map((e) => e.char)
          .toList(),
      explanation: '${c.zhuyin} 是「${c.char}」。',
    );
  }
  for (final vocab in vocabulary) {
    final example = vocab.example ?? '';
    add(
      prompt: '哪一句用到了「${vocab.term}」？',
      correct: example,
      pool: [
        ...vocabulary.map((v) => v.example ?? ''),
        ..._fillerSentences,
      ].where((sentence) => !sentence.contains(vocab.term)).toList(),
      explanation: '例句是：$example',
    );
  }

  return questions;
}
