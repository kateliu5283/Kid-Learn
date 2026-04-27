import 'package:flutter/material.dart';
import '../../curriculum/curriculum.dart';
import '../../models/lesson.dart';
import '../../widgets/kid_button.dart';
import 'lesson_study_screen.dart';

/// 預習畫面：介紹課程內容、重點、關鍵字詞，幫助學習前建立預期。
class PreviewScreen extends StatefulWidget {
  final Lesson lesson;

  const PreviewScreen({super.key, required this.lesson});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  int _currentStep = 0;

  List<String> get _objectives =>
      widget.lesson.objectives.isNotEmpty
          ? widget.lesson.objectives
          : _fallbackObjectives();

  List<String> _fallbackObjectives() {
    return [
      '認識「${widget.lesson.title}」的主要內容',
      widget.lesson.summary,
      '能正確完成本課的測驗',
    ];
  }

  List<String> get _keyPoints =>
      widget.lesson.keyPoints.isNotEmpty
          ? widget.lesson.keyPoints
          : _fallbackKeyPoints();

  List<String> _fallbackKeyPoints() {
    final lines = widget.lesson.content
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .take(4)
        .toList();
    return lines.isEmpty ? [widget.lesson.summary] : lines;
  }

  List<VocabItem> get _vocabulary => widget.lesson.vocabulary;

  @override
  Widget build(BuildContext context) {
    final subject = subjectById(widget.lesson.subjectId);
    final steps = <_Step>[
      _Step(
        title: '今天要學什麼？',
        icon: Icons.flag_rounded,
        builder: () => _buildObjectives(subject.color),
      ),
      _Step(
        title: '重點搶先看',
        icon: Icons.lightbulb_rounded,
        builder: () => _buildKeyPoints(subject.color),
      ),
      if (_vocabulary.isNotEmpty)
        _Step(
          title: '關鍵字詞',
          icon: Icons.auto_stories_rounded,
          builder: () => _buildVocab(subject.color),
        ),
    ];

    final current = steps[_currentStep];

    return Scaffold(
      appBar: AppBar(
        title: const Text('預習'),
        backgroundColor: subject.color.withValues(alpha: 0.12),
      ),
      body: Column(
        children: [
          _buildStepHeader(subject.color, steps),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(current.icon, color: subject.color, size: 26),
                      const SizedBox(width: 8),
                      Text(
                        current.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  current.builder(),
                ],
              ),
            ),
          ),
          _buildFooter(subject.color, steps.length),
        ],
      ),
    );
  }

  Widget _buildStepHeader(Color color, List<_Step> steps) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      color: color.withValues(alpha: 0.08),
      child: Row(
        children: List.generate(steps.length, (i) {
          final active = i <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == steps.length - 1 ? 0 : 6),
              height: 6,
              decoration: BoxDecoration(
                color: active ? color : color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildObjectives(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LessonCoverCard(lesson: widget.lesson),
        const SizedBox(height: 16),
        const Text(
          '學習目標',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        ..._objectives.asMap().entries.map((e) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${e.key + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.value,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildKeyPoints(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _keyPoints.map((p) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.12),
                color.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.star_rounded, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  p,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVocab(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _vocabulary.map((v) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  v.term,
                  style: TextStyle(
                    color: color,
                    fontSize: v.term.length > 2 ? 16 : 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.meaning,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (v.example != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        v.example!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(Color color, int total) {
    final isLast = _currentStep >= total - 1;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('上一步'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => setState(() => _currentStep--),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: KidButton(
                label: isLast ? '開始學習' : '下一步',
                icon: isLast
                    ? Icons.play_arrow_rounded
                    : Icons.arrow_forward,
                color: color,
                expanded: true,
                onPressed: () {
                  if (isLast) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) =>
                            LessonStudyScreen(lesson: widget.lesson),
                      ),
                    );
                  } else {
                    setState(() => _currentStep++);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step {
  final String title;
  final IconData icon;
  final Widget Function() builder;

  _Step({required this.title, required this.icon, required this.builder});
}

/// 預習時用的課程封面卡片
class _LessonCoverCard extends StatelessWidget {
  final Lesson lesson;
  const _LessonCoverCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final subject = subjectById(lesson.subjectId);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [subject.color, subject.color.withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(subject.icon, color: Colors.white, size: 22),
              const SizedBox(width: 6),
              Text(
                '${subject.name} · ${lesson.grade} 年級',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            lesson.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lesson.summary,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.schedule, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                '約 ${lesson.estimatedMinutes} 分鐘',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.quiz, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                '${lesson.questions.length} 題',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
