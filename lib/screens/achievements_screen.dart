import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../curriculum/curriculum.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final badges = _computeBadges(progress);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '我的成就',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                _buildStat(
                  '完成單元',
                  '${progress.completedCount}',
                  Icons.check_circle,
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStat(
                  '總星星',
                  '${progress.totalStars}',
                  Icons.star,
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStat(
                  '徽章',
                  '${badges.where((b) => b.unlocked).length}',
                  Icons.military_tech,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '徽章牆',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: badges.length,
            itemBuilder: (context, i) {
              return _buildBadge(badges[i]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(_Badge badge) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: badge.unlocked
                ? LinearGradient(
                    colors: [
                      badge.color.withOpacity(0.8),
                      badge.color,
                    ],
                  )
                : null,
            color: badge.unlocked ? null : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(24),
            boxShadow: badge.unlocked
                ? [
                    BoxShadow(
                      color: badge.color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Icon(
            badge.unlocked ? badge.icon : Icons.lock,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          badge.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: badge.unlocked ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    );
  }

  List<_Badge> _computeBadges(ProgressProvider progress) {
    final completed = progress.completedCount;
    final stars = progress.totalStars;
    final byChinese = kLessons
        .where((l) => l.subjectId == 'chinese')
        .every((l) => progress.progressOf(l.id).completed);
    final byEnglish = kLessons
        .where((l) => l.subjectId == 'english')
        .every((l) => progress.progressOf(l.id).completed);
    final byMath = kLessons
        .where((l) => l.subjectId == 'math')
        .every((l) => progress.progressOf(l.id).completed);

    return [
      _Badge('初學者', Icons.emoji_events, const Color(0xFFFFB300), completed >= 1),
      _Badge('努力家', Icons.local_fire_department,
          const Color(0xFFEF5350), completed >= 5),
      _Badge('學霸', Icons.workspace_premium,
          AppTheme.primaryColor, completed >= 10),
      _Badge('星星王', Icons.star, Colors.amber, stars >= 10),
      _Badge('閱讀達人', Icons.menu_book,
          const Color(0xFFEF5350), byChinese),
      _Badge('英語小老師', Icons.translate,
          const Color(0xFF42A5F5), byEnglish),
      _Badge('數學神童', Icons.calculate,
          const Color(0xFF66BB6A), byMath),
      _Badge('百科小博士', Icons.science,
          const Color(0xFFAB47BC), completed >= 15),
      _Badge('全能王', Icons.diamond,
          const Color(0xFF26C6DA), completed >= kLessons.length),
    ];
  }
}

class _Badge {
  final String name;
  final IconData icon;
  final Color color;
  final bool unlocked;

  const _Badge(this.name, this.icon, this.color, this.unlocked);
}
