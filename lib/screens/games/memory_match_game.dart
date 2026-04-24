import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

enum _Topic {
  english('英語單字', Color(0xFF42A5F5)),
  math('數學算式', Color(0xFF66BB6A)),
  chinese('國字注音', Color(0xFFEF5350));

  final String label;
  final Color color;
  const _Topic(this.label, this.color);
}

enum _Difficulty {
  easy('簡單', 4, 2),
  normal('中等', 6, 3),
  hard('困難', 8, 4);

  final String label;
  final int pairs;
  final int columns;
  const _Difficulty(this.label, this.pairs, this.columns);
}

class _Pair {
  final String a;
  final String b;
  const _Pair(this.a, this.b);
}

const _englishPairs = [
  _Pair('apple', '蘋果'),
  _Pair('cat', '貓'),
  _Pair('dog', '狗'),
  _Pair('book', '書'),
  _Pair('sun', '太陽'),
  _Pair('moon', '月亮'),
  _Pair('fish', '魚'),
  _Pair('water', '水'),
  _Pair('red', '紅色'),
  _Pair('blue', '藍色'),
  _Pair('happy', '快樂'),
  _Pair('school', '學校'),
];

const _mathPairs = [
  _Pair('2 + 3', '5'),
  _Pair('6 − 4', '2'),
  _Pair('7 + 5', '12'),
  _Pair('10 − 6', '4'),
  _Pair('3 × 4', '12'),
  _Pair('5 × 2', '10'),
  _Pair('8 + 7', '15'),
  _Pair('9 − 3', '6'),
  _Pair('6 × 3', '18'),
  _Pair('4 × 5', '20'),
  _Pair('2 × 9', '18'),
  _Pair('12 ÷ 3', '4'),
];

const _chinesePairs = [
  _Pair('爸', 'ㄅㄚˋ'),
  _Pair('媽', 'ㄇㄚ'),
  _Pair('學', 'ㄒㄩㄝˊ'),
  _Pair('校', 'ㄒㄧㄠˋ'),
  _Pair('書', 'ㄕㄨ'),
  _Pair('貓', 'ㄇㄠ'),
  _Pair('狗', 'ㄍㄡˇ'),
  _Pair('魚', 'ㄩˊ'),
  _Pair('花', 'ㄏㄨㄚ'),
  _Pair('水', 'ㄕㄨㄟˇ'),
  _Pair('山', 'ㄕㄢ'),
  _Pair('火', 'ㄏㄨㄛˇ'),
];

class MemoryMatchSetupScreen extends StatefulWidget {
  const MemoryMatchSetupScreen({super.key});

  @override
  State<MemoryMatchSetupScreen> createState() => _MemoryMatchSetupScreenState();
}

