import 'package:flutter/material.dart';
import 'memory_match_game.dart';
import 'math_blitz_game.dart';
import 'word_rain_game.dart';
import '../handwriting/handwriting_hub_screen.dart';
import '../lesson/daily_review_hub.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = <_GameInfo>[
      _GameInfo(
        title: '記憶翻牌',
        subtitle: '找出相同的一對！',
        emoji: '🃏',
        gradient: const [Color(0xFF7C4DFF), Color(0xFFB388FF)],
        builder: (_) => const MemoryMatchSetupScreen(),
        tags: const ['國語', '英語', '數學'],
      ),
      _GameInfo(
        title: '數學快閃',
        subtitle: '60 秒算越多越厲害',
        emoji: '⚡',
        gradient: const [Color(0xFFFFA726), Color(0xFFFFD54F)],
        builder: (_) => const MathBlitzSetupScreen(),
        tags: const ['數學'],
      ),
      _GameInfo(
        title: '單字雨',
        subtitle: '接住正確的英文單字',
        emoji: '🌧️',
        gradient: const [Color(0xFF42A5F5), Color(0xFF80DEEA)],
        builder: (_) => const WordRainSetupScreen(),
        tags: const ['英語'],
      ),
      _GameInfo(
        title: '國字手寫練習',
        subtitle: '用手指描字，九宮格輔助',
        emoji: '✍️',
        gradient: const [Color(0xFFEF5350), Color(0xFFFF8A65)],
        builder: (_) => const HandwritingHubScreen(),
        tags: const ['國語', '書寫'],
      ),
      _GameInfo(
        title: '每日複習',
        subtitle: '綜合題庫隨機 10 題',
        emoji: '✨',
        gradient: const [Color(0xFF7C4DFF), Color(0xFFB388FF)],
        builder: (_) => const DailyReviewHub(),
        tags: const ['複習', '綜合'],
      ),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '小遊戲',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            '邊玩邊學，學習更有趣！',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ...games.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _GameCard(info: g),
              )),
        ],
      ),
    );
  }
}

class _GameInfo {
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradient;
  final WidgetBuilder builder;
  final List<String> tags;

  const _GameInfo({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.builder,
    required this.tags,
  });
}

class _GameCard extends StatelessWidget {
  final _GameInfo info;

  const _GameCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: info.builder),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: info.gradient),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: info.gradient.last.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(info.emoji,
                    style: const TextStyle(fontSize: 40)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: info.tags
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  t,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill,
                  color: Colors.white, size: 42),
            ],
          ),
        ),
      ),
    );
  }
}
