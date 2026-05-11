import '../../models/lesson.dart';
import '../../models/question.dart';
import 'lesson_108_helpers.dart';

/// 數學 3～6 年級：每學期 6 單元，主題對齊 108 課綱數學領域常見學習內容（數與量、幾何、關係、統計與機率等）。
List<Lesson> buildMathUpperPrimaryLessons() {
  final specs = <_MathSpec>[
    // 三年級
    _MathSpec(3, 1, 1, '三位數的加減', '直式計算與併式', '學習三位數的進位加法與退位減法，並能檢查答案是否合理。', 'addsub'),
    _MathSpec(3, 1, 2, '乘法（一）', '一位數乘兩、三位數', '理解乘法意義，熟練一位數乘兩、三位數。', 'mul'),
    _MathSpec(3, 1, 3, '除法（一）', '除法與餘數', '認識除法直式，理解餘數須小於除數。', 'div'),
    _MathSpec(3, 1, 4, '角與形', '角的大小、三角形與四邊形', '能用半圓規量角，辨認直角、鋭角、鈍角。', 'geo'),
    _MathSpec(3, 1, 5, '分數（一）', '同分母分數', '理解單位分數與同分母分數的加減。', 'frac'),
    _MathSpec(3, 1, 6, '公升與毫升', '容量', '能讀刻度並換算 1 公升 = 1000 毫升。', 'measure'),
    _MathSpec(3, 2, 1, '乘法（二）', '兩位數相乘', '學習兩位數乘兩位數的直式計算。', 'mul2'),
    _MathSpec(3, 2, 2, '除法（二）', '除數為兩位數', '學習除數為兩位數的除法與估商。', 'div2'),
    _MathSpec(3, 2, 3, '公斤與公克', '重量', '能換算公斤與公克，並解決生活問題。', 'measure'),
    _MathSpec(3, 2, 4, '面積（一）', '平方公分', '能用方格紙或乘法算面積。', 'area'),
    _MathSpec(3, 2, 5, '年、月、日與時間', '24 小時制', '能讀出幾時幾分並換算 24 小時制。', 'time'),
    _MathSpec(3, 2, 6, '統計圖表', '條形圖', '能製作與解讀條形圖。', 'data'),
    // 四年級
    _MathSpec(4, 1, 1, '大數與位值', '萬、億', '理解位值系統，能讀寫大數。', 'num'),
    _MathSpec(4, 1, 2, '四則混合', '併式與括號', '理解先乘除後加減與括號的運算順序。', 'mix'),
    _MathSpec(4, 1, 3, '分數（二）', '異分母加減', '通分後再加減。', 'frac'),
    _MathSpec(4, 1, 4, '小數（一）', '一位小數', '理解小數意義與一位小數的加減。', 'dec'),
    _MathSpec(4, 1, 5, '角度與垂直平行', '角與線', '辨認垂直、平行與角的大小關係。', 'geo'),
    _MathSpec(4, 1, 6, '面積（二）', '長方形與正方形', '用長×寬算面積並解題。', 'area'),
    _MathSpec(4, 2, 1, '概數', '四捨五入', '能用四捨五入取概數。', 'round'),
    _MathSpec(4, 2, 2, '兩步驟問題', '解題策略', '能列式解兩步驟以上的問題。', 'word'),
    _MathSpec(4, 2, 3, '小數（二）', '兩位小數', '兩位小數的加減與大小比較。', 'dec'),
    _MathSpec(4, 2, 4, '圓', '圓心、半徑、直徑', '認識圓的要素與圓周長入門。', 'geo'),
    _MathSpec(4, 2, 5, '折線圖', '統計', '能解讀折線圖的變化趨勢。', 'data'),
    _MathSpec(4, 2, 6, '規律與關係', '數列規律', '能找出數列規律並延伸。', 'pattern'),
    // 五年級
    _MathSpec(5, 1, 1, '倍數與因數', '質數與合數', '理解質因數分解與公因數、公倍數。', 'factor'),
    _MathSpec(5, 1, 2, '分數除法', '分數除以整數', '理解分數除法的意義與計算。', 'fracdiv'),
    _MathSpec(5, 1, 3, '小數乘法', '小數相乘', '小數乘法的直式與位值理解。', 'muld'),
    _MathSpec(5, 1, 4, '面積（三）', '三角形、平行四邊形', '用公式求面積。', 'area'),
    _MathSpec(5, 1, 5, '體積', '立方公分', '長方體體積 = 長×寬×高。', 'vol'),
    _MathSpec(5, 1, 6, '比率與百分率', '入門', '認識「比」與百分率的生活應用。', 'ratio'),
    _MathSpec(5, 2, 1, '小數除法', '除到小數', '能處理除不盡與四捨五入。', 'divd'),
    _MathSpec(5, 2, 2, '立體圖形', '角柱與角錐', '辨認展開圖與形體。', 'solid'),
    _MathSpec(5, 2, 3, '整數的四則運算', '正負入門（選讀）', '初步認識負數與數線（依學校進度調整）。', 'int'),
    _MathSpec(5, 2, 4, '可能性', '機率入門', '能描述事件發生的可能性大小。', 'prob'),
    _MathSpec(5, 2, 5, '速率', '路程時間', '認識速率 = 路程÷時間。', 'rate'),
    _MathSpec(5, 2, 6, '解題統整', '綜合應用', '統整分數、小數與幾何解題。', 'word'),
    // 六年級
    _MathSpec(6, 1, 1, '分數的四則', '混合運算', '熟練分數加減乘除混合運算。', 'fracmix'),
    _MathSpec(6, 1, 2, '比與比例', '比例式', '能列比例式並解題。', 'prop'),
    _MathSpec(6, 1, 3, '小數與分數', '互換與比較', '能在小數與分數間轉換並比大小。', 'conv'),
    _MathSpec(6, 1, 4, '圓面積與圓周長', 'π 的應用', '理解圓周長與面積公式。', 'circle'),
    _MathSpec(6, 1, 5, '柱體體積', '角柱', '底面積×高。', 'vol'),
    _MathSpec(6, 1, 6, '統計與平均數', '平均數、中位數', '能計算並解釋平均數。', 'data'),
    _MathSpec(6, 2, 1, '兩量關係', '正比與反比入門', '能從表格判變化關係。', 'rel'),
    _MathSpec(6, 2, 2, '速率與比', '綜合應用', '結合比、比例與速率解題。', 'rate'),
    _MathSpec(6, 2, 3, '規律與代數', '符號表示式', '能用符號表示數量關係。', 'alg'),
    _MathSpec(6, 2, 4, '縮放與比例尺', '圖形放大縮小', '認識比例尺與相似概念。', 'scale'),
    _MathSpec(6, 2, 5, '數學解題策略', '假設、列表、逆推', '能選擇合適策略解題。', 'word'),
    _MathSpec(6, 2, 6, '總複習', '銜接國中', '統整六年級重要概念。', 'rev'),
  ];

  return [
    for (final s in specs)
      lesson108Core(
        id: 'ex-ma-${s.grade}-${s.semester}-${s.unit}',
        subjectId: 'math',
        grade: s.grade,
        semester: s.semester == 1 ? Semester.first : Semester.second,
        unit: s.unit,
        title: s.title,
        summary: s.summary,
        content: '${s.content}\n\n${_semIntro(s.grade, s.semester)}\n重點：${s.summary}。',
        questions: _mathQuestions(s),
      ),
  ];
}

