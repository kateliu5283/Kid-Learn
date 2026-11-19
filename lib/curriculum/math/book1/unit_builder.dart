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

/// 數學各冊一個單元：自編例子、步驟與測驗。
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
  int grade = 1,
  Semester semester = Semester.first,
}) {
  if (unit < 1 || unit > 12) {
    throw StateError('$title 的單元編號要在 1 到 12');
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
  final id = 'cl-m-$grade-$term-$code-u${unit.toString().padLeft(2, '0')}';
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
    grade: grade,
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
  count200,
  count300,
  count1000,
  twoDigitCol,
  centimeter,
  addRelation,
  area,
  twoStep,
  mul248,
  mul3697,
  mul0110,
  mulGeneral,
  minutes,
  capacity,
  weight,
  threeDigit,
  planeShape,
  yearMonth,
  meter,
  sortSolid,
  sharing,
  fraction,
  mulAdd,
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
    case '200 以內的數':
      return _Drill.count200;
    case '數到 300':
      return _Drill.count300;
    case '1000 以內的數':
    case '數到 1000':
      return _Drill.count1000;
    case '二位數的直式加減':
    case '二位數的加減法':
    case '二位數的加減':
      return _Drill.twoDigitCol;
    case '量長度':
    case '認識公分':
    case '幾公分':
      return _Drill.centimeter;
    case '加減關係與應用':
    case '加減應用':
    case '加減的關係與應用':
      return _Drill.addRelation;
    case '面積大小的比較':
    case '面的大小比較':
      return _Drill.area;
    case '兩步驟的加減':
    case '加減兩步驟':
      return _Drill.twoStep;
    case '2、5、4、8 的乘法':
    case '乘法 (一)':
      return _Drill.mul248;
    case '3、6、9、7 的乘法':
    case '3、6、7、9 的乘法':
    case '乘法 (二)':
      return _Drill.mul3697;
    case '0、1、10 的乘法':
      return _Drill.mul0110;
    case '乘法':
      return _Drill.mulGeneral;
    case '幾時幾分':
    case '時間':
      return _Drill.minutes;
    case '容量':
    case '容量與重量':
      return _Drill.capacity;
    case '重量':
      return _Drill.weight;
    case '三位數的加減':
    case '加加減減':
      return _Drill.threeDigit;
    case '平面圖形':
    case '平面圖形與立體形體':
      return _Drill.planeShape;
    case '年、月、日':
    case '年月日':
      return _Drill.yearMonth;
    case '兩步驟應用問題':
    case '乘與加兩步驟':
    case '兩步驟的計算':
      return _Drill.mulAdd;
    case '公尺和公分':
    case '公尺與公分':
    case '幾公尺':
      return _Drill.meter;
    case '分類與立體圖形':
    case '面的大小與立體':
      return _Drill.sortSolid;
    case '分分看':
    case '分裝與平分':
    case '分東西':
      return _Drill.sharing;
    case '分數':
    case '認識分數':
    case '單位分數':
      return _Drill.fraction;
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
    case _Drill.count200:
      _fillHundreds(add, 200);
    case _Drill.count300:
      _fillHundreds(add, 300);
    case _Drill.count1000:
      _fillHundreds(add, 1000);
    case _Drill.twoDigitCol:
      _fillCarry(add);
    case _Drill.centimeter:
      _fillBank(add, _centimeterBank);
    case _Drill.addRelation:
      _fillRelation(add);
    case _Drill.area:
      _fillBank(add, _areaBank);
    case _Drill.twoStep:
      _fillTwoStep(add);
    case _Drill.mul248:
      _fillMul(add, const [2, 5, 4, 8]);
    case _Drill.mul3697:
      _fillMul(add, const [3, 6, 7, 9]);
    case _Drill.mul0110:
      _fillMul(add, const [0, 1, 10]);
    case _Drill.mulGeneral:
      _fillMul(add, const [2, 3, 4, 5, 6, 7, 8, 9]);
    case _Drill.minutes:
      _fillMinutes(add);
    case _Drill.capacity:
      _fillBank(add, _capacityBank);
    case _Drill.weight:
      _fillBank(add, _weightBank);
    case _Drill.threeDigit:
      _fillThreeDigit(add);
    case _Drill.planeShape:
      _fillBank(add, _planeShapeBank);
    case _Drill.yearMonth:
      _fillBank(add, _yearMonthBank);
    case _Drill.meter:
      _fillBank(add, _meterBank);
    case _Drill.sortSolid:
      _fillBank(add, _sortSolidBank);
    case _Drill.sharing:
      _fillSharing(add);
    case _Drill.fraction:
      _fillBank(add, _fractionBank);
    case _Drill.mulAdd:
      _fillMulAdd(add);
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

void _fillHundreds(_Add add, int max) {
  final samples = max <= 200
      ? [108, 120, 135, 146, 160, 174, 186, 199]
      : max <= 300
          ? [108, 146, 180, 215, 240, 263, 288, 300]
          : [108, 250, 407, 530, 648, 715, 860, 999];
  for (final n in samples) {
    final hundreds = n ~/ 100;
    final tens = (n ~/ 10) % 10;
    final ones = n % 10;
    add(
      prompt: '$n 的百位是多少？',
      correct: '$hundreds',
      pool: const ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
      explanation: '$n 有 $hundreds 個百。',
    );
    add(
      prompt: '$n 的十位是多少？',
      correct: '$tens',
      pool: const ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
      explanation: '$n 的十位是 $tens。',
    );
    add(
      prompt: '$n 的個位是多少？',
      correct: '$ones',
      pool: const ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
      explanation: '$n 的個位是 $ones。',
    );
    if (n < max) {
      add(
        prompt: '$n 的後一個數是多少？',
        correct: '${n + 1}',
        pool: _numberPool(n + 1, high: max + 2),
        explanation: '$n 再加 1 是 ${n + 1}。',
      );
    }
  }
}

void _fillCarry(_Add add) {
  const pairs = [
    (27, 16),
    (38, 25),
    (46, 37),
    (58, 24),
    (19, 43),
    (64, 28),
    (35, 47),
    (72, 19),
    (29, 15),
    (48, 36),
    (67, 18),
    (81, 39),
  ];
  for (final (a, b) in pairs) {
    final sum = a + b;
    add(
      prompt: '$a + $b = ?',
      correct: '$sum',
      pool: _numberPool(sum, low: 10, high: 120),
      explanation: '個位滿十要進位，$a + $b = $sum。',
    );
  }
  const subs = [
    (52, 18),
    (70, 26),
    (83, 37),
    (61, 29),
    (90, 45),
    (44, 17),
    (75, 38),
    (63, 28),
    (55, 17),
    (92, 48),
    (76, 29),
    (64, 37),
  ];
  for (final (a, b) in subs) {
    final diff = a - b;
    add(
      prompt: '$a - $b = ?',
      correct: '$diff',
      pool: _numberPool(diff, high: 90),
      explanation: '個位不夠減要向十位借，$a - $b = $diff。',
    );
  }
}

void _fillRelation(_Add add) {
  const facts = [(8, 5), (13, 6), (15, 9), (17, 8), (20, 7), (24, 9), (30, 12), (18, 4)];
  for (final (sum, part) in facts) {
    final other = sum - part;
    add(
      prompt: '$part + □ = $sum，□ 是多少？',
      correct: '$other',
      pool: _numberPool(other, high: 40),
      explanation: '$sum - $part = $other，所以空格是 $other。',
    );
    add(
      prompt: '$sum - □ = $part，□ 是多少？',
      correct: '$other',
      pool: _numberPool(other, high: 40),
      explanation: '$sum - $other = $part。',
    );
  }
}

void _fillTwoStep(_Add add) {
  const jobs = [
    (12, 8, 5, true, true),
    (20, 6, 4, true, false),
    (30, 9, 7, false, false),
    (15, 10, 3, true, true),
    (40, 12, 8, false, true),
    (18, 7, 6, true, false),
    (25, 5, 9, true, true),
    (50, 20, 6, false, false),
    (16, 9, 4, true, true),
    (28, 8, 5, true, false),
    (36, 10, 6, false, false),
    (22, 7, 3, true, true),
    (45, 15, 9, false, true),
    (19, 6, 8, true, false),
    (33, 4, 7, true, true),
    (60, 25, 10, false, false),
  ];
  for (final (a, b, c, firstAdd, secondAdd) in jobs) {
    final mid = firstAdd ? a + b : a - b;
    final result = secondAdd ? mid + c : mid - c;
    final op1 = firstAdd ? '+' : '-';
    final op2 = secondAdd ? '+' : '-';
    add(
      prompt: '先算 $a $op1 $b，再 $op2 $c，結果是多少？',
      correct: '$result',
      pool: _numberPool(result, high: 80),
      explanation: '$a $op1 $b = $mid，$mid $op2 $c = $result。',
    );
  }
}

void _fillMul(_Add add, List<int> factors) {
  for (final a in factors) {
    for (var b = 1; b <= 9; b++) {
      final product = a * b;
      add(
        prompt: '$a × $b = ?',
        correct: '$product',
        pool: _numberPool(product, high: (factors.last * 9) + 8),
        explanation: '$a 的 $b 倍是 $product。',
      );
    }
  }
}

void _fillMinutes(_Add add) {
  for (final mark in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]) {
    final minutes = mark * 5;
    add(
      prompt: '長針指著 $mark，是幾分？',
      correct: '$minutes 分',
      pool: ['${minutes - 5} 分', '$minutes 分', '${minutes + 5} 分', '$mark 分']
          .where((item) => !item.startsWith('-'))
          .toList(),
      explanation: '長針走 1 大格是 5 分，指著 $mark 就是 $minutes 分。',
    );
  }
  add(
    prompt: '1 小時等於幾分鐘？',
    correct: '60 分',
    pool: const ['10 分', '30 分', '60 分', '100 分'],
    explanation: '長針走一圈是 60 分，也就是 1 小時。',
  );
  const clocks = [(3, 6, '3 點 30 分'), (7, 3, '7 點 15 分'), (4, 9, '4 點 45 分'), (8, 6, '8 點 30 分'), (1, 2, '1 點 10 分')];
  for (final (hour, mark, label) in clocks) {
    add(
      prompt: '短針在 $hour 和 ${hour + 1} 之間、長針指著 $mark，是什麼時刻？',
      correct: label,
      pool: ['$hour 點整', label, '${hour + 1} 點整', '$mark 點 $hour 分'],
      explanation: '短針還沒到 ${hour + 1}，時是 $hour；長針指 $mark 是 ${mark * 5} 分。',
    );
  }
}

void _fillThreeDigit(_Add add) {
  const pairs = [
    (128, 46),
    (235, 157),
    (340, 125),
    (408, 219),
    (516, 278),
    (627, 135),
    (256, 178),
    (319, 246),
    (480, 165),
    (734, 258),
    (152, 87),
    (603, 247),
  ];
  for (final (a, b) in pairs) {
    add(
      prompt: '$a + $b = ?',
      correct: '${a + b}',
      pool: _numberPool(a + b, low: 50, high: 999),
      explanation: '$a + $b = ${a + b}。',
    );
    add(
      prompt: '$a - $b = ?',
      correct: '${a - b}',
      pool: _numberPool(a - b, high: 900),
      explanation: '$a - $b = ${a - b}。',
    );
  }
}

void _fillSharing(_Add add) {
  const packs = [
    (12, 3),
    (10, 2),
    (18, 6),
    (20, 4),
    (15, 5),
    (16, 4),
    (9, 3),
    (8, 2),
    (14, 2),
    (21, 3),
    (24, 6),
    (12, 4),
    (18, 2),
    (20, 5),
    (16, 8),
    (24, 8),
  ];
  for (final (total, groups) in packs) {
    final each = total ~/ groups;
    add(
      prompt: '$total 個平分成 $groups 份，一份有幾個？',
      correct: '$each 個',
      pool: ['${each - 1} 個', '$each 個', '${each + 1} 個', '$total 個']
          .where((item) => !item.startsWith('-') && !item.startsWith('0'))
          .toList(),
      explanation: '$groups × $each = $total，所以一份是 $each 個。',
    );
  }
}

void _fillMulAdd(_Add add) {
  const jobs = [
    (3, 4, 5),
    (2, 6, 8),
    (5, 3, 7),
    (4, 4, 6),
    (2, 9, 5),
    (6, 2, 10),
    (3, 5, 4),
    (4, 3, 9),
    (7, 2, 6),
    (5, 4, 3),
    (8, 2, 5),
    (3, 6, 4),
    (4, 5, 2),
    (2, 8, 7),
    (6, 3, 5),
    (9, 2, 4),
  ];
  for (final (a, b, c) in jobs) {
    final product = a * b;
    add(
      prompt: '先算 $a × $b，再加 $c，結果是多少？',
      correct: '${product + c}',
      pool: _numberPool(product + c, high: 80),
      explanation: '$a × $b = $product，$product + $c = ${product + c}。',
    );
  }
}

const _centimeterBank = [
  _BankQ('用公分尺量長度，起點要對齊？', '0', ['1', '10', '尺的尾巴'], '一端對齊 0，再看另一端的刻度。'),
  _BankQ('1 公分裡面大約有幾個小格？', '看尺上的刻度', ['一定是 100 格', '沒有刻度', '只有 1 格就結束'], '公分尺用刻度表示長度。'),
  _BankQ('鉛筆大約用哪一個單位量？', '公分', ['公尺', '公斤', '公升'], '鉛筆比手臂短，用公分量比較合適。'),
  _BankQ('14 公分比 9 公分？', '長', ['短', '一樣長', '不能比'], '數字比較大，長度就比較長。'),
  _BankQ('量完要讀的是？', '另一端對到的刻度', ['尺的顏色', '誰拿的尺', '尺有沒有名字'], '對齊 0 之後，讀另一端的數字。'),
  _BankQ('3 公分和 5 公分接起來是？', '8 公分', ['2 公分', '15 公分', '35 公分'], '同一單位可以直接相加，3 + 5 = 8。'),
  _BankQ('8 公分剪掉 3 公分，剩下？', '5 公分', ['11 公分', '3 公分', '8 公分'], '8 - 3 = 5 公分。'),
  _BankQ('公分可以寫成？', 'cm', ['kg', 'L', '元'], '公分的符號是 cm。'),
  _BankQ('估測之後最好再？', '用尺量一次', ['把尺丟掉', '只看顏色', '改成公斤'], '估測完用尺核對，才知道差多少。'),
  _BankQ('哪一個比較適合用公分量？', '橡皮擦', ['操場跑道', '一棟房子', '一座山'], '橡皮擦不長，用公分就夠。'),
  _BankQ('兩枝筆都是 12 公分，它們？', '一樣長', ['第一枝比較長', '第二枝比較短', '不能比'], '數字相同，長度就一樣。'),
  _BankQ('尺沒有對齊 0，結果會？', '可能量錯', ['一定比較準', '長度會變 0', '不用再讀刻度'], '起點沒對齊，讀到的數字就不是真正的長度。'),
  _BankQ('6 公分再加 6 公分是？', '12 公分', ['66 公分', '0 公分', '6 公分'], '6 + 6 = 12 公分。'),
  _BankQ('公分是在量？', '長度', ['重量', '容量', '時間'], '公分是長度單位。'),
  _BankQ('20 公分比 18 公分多幾公分？', '2 公分', ['20 公分', '38 公分', '18 公分'], '20 - 18 = 2 公分。'),
  _BankQ('量彎彎的線，可以？', '用繩子比完再拉直量', ['一定不能量', '只能量直線', '改看時鐘'], '先用繩子沿著彎線比，再拉直放到尺上。'),
];

const _areaBank = [
  _BankQ('比面積時，要看？', '面有多大', ['線有多長', '有多重', '幾點鐘'], '面積是面的大小。'),
  _BankQ('用同樣的方格鋪滿，格數比較多的？', '面積比較大', ['一定比較輕', '邊長一定是 1', '不能比'], '同一種方格，格數多的面積比較大。'),
  _BankQ('直接比較面積可以？', '把兩個圖形疊起來', ['只看顏色', '先秤重量', '看是星期幾'], '疊起來，多出來的那邊比較大。'),
  _BankQ('方格有 6 格和 4 格，哪一個面積大？', '6 格', ['4 格', '一樣大', '不能用格數比'], '6 比 4 多，面積比較大。'),
  _BankQ('圖形被遮住一角，格數會？', '變少', ['一定變多', '不會變', '變成重量'], '少了一塊，蓋住的格數就變少。'),
  _BankQ('兩張紙疊起來一樣大，表示？', '面積一樣', ['重量一定一樣', '顏色一樣', '時間一樣'], '沒有哪一張多出來，面積就一樣。'),
  _BankQ('用不同大小的方格，格數可以直接比嗎？', '不行', ['可以', '只要顏色一樣就可以', '格數一定相等'], '單位不一樣，格數不能直接比。'),
  _BankQ('面積比的是？', '面', ['邊的條數', '角的個數', '有幾個人'], '面積看的是面有多大。'),
  _BankQ('3 格加 2 格，合起來是？', '5 格', ['1 格', '6 格', '32 格'], '同一種方格可以相加，3 + 2 = 5。'),
  _BankQ('哪一個動作是在比面積？', '看哪一張桌墊蓋住比較多', ['看哪一枝筆比較長', '看哪一袋米比較重', '看現在幾點'], '桌墊蓋住的範圍就是面積。'),
  _BankQ('正方形和長方形都可以？', '用方格比較面積', ['只有圓形能比', '不能放在桌上', '一定一樣大'], '平面圖形都能用同一種方格來比。'),
  _BankQ('圖形沒有鋪滿就開始比，結果會？', '可能數錯', ['一定更準', '面積變成 0', '方格會變大'], '要鋪滿再數，空掉的地方不算進去。'),
  _BankQ('8 格比 8 格？', '一樣大', ['左邊比較大', '右邊比較小', '不能比'], '格數相同，面積一樣。'),
  _BankQ('把圖形剪開再拼起來，面積？', '還是一樣', ['一定變大', '一定變小', '變成長度'], '只是形狀變了，面的大小沒有變。'),
  _BankQ('教室地板比課本封面？', '面積大多了', ['一定比較小', '一樣大', '不能算面積'], '地板蓋住的面比一本書大很多。'),
  _BankQ('數方格時，每一格要？', '一樣大', ['顏色不同', '有的大有的小', '只數邊線'], '單位要相同，格數才有意義。'),
];

const _capacityBank = [
  _BankQ('容量是在比？', '容器能裝多少', ['繩子有多長', '物品有多重', '現在幾點'], '容量看的是能裝下的多少。'),
  _BankQ('水裝得比較滿的杯子，容量使用量？', '比較多', ['比較少', '一定一樣', '不能倒水'], '裝得更多，使用的容量就更多。'),
  _BankQ('直接比較容量可以？', '把水倒過去看會不會滿出來', ['只看杯子顏色', '先秤杯子多重', '看杯子有幾個角'], '倒過去還有剩下，原來的容器就裝得比較多。'),
  _BankQ('1 公升等於幾毫升？', '1000 毫升', ['10 毫升', '100 毫升', '60 毫升'], '1 公升是 1000 毫升。'),
  _BankQ('牛奶盒大約 1 公升，小湯匙大約用？', '毫升', ['公尺', '公斤', '小時'], '湯匙裝得很少，用毫升比較合適。'),
  _BankQ('500 毫升和 500 毫升合起來是？', '1000 毫升', ['500 公升', '50 毫升', '5 毫升'], '500 + 500 = 1000 毫升，也就是 1 公升。'),
  _BankQ('哪一個是容量單位？', '公升', ['公分', '公斤', '元'], '公升用來表示能裝多少。'),
  _BankQ('兩個一樣的杯子都裝滿，容量？', '一樣', ['高的杯子一定比較多', '只要顏色不同就不同', '不能比'], '容器相同又都裝滿，容量就一樣。'),
  _BankQ('水倒進量杯，是要？', '讀出有多少', ['把水喝完', '量長度', '看星期幾'], '量杯的刻度用來讀容量。'),
  _BankQ('容器比較寬、又比較高，通常？', '可能裝得比較多', ['一定裝得比較少', '容量變成重量', '不用再比較'], '又寬又高的容器，常常裝得比較多，但仍要用倒水確認。'),
  _BankQ('300 毫升比 800 毫升？', '少', ['多', '一樣', '不能比'], '300 比 800 小，所以比較少。'),
  _BankQ('容量和重量？', '是不同的量', ['一定相等', '都用公分', '都看時鐘'], '裝多少和有多重要分開看。'),
  _BankQ('1 公升的水倒進兩個一樣的杯子，每個杯子大約？', '不到 1 公升', ['還是 1 公升', '變成 2 公升', '不能分'], '1 公升分成兩杯，每一杯比 1 公升少。'),
  _BankQ('量杯的刻度要怎麼看？', '水面對到的線', ['杯子的把手', '桌面的顏色', '誰先倒的'], '水面對準的刻度就是現在的容量。'),
  _BankQ('空杯子的容量是？', '它最多能裝多少', ['現在是 0 所以沒有容量', '杯子的重量', '杯子有多高'], '容量是容器能裝的量，不是現在裝了多少。'),
  _BankQ('2 公升比 1 公升？', '多', ['少', '一樣', '不能比'], '2 比 1 大，所以 2 公升比較多。'),
];

const _weightBank = [
  _BankQ('重量是在比？', '物品有多重', ['能裝多少水', '有多長', '幾月幾日'], '重量看的是輕重。'),
  _BankQ('天平兩邊一樣高，表示？', '兩邊一樣重', ['左邊比較重', '右邊比較長', '不能比'], '天平平衡時，兩邊重量相同。'),
  _BankQ('哪一邊往下沉，哪一邊就？', '比較重', ['比較輕', '比較長', '容量比較大'], '重的一邊會把天平壓下去。'),
  _BankQ('1 公斤等於幾公克？', '1000 公克', ['10 公克', '100 公克', '60 公克'], '1 公斤是 1000 公克。'),
  _BankQ('一袋米大約用哪一個單位？', '公斤', ['公分', '毫升', '小時'], '一袋米用手拿得很有重量，常用公斤。'),
  _BankQ('一顆葡萄大約用？', '公克', ['公尺', '公升', '年'], '一顆葡萄很輕，用公克比較合適。'),
  _BankQ('300 公克和 200 公克合起來是？', '500 公克', ['100 公克', '500 公斤', '32 公克'], '300 + 200 = 500 公克。'),
  _BankQ('哪一個是重量單位？', '公斤', ['公升', '公分', '分鐘'], '公斤用來表示有多重。'),
  _BankQ('先用手掂一掂，是在？', '估測重量', ['量長度', '看時間', '分類顏色'], '掂一掂可以先猜大概有多重。'),
  _BankQ('800 公克比 1 公斤？', '輕', ['重', '一樣重', '不能比'], '1 公斤是 1000 公克，800 公克比較輕。'),
  _BankQ('天平左邊放蘋果、右邊放同樣重的砝碼，表示？', '蘋果和砝碼一樣重', ['蘋果比較長', '砝碼是容量', '不用讀數字'], '平衡就代表兩邊一樣重。'),
  _BankQ('2 公斤比 2 公克？', '重很多', ['輕很多', '一樣重', '不能比'], '公斤比公克大很多。'),
  _BankQ('重量和容量？', '要分開看', ['一定相同', '都用公尺', '都是時間'], '多重和能裝多少不是同一件事。'),
  _BankQ('500 公克再加 500 公克是？', '1 公斤', ['500 公斤', '100 公克', '5 公克'], '1000 公克就是 1 公斤。'),
  _BankQ('哪一個通常比較重？', '一袋 2 公斤的米', ['一枝鉛筆', '一張紙', '一顆葡萄'], '2 公斤比鉛筆、紙和一顆葡萄重。'),
  _BankQ('砝碼上的數字是在說？', '這個砝碼有多重', ['這個砝碼有多長', '能裝幾公升', '現在幾點'], '砝碼用來表示重量。'),
  _BankQ('250 公克加 250 公克是？', '500 公克', ['500 公斤', '25 公克', '2 公斤'], '250 + 250 = 500 公克。'),
  _BankQ('天平左邊下沉，表示左邊？', '比較重', ['比較輕', '比較長', '是容量'], '下沉的一邊比較重。'),
];

const _planeShapeBank = [
  _BankQ('三角形有幾條邊？', '3 條', ['4 條', '0 條', '5 條'], '三角形有 3 條直邊。'),
  _BankQ('四邊形有幾個角？', '4 個', ['3 個', '0 個', '6 個'], '四邊形有 4 個角。'),
  _BankQ('正方形的四條邊？', '一樣長', ['都是彎的', '只有 2 條', '沒有角'], '正方形四邊等長，也有四個直角。'),
  _BankQ('長方形的對邊？', '一樣長', ['一定不一樣', '是彎的', '只有一條'], '長方形兩組對邊分別一樣長。'),
  _BankQ('圓形有幾個角？', '0 個', ['1 個', '3 個', '4 個'], '圓形沒有角。'),
  _BankQ('正方體有幾個正方形的面？', '6 個', ['4 個', '8 個', '1 個'], '正方體六個面都是一樣大的正方形。'),
  _BankQ('長方體的面是？', '長方形或正方形', ['都是圓形', '都是三角形', '沒有面'], '長方體的面是長方形，也可能有正方形。'),
  _BankQ('球和圓形的差別是？', '球是立體的，圓形是平的', ['兩個都會自己站好', '圓形比較重', '球沒有表面'], '球可以滾，圓形是畫在平面上的。'),
  _BankQ('哪一個是平面圖形？', '紙上的三角形', ['骰子', '皮球', '牛奶盒'], '畫在紙上的三角形是平的。'),
  _BankQ('哪一個是立體形體？', '骰子', ['紙上的圓', '紙上的正方形', '一條線'], '骰子有長、寬、高，是正方體。'),
  _BankQ('數立體形體的角，正方體有？', '8 個角', ['4 個角', '6 個角', '0 個角'], '正方體有 8 個角。'),
  _BankQ('長方體有幾條邊？', '12 條', ['4 條', '6 條', '8 條'], '長方體有 12 條邊。'),
  _BankQ('四邊形一定有？', '4 條邊', ['3 條邊', '0 個角', '會滾的曲面'], '四邊形的名字就表示有四條邊。'),
  _BankQ('把正方形紙對折，可能得到？', '兩個一樣的部分', ['一個圓', '一顆球', '沒有邊的圖'], '對折可以把正方形分成兩半。'),
  _BankQ('圓柱立起來，上下的面是？', '圓形', ['三角形', '沒有面', '一條線'], '圓柱的頂面和底面是圓形。'),
  _BankQ('哪一個沒有平面可以穩穩站住？', '球', ['正方體', '長方體', '圓柱'], '球沒有平面，會滾。'),
  _BankQ('長方形有幾個角？', '4 個', ['3 個', '0 個', '5 個'], '長方形有 4 個角。'),
  _BankQ('圓柱的側面是？', '彎彎的', ['三角形', '一個尖角', '沒有側面'], '圓柱的側面是彎的，放倒才會滾。'),
  _BankQ('紙上的圓形和球，哪一個是平的？', '紙上的圓形', ['球', '兩個都會滾', '兩個都有 8 個角'], '畫在紙上的圓是平面圖形。'),
  _BankQ('四邊形有幾條邊？', '4 條', ['3 條', '5 條', '0 條'], '四邊形有 4 條邊。'),
];

const _yearMonthBank = [
  _BankQ('一年有幾個月？', '12 個月', ['7 個月', '10 個月', '30 個月'], '年曆上從 1 月排到 12 月。'),
  _BankQ('一個星期有幾天？', '7 天', ['5 天', '10 天', '12 天'], '星期一到星期日是 7 天。'),
  _BankQ('1 月的下一個月是？', '2 月', ['12 月', '3 月', '11 月'], '月分照 1 到 12 的順序排。'),
  _BankQ('12 月的下一個月是新的一年的？', '1 月', ['11 月', '2 月', '13 月'], '12 月結束就進入下一年的 1 月。'),
  _BankQ('大月有幾天？', '31 天', ['28 天', '30 天', '7 天'], '1、3、5、7、8、10、12 月有 31 天。'),
  _BankQ('4 月有幾天？', '30 天', ['31 天', '28 天', '7 天'], '4、6、9、11 月是小月，有 30 天。'),
  _BankQ('平年的 2 月有幾天？', '28 天', ['30 天', '31 天', '29 天一定'], '平年 2 月是 28 天，閏年才是 29 天。'),
  _BankQ('月曆上同一直行常常是？', '同一個星期幾', ['同一天', '不同的月', '同一小時'], '直著看，通常是下一個星期的同一天。'),
  _BankQ('從 3 月 1 日到 3 月 8 日經過幾天？', '7 天', ['8 天', '3 天', '30 天'], '8 - 1 = 7，中間經過 7 天。'),
  _BankQ('年曆是用來查？', '幾月幾日和星期', ['物品有多重', '水有幾公升', '線有幾公尺'], '年曆把一年的月和日排在一起。'),
  _BankQ('6 月 30 日的下一天是？', '7 月 1 日', ['6 月 31 日', '5 月 30 日', '6 月 1 日'], '6 月只有 30 天，下一天就是 7 月 1 日。'),
  _BankQ('今天星期三，再過 7 天是？', '星期三', ['星期四', '星期二', '星期天一定不是'], '一個星期有 7 天，再過 7 天回到同一個星期幾。'),
  _BankQ('一年的第一個月是？', '1 月', ['12 月', '6 月', '2 月'], '1 月是一年的開始。'),
  _BankQ('哪一個月不是大月？', '4 月', ['1 月', '7 月', '12 月'], '4 月有 30 天，不是大月。'),
  _BankQ('月曆橫著的一列通常有？', '7 天', ['12 天', '30 天', '24 小時'], '一列常常就是一個星期的 7 天。'),
  _BankQ('2 月 28 日的前一天是？', '2 月 27 日', ['3 月 1 日', '2 月 29 日一定有', '1 月 28 日'], '同一個月裡，28 的前一天是 27。'),
  _BankQ('9 月有幾天？', '30 天', ['31 天', '28 天', '29 天'], '9 月是小月，有 30 天。'),
  _BankQ('8 月有幾天？', '31 天', ['30 天', '28 天', '7 天'], '8 月是大月，有 31 天。'),
  _BankQ('11 月的下一個月是？', '12 月', ['10 月', '1 月', '9 月'], '11 月過完是 12 月。'),
  _BankQ('平年 2 月的下一天若是 2 月 28 日，再過一天是？', '3 月 1 日', ['2 月 29 日', '2 月 27 日', '1 月 1 日'], '平年 2 月到 28 日結束。'),
  _BankQ('從星期一再過 2 天是？', '星期三', ['星期二', '星期五', '星期日'], '星期一的後兩天是星期三。'),
  _BankQ('一年的最後一個月是？', '12 月', ['1 月', '11 月', '6 月'], '12 月是一年的最後一個月。'),
  _BankQ('5 月 1 日的前一天是？', '4 月 30 日', ['5 月 2 日', '4 月 1 日', '5 月 31 日'], '5 月開始之前是 4 月的最後一天。'),
];

const _meterBank = [
  _BankQ('1 公尺等於幾公分？', '100 公分', ['10 公分', '60 公分', '1000 公分'], '公尺是比較長的單位，1 公尺有 100 公分。'),
  _BankQ('量教室有多長，比較適合用？', '公尺', ['毫米', '公克', '毫升'], '教室比一枝鉛筆長很多，用公尺比較合適。'),
  _BankQ('2 公尺等於幾公分？', '200 公分', ['20 公分', '2 公分', '102 公分'], '1 公尺是 100 公分，2 公尺就是 200 公分。'),
  _BankQ('150 公分等於？', '1 公尺 50 公分', ['15 公尺', '150 公尺', '1 公尺 5 公分'], '100 公分是 1 公尺，剩下 50 公分。'),
  _BankQ('3 公尺比 250 公分？', '長', ['短', '一樣長', '不能比'], '3 公尺是 300 公分，比 250 公分長。'),
  _BankQ('80 公分比 1 公尺？', '短', ['長', '一樣', '不能比'], '1 公尺有 100 公分，80 公分比較短。'),
  _BankQ('公尺和公分都是？', '長度單位', ['重量單位', '容量單位', '時間單位'], '兩個都在說有多長。'),
  _BankQ('1 公尺 20 公分寫成公分是？', '120 公分', ['12 公分', '1020 公分', '20 公分'], '100 + 20 = 120 公分。'),
  _BankQ('操場跑道一小段大約用？', '公尺', ['一顆葡萄的公克', '一杯水的毫升', '鐘上的分鐘'], '跑道的長度常用公尺。'),
  _BankQ('先估測再實測，是為了？', '檢查自己猜得準不準', ['讓長度變短', '不用再看單位', '把公尺改成公斤'], '估測之後用尺量，就能知道差多少。'),
  _BankQ('4 公尺減 1 公尺是？', '3 公尺', ['5 公尺', '41 公尺', '1 公分'], '同一單位可以直接相減。'),
  _BankQ('哪一個換算是對的？', '1 公尺 = 100 公分', ['1 公尺 = 10 公分', '1 公尺 = 100 公斤', '1 公分 = 100 公尺'], '公分換成公尺時，100 公分才是 1 公尺。'),
  _BankQ('身高 1 公尺 35 公分，比較接近？', '135 公分', ['35 公分', '1 公分', '135 公尺'], '1 公尺再加 35 公分是 135 公分。'),
  _BankQ('兩段都是 2 公尺，接起來是？', '4 公尺', ['2 公尺', '22 公尺', '200 公尺'], '2 + 2 = 4 公尺。'),
  _BankQ('量很短的橡皮擦，仍用公尺會？', '數字很小、不好讀', ['一定更準', '橡皮擦會變長', '公尺不能量長度'], '太短的東西用公分比較清楚。'),
  _BankQ('300 公分等於幾公尺？', '3 公尺', ['30 公尺', '300 公尺', '13 公尺'], '300 ÷ 100 = 3，所以是 3 公尺。'),
  _BankQ('5 公尺等於幾公分？', '500 公分', ['50 公分', '5 公分', '105 公分'], '5 × 100 = 500 公分。'),
  _BankQ('90 公分比 1 公尺？', '短', ['長', '一樣長', '不能比'], '1 公尺是 100 公分，90 公分比較短。'),
  _BankQ('2 公尺 5 公分等於幾公分？', '205 公分', ['25 公分', '250 公分', '2005 公分'], '200 + 5 = 205 公分。'),
  _BankQ('哪一個換算不對？', '1 公尺 = 10 公分', ['1 公尺 = 100 公分', '2 公尺 = 200 公分', '150 公分 = 1 公尺 50 公分'], '1 公尺不是 10 公分。'),
];

const _sortSolidBank = [
  _BankQ('分類時要先決定？', '用什麼標準分', ['誰先拿到', '顏色好不好看就結束', '不用看形狀'], '標準一樣，大家才會分成同樣的結果。'),
  _BankQ('正方體的每個面是？', '一樣大的正方形', ['圓形', '三角形', '不一樣的長方形'], '骰子就是正方體，六個面都是正方形。'),
  _BankQ('長方體和正方體都可以？', '穩穩放在桌上', ['像球一樣沒有平面', '只有一個面', '不能分類'], '它們都有平面，所以放得住。'),
  _BankQ('球會滾，是因為？', '沒有平面', ['有 6 個正方形面', '有 8 個角', '它是平面圖形'], '球的表面是彎的，沒有可以站住的平面。'),
  _BankQ('圓柱放倒時會？', '滾動', ['變成三角形', '沒有底面', '不能移動'], '圓柱的側面是彎的，放倒可以滾。'),
  _BankQ('依「會不會滾」來分，球應該和誰一類？', '放倒的圓柱', ['正方體', '長方體', '一本平放的書'], '球和放倒的圓柱都會滾。'),
  _BankQ('數正方體的面，有幾個？', '6 個', ['4 個', '8 個', '12 個'], '前後、左右、上下，一共 6 個面。'),
  _BankQ('分類完最好再？', '數一數每一類有幾個', ['把標準忘掉', '只留下一類', '改量時間'], '數完才能說哪一類最多。'),
  _BankQ('同一個物品可以？', '用不同標準再分一次', ['只能分成一類以後不能再看', '沒有形狀', '一定是平面'], '可以先照會不會滾分，再照有沒有角分。'),
  _BankQ('長方體有幾個角？', '8 個', ['4 個', '6 個', '0 個'], '長方體和正方體一樣有 8 個角。'),
  _BankQ('哪一個不是立體形體？', '紙上畫的三角形', ['骰子', '茶葉罐', '球'], '畫在紙上的三角形是平面圖形。'),
  _BankQ('茶葉罐比較像？', '圓柱', ['正方體', '三角形', '一條線'], '茶葉罐上下是圓形，中間是彎彎的側面。'),
  _BankQ('兩類數量都是 4，表示？', '一樣多', ['立體比較多', '平面比較少', '不能記錄'], '數量相同就是一樣多。'),
  _BankQ('角是尖尖的地方。球有幾個角？', '0 個', ['1 個', '6 個', '8 個'], '球沒有尖角。'),
  _BankQ('把方盒和圓罐分開，是在做？', '分類', ['量公尺', '看月曆', '算乘法'], '依形體的不同把它們分開。'),
  _BankQ('記錄時一個物品只能？', '在同一個標準下進一類', ['同時算兩類又算三類', '不寫數量', '改成時間'], '標準定好以後，一個物品歸一類，數量才不會重複。'),
  _BankQ('長方體有幾個面？', '6 個', ['4 個', '8 個', '12 個'], '長方體有 6 個面。'),
  _BankQ('正方體有幾條邊？', '12 條', ['6 條', '8 條', '4 條'], '正方體有 12 條邊。'),
  _BankQ('球和正方體比，誰比較容易滾？', '球', ['正方體', '兩個都不會滾', '兩個都有平面'], '球沒有平面，所以比較容易滾。'),
  _BankQ('圓柱立起來可以？', '放穩', ['一定滾走', '變成三角形', '沒有底'], '圓柱直立時有平平的圓底。'),
];

const _fractionBank = [
  _BankQ('平分成 2 份，其中 1 份是？', '二分之一', ['四分之一', '一整個', '三分之一'], '分母 2 表示分成 2 份，分子 1 表示取 1 份。'),
  _BankQ('平分成 4 份，其中 1 份是？', '四分之一', ['二分之一', '四個', '四分之四'], '四份裡的一份讀作四分之一。'),
  _BankQ('平分成 8 份，其中 1 份是？', '八分之一', ['八分之八', '二分之一', '一整個'], '八份裡的一份是八分之一。'),
  _BankQ('分數裡下面的數在說？', '一共平分成幾份', ['拿走幾份', '有多重', '幾點鐘'], '分母表示全部被分成幾份。'),
  _BankQ('分數裡上面的數在說？', '拿了幾份', ['一共分成幾份', '單位是公尺', '是星期幾'], '分子表示取走的份數。'),
  _BankQ('沒有平分，每一份？', '不能都叫二分之一', ['還是一樣大', '一定是四分之一', '就是 1 公尺'], '要每份一樣大，才是分數說的一份。'),
  _BankQ('二分之一和另外二分之一合起來是？', '一整個', ['四分之一', '還是二分之一', '八分之一'], '兩個一半合起來是一個。'),
  _BankQ('四個四分之一合起來是？', '一整個', ['二分之一', '四分之四還不夠一個', '八分之一'], '四份都拿齊，就是整個。'),
  _BankQ('同一個披薩，四分之一和二分之一比，哪一份比較大？', '二分之一', ['四分之一', '一樣大', '不能比'], '一半比四份裡的一份多。'),
  _BankQ('把一條繩子平分成 3 份，一份是？', '三分之一', ['二分之一', '三公尺', '四分之一'], '三份裡的一份是三分之一。'),
  _BankQ('著色 1 份、一共 4 份，可以寫成？', '1/4', ['4/1', '1/2', '4/4'], '分子寫 1，分母寫 4。'),
  _BankQ('1/2 讀作？', '二分之一', ['一分之二', '一又二分', '十二'], '先讀分母，再讀分子。'),
  _BankQ('平分成 4 份後拿 2 份，是？', '四分之二', ['四分之一', '二分之四', '一整個再多一點'], '四份拿兩份，是四分之二，也和一半一樣大。'),
  _BankQ('單位分數是？', '分子是 1 的分數', ['分母是 1', '大於 1 的數', '只有 1/2'], '三分之一、四分之一都是單位分數。'),
  _BankQ('哪一個分法才看得到四分之一？', '四份一樣大', ['一大塊加三小塊', '沒有切開', '只切成兩半'], '每一份都要一樣大。'),
  _BankQ('八分之一比四分之一？', '小', ['大', '一樣', '不能比'], '分成的份數愈多，每一份就愈小。'),
  _BankQ('平分成 3 份，其中 1 份是？', '三分之一', ['二分之一', '四分之一', '三個'], '三份裡的一份是三分之一。'),
  _BankQ('分子是 1 的分數可以叫做？', '單位分數', ['整數', '公尺', '乘法'], '二分之一、四分之一都是單位分數。'),
  _BankQ('四份都拿齊，是？', '一整個', ['四分之一', '二分之一', '還不到一個'], '四個四分之一合起來是一個。'),
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
