import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/curriculum_data.dart';
import '../models/lesson.dart';
import '../providers/progress_provider.dart';
import 'lesson/preview_screen.dart';
import 'lesson/lesson_study_screen.dart';
import 'lesson/review_screen.dart';
import 'quiz_screen.dart';

/// 課程首頁：步驟式導覽 —— 預習 → 學習 → 測驗 → 複習
class LessonDetailScreen extends StatelessWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final subject = subjectById(lesson.subjectId);
    final progress = context.watch<ProgressProvider>().progressOf(lesson.id);
    final hasStudied = progress.completed;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        backgroundColor: subject.color.withValues(alpha: 0.12),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(subject.color),
          const SizedBox(height: 16),
          if (hasStudied) _buildProgressCard(progress.lastScore, progress.stars),
          if (hasStudied) const SizedBox(height: 16),
          const Text(
            '學習流程',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _StepCard(
            step: 1,
            title: '預習',
            subtitle: '學習目標、重點搶先看、關鍵字詞',
            icon: Icons.visibility_rounded,
            color: const Color(0xFF42A5F5),
            badge: lesson.vocabulary.isNotEmpty
                ? '${lesson.vocabulary.length} 個字詞'
                : null,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PreviewScreen(lesson: lesson),
                ),
              );
            },
          ),
          _StepCard(
            step: 2,
            title: '學習',
            subtitle: '閱讀課程內容、TTS 朗讀',
            icon: Icons.menu_book_rounded,
            color: const Color(0xFF66BB6A),
            badge: '約 ${lesson.estimatedMinutes} 分鐘',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LessonStudyScreen(lesson: lesson),
                ),
              );
            },
          ),
          _StepCard(
            step: 3,
            title: '測驗',
            subtitle: '檢驗學習成果',
            icon: Icons.quiz_rounded,
            color: const Color(0xFFFFA726),
            badge: '${lesson.questions.length} 題',
            disabled: lesson.questions.isEmpty,
            onTap: lesson.questions.isEmpty
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(lesson: lesson),
                      ),
                    );
                  },
          ),
          _StepCard(
            step: 4,
            title: '複習',
            subtitle: '重點回顧 + 混合題挑戰',
            icon: Icons.replay_rounded,
            color: const Color(0xFFEF5350),
            badge: hasStudied ? '建議進行' : '先完成測驗',
            highlighted: hasStudied,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReviewScreen(lesson: lesson),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            children: [
              _chip('${lesson.grade} 年級'),
              if (lesson.track != CurriculumTrack.general)
                _chip(lesson.editionLabel),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            lesson.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lesson.summary,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildProgressCard(int lastScore, int stars) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF43A047)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF43A047), size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '上次成績 $lastScore / ${lesson.questions.length} 分',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (i) => Icon(
                i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                color: Colors.amber,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? badge;
  final bool highlighted;
  final bool disabled;
  final VoidCallback? onTap;

  const _StepCard({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.badge,
    this.highlighted = false,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: disabled ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: disabled
                  ? Colors.grey.shade100
                  : (highlighted
                      ? color.withValues(alpha: 0.08)
                      : Colors.white),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: disabled
                    ? Colors.grey.shade200
                    : (highlighted
                        ? color
                        : color.withValues(alpha: 0.3)),
                width: highlighted ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: disabled
                        ? null
                        : LinearGradient(
                            colors: [color, color.withValues(alpha: 0.7)],
                          ),
                    color: disabled ? Colors.grey.shade200 : null,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon,
                      color: disabled ? Colors.grey : Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: disabled
                                  ? Colors.grey.shade300
                                  : color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'STEP $step',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: disabled ? Colors.grey : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: disabled
                              ? Colors.grey
                              : Colors.grey.shade600,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: disabled
                                ? Colors.grey.shade200
                                : color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              color: disabled ? Colors.grey : color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  disabled ? Icons.lock : Icons.chevron_right,
                  color: disabled ? Colors.grey : color,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
