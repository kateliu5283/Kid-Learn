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

/// 數學第一冊一個單元：自編例子、步驟與測驗。
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
  final id = 'cl-m-1-1-$code-u${unit.toString().padLeft(2, '0')}';
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
    semester: Semester.first,
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
