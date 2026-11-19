import '../../../models/lesson.dart';
import '../../../models/lesson_block.dart';
import '../../../models/question.dart';

/// 一上數學的一則自編範例。左邊是看到的，右邊是讀法。
class MathExample {
  final String leading;
  final String text;

  const MathExample(this.leading, this.text);
}

/// 一上數學的一個重點。
class MathPoint {
  final String leading;
  final String title;
  final String text;

  const MathPoint(this.leading, this.title, this.text);
}

/// 一上數學的選擇題。正確選項會在組課時再檢查。
class MathQ {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const MathQ({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

final _addEquation = RegExp(r'^(\d+) \+ (\d+) = \?$');
final _subEquation = RegExp(r'^(\d+) - (\d+) = \?$');

/// 數學第一冊、第二冊一個單元：自編例子、步驟與測驗。
///
/// 單元名稱對齊各版本目錄；句子為小學堂自編，不摘錄課本原文。
Lesson mathUnit({
  required TextbookPublisher publisher,
  required int unit,
  required String title,
  required String summary,
  required String opening,
  required String method,
  required List<MathExample> examples,
  required List<MathPoint> points,
  required List<String> steps,
  required String tip,
  required List<String> objectives,
  required List<String> keyPoints,
  required List<VocabItem> vocabulary,
  required List<MathQ> questions,
  Semester semester = Semester.first,
}) {
  if (unit < 1 || unit > 9) {
    throw StateError('$title 的單元編號要在 1 到 9');
  }
  if (examples.length < 3) throw StateError('$title 的範例不足');
  if (points.length < 3) throw StateError('$title 的重點不足');
  if (steps.length < 3) throw StateError('$title 的步驟不足');
  if (objectives.length < 2) throw StateError('$title 的學習目標不足');
  if (keyPoints.length < 2) throw StateError('$title 的重點條列不足');
  if (questions.length < 6) throw StateError('$title 的題目不足');
  if (questions.map((q) => q.prompt).toSet().length != questions.length) {
    throw StateError('$title 有重複題目');
  }
  for (final vocab in vocabulary) {
    final example = vocab.example ?? '';
    if (!example.contains(vocab.term)) {
      throw StateError('$title 的例句沒有用到「${vocab.term}」');
    }
  }
  for (final q in questions) {
    if (q.options.length != 4 || q.options.toSet().length != 4) {
      throw StateError('$title 的選項需要 4 個不同答案：${q.prompt}');
    }
    if (q.correctIndex < 0 || q.correctIndex > 3) {
      throw StateError('$title 的正確答案超出範圍：${q.prompt}');
    }
    if (q.explanation.trim().isEmpty) {
      throw StateError('$title 缺少解析：${q.prompt}');
    }
    _checkEquation(title, q);
  }

  final code = publisher.code;
  final term = semester == Semester.second ? '2' : '1';
  final id = 'cl-m-1-$term-$code-u${unit.toString().padLeft(2, '0')}';
  final authored = [
    for (var i = 0; i < questions.length; i++)
      Question(
        id: '$id-q${(i + 1).toString().padLeft(2, '0')}',
        type: QuestionType.multipleChoice,
        prompt: questions[i].prompt,
        options: questions[i].options,
        correctIndex: questions[i].correctIndex,
        explanation: questions[i].explanation,
      ),
  ];
  final quiz = _expandQuestions(
    lessonId: id,
    title: title,
    authored: authored,
  );

  final exampleLines =
      examples.map((e) => '${e.leading} → ${e.text}').join('\n');
  final pointLines = points.map((p) => '${p.title}：${p.text}').join('\n');
  final stepLines = [
    for (var i = 0; i < steps.length; i++) '${i + 1}. ${steps[i]}',
  ].join('\n');
  final content = '''
$opening

$method

範例
$exampleLines

重點
$pointLines

練習
$stepLines

$tip
'''
      .trim();

  return Lesson(
    id: id,
    subjectId: 'math',
    grade: 1,
    track: CurriculumTrack.core,
    semester: semester,
    unit: unit,
    publisher: publisher,
    title: title,
    summary: summary,
    estimatedMinutes: 12,
    objectives: objectives,
    keyPoints: keyPoints,
    vocabulary: vocabulary,
    content: content,
    questions: quiz,
    teachingBlocks: [
      LessonBlock(kind: LessonBlockKind.intro, text: opening),
      LessonBlock(kind: LessonBlockKind.paragraph, text: method),
      for (final e in examples)
        LessonBlock(
          kind: LessonBlockKind.example,
          leading: e.leading,
          text: e.text,
        ),
      for (final p in points)
        LessonBlock(
          kind: LessonBlockKind.bullet,
          leading: p.leading,
          title: p.title,
          text: p.text,
        ),
      for (var i = 0; i < steps.length; i++)
        LessonBlock(
          kind: LessonBlockKind.step,
          leading: '${i + 1}',
          text: steps[i],
        ),
      LessonBlock(kind: LessonBlockKind.tip, text: tip),
    ],
  );
}

enum _Drill {
  count10,
  length,
  order,
  compose,
  solid,
  count30,
  add10,
  sub10,
  addSub,
  shape,
  clock,
  count50,
  count100,
  add18,
  add20,
  sub18,
  sub20,
  measure,
  shapeSort,
  money,
  twoDigit,
  calendar,
  tally,
}

_Drill _drillFor(String title) {
  switch (title) {
    case '10 以內的數':
    case '數到 10':
      return _Drill.count10;
    case '比長短':
      return _Drill.length;
    case '排順序、比多少':
    case '順序和多少':
    case '順序與多少':
      return _Drill.order;
    case '分與合':
      return _Drill.compose;
    case '方盒、圓罐、球':
      return _Drill.solid;
    case '30 以內的數':
    case '數到 30':
      return _Drill.count30;
    case '10 以內的加法':
    case '加一加':
      return _Drill.add10;
    case '10 以內的減法':
      return _Drill.sub10;
    case '減一減與加減應用':
      return _Drill.addSub;
    case '認識形狀':
      return _Drill.shape;
    case '幾點鐘':
    case '讀鐘錶':
    case '時間':
      return _Drill.clock;
    case '50 以內的數':
      return _Drill.count50;
    case '100 以內的數':
    case '數到 100':
      return _Drill.count100;
    case '18 以內的加法':
      return _Drill.add18;
    case '20 以內的加法':
      return _Drill.add20;
    case '18 以內的減法':
      return _Drill.sub18;
    case '20 以內的減法':
      return _Drill.sub20;
    case '有多長':
    case '長度':
      return _Drill.measure;
    case '圖形與分類':
    case '圖形和形體':
    case '形狀與形體':
      return _Drill.shapeSort;
    case '認識錢幣':
    case '錢幣':
    case '數數看有多少元':
      return _Drill.money;
    case '二位數的加減':
    case '兩位數的加減法':
      return _Drill.twoDigit;
    case '幾月幾日星期幾':
    case '幾月幾日':
      return _Drill.calendar;
    case '做紀錄':
    case '分類整理':
      return _Drill.tally;
  }
  throw StateError('沒有對應的練習題庫：$title');
}

List<String> _numberPool(int answer, {int low = 0, int high = 12}) {
  final pool = <String>[];
  for (final d in [1, 2, 3, 4, 5]) {
    if (answer - d >= low) pool.add('${answer - d}');
    if (answer + d <= high) pool.add('${answer + d}');
  }
  return pool;
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

/// 手寫題之外，依單元補上計算與概念練習，湊滿約 22 題。
List<Question> _expandQuestions({
  required String lessonId,
  required String title,
  required List<Question> authored,
}) {
  const target = 22;
  final questions = [...authored];
  final seen = authored.map((q) => q.prompt).toSet();
  var n = 0;

  void add({
    required String prompt,
    required String correct,
    required List<String> pool,
    required String explanation,
  }) {
    if (questions.length >= target || !seen.add(prompt)) return;
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

  switch (_drillFor(title)) {
    case _Drill.count10:
      _fillCount10(add);
    case _Drill.length:
      _fillBank(add, _lengthBank);
    case _Drill.order:
      _fillOrder(add);
    case _Drill.compose:
      _fillCompose(add);
    case _Drill.solid:
      _fillBank(add, _solidBank);
    case _Drill.count30:
      _fillCount30(add);
    case _Drill.add10:
      _fillAdd(add);
    case _Drill.sub10:
      _fillSub(add);
    case _Drill.addSub:
      _fillAddSub(add);
    case _Drill.shape:
      _fillBank(add, _shapeBank);
    case _Drill.clock:
      _fillClock(add);
    case _Drill.count50:
      _fillCountTo(add, 50);
    case _Drill.count100:
      _fillCountTo(add, 100);
    case _Drill.add18:
      _fillAddTo(add, 18);
    case _Drill.add20:
      _fillAddTo(add, 20);
    case _Drill.sub18:
      _fillSubTo(add, 18);
    case _Drill.sub20:
      _fillSubTo(add, 20);
    case _Drill.measure:
      _fillMeasure(add);
    case _Drill.shapeSort:
      _fillBank(add, _shapeSortBank);
    case _Drill.money:
      _fillMoney(add);
    case _Drill.twoDigit:
      _fillTwoDigit(add);
    case _Drill.calendar:
      _fillBank(add, _calendarBank);
    case _Drill.tally:
      _fillBank(add, _tallyBank);
  }

  if (questions.length < 20 || questions.length > 24) {
    throw StateError('$title 的題數是 ${questions.length}，應在 20 到 24 題');
  }
  return questions;
}

typedef _Add = void Function({
  required String prompt,
  required String correct,
  required List<String> pool,
  required String explanation,
});

void _fillCount10(_Add add) {
  for (var n = 1; n <= 10; n++) {
    add(
      prompt: '${'●' * n} 有幾個？',
      correct: '$n',
      pool: _numberPool(n, high: 10),
      explanation: '一個點一次，一共 $n 個。',
    );
    add(
      prompt: '$n 的前一個數是多少？',
      correct: '${n - 1}',
      pool: _numberPool(n - 1, high: 10),
      explanation: '$n 的前一個是 ${n - 1}。',
    );
    if (n < 10) {
      add(
        prompt: '$n 的後一個數是多少？',
        correct: '${n + 1}',
        pool: _numberPool(n + 1, high: 11),
        explanation: '$n 的後一個是 ${n + 1}。',
      );
    }
  }
}

void _fillCount30(_Add add) {
  for (final n in [11, 13, 16, 22, 24, 27]) {
    final tens = n ~/ 10;
    final ones = n % 10;
    add(
      prompt: '$n 的前一個數是多少？',
      correct: '${n - 1}',
      pool: _numberPool(n - 1, high: 30),
      explanation: '$n 的前一個是 ${n - 1}。',
    );
    add(
      prompt: '$n 的後一個數是多少？',
      correct: '${n + 1}',
      pool: _numberPool(n + 1, high: 30),
      explanation: '$n 的後一個是 ${n + 1}。',
    );
    add(
      prompt: '$n 有幾個十？',
      correct: '$tens',
      pool: const ['0', '1', '2', '3', '4'],
      explanation: '$n 的十位是 $tens。',
    );
    add(
      prompt: '$n 有幾個一？',
      correct: '$ones',
      pool: _numberPool(ones, high: 12),
      explanation: '$n 的個位是 $ones。',
    );
  }
}

void _fillCompose(_Add add) {
  final splits = <(int, int)>[];
  final joins = <(int, int)>[];
  for (var whole = 2; whole <= 10; whole++) {
    for (var part = 0; part <= whole; part++) {
      splits.add((whole, part));
    }
  }
  for (var a = 0; a <= 9; a++) {
    for (var b = a; b <= 10 - a; b++) {
      joins.add((a, b));
    }
  }
  var i = 0;
  while (i < splits.length || i < joins.length) {
    if (i < splits.length) {
      final (whole, part) = splits[i];
      final other = whole - part;
      add(
        prompt: '$whole 分成 $part 和幾？',
        correct: '$other',
        pool: _numberPool(other, high: 12),
        explanation: '$part 和 $other 合起來是 $whole。',
      );
    }
    if (i < joins.length) {
      final (a, b) = joins[i];
      final sum = a + b;
      add(
        prompt: '$a 和 $b 合起來是多少？',
        correct: '$sum',
        pool: _numberPool(sum, high: 12),
        explanation: '$a 和 $b 合起來是 $sum。',
      );
    }
    i++;
  }
}

void _fillAdd(_Add add) {
  final buckets = List.generate(11, (_) => <(int, int)>[]);
  for (var a = 0; a <= 10; a++) {
    for (var b = 0; b <= 10 - a; b++) {
      if (a == 0 && b == 0) continue;
      buckets[a + b].add((a, b));
    }
  }
  var moved = true;
  while (moved) {
    moved = false;
    for (var sum = 1; sum <= 10; sum++) {
      if (buckets[sum].isEmpty) continue;
      final (a, b) = buckets[sum].removeAt(0);
      add(
        prompt: '$a + $b = ?',
        correct: '$sum',
        pool: _numberPool(sum, high: 12),
        explanation: '$a + $b = $sum。',
      );
      moved = true;
    }
  }
}

void _fillSub(_Add add) {
  final buckets = List.generate(11, (_) => <(int, int)>[]);
  for (var a = 0; a <= 10; a++) {
    for (var b = 0; b <= a; b++) {
      buckets[a - b].add((a, b));
    }
  }
  var moved = true;
  while (moved) {
    moved = false;
    for (var diff = 0; diff <= 10; diff++) {
      if (buckets[diff].isEmpty) continue;
      final (a, b) = buckets[diff].removeAt(0);
      add(
        prompt: '$a - $b = ?',
        correct: '$diff',
        pool: _numberPool(diff, high: 12),
        explanation: '$a - $b = $diff。',
      );
      moved = true;
    }
  }
}

void _fillAddSub(_Add add) {
  final adds = <(int, int)>[];
  final subs = <(int, int)>[];
  for (var a = 1; a <= 9; a++) {
    for (var b = 1; b <= 10 - a; b++) {
      adds.add((a, b));
    }
  }
  for (var a = 2; a <= 10; a++) {
    for (var b = 1; b <= a; b++) {
      subs.add((a, b));
    }
  }
  var i = 0;
  while (i < adds.length || i < subs.length) {
    if (i < subs.length) {
      final (a, b) = subs[i];
      add(
        prompt: '有 $a 個，拿走 $b 個，還剩多少？',
        correct: '${a - b}',
        pool: _numberPool(a - b, high: 12),
        explanation: '拿走用減法，$a - $b = ${a - b}。',
      );
      add(
        prompt: '$a - $b = ?',
        correct: '${a - b}',
        pool: _numberPool(a - b, high: 12),
        explanation: '$a - $b = ${a - b}。',
      );
    }
    if (i < adds.length) {
      final (a, b) = adds[i];
      add(
        prompt: '有 $a 個，再放進 $b 個，一共是多少？',
        correct: '${a + b}',
        pool: _numberPool(a + b, high: 12),
        explanation: '再放進用加法，$a + $b = ${a + b}。',
      );
    }
    i++;
  }
}

void _fillOrder(_Add add) {
  var positions = 0;
  for (var total = 3; total <= 8 && positions < 12; total++) {
    for (var fromBack = 1; fromBack <= total && positions < 12; fromBack++) {
      final fromFront = total - fromBack + 1;
      final before = positions;
      add(
        prompt: '$total 個人排一列，從後面數第 $fromBack 個，從前面數是第幾個？',
        correct: '第 $fromFront 個',
        pool: [for (var i = 1; i <= 9; i++) '第 $i 個'],
        explanation: '$total − $fromBack + 1 = $fromFront，從前面數是第 $fromFront 個。',
      );
      positions = before + 1;
    }
  }
  const pairs = [
    (1, 6),
    (2, 8),
    (3, 7),
    (4, 9),
    (5, 8),
    (6, 10),
    (8, 2),
    (9, 4)
  ];
  for (final (a, b) in pairs) {
    final bigger = a > b ? a : b;
    final smaller = a < b ? a : b;
    add(
      prompt: '$a 個和 $b 個，哪一邊比較多？',
      correct: '$bigger 個',
      pool: ['$smaller 個', '一樣多', '不能比'],
      explanation: '$bigger 比 $smaller 大，所以 $bigger 個比較多。',
    );
  }
}

void _fillClock(_Add add) {
  for (var hour = 1; hour <= 12; hour++) {
    add(
      prompt: '短針指 $hour、長針指 12，是幾點鐘？',
      correct: '$hour 點',
      pool: [for (var h = 1; h <= 12; h++) '$h 點'],
      explanation: '長針在 12，短針指 $hour，就是 $hour 點。',
    );
  }
  _fillBank(add, _clockBank);
}

class _BankQ {
  final String prompt;
  final String correct;
  final List<String> pool;
  final String explanation;

  const _BankQ(this.prompt, this.correct, this.pool, this.explanation);
}

void _fillBank(_Add add, List<_BankQ> bank) {
  for (final item in bank) {
    add(
      prompt: item.prompt,
      correct: item.correct,
      pool: item.pool,
      explanation: item.explanation,
    );
  }
}

const _lengthBank = [
  _BankQ('比長短時，彎曲的繩子要先怎樣？', '先拉直', ['先染色', '先捲更緊', '先剪斷'], '彎曲的東西要先拉直，才看得出長度。'),
  _BankQ('一端對齊後，另一端比較近的那一邊？', '比較短', ['比較長', '一樣長', '不能比'], '終點比較近，長度就比較短。'),
  _BankQ(
      '兩樣東西一樣長時，兩端會怎樣？', '都對齊', ['一定錯開', '只能看顏色', '要先捲起來'], '起點和終點都對齊，就是一樣長。'),
  _BankQ('比長短要看的是？', '長度', ['顏色', '重量', '味道'], '長短看的是從一端到另一端的距離。'),
  _BankQ('沒有把起點對齊就比較，結果會？', '容易比錯', ['一定正確', '兩樣會變成一樣長', '不用再看終點'],
      '起點沒對齊，終點遠近就沒有意義。'),
  _BankQ('較長的東西，從起點到終點的距離？', '比較遠', ['比較近', '一定是 0', '看不出來'], '距離比較遠，就是比較長。'),
  _BankQ('只看哪一根比較漂亮，能決定長短嗎？', '不能', ['能', '漂亮的一定比較長', '不用對齊'], '好不好看不會改變長度。'),
  _BankQ(
      '桌緣可以幫忙做什麼？', '把一端靠齊', ['把繩子染色', '把東西捲起來', '決定顏色'], '一端靠著同一條線，起點就對齊了。'),
  _BankQ('兩條線的起點和終點都重疊，它們？', '一樣長', ['左邊比較長', '右邊比較短', '還沒開始比'],
      '兩端都在同一個位置，長度相同。'),
  _BankQ('比完長短，可以怎麼說結果？', '比較長、比較短或一樣長', ['比較重或比較輕', '比較貴或比較便宜', '比較甜或比較酸'],
      '長短的結果是比較長、比較短或一樣長。'),
  _BankQ(
      '粗的鉛筆一定比細的鉛筆長嗎？', '不一定', ['一定', '粗的一定比較短', '細的不能比'], '粗細不是長度，還是要對齊再比。'),
  _BankQ('軟軟的吸管還沒拉直，可以先比長短嗎？', '先不要，拉直再比', ['可以，彎的一定比較長', '可以，不用看終點', '只有尺才能比'],
      '彎著的時候看不出真正的長度。'),
  _BankQ('終點超出比較多，表示這一樣東西？', '比較長', ['比較短', '一樣長', '沒有長度'], '另一端伸出比較多，就是比較長。'),
  _BankQ(
      '兩枝筆的終點都停在同一個地方，表示？', '一樣長', ['左邊比較長', '右邊比較長', '還要看顏色'], '終點重疊，長度就相同。'),
  _BankQ('比長短時，兩樣東西都要？', '拉直', ['捲起來', '藏起來', '塗成同一種顏色'], '拉直以後才能把一端對齊。'),
  _BankQ(
      '哪一種做法最能把長短比準？', '拉直後一端對齊', ['只看顏色', '拿起來甩一甩', '閉著眼睛猜'], '拉直、對齊起點，再看終點。'),
  _BankQ(
      '短的那一端，終點會出現在？', '比較近的地方', ['比較遠的地方', '起點後面', '桌子外面才算'], '比較短的終點離起點比較近。'),
  _BankQ('顏色比較深的繩子，長度就比較長嗎？', '不是', ['是', '深色一定一樣長', '淺色不能比'], '顏色和長度沒有關係。'),
];

const _solidBank = [
  _BankQ('球放在斜坡上會怎樣？', '滾下去', ['穩穩停住', '變成方盒', '自己疊高'], '球沒有平面，在斜坡上會滾。'),
  _BankQ('方盒放在平桌上，最不容易發生的是？', '到處滾', ['停在桌上', '一個一個疊高', '有平平的面'],
      '方盒有平面，放在桌上不容易滾。'),
  _BankQ('哪一種立起來以後可以疊高？', '圓罐', ['球', '紙上畫的圓', '一顆彈珠'], '圓罐立起來有平平的底，可以疊。'),
  _BankQ('球的表面有沒有平平的面？', '沒有', ['四面都是平的', '只有底部是平的', '和方盒一樣'], '球的表面是彎的，沒有平面。'),
  _BankQ('方盒的面是什麼樣子？', '平的', ['全是圓的', '沒有面', '只能滾'], '方盒的面是平的，所以放得穩。'),
  _BankQ('圓罐放倒時，彎彎的側面會讓它？', '滾動', ['變成方盒', '不能移動', '自動疊高'], '放倒以後側面是彎的，就會滾。'),
  _BankQ('哪一個不能疊穩？', '球', ['方盒', '立著的圓罐', '牙膏盒'], '球沒有平面，上面放東西會滑掉。'),
  _BankQ('積木盒通常比較像哪一種？', '方盒', ['球', '放倒才會停的圓罐', '一張圖畫'], '積木盒有平平的面，可以疊。'),
  _BankQ('圓罐直立時，底部是？', '平的', ['尖的', '沒有底', '和球一樣圓到底'], '直立的圓罐有平平的底。'),
  _BankQ(
      '球為什麼不能疊穩？', '沒有平平的面', ['因為它是紅色', '因為它太輕', '因為它有四個角'], '沒有平面，上面的東西放不住。'),
  _BankQ('方盒會因為是紅色就開始滾嗎？', '不會', ['會', '紅色一定會滾', '要看味道'], '會不會滾看的是形狀，不是顏色。'),
  _BankQ('想知道一個罐子會不會滾，可以？', '放倒和直立各試一次', ['只看顏色', '把它畫在紙上', '閉著眼睛猜'],
      '直立和放倒的結果不一樣，要分別試。'),
  _BankQ('圓罐和球都會滾，差在哪裡？', '圓罐立起來可以不滾', ['球立起來就不會滾', '圓罐沒有側面', '球有平平的底'],
      '圓罐可以立穩，球則怎麼放都會滾。'),
  _BankQ('把書疊在球上，書會？', '滑下來', ['穩穩停住', '變成圓罐', '和疊在盒子上一樣穩'], '球沒有平面，書放不穩。'),
  _BankQ('把書疊在方盒上，書會？', '放得住', ['立刻滾走', '變成球', '不能放'], '方盒的面是平的，書可以疊在上面。'),
  _BankQ('罐頭直立時比較像？', '圓罐', ['球', '沒有底的圖形', '一條線'], '罐頭有圓圓的側面和平平的底。'),
  _BankQ('皮球比較像哪一種？', '球', ['方盒', '立著的圓罐', '長方形紙卡'], '皮球沒有平面，會到處滾。'),
  _BankQ('哪一種同時可以「立穩」和「放倒就滾」？', '圓罐', ['球', '方盒', '紙上的三角形'], '圓罐立起來穩，放倒才滾。'),
];

const _shapeBank = [
  _BankQ('圓形有幾個角？', '0 個', ['1 個', '3 個', '4 個'], '圓形的邊是彎的，沒有角。'),
  _BankQ('正方形有幾個角？', '4 個', ['0 個', '3 個', '5 個'], '正方形有 4 條邊，也有 4 個角。'),
  _BankQ('長方形有幾個角？', '4 個', ['0 個', '3 個', '6 個'], '長方形有 4 個角。'),
  _BankQ('三角形有幾條直邊？', '3 條', ['0 條', '2 條', '4 條'], '三角形有 3 條直邊。'),
  _BankQ('哪一個形狀的邊是彎的？', '圓形', ['三角形', '正方形', '長方形'], '圓形沒有直邊，邊是彎彎的。'),
  _BankQ('正方形的四條邊長度怎樣？', '一樣長', ['都是彎的', '只有 3 條', '沒有邊'], '正方形四條邊一樣長。'),
  _BankQ('長方形對面的兩條邊怎樣？', '一樣長', ['一定是彎的', '沒有對邊', '只有 1 條邊'], '長方形的對邊一樣長。'),
  _BankQ(
      '紙上的三角形會自己滾走嗎？', '不會', ['會', '只有圓形紙會滾', '有角的都會滾'], '畫在紙上的形狀是平的，不會自己滾。'),
  _BankQ('時鐘的表面常常是哪一種形狀？', '圓形', ['三角形', '一條直線', '沒有邊的點'], '時鐘表面常常是圓形。'),
  _BankQ('窗戶常常是哪一種形狀？', '長方形', ['圓形', '三角形', '球'], '窗戶常常有 4 個角，對邊一樣長。'),
  _BankQ('有 3 個角的是？', '三角形', ['圓形', '正方形', '長方形'], '三角形有 3 個角。'),
  _BankQ('沒有角的平面形狀是？', '圓形', ['三角形', '正方形', '長方形'], '圓形沒有角。'),
  _BankQ(
      '正方形和圓形，哪一個有直邊？', '正方形', ['圓形', '兩個都沒有邊', '兩個都是彎的'], '正方形有直邊，圓形的邊是彎的。'),
  _BankQ('長方形有幾條邊？', '4 條', ['0 條', '3 條', '5 條'], '長方形有 4 條邊。'),
  _BankQ('數角的時候，圓形要數成幾個？', '0 個', ['2 個', '3 個', '4 個'], '圓形摸不到角，是 0 個。'),
  _BankQ(
      '哪一個不是平面圖形？', '會滾的皮球', ['紙上的圓形', '紙上的三角形', '紙上的正方形'], '皮球是立體的，紙上的圖形是平的。'),
  _BankQ('正方形有幾條邊？', '4 條', ['3 條', '5 條', '0 條'], '正方形有 4 條一樣長的邊。'),
  _BankQ('三角形和正方形，角比較多的是？', '正方形', ['三角形', '一樣多', '兩個都沒有角'],
      '正方形有 4 個角，三角形有 3 個角。'),
];

const _clockBank = [
  _BankQ('時針比較短還是比較長？', '比較短', ['比較長', '和分針一樣長', '時鐘沒有針'], '時針是較短的那一根。'),
  _BankQ('分針比較短還是比較長？', '比較長', ['比較短', '和時針一樣長', '分針不會動'], '分針是較長的那一根。'),
  _BankQ('長針指著 9、短針指著 4，是整點嗎？', '不是', ['是，4 點', '是，9 點', '不用看長針'],
      '長針要指著 12 才是整點。'),
  _BankQ('鐘面上有數字 13 嗎？', '沒有', ['有', '13 就是 1 點', '數字寫到 30'], '鐘面的數字只到 12。'),
  _BankQ(
      '短針和長針都指著 12，是幾點？', '12 點', ['0 點', '6 點', '1 點'], '兩根針都在 12，就是 12 點。'),
  _BankQ('讀整點時，要先確認哪一根針？', '長針有沒有指著 12', ['只看顏色', '只看鐘的大小', '不用看針'],
      '長針在 12，再看短針指幾。'),
];

void _fillCountTo(_Add add, int max) {
  final samples = max <= 50
      ? [12, 15, 18, 21, 24, 27, 33, 36, 42, 48]
      : [51, 58, 63, 70, 74, 80, 86, 91, 97, 99];
  for (final n in samples) {
    add(
      prompt: '$n 的前一個數是多少？',
      correct: '${n - 1}',
      pool: _numberPool(n - 1, high: max + 2),
      explanation: '$n 的前一個是 ${n - 1}。',
    );
    add(
      prompt: '$n 的後一個數是多少？',
      correct: '${n + 1}',
      pool: _numberPool(n + 1, high: max + 2),
      explanation: '$n 的後一個是 ${n + 1}。',
    );
    add(
      prompt: '$n 有幾個十？',
      correct: '${n ~/ 10}',
      pool: _numberPool(n ~/ 10, high: 12),
      explanation: '$n 的十位是 ${n ~/ 10}。',
    );
    add(
      prompt: '$n 有幾個一？',
      correct: '${n % 10}',
      pool: _numberPool(n % 10, high: 12),
      explanation: '$n 的個位是 ${n % 10}。',
    );
  }
  if (max <= 50) {
    add(
      prompt: '2 個一數：10、12、14，下一個是多少？',
      correct: '16',
      pool: _numberPool(16, high: max),
      explanation: '2 個一數，14 再加 2 是 16。',
    );
    add(
      prompt: '5 個一數：15、20、25，下一個是多少？',
      correct: '30',
      pool: _numberPool(30, high: max),
      explanation: '5 個一數，25 再加 5 是 30。',
    );
    add(
      prompt: '10 個一數：20、30、40，下一個是多少？',
      correct: '50',
      pool: _numberPool(50, high: max + 5),
      explanation: '10 個一數，40 再加 10 是 50。',
    );
  } else {
    add(
      prompt: '10 個一數：60、70、80，下一個是多少？',
      correct: '90',
      pool: _numberPool(90, high: max),
      explanation: '10 個一數，80 再加 10 是 90。',
    );
    add(
      prompt: '5 個一數：75、80、85，下一個是多少？',
      correct: '90',
      pool: _numberPool(90, high: max),
      explanation: '5 個一數，85 再加 5 是 90。',
    );
    add(
      prompt: '100 有幾個十？',
      correct: '10',
      pool: _numberPool(10, high: 12),
      explanation: '10 個十合起來是 100。',
    );
    add(
      prompt: '99 的後一個數是多少？',
      correct: '100',
      pool: _numberPool(100, high: 105),
      explanation: '99 再加 1 就是 100。',
    );
  }
}

void _fillAddTo(_Add add, int max) {
  for (var sum = 11; sum <= max; sum++) {
    for (var a = 0; a <= sum; a++) {
      final b = sum - a;
      if (a > max || b > max) continue;
      add(
        prompt: '$a + $b = ?',
        correct: '$sum',
        pool: _numberPool(sum, high: max + 2),
        explanation: '$a + $b = $sum。',
      );
    }
  }
}

void _fillSubTo(_Add add, int max) {
  for (var diff = 0; diff <= max; diff++) {
    for (var b = 1; b <= max; b++) {
      final a = diff + b;
      if (a > max) continue;
      add(
        prompt: '$a - $b = ?',
        correct: '$diff',
        pool: _numberPool(diff, high: max),
        explanation: '$a - $b = $diff。',
      );
    }
  }
}

void _fillMeasure(_Add add) {
  for (var a = 1; a <= 8; a++) {
    for (var b = 1; b <= 6; b++) {
      final sum = a + b;
      add(
        prompt: '$a 根積木接上 $b 根，一共幾根長？',
        correct: '$sum',
        pool: _numberPool(sum, high: 16),
        explanation: '同一種單位接起來用加法，$a + $b = $sum。',
      );
    }
  }
  for (var whole = 4; whole <= 12; whole++) {
    for (var part = 1; part < whole && part <= 6; part++) {
      final left = whole - part;
      add(
        prompt: '一條有 $whole 個迴紋針長，拿掉 $part 個長，還剩幾個長？',
        correct: '$left',
        pool: _numberPool(left, high: 12),
        explanation: '拿掉一段用減法，$whole - $part = $left。',
      );
    }
  }
  _fillBank(add, _measureBank);
}

void _fillMoney(_Add add) {
  for (final value in [1, 5, 10, 50, 100]) {
    add(
      prompt: '1 個 $value 元，是多少元？',
      correct: '$value',
      pool: const ['1', '5', '10', '50', '100', '2', '20'],
      explanation: '這個錢幣是 $value 元。',
    );
  }
  for (final n in [2, 3, 4, 5, 6, 8, 10]) {
    add(
      prompt: '$n 個 10 元，一共多少元？',
      correct: '${n * 10}',
      pool: _numberPool(n * 10, high: 120),
      explanation: '$n 個十元是 ${n * 10} 元。',
    );
    add(
      prompt: '$n 個 5 元，一共多少元？',
      correct: '${n * 5}',
      pool: _numberPool(n * 5, high: 60),
      explanation: '$n 個五元是 ${n * 5} 元。',
    );
  }
  const pairs = <(int, int)>[
    (1, 5),
    (5, 10),
    (10, 10),
    (50, 10),
    (50, 50),
    (50, 5),
    (10, 5),
    (100, 0),
  ];
  for (final (a, b) in pairs) {
    if (b == 0) continue;
    add(
      prompt: '1 個 $a 元和 1 個 $b 元，一共多少元？',
      correct: '${a + b}',
      pool: _numberPool(a + b, high: 120),
      explanation: '$a + $b = ${a + b}，一共 ${a + b} 元。',
    );
  }
}

void _fillTwoDigit(_Add add) {
  for (var tens = 1; tens <= 4; tens++) {
    for (var ones = 0; ones <= 4; ones++) {
      for (var addTens = 1; addTens <= 4; addTens++) {
        for (var addOnes = 0; addOnes <= 4 - ones; addOnes++) {
          final a = tens * 10 + ones;
          final b = addTens * 10 + addOnes;
          final sum = a + b;
          if (sum > 99) continue;
          add(
            prompt: '$a + $b = ?',
            correct: '$sum',
            pool: _numberPool(sum, high: 100),
            explanation: '個位 $ones + $addOnes 不用進位，$a + $b = $sum。',
          );
        }
      }
    }
  }
  for (var tens = 1; tens <= 6; tens++) {
    for (var ones = 5; ones <= 9; ones++) {
      for (var addOnes = 1; addOnes <= 9; addOnes++) {
        if (ones + addOnes < 10) continue;
        final a = tens * 10 + ones;
        final sum = a + addOnes;
        if (sum > 99) continue;
        add(
          prompt: '$a + $addOnes = ?',
          correct: '$sum',
          pool: _numberPool(sum, high: 100),
          explanation: '個位 $ones + $addOnes 滿十要進位，$a + $addOnes = $sum。',
        );
      }
    }
  }
  for (var tens = 2; tens <= 9; tens++) {
    for (var ones = 0; ones <= 9; ones++) {
      for (var subTens = 1; subTens < tens; subTens++) {
        for (var subOnes = 0; subOnes <= ones; subOnes++) {
          final a = tens * 10 + ones;
          final b = subTens * 10 + subOnes;
          final diff = a - b;
          add(
            prompt: '$a - $b = ?',
            correct: '$diff',
            pool: _numberPool(diff, high: 100),
            explanation: '個位夠減，不用退位，$a - $b = $diff。',
          );
        }
      }
    }
  }
}

const _measureBank = [
  _BankQ(
      '量長度時，每一段單位要？', '一樣長', ['隨便換', '一次比一次長', '只用顏色區分'], '單位不一樣長，數出來的結果不能比。'),
  _BankQ('積木和迴紋針混在一起數，可以嗎？', '不可以', ['可以', '積木比較漂亮就可以', '只要總數一樣就好'],
      '要先選定同一種單位，再一個一個接。'),
  _BankQ('兩條繩子要先怎樣才能比長短？', '拉直並一端對齊', ['捲起來比粗細', '只看顏色', '先剪成一樣長'],
      '彎曲的先拉直，一端對齊再看另一端。'),
  _BankQ('終點比較遠的那一條？', '比較長', ['比較短', '一樣長', '沒有長度'], '起點對齊後，終點比較遠就是比較長。'),
  _BankQ('用 4 個迴紋針剛好排滿，這條線是？', '4 個迴紋針長', ['4 公分', '4 公斤', '4 點'],
      '一年級先用同樣的東西當單位，這裡是 4 個迴紋針長。'),
  _BankQ(
      '單位之間留了空隙，量出來會？', '變短、不準', ['一定更準', '長度不會變', '變成重量'], '單位要首尾相接，中間不能空一截。'),
];

const _shapeSortBank = [
  _BankQ('形狀和大小都一樣，疊起來會？', '完全重疊', ['一定露出一截', '變成另一種形狀', '不能放在一起'],
      '形狀、大小都相同，邊和角會重疊。'),
  _BankQ('只是顏色一樣，形狀不一樣，算完全一樣嗎？', '不算', ['算', '顏色一樣就一樣大', '不用再看邊'],
      '還要看形狀和大小，顏色不是判斷標準。'),
  _BankQ('把圓形和三角形分開，是在看？', '形狀', ['價錢', '味道', '星期幾'], '圓形和三角形的差別在形狀。'),
  _BankQ('把紅的和藍的分開，是在看？', '顏色', ['角的個數', '是不是立體', '有幾公分'], '紅和藍是顏色，可以當成分類標準。'),
  _BankQ(
      '圖形規律是紅圓、藍圓、紅圓，下一個是？', '藍圓', ['紅三角', '藍三角', '綠方塊'], '規律是紅、藍重複，下一個回到藍圓。'),
  _BankQ(
      '方盒可以疊高，因為它？', '有平平的面', ['是紅色的', '沒有面', '一定是圓的'], '平面讓方盒放得穩，所以上面可以再疊。'),
  _BankQ('球不容易疊高，因為它？', '沒有平平的面', ['太大', '太輕', '有四個角'], '球的表面是彎的，上面的東西會滑掉。'),
  _BankQ('圓罐立起來時可以？', '放穩', ['一定滾走', '變成三角形', '沒有底'], '圓罐直立時有平平的底，可以放穩。'),
  _BankQ('圓罐放倒時，彎彎的側面會讓它？', '滾動', ['變成方盒', '自動疊高', '不能移動'], '放倒以後側面是圓的，就會滾。'),
  _BankQ('形狀一樣但一大一小，能完全重疊嗎？', '不能', ['能', '只要顏色一樣就能', '轉一轉就一定重疊'],
      '大小不同，小的蓋不滿大的。'),
  _BankQ('分類時要先決定？', '同一類相同的地方', ['哪一個最好看', '哪一個最貴', '今天星期幾'],
      '先說好看形狀、顏色或大小，再把相同的放一起。'),
  _BankQ('兩張一樣的正方形，轉一個方向後？', '還是正方形', ['變成圓形', '角變少了', '不能再分類'],
      '轉方向不會改變邊和角，它還是正方形。'),
  _BankQ('紙上的圓和皮球，哪一個是立體的？', '皮球', ['紙上的圓', '兩個都是畫在紙上', '兩個都沒有面'],
      '皮球可以拿起來轉，是立體的；紙上的圓是平面圖形。'),
  _BankQ('三角形有幾個角？', '3 個', ['0 個', '4 個', '5 個'], '三角形有 3 條邊、3 個角。'),
  _BankQ('哪一個可以當分類的標準？', '形狀', ['今天的心情', '誰先拿到', '名字好不好聽'], '形狀是看得到、說得清楚的標準。'),
  _BankQ('長積木和短積木分開，是在比？', '長短', ['味道', '聲音', '星期'], '長和短是長度，可以分成兩類。'),
  _BankQ('接下去排同樣的圖形前，要先看？', '重複的規律', ['桌子的顏色', '現在幾點', '誰站得比較高'],
      '找出重複的部分，才知道下一個該排什麼。'),
  _BankQ('大小相同的兩個三角形，翻面後？', '還是可以重疊', ['一定變成圓形', '角會消失', '不能再比較'],
      '翻面沒有改變形狀和大小，還是可以對齊。'),
];

const _calendarBank = [
  _BankQ('一星期有幾天？', '7 天', ['5 天', '10 天', '12 天'], '一星期有七天。'),
  _BankQ('星期一的後一天是？', '星期二', ['星期日', '星期三', '星期五'], '星期一再過一天是星期二。'),
  _BankQ('星期二的後一天是？', '星期三', ['星期一', '星期四', '星期六'], '星期二的下一天是星期三。'),
  _BankQ('星期三的後一天是？', '星期四', ['星期二', '星期五', '星期日'], '星期三再過一天是星期四。'),
  _BankQ('星期四的後一天是？', '星期五', ['星期三', '星期六', '星期一'], '星期四的下一天是星期五。'),
  _BankQ('星期五的後一天是？', '星期六', ['星期四', '星期日', '星期二'], '星期五再過一天是星期六。'),
  _BankQ('星期六的後一天是？', '星期日', ['星期五', '星期一', '星期三'], '星期六的下一天是星期日。'),
  _BankQ('星期日的後一天是？', '星期一', ['星期六', '星期二', '星期五'], '星期日過了，就換新的一星期，是星期一。'),
  _BankQ('星期三的前一天是？', '星期二', ['星期四', '星期一', '星期五'], '星期三的前一天是星期二。'),
  _BankQ('星期一的前一天是？', '星期日', ['星期二', '星期六', '星期五'], '星期一的前一天回到星期日。'),
  _BankQ('3 月的下一個月是？', '4 月', ['2 月', '5 月', '1 月'], '3 月過完是 4 月。'),
  _BankQ('12 月的下一個月是？', '1 月', ['11 月', '2 月', '10 月'],
      '12 月是一年的最後一個月，下一個月是 1 月。'),
  _BankQ('1 月的前一個月是？', '12 月', ['2 月', '11 月', '3 月'], '1 月的前一個月是上一年的 12 月。'),
  _BankQ('今天是 5 月 8 日，明天是？', '5 月 9 日', ['5 月 7 日', '6 月 8 日', '5 月 18 日'],
      '同一個月，日期加 1 就是明天。'),
  _BankQ('今天是 6 月 10 日，昨天是？', '6 月 9 日', ['6 月 11 日', '5 月 10 日', '6 月 1 日'],
      '同一個月，日期減 1 就是昨天。'),
  _BankQ('今天的後一天叫什麼？', '明天', ['昨天', '上個月', '去年'], '比今天再過一天，叫做明天。'),
  _BankQ('今天的前一天叫什麼？', '昨天', ['明天', '下個月', '明年'], '今天的前一天叫做昨天。'),
  _BankQ('8 月的前一個月是？', '7 月', ['9 月', '6 月', '10 月'], '8 月前面是 7 月。'),
  _BankQ('5 月 20 日的後一天是？', '5 月 21 日', ['5 月 19 日', '6 月 20 日', '4 月 20 日'],
      '5 月 20 日再過一天是 5 月 21 日。'),
  _BankQ('月曆上直的一欄，常常是？', '同一個星期幾', ['同一天的日期', '不同的年份', '只寫 1 日'],
      '直的一欄對齊的是同一個星期幾。'),
];

const _tallyBank = [
  _BankQ('畫記 |||| 是幾個？', '4 個', ['3 個', '5 個', '1 個'], '四條直線就是 4 個。'),
  _BankQ('畫記 ||||| 是幾個？', '5 個', ['4 個', '6 個', '10 個'], '五條一組，這組是 5 個。'),
  _BankQ('蘋果 6 個、香蕉 4 個，比較多的是？', '蘋果', ['香蕉', '一樣多', '不能比'], '6 比 4 大，蘋果比較多。'),
  _BankQ('表格最主要是用來？', '把每一類的數量記下來', ['把東西塗上顏色', '算出今天星期幾', '比哪一根比較長'],
      '分類以後，把數量寫進表裡。'),
  _BankQ('先分類再數，是為了知道？', '每一類有幾個', ['哪一個最好看', '明天幾點', '繩子有多長'],
      '同一類放在一起，再數就不會混在一起。'),
  _BankQ('貓 2 隻、狗 2 隻，哪一種比較多？', '一樣多', ['貓', '狗', '不能記'], '兩邊都是 2，數量一樣。'),
  _BankQ('紅球 3 顆、藍球 5 顆，一共幾顆？', '8 顆', ['2 顆', '15 顆', '5 顆'],
      '3 + 5 = 8，一共 8 顆。'),
  _BankQ('畫記每 5 個成一組，是為了？', '比較好數', ['讓數量變少', '不用再分類', '把 5 看成 1'],
      '五個一組，之後用五個五個加。'),
  _BankQ('統計表的標題在說？', '這張表在記什麼', ['今天星期幾', '誰寫得比較快', '線條好不好看'],
      '先看標題，才知道表裡的數量是什麼東西。'),
  _BankQ('哪一類最少，要看？', '數量最小的', ['名字最長的', '排在最上面的一定最少', '顏色最深的'],
      '比的是數量，最小的那一類最少。'),
  _BankQ('3 個圈的畫記是幾個？', '3 個', ['2 個', '4 個', '6 個'], '一個圈代表一個，三個圈是 3。'),
  _BankQ('8 和 5 比，8 比較？', '多', ['少', '一樣', '不能比'], '8 比 5 大，所以 8 比較多。'),
  _BankQ('把一樣的放在一起，叫做？', '分類', ['唱數', '量長度', '看時鐘'], '相同的放一起，就是分類。'),
  _BankQ('紀錄做完，可以回答？', '哪一類最多', ['明天會不會下雨', '繩子有幾公分', '現在幾點'],
      '每一類的數量都有了，就能找出最多的。'),
  _BankQ(
      '星星 7 個、月亮 7 個，結果是？', '一樣多', ['星星比較多', '月亮比較少', '不能畫記'], '兩邊都是 7，一樣多。'),
  _BankQ('鉛筆 9 枝、橡皮 4 個，鉛筆比橡皮多幾個？', '5 個', ['4 個', '13 個', '9 個'],
      '9 - 4 = 5，鉛筆多 5 個。'),
  _BankQ('兩類數量都寫成 0，表示？', '兩類都沒有', ['兩類都很多', '只要再分類一次', '表格寫錯才會是 0'],
      '0 表示這一類一個也沒有。'),
  _BankQ('畫記 |||| 再加 ||，一共是？', '6 個', ['4 個', '2 個', '8 個'], '4 + 2 = 6。'),
];

void _checkEquation(String title, MathQ q) {
  final add = _addEquation.firstMatch(q.prompt);
  if (add != null) {
    final expect = int.parse(add.group(1)!) + int.parse(add.group(2)!);
    if (q.options[q.correctIndex] != '$expect') {
      throw StateError('$title 的加法答案應為 $expect：${q.prompt}');
    }
  }
  final sub = _subEquation.firstMatch(q.prompt);
  if (sub != null) {
    final a = int.parse(sub.group(1)!);
    final b = int.parse(sub.group(2)!);
    if (b > a) throw StateError('$title 的減法被減數太小：${q.prompt}');
    final expect = a - b;
    if (q.options[q.correctIndex] != '$expect') {
      throw StateError('$title 的減法答案應為 $expect：${q.prompt}');
    }
  }
}
