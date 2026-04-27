import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../curriculum/curriculum.dart';
import '../../models/lesson.dart';
import '../../models/question.dart';
import '../../providers/progress_provider.dart';
import '../../services/remote_question_repository.dart';
import '../../widgets/kid_button.dart';

/// 複習畫面：摘要重點 + 綜合題（該課題目 + 延伸題庫），幫助鞏固記憶。
/// 若 lesson 為 null，表示「每日複習」：從學過的課程混合出題。
class ReviewScreen extends StatefulWidget {
  final Lesson? lesson;

  /// 每日複習模式下可指定的學科／年級；若沒傳則用目前 profile
  final String? subjectId;
  final int? grade;

  const ReviewScreen({
    super.key,
    this.lesson,
    this.subjectId,
    this.grade,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final List<Question> _questions;
  final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 2));

  int _currentIdx = 0;
  int? _selected;
  bool _revealed = false;
  int _score = 0;
  bool _finished = false;
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions();
  }

  List<Question> _buildQuestions() {
    final rnd = Random();
    final remoteRepo = _safeRemoteRepo();

    if (widget.lesson != null) {
      final l = widget.lesson!;
      final extra = getReviewPool(l.subjectId, l.grade);
      final remote = remoteRepo?.questionsFor(
            subject: l.subjectId,
            grade: l.grade,
            count: 20,
          ) ??
          const <Question>[];
      final combined = [...l.questions, ...extra, ...remote];
      combined.shuffle(rnd);
      return combined.take(min(10, combined.length)).toList();
    }
    // 每日複習
    final progress = context.read<ProgressProvider>();
    final profile = progress.profile;
    final grade = widget.grade ?? profile.grade;

    final pool = <Question>[];
    // 1. 從已學過的課程抽題
    final learned = kLessons.where((l) {
      if (widget.subjectId != null && l.subjectId != widget.subjectId) {
        return false;
      }
      return progress.progressOf(l.id).completed;
    });
    for (final l in learned) {
      pool.addAll(l.questions);
    }
    // 2. 補一些該年級延伸題庫（本地）
    final subjectIds = widget.subjectId != null
        ? [widget.subjectId!]
        : kSubjects.map((s) => s.id);
    for (final sid in subjectIds) {
      pool.addAll(getReviewPool(sid, grade));
    }
    // 3. 再加上遠端題庫（若有載入）
    if (remoteRepo != null) {
      for (final sid in subjectIds) {
        pool.addAll(remoteRepo.questionsFor(
          subject: sid,
          grade: grade,
          count: 20,
        ));
      }
    }

    pool.shuffle(rnd);
    return pool.take(min(10, pool.length)).toList();
  }

  RemoteQuestionRepository? _safeRemoteRepo() {
    try {
      final repo = context.read<RemoteQuestionRepository>();
      return repo.isReady ? repo : null;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _answer(int idx) {
    if (_revealed) return;
    setState(() {
      _selected = idx;
      _revealed = true;
      if (_questions[_currentIdx].isCorrect(idx)) {
        _score++;
      }
    });
  }

  void _next() async {
    if (_currentIdx < _questions.length - 1) {
      setState(() {
        _currentIdx++;
        _selected = null;
        _revealed = false;
      });
    } else {
      setState(() => _finished = true);
      _confetti.play();
      // 如果是單課複習，把進度也順便記錄
      if (widget.lesson != null) {
        await context.read<ProgressProvider>().setLessonResult(
              lessonId: widget.lesson!.id,
              score: _score,
              total: _questions.length,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final accent = lesson != null
        ? subjectById(lesson.subjectId).color
        : Theme.of(context).colorScheme.primary;

    if (_questions.isEmpty) {
      return _buildEmptyState(accent);
    }

    if (_showIntro && lesson != null) {
      return _buildIntro(lesson, accent);
    }

    if (_finished) {
      return _buildResult(accent);
    }

    return _buildQuiz(accent);
  }

  Widget _buildEmptyState(Color color) {
    return Scaffold(
      appBar: AppBar(title: const Text('複習')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_stories_rounded,
                  size: 80, color: color.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              const Text(
                '還沒有題目可以複習！',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                '先完成幾課再來複習吧～',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro(Lesson lesson, Color color) {
    final keyPoints = lesson.keyPoints.isNotEmpty
        ? lesson.keyPoints
        : (lesson.summary.isNotEmpty ? [lesson.summary] : <String>[]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('複習'),
        backgroundColor: color.withValues(alpha: 0.12),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.replay_rounded,
                    color: Colors.white, size: 28),
                const SizedBox(height: 6),
                Text(
                  '複習：${lesson.title}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '回顧重點，再練習 ${_questions.length} 題挑戰',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (keyPoints.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('重點回顧',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...keyPoints.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(p,
                            style: const TextStyle(
                                fontSize: 15, height: 1.5)),
                      ),
                    ],
                  ),
                )),
          ],
          if (lesson.vocabulary.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('重要字詞',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: lesson.vocabulary
                  .map((v) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.term,
                              style: TextStyle(
                                color: color,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              v.meaning,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),
          KidButton(
            label: '開始複習挑戰',
            icon: Icons.play_arrow_rounded,
            color: color,
            expanded: true,
            onPressed: () => setState(() => _showIntro = false),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz(Color color) {
    final q = _questions[_currentIdx];
    final progress = (_currentIdx + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('複習 ${_currentIdx + 1} / ${_questions.length}'),
        backgroundColor: color.withValues(alpha: 0.12),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Q${_currentIdx + 1}',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            q.prompt,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(q.options.length, (i) {
                    final selected = _selected == i;
                    final isCorrect = q.correctIndex == i;
                    Color borderColor = Colors.grey.shade300;
                    Color bgColor = Colors.white;
                    if (_revealed) {
                      if (isCorrect) {
                        borderColor = const Color(0xFF43A047);
                        bgColor = const Color(0xFFE8F5E9);
                      } else if (selected) {
                        borderColor = const Color(0xFFE53935);
                        bgColor = const Color(0xFFFFEBEE);
                      }
                    } else if (selected) {
                      borderColor = color;
                      bgColor = color.withValues(alpha: 0.08);
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _answer(i),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: borderColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  String.fromCharCode(65 + i),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  q.options[i],
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (_revealed && isCorrect)
                                const Icon(Icons.check_circle,
                                    color: Color(0xFF43A047)),
                              if (_revealed && selected && !isCorrect)
                                const Icon(Icons.cancel,
                                    color: Color(0xFFE53935)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_revealed && q.explanation != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb,
                              color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              q.explanation!,
                              style: const TextStyle(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(_currentIdx < _questions.length - 1
                      ? Icons.arrow_forward
                      : Icons.flag),
                  label: Text(_currentIdx < _questions.length - 1
                      ? '下一題'
                      : '看結果'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _revealed ? _next : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(Color color) {
    final ratio = _score / _questions.length;
    final level = ratio >= 0.9
        ? '太棒了！'
        : ratio >= 0.7
            ? '很不錯！'
            : ratio >= 0.5
                ? '再加油！'
                : '多練習會更好！';
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.7)],
                      ),
                    ),
                    child: const Icon(Icons.emoji_events,
                        color: Colors.white, size: 64),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    level,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '答對 $_score / ${_questions.length} 題',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Icon(
                        i < (ratio >= 0.9 ? 3 : ratio >= 0.7 ? 2 : ratio >= 0.5 ? 1 : 0)
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.home),
                      label: const Text('完成'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
            shouldLoop: false,
            colors: const [
              Colors.amber,
              Colors.deepPurple,
              Colors.lightBlue,
              Colors.pinkAccent,
              Colors.green,
            ],
          ),
        ],
      ),
    );
  }
}
