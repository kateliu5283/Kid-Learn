import '../../models/lesson.dart';
import '../../models/question.dart';

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
          '理解「$title」的核心概念',
          '能於生活或學習情境中辨識相關例子',
        ],
    keyPoints: keyPoints ??
        [
          '本單元對應國小${grade}年級課程綱要之學習內容',
          '各版本教材用語可能不同，重點概念相通',
        ],
    vocabulary: vocabulary ?? const [],
    questions: questions ?? mcqPairFor108Unit(lessonId: id, title: title, summary: summary),
  );
}
