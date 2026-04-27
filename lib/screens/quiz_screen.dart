import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../curriculum/curriculum.dart';
import '../models/lesson.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/kid_button.dart';

class QuizScreen extends StatefulWidget {
  final Lesson lesson;

  const QuizScreen({super.key, required this.lesson});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _revealed = false;
  bool _showResult = false;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subject = subjectById(widget.lesson.subjectId);

    if (_showResult) {
      return _buildResultScreen(context, subject.color);
    }

    final question = widget.lesson.questions[_index];
    final total = widget.lesson.questions.length;
    final answered = _revealed;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.lesson.title}（${_index + 1}/$total）'),
        backgroundColor: subject.color.withOpacity(0.1),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / total,
            backgroundColor: subject.color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(subject.color),
            minHeight: 6,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '第 ${_index + 1} 題',
                          style: TextStyle(
                            color: subject.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question.prompt,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(question.options.length, (i) {
                  final isCorrect = i == question.correctIndex;
                  final isSelected = _selected == i;
                  Color bgColor = Colors.white;
                  Color borderColor = Colors.grey.shade300;
                  Color textColor = Colors.black87;

                  if (answered) {
                    if (isCorrect) {
                      bgColor = const Color(0xFFE8F5E9);
                      borderColor = AppTheme.successColor;
                    } else if (isSelected) {
                      bgColor = const Color(0xFFFFEBEE);
                      borderColor = AppTheme.errorColor;
                    }
                  } else if (isSelected) {
                    bgColor = subject.color.withOpacity(0.1);
                    borderColor = subject.color;
                    textColor = subject.color;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: answered
                          ? null
                          : () => setState(() => _selected = i),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: borderColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                String.fromCharCode(65 + i),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                question.options[i],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                            if (answered && isCorrect)
                              const Icon(Icons.check_circle,
                                  color: AppTheme.successColor),
                            if (answered && isSelected && !isCorrect)
                              const Icon(Icons.cancel,
                                  color: AppTheme.errorColor),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (answered && question.explanation != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb,
                            color: Colors.amber, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            question.explanation!,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: KidButton(
              expanded: true,
              color: subject.color,
              icon: answered ? Icons.arrow_forward : Icons.check,
              label: answered
                  ? (_index + 1 == total ? '看結果' : '下一題')
                  : '確認答案',
              onPressed: _selected == null
                  ? null
                  : () {
                      if (!answered) {
                        setState(() {
                          if (question.isCorrect(_selected!)) _score++;
                          _revealed = true;
                        });
                      } else {
                        if (_index + 1 == total) {
                          _finish();
                        } else {
                          setState(() {
                            _index++;
                            _selected = null;
                            _revealed = false;
                          });
                        }
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  void _finish() async {
    await context.read<ProgressProvider>().setLessonResult(
          lessonId: widget.lesson.id,
          score: _score,
          total: widget.lesson.questions.length,
        );
    if (!mounted) return;
    setState(() => _showResult = true);
    _confetti.play();
  }

  Widget _buildResultScreen(BuildContext context, Color color) {
    final total = widget.lesson.questions.length;
    final ratio = total == 0 ? 0 : _score / total;
    final stars = ratio >= 0.9
        ? 3
        : ratio >= 0.7
            ? 2
            : ratio >= 0.5
                ? 1
                : 0;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      stars >= 2 ? '太棒了！🎉' : '再接再厲！💪',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              3,
                              (i) => Icon(
                                i < stars ? Icons.star : Icons.star_border,
                                size: 56,
                                color: i < stars
                                    ? Colors.amber
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$_score / $total',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '正確率 ${(ratio * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _index = 0;
                                _score = 0;
                                _selected = null;
                                _revealed = false;
                                _showResult = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('再試一次'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: KidButton(
                            label: '完成',
                            icon: Icons.home,
                            color: color,
                            expanded: true,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
            maxBlastForce: 20,
            gravity: 0.3,
          ),
        ],
      ),
    );
  }
}