class _MemoryMatchSetupScreenState extends State<MemoryMatchSetupScreen> {
  _Topic _topic = _Topic.english;
  _Difficulty _difficulty = _Difficulty.easy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('記憶翻牌')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('選擇主題',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _Topic.values
                  .map((t) => _choice(
                        label: t.label,
                        selected: _topic == t,
                        color: t.color,
                        onTap: () => setState(() => _topic = t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text('難度',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _Difficulty.values
                  .map((d) => _choice(
                        label: '${d.label}（${d.pairs} 對）',
                        selected: _difficulty == d,
                        color: Theme.of(context).colorScheme.primary,
                        onTap: () => setState(() => _difficulty = d),
                      ))
                  .toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 26),
                label: const Text('開始遊戲'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => MemoryMatchGame(
                        topic: _topic,
                        difficulty: _difficulty,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _choice({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class MemoryMatchGame extends StatefulWidget {
  final _Topic topic;
  final _Difficulty difficulty;

  const MemoryMatchGame({
    super.key,
    required this.topic,
    required this.difficulty,
  });

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  late List<_Card> _cards;
  int? _firstIndex;
  int _moves = 0;
  int _matched = 0;
  int _seconds = 0;
  Timer? _timer;
  bool _lock = false;
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _setupCards();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _setupCards() {
    final pool = _poolFor(widget.topic);
    final rand = Random();
    final shuffled = [...pool]..shuffle(rand);
    final chosen = shuffled.take(widget.difficulty.pairs).toList();
    final cards = <_Card>[];
    for (var i = 0; i < chosen.length; i++) {
      cards.add(_Card(pairId: i, text: chosen[i].a));
      cards.add(_Card(pairId: i, text: chosen[i].b));
    }
    cards.shuffle(rand);
    _cards = cards;
  }

  List<_Pair> _poolFor(_Topic t) {
    switch (t) {
      case _Topic.english:
        return _englishPairs;
      case _Topic.math:
        return _mathPairs;
      case _Topic.chinese:
        return _chinesePairs;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _onTap(int i) async {
    if (_lock) return;
    final c = _cards[i];
    if (c.matched || c.faceUp) return;

    setState(() {
      c.faceUp = true;
    });

    if (_firstIndex == null) {
      _firstIndex = i;
      return;
    }

    final first = _cards[_firstIndex!];
    _moves++;
    _lock = true;

    if (first.pairId == c.pairId) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        first.matched = true;
        c.matched = true;
        _matched++;
        _firstIndex = null;
        _lock = false;
      });
      if (_matched == widget.difficulty.pairs) _onWin();
    } else {
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        first.faceUp = false;
        c.faceUp = false;
        _firstIndex = null;
        _lock = false;
      });
    }
  }

  void _onWin() {
    _timer?.cancel();
    _confetti.play();
  }

  @override
  Widget build(BuildContext context) {
    final done = _matched == widget.difficulty.pairs;

    return Scaffold(
      appBar: AppBar(
        title: Text('記憶翻牌 · ${widget.topic.label}'),
        backgroundColor: widget.topic.color.withOpacity(0.1),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('步數', '$_moves', Icons.touch_app),
                    _stat('時間', _fmt(_seconds), Icons.timer),
                    _stat('進度', '$_matched / ${widget.difficulty.pairs}',
                        Icons.check_circle),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.difficulty.columns,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, i) {
                      final c = _cards[i];
                      return _MemoryCard(
                        card: c,
                        color: widget.topic.color,
                        onTap: () => _onTap(i),
                      );
                    },
                  ),
                ),
              ),
              if (done)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('再玩一次'),
                          onPressed: () {
                            setState(() {
                              _firstIndex = null;
                              _moves = 0;
                              _matched = 0;
                              _seconds = 0;
                              _setupCards();
                              _timer?.cancel();
                              _timer = Timer.periodic(
                                  const Duration(seconds: 1), (_) {
                                if (mounted) setState(() => _seconds++);
                              });
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.home),
                          label: const Text('完成'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (done) _buildWinBanner(),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildWinBanner() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.topic.color,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: widget.topic.color.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.white, size: 56),
            const SizedBox(height: 8),
            const Text(
              '全部配對成功！',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '用了 $_moves 步 · ${_fmt(_seconds)}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: widget.topic.color, size: 22),
        const SizedBox(height: 2),
        Text(value,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }
}

class _Card {
  final int pairId;
  final String text;
  bool faceUp;
  bool matched;
  _Card({
    required this.pairId,
    required this.text,
    this.faceUp = false,
    this.matched = false,
  });
}

class _MemoryCard extends StatelessWidget {
  final _Card card;
  final Color color;
  final VoidCallback onTap;

  const _MemoryCard({
    required this.card,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showFront = card.faceUp || card.matched;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: showFront
              ? LinearGradient(
                  colors: [
                    Colors.white,
                    card.matched
                        ? color.withOpacity(0.15)
                        : Colors.grey.shade100,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [color, color.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: card.matched ? color : Colors.grey.shade300,
            width: card.matched ? 3 : 1.5,
          ),
        ),
        child: Center(
          child: showFront
              ? Padding(
                  padding: const EdgeInsets.all(6),
                  child: FittedBox(
                    child: Text(
                      card.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: card.matched ? color : Colors.black87,
                      ),
                    ),
                  ),
                )
              : const Icon(Icons.question_mark,
                  color: Colors.white, size: 40),
        ),
      ),
    );
  }
}