String _semIntro(int grade, int sem) {
  final s = sem == 1 ? '上學期' : '下學期';
  return '國小 $grade 年級數學 $s。';
}

class _MathSpec {
  _MathSpec(
    this.grade,
    this.semester,
    this.unit,
    this.title,
    this.summary,
    this.content,
    this.kind,
  );
  final int grade;
  final int semester;
  final int unit;
  final String title;
  final String summary;
  final String content;
  final String kind;
}

List<Question> _mathQuestions(_MathSpec s) {
  final lid = 'ex-ma-${s.grade}-${s.semester}-${s.unit}';
  switch (s.kind) {
    case 'mul':
      return [
        Question(
          id: '${lid}-q1',
          type: QuestionType.multipleChoice,
          prompt: '12 × 3 = ？',
          options: ['33', '36', '39', '42'],
          correctIndex: 1,
        ),
        Question(
          id: '${lid}-q2',
          type: QuestionType.multipleChoice,
          prompt: '下列哪一個式子表示「6 的 4 倍」？',
          options: ['6 + 4', '6 ÷ 4', '6 × 4', '6 − 4'],
          correctIndex: 2,
        ),
      ];
    case 'div':
      return [
        Question(
          id: '${lid}-q1',
          type: QuestionType.multipleChoice,
          prompt: '17 ÷ 5 的餘數是？',
          options: ['0', '1', '2', '3'],
          correctIndex: 2,
        ),
        Question(
          id: '${lid}-q2',
          type: QuestionType.multipleChoice,
          prompt: '餘數一定？',
          options: ['大於除數', '等於除數', '小於除數', '等於被除數'],
          correctIndex: 2,
        ),
      ];
    case 'frac':
      return [
        Question(
          id: '${lid}-q1',
          type: QuestionType.multipleChoice,
          prompt: '1/5 + 2/5 = ？',
          options: ['2/10', '3/5', '3/10', '1/5'],
          correctIndex: 1,
        ),
        Question(
          id: '${lid}-q2',
          type: QuestionType.multipleChoice,
          prompt: '同分母分數相加時，分母會？',
          options: ['相加', '相減', '不變', '相乘'],
          correctIndex: 2,
        ),
      ];
    case 'area':
      return [
        Question(
          id: '${lid}-q1',
          type: QuestionType.multipleChoice,
          prompt: '長 5 公分、寬 4 公分的長方形面積是？',
          options: ['9 平方公分', '18 平方公分', '20 平方公分', '24 平方公分'],
          correctIndex: 2,
        ),
        Question(
          id: '${lid}-q2',
          type: QuestionType.multipleChoice,
          prompt: '面積單位「平方公分」可寫成？',
          options: ['cm', 'cm²', 'g', 'mL'],
          correctIndex: 1,
        ),
      ];
    case 'circle':
      return [
        Question(
          id: '${lid}-q1',
          type: QuestionType.multipleChoice,
          prompt: '圓周長大約是直徑的幾倍？',
          options: ['2 倍', '3 倍', 'π 倍', '10 倍'],
          correctIndex: 2,
        ),
        Question(
          id: '${lid}-q2',
          type: QuestionType.multipleChoice,
          prompt: '半徑 3 公分的圓，直徑是？',
          options: ['3', '6', '9', '12'],
          correctIndex: 1,
        ),
      ];
    case 'prop':
      return [
        Question(
          id: '${lid}-q1',
          type: QuestionType.multipleChoice,
          prompt: '2 : 3 等於下列哪一組比？',
          options: ['4 : 5', '4 : 6', '5 : 6', '3 : 2'],
          correctIndex: 1,
        ),
        Question(
          id: '${lid}-q2',
          type: QuestionType.multipleChoice,
          prompt: '比例式中，內項之積與外項之積？',
          options: ['一定不相等', '不一定相等', '一定相等', '永遠是 0'],
          correctIndex: 2,
        ),
      ];
    default:
      return mcqPairFor108Unit(
        lessonId: lid,
        title: s.title,
        summary: s.summary,
      );
  }
}
