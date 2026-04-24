import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/character_sets.dart';
import '../../data/stroke_templates.dart';
import '../../providers/progress_provider.dart';
import 'handwriting_practice_screen.dart';
import 'stroke_order_challenge_screen.dart';

class HandwritingHubScreen extends StatelessWidget {
  const HandwritingHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final grade = context.watch<ProgressProvider>().profile.grade;

    // 依年級排序（和目前年級相近的排前面）
    final sorted = [...kCharacterSets]
      ..sort((a, b) =>
          (a.grade - grade).abs().compareTo((b.grade - grade).abs()));

    return Scaffold(
      appBar: AppBar(title: const Text('國字手寫練習')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF5350), Color(0xFFFF8A65)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.brush, color: Colors.white, size: 40),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '用手指在畫布上寫國字；點選 ✨ 挑戰模式，\n系統會依「筆順、起筆、方向、形狀」打分數！',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '選擇字庫',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...sorted.map((s) => _buildSetCard(context, s)),
        ],
      ),
    );
  }

  Widget _buildSetCard(BuildContext context, CharacterSet set) {
    final challengeCount =
        set.characters.where((c) => hasTemplate(c.char)).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HandwritingPracticeScreen(set: set),
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
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF5350).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        set.characters.first.char,
                        style: const TextStyle(
                          fontSize: 32,
                          color: Color(0xFFEF5350),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                set.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${set.grade} 年級',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${set.description}　共 ${set.characters.length} 字',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            children: set.characters
                                .take(8)
                                .map((c) => Text(
                                      c.char,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade700,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Colors.grey, size: 28),
                  ],
                ),
                if (challengeCount > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.brush, size: 16),
                          label: const Text('一般練習',
                              style: TextStyle(fontSize: 13)),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    HandwritingPracticeScreen(set: set),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: Text(
                            '筆順挑戰 ($challengeCount)',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF5E35B1),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    StrokeOrderChallengeScreen(set: set),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
