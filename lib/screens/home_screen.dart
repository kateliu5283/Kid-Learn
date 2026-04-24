import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/curriculum_data.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/subject_card.dart';
import '../widgets/progress_ring.dart';
import 'lesson_list_screen.dart';
import 'lesson_detail_screen.dart';
import 'games/memory_match_game.dart';
import 'games/math_blitz_game.dart';
import 'games/word_rain_game.dart';
import 'handwriting/handwriting_hub_screen.dart';
import 'lesson/daily_review_hub.dart';
import 'profile/profile_select_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final profile = progress.profile;
    final quote =
        kDailyQuotes[DateTime.now().day % kDailyQuotes.length];

    final todayLesson = _pickTodayLesson(profile.grade);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, profile.name, profile.avatar, profile.grade),
            const SizedBox(height: 16),
            _buildStatCard(context, progress),
            const SizedBox(height: 16),
            _buildQuoteCard(quote),
            const SizedBox(height: 20),
            _buildDailyReviewCard(context),
            const SizedBox(height: 20),
            const Text(
              '今日任務',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (todayLesson != null)
              _buildTodayLessonCard(context, todayLesson),
            const SizedBox(height: 20),
            const Text(
              '小遊戲',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _buildGamesRow(context),
            const SizedBox(height: 20),
            const Text(
              '學科',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kSubjects.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, i) {
                final subject = kSubjects[i];
                final lessons = lessonsForSubject(subject.id)
                    .where((l) => l.grade == profile.grade)
                    .map((l) => l.id);
                final subjProgress =
                    progress.subjectProgress(lessons.toList());
                return SubjectCard(
                  subject: subject,
                  progress: subjProgress,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonListScreen(
                          subject: subject,
                          grade: profile.grade,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, String name, String avatar, int grade) {
    final hasMultiple =
        context.watch<ProgressProvider>().profiles.length > 1;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const ProfileSelectScreen(goToMainAfterSelect: false),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(avatar, style: const TextStyle(fontSize: 30)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Hi, $name 👋',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (hasMultiple) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.swap_horiz,
                            color: AppTheme.primaryColor, size: 20),
                      ],
                    ],
                  ),
                  Text(
                    '國小 $grade 年級${hasMultiple ? ' · 點擊切換' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_rounded),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, ProgressProvider progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ProgressRing(
              progress: kLessons.isEmpty
                  ? 0
                  : progress.completedCount / kLessons.length,
              color: AppTheme.primaryColor,
              size: 72,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '學習進度',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '已完成 ${progress.completedCount} / ${kLessons.length} 單元',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        '${progress.totalStars} 顆星',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(String quote) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_rounded,
              color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyReviewCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DailyReviewHub()),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '每日複習',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '綜合複習 10 題，學過的記得更牢',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayLessonCard(BuildContext context, todayLesson) {
    final subject = subjectById(todayLesson.subjectId);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LessonDetailScreen(lesson: todayLesson),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: subject.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(subject.icon, color: subject.color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${subject.name} · 推薦',
                      style: TextStyle(
                        color: subject.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      todayLesson.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      todayLesson.summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill,
                  color: AppTheme.primaryColor, size: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGamesRow(BuildContext context) {
    final games = [
      _GameShortcut(
        title: '記憶翻牌',
        emoji: '🃏',
        colors: const [Color(0xFF7C4DFF), Color(0xFFB388FF)],
        builder: (_) => const MemoryMatchSetupScreen(),
      ),
      _GameShortcut(
        title: '數學快閃',
        emoji: '⚡',
        colors: const [Color(0xFFFFA726), Color(0xFFFFD54F)],
        builder: (_) => const MathBlitzSetupScreen(),
      ),
      _GameShortcut(
        title: '單字雨',
        emoji: '🌧️',
        colors: const [Color(0xFF42A5F5), Color(0xFF80DEEA)],
        builder: (_) => const WordRainSetupScreen(),
      ),
      _GameShortcut(
        title: '手寫練習',
        emoji: '✍️',
        colors: const [Color(0xFFEF5350), Color(0xFFFF8A65)],
        builder: (_) => const HandwritingHubScreen(),
      ),
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final g = games[i];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: g.builder),
                );
              },
              child: Ink(
                width: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: g.colors),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: g.colors.last.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(g.emoji, style: const TextStyle(fontSize: 36)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '立即開始 →',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  dynamic _pickTodayLesson(int grade) {
    final gradeLessons =
        kLessons.where((l) => l.grade == grade).toList();
    if (gradeLessons.isEmpty) {
      return kLessons.isNotEmpty ? kLessons.first : null;
    }
    final seed = DateTime.now().day;
    return gradeLessons[Random(seed).nextInt(gradeLessons.length)];
  }
}

class _GameShortcut {
  final String title;
  final String emoji;
  final List<Color> colors;
  final WidgetBuilder builder;

  const _GameShortcut({
    required this.title,
    required this.emoji,
    required this.colors,
    required this.builder,
  });
}
