import '../../../models/lesson.dart';
import '../../../models/lesson_block.dart';
import '../../../models/question.dart';

/// 本課要認的注音，附一個生活例字。
class SymbolCue {
  final String symbol;
  final String word;
  final String reading;

  const SymbolCue(this.symbol, this.word, this.reading);
}

Question primerQ({
  required String id,
  required String prompt,
  required List<String> options,
  required int correctIndex,
  required String explanation,
}) {
  return Question(
    id: id,
    type: QuestionType.multipleChoice,
    prompt: prompt,
    options: options,
    correctIndex: correctIndex,
    explanation: explanation,
  );
}

/// 國語首冊一課：自編練習短文、符號卡、練習步驟與測驗。
///
/// 課次與符號範圍對齊各版本公開教學計畫；句子為小學堂自編，不摘錄課本原文。
Lesson primerLesson({
  required TextbookPublisher publisher,
  required int unit,
  required String title,
  required String summary,
  required String passage,
  required List<SymbolCue> symbols,
  required List<String> objectives,
  required List<String> keyPoints,
  required List<VocabItem> vocabulary,
  required List<String> practiceSteps,
  required String tip,
  required List<Question> questions,
  int estimatedMinutes = 12,
}) {
  final code = publisher.code;
  final symbolLine = symbols.map((s) => s.symbol).join('、');
  final phonicsLines = symbols
      .map((s) => '${s.symbol}　${s.word}　${s.reading}')
      .join('\n');
  final stepLines = [
    for (var i = 0; i < practiceSteps.length; i++) '${i + 1}. ${practiceSteps[i]}',
  ].join('\n');

  final id = 'cl-c-1-1-$code-${unit.toString().padLeft(2, '0')}';
  final writing = _writingGlyphs(symbols);
  final writingLine = writing.map((g) => g.char).join('、');
  final quiz = _expandQuestions(
    lessonId: id,
    authored: questions,
    symbols: symbols,
    vocabulary: vocabulary,
  );

  final content = '''
$passage

本課符號：$symbolLine
$phonicsLines

生字：$writingLine

練習
$stepLines

$tip
'''.trim();

  return Lesson(
    id: id,
    subjectId: 'chinese',
    grade: 1,
    track: CurriculumTrack.core,
    semester: Semester.first,
    unit: unit,
    publisher: publisher,
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
        text: '本課符號　$symbolLine',
      ),
      for (final s in symbols)
        LessonBlock(
          kind: LessonBlockKind.phonics,
          leading: s.symbol,
          text: '${s.word}\n${s.reading}',
        ),
      LessonBlock(
        kind: LessonBlockKind.heading,
        text: '生字　$writingLine',
      ),
      LessonBlock(
        kind: LessonBlockKind.paragraph,
        text: '這幾個例字可以在「生字手寫」裡一筆一畫練習：$writingLine。',
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

const _initials = 'ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙ';

const _extraReadings = [
  'ㄅㄚ',
  'ㄆㄛ',
  'ㄇㄚ',
  'ㄈㄥ',
  'ㄉㄧˋ',
  'ㄊㄚ',
  'ㄋㄧˊ',
  'ㄌㄧˋ',
  'ㄍㄨˇ',
  'ㄎㄜˋ',
  'ㄏㄨㄚ',
  'ㄐㄧˇ',
  'ㄑㄧˊ',
  'ㄒㄧㄝˋ',
  'ㄓˋ',
  'ㄔˊ',
  'ㄕˊ',
  'ㄖˊ',
  'ㄗㄞˇ',
  'ㄘˋ',
  'ㄙㄢˊ',
  'ㄧˋ',
  'ㄨˊ',
  'ㄩˇ',
  'ㄚˊ',
  'ㄛˋ',
  'ㄜˇ',
  'ㄝˋ',
  'ㄞˇ',
  'ㄟˊ',
  'ㄠˋ',
  'ㄡˊ',
  'ㄢˇ',
  'ㄣˋ',
  'ㄤˇ',
  'ㄥˊ',
];

const _extraWords = ['八', '不', '上', '下', '口', '手', '山', '水', '火', '土', '白', '石'];

const _extraMeanings = [
  '把兩樣東西交換',
  '很晚才起床',
  '一種天氣儀器',
  '把書本撕掉',
  '只能在夜裡說的話',
  '一種交通號誌',
];

bool _isInitial(String symbol) =>
    symbol.length == 1 && _initials.contains(symbol);

String _bareReading(String reading) =>
    reading.replaceAll(RegExp(r'[ˊˇˋ˙]'), '');

/// 錯誤選項不能也出現在這個字的注音裡，避免一題有兩個都說得通的答案。
bool _symbolInsideReading(String reading, String symbol) =>
    _bareReading(reading).contains(symbol);

String _toneName(String reading) {
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

List<Question> _expandQuestions({
  required String lessonId,
  required List<Question> authored,
  required List<SymbolCue> symbols,
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

  final readings = [...symbols.map((s) => s.reading), ..._extraReadings];
  const extraSymbols = [
    'ㄅ', 'ㄆ', 'ㄇ', 'ㄈ', 'ㄉ', 'ㄊ', 'ㄋ', 'ㄌ', 'ㄍ', 'ㄎ', 'ㄏ',
    'ㄐ', 'ㄑ', 'ㄒ', 'ㄚ', 'ㄛ', 'ㄜ', 'ㄝ', 'ㄞ', 'ㄟ', 'ㄠ', 'ㄡ',
    'ㄢ', 'ㄣ', 'ㄤ', 'ㄥ', 'ㄧㄚ', 'ㄨㄛ', 'ㄩㄝ',
  ];
  final symbolPool = [...symbols.map((s) => s.symbol), ...extraSymbols];
  final meanings = [
    ...vocabulary.map((v) => v.meaning),
    ..._extraMeanings,
  ];
  const tones = ['一聲', '二聲', '三聲', '四聲'];

  for (final s in symbols) {
    final otherWords = symbols
        .where((other) => other.reading != s.reading)
        .map((other) => other.word)
        .followedBy(_extraWords);
    add(
      prompt: '「${s.word}」的注音是哪一個？',
      correct: s.reading,
      pool: readings,
      explanation: '${s.word}的注音是 ${s.reading}。',
    );
    add(
      prompt: '哪一個字念「${s.reading}」？',
      correct: s.word,
      pool: otherWords.toList(),
      explanation: '${s.reading} 是「${s.word}」。',
    );
    add(
      prompt: '「${s.word}」的注音裡，有哪一個符號？',
      correct: s.symbol,
      pool: symbolPool
          .where((item) => !_symbolInsideReading(s.reading, item))
          .toList(),
      explanation: '${s.word}（${s.reading}）裡有 ${s.symbol}。',
    );
    add(
      prompt: '「${s.word}」是第幾聲？',
      correct: _toneName(s.reading),
      pool: tones,
      explanation: '${s.word} 是 ${_toneName(s.reading)}（${s.reading}）。',
    );
    if (_isInitial(s.symbol)) {
      add(
        prompt: '「${s.word}」的聲母是？',
        correct: s.symbol,
        pool: symbolPool.where(_isInitial).toList(),
        explanation: '${s.word} 的聲母是 ${s.symbol}。',
      );
    } else {
      add(
        prompt: '本課裡，「${s.word}」要練習的韻母是？',
        correct: s.symbol,
        pool: symbolPool
            .where((item) =>
                !_isInitial(item) && !_symbolInsideReading(s.reading, item))
            .toList(),
        explanation: '${s.word}（${s.reading}）要練習的韻母是 ${s.symbol}。',
      );
    }
  }

  for (final vocab in vocabulary) {
    add(
      prompt: '「${vocab.term}」的意思最接近？',
      correct: vocab.meaning,
      pool: meanings,
      explanation: '${vocab.term}：${vocab.meaning}。',
    );
    if (vocab.example != null && vocab.example!.isNotEmpty) {
      add(
        prompt: '哪一句用到了「${vocab.term}」？',
        correct: vocab.example!,
        pool: [
          ...vocabulary.map((v) => v.example ?? ''),
          '我把書包丟在地上。',
          '今天不要去學校。',
          '這個字不用念。',
        ].where((sentence) => !sentence.contains(vocab.term)).toList(),
        explanation: '例句是：${vocab.example}',
      );
    }
  }

  return questions;
}

List<WritingGlyph> _writingGlyphs(List<SymbolCue> symbols) {
  final chosen = <String, SymbolCue>{};
  for (final symbol in symbols) {
    if (symbol.word.runes.length != 1) continue;
    final previous = chosen[symbol.word];
    if (previous == null || symbol.reading.length > previous.reading.length) {
      chosen[symbol.word] = symbol;
    }
  }
  return [
    for (final symbol in chosen.values)
      WritingGlyph(
        char: symbol.word,
        zhuyin: symbol.reading,
        meaning: '例字，用來練習 ${symbol.symbol}',
        strokes: _strokesOf(symbol.word),
      ),
  ];
}

int _strokesOf(String char) {
  final strokes = _strokeCounts[char];
  if (strokes == null) {
    throw StateError('缺少生字筆畫數：$char');
  }
  return strokes;
}

const _strokeCounts = <String, int>{
  '一': 1,
  '七': 2,
  '人': 2,
  '八': 2,
  '下': 3,
  '大': 3,
  '子': 3,
  '小': 3,
  '也': 3,
  '三': 3,
  '中': 4,
  '天': 4,
  '木': 4,
  '日': 4,
  '月': 4,
  '王': 4,
  '文': 4,
  '五': 4,
  '公': 4,
  '四': 5,
  '去': 5,
  '可': 5,
  '用': 5,
  '衣': 6,
  '安': 6,
  '早': 6,
  '有': 6,
  '羊': 6,
  '吃': 6,
  '在': 6,
  '收': 6,
  '好': 6,
  '我': 7,
  '你': 7,
  '快': 7,
  '字': 6,
  '唷': 10,
  '爸': 8,
  '來': 8,
  '兒': 8,
  '玩': 8,
  '拉': 8,
  '阿': 8,
  '怕': 8,
  '青': 8,
  '河': 8,
  '飛': 9,
  '咪': 9,
  '是': 9,
  '很': 9,
  '音': 9,
  '英': 9,
  '草': 10,
  '為': 9,
  '風': 9,
  '高': 10,
  '旁': 10,
  '家': 10,
  '笑': 10,
  '隻': 10,
  '翁': 10,
  '恩': 10,
  '紙': 10,
  '個': 10,
  '狸': 10,
  '兔': 8,
  '菜': 12,
  '崖': 11,
  '排': 11,
  '晚': 11,
  '魚': 11,
  '跑': 12,
  '畫': 12,
  '登': 12,
  '雲': 12,
  '陽': 12,
  '喔': 12,
  '黑': 12,
  '媽': 13,
  '會': 13,
  '搖': 13,
  '摸': 14,
  '園': 13,
  '圓': 13,
  '誒': 14,
  '滴': 14,
  '踏': 15,
  '糖': 16,
  '貓': 16,
  '鴨': 16,
  '機': 16,
  '顆': 17,
  '聲': 17,
  '鵝': 18,
  '聽': 22,
};
