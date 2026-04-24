enum QuestionType { multipleChoice, trueFalse, fillBlank }

class Question {
  final String id;
  final QuestionType type;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String? imageAsset;

  const Question({
    required this.id,
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.imageAsset,
  });

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}
