import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum_data.dart';
import '../../data/review_question_pool.dart';
import '../../providers/progress_provider.dart';
import '../../services/remote_question_repository.dart';
import 'review_screen.dart';

/// 每日複習：按學科分區，讓小朋友針對「已學過的課 + 延伸題庫」做綜合練習。
class DailyReviewHub extends StatelessWidget {
  const DailyReviewHub({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final grade = progress.profile.grade;
    final remote = _safeRemote(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('每日複習'),
        actions: [
          if (remote != null)
            IconButton(
              icon: const Icon(Icons.cloud_sync),
              tooltip: '同步雲端題庫',
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('同步中...')),
                );
                final ok = await remote.syncFromServer();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? '已同步 ${remote.questionCount} 題雲端題庫'
                          : '同步失敗，已使用本地題庫'),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (remote != null && remote.isReady)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_done, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '雲端題庫已載入（${remote.questionCount} 題）',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome,
                    color: Colors.white, size: 36),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '每天練 10 題\n讓學過的知識記得更牢！',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildMixedCard(context, grade),
          const SizedBox(height: 20),
          const Text(
            '依學科複習',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...kSubjects.map((s) {
            final subjectLessons = lessonsForSubject(s.id)
                .where((l) => l.grade == grade)
                .toList();
            final completed = subjectLessons
                .where((l) => progress.progressOf(l.id).completed)
                .length;
            final pool = getReviewPool(s.id, grade);
            final totalQ = pool.length +
                subjectLessons.fold<int>(
                    0, (sum, l) => sum + l.questions.length);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildSubjectCard(
                context,
                s.id,
                s.name,
                s.icon,
                s.color,
                completed: completed,
                totalLessons: subjectLessons.length,
                totalQuestions: totalQ,
                grade: grade,
              ),
            );
          }),
        ],
      ),
    );
  }

  RemoteQuestionRepository? _safeRemote(BuildContext context) {
    try {
      return context.watch<RemoteQuestionRepository>();
    } catch (_) {
      return null;
    }
  }

  Widget _buildMixedCard(BuildContext context, int grade) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ReviewScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFA726), Color(0xFFFFD54F)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.shuffle,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '綜合複習（推薦）',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '混合所有學科、隨機 10 題',
                      style: TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    String subjectId,
    String name,
    IconData icon,
    Color color, {
    required int completed,
    required int totalLessons,
    required int totalQuestions,
    required int grade,
  }) {
    final disabled = totalQuestions == 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: disabled
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReviewScreen(
                      subjectId: subjectId,
                      grade: grade,
                    ),
                  ),
                );
              },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: disabled
                  ? Colors.grey.shade200
                  : color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      disabled
                          ? '尚無題目'
                          : '已完成 $completed / $totalLessons 課　·　題庫 $totalQuestions 題',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                disabled ? Icons.lock : Icons.arrow_forward_ios,
                color: disabled ? Colors.grey : color,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
