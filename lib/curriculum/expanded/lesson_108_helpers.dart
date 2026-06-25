import '../../models/lesson.dart';
import '../../models/question.dart';

/// 未另填 vocabulary 時，依單元標題產生三筆通用字詞卡（預習／複習畫面可用）。
List<VocabItem> default108Vocabulary(String title, {String subjectId = ''}) {
  final anchor = title.length > 18 ? title.substring(0, 18) : title;
  final domain = switch (subjectId) {
    'english' => '英語文',
    'science' => '自然',
    'social' => '社會',
    'life' => '綜合活動',
    'math' => '數學',
    'chinese' => '國語文',
    _ => '學習內容',
  };
  return [
    VocabItem(term: anchor, meaning: '本單元主題詞', example: '對照課本目標與活動'),
    VocabItem(term: domain, meaning: '本課所屬學習領域', example: '呼應 108 課綱素養導向'),
    VocabItem(term: '學習單', meaning: '引導探究或練習的工作紙', example: '依題序完成並自我檢核'),
  ];
}

/// 108 課綱擴充單元：共用簡短測驗（每單元 2 題選擇），避免重複撰寫數百份完全相同題型。
List<Question> mcqPairFor108Unit({
  required String lessonId,
  required String title,
  required String summary,
}) {
  final hint = summary.length > 28 ? '${summary.substring(0, 28)}…' : summary;
  return [
    Question(
      id: '${lessonId}-q1',
      type: QuestionType.multipleChoice,
      prompt: '「$title」這個單元主要在學什麼？',
      options: [
        hint,
        '與本單元主題無關的內容',
        '只要背答案不必理解',
        '只練習考試技巧',
      ],
      correctIndex: 0,
      explanation: '請對照單元摘要與課文重點複習。',
    ),
    Question(
      id: '${lessonId}-q2',
      type: QuestionType.multipleChoice,
      prompt: '學習這個單元時，較符合 108 課綱「自主行動」精神的作法是？',
      options: [
        '被動抄寫不思考',
        '主動提問並連結生活經驗',
        '完全不做練習',
        '只依賴家長代寫',
      ],
      correctIndex: 1,
      explanation: '能提問、連結生活，有助於真正理解與應用。',
    ),
  ];
}

Lesson lesson108Core({
  required String id,
  required String subjectId,
  required int grade,
  required Semester semester,
  required int unit,
  required String title,
  required String summary,
  required String content,
  List<String>? objectives,
  List<String>? keyPoints,
  List<VocabItem>? vocabulary,
  List<Question>? questions,
  int estimatedMinutes = 10,
}) {
  return Lesson(
    id: id,
    subjectId: subjectId,
    grade: grade,
    track: CurriculumTrack.core,
    semester: semester,
    unit: unit,
    title: title,
    summary: summary,
    content: content,
    estimatedMinutes: estimatedMinutes,
    objectives: objectives ??
        [
          '理解「$title」的核心概念與關鍵詞彙',
          '能於生活或學習情境中舉例並說明所學',
          '能與同儕合作完成探究或發表並自我檢核',
        ],
    keyPoints: keyPoints ??
        [
          '本單元對應國小 $grade 年級課程綱要之學習內容',
          '建議搭配圖表、實例與討論加深理解',
          '整理筆記有助複習與遷移應用',
        ],
    vocabulary: vocabulary ?? default108Vocabulary(title, subjectId: subjectId),
    questions: questions ?? mcqPairFor108Unit(lessonId: id, title: title, summary: summary),
  );
}
