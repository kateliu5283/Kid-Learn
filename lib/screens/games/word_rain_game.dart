import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

enum _RainLevel {
  easy('簡單', 2.0, Duration(seconds: 4)),
  normal('中等', 1.5, Duration(seconds: 3)),
  hard('困難', 1.0, Duration(milliseconds: 2200));

  final String label;
  final double fallSpeed; // higher = slower fall in seconds
  final Duration spawnInterval;
  const _RainLevel(this.label, this.fallSpeed, this.spawnInterval);
}

class _WordPair {
  final String en;
  final String zh;
  const _WordPair(this.en, this.zh);
}

const _words = <_WordPair>[
  _WordPair('apple', '蘋果'),
  _WordPair('banana', '香蕉'),
  _WordPair('cat', '貓'),
  _WordPair('dog', '狗'),
  _WordPair('book', '書'),
  _WordPair('pen', '筆'),
  _WordPair('sun', '太陽'),
  _WordPair('moon', '月亮'),
  _WordPair('star', '星星'),
  _WordPair('fish', '魚'),
  _WordPair('bird', '鳥'),
  _WordPair('tree', '樹'),
  _WordPair('flower', '花'),
  _WordPair('water', '水'),
  _WordPair('milk', '牛奶'),
  _WordPair('bread', '麵包'),
  _WordPair('red', '紅色'),
  _WordPair('blue', '藍色'),
  _WordPair('green', '綠色'),
  _WordPair('yellow', '黃色'),
  _WordPair('happy', '快樂'),
  _WordPair('sad', '難過'),
  _WordPair('big', '大的'),
  _WordPair('small', '小的'),
  _WordPair('mother', '媽媽'),
  _WordPair('father', '爸爸'),
  _WordPair('school', '學校'),
  _WordPair('teacher', '老師'),
  _WordPair('friend', '朋友'),
  _WordPair('run', '跑'),
  _WordPair('jump', '跳'),
  _WordPair('eat', '吃'),
];

class WordRainSetupScreen extends StatefulWidget {
  const WordRainSetupScreen({super.key});

  @override
  State<WordRainSetupScreen> createState() => _WordRainSetupScreenState();
}

class _WordRainSetupScreenState extends State<WordRainSetupScreen> {
  _RainLevel _level = _RainLevel.easy;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF42A5F5);
    return Scaffold(
      appBar: AppBar(title: const Text('單字雨')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF80DEEA)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.water_drop, color: Colors.white, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '畫面上方會顯示中文，\n點擊正確的英文單字！\n小心不要讓錯的掉落。',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('難度',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _RainLevel.values
                  .map((l) => InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() => _level = l),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: _level == l ? blue : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _level == l ? blue : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            l.label,
                            style: TextStyle(
                              color: _level == l
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: blue),
                icon: const Icon(Icons.play_arrow_rounded, size: 26),
                label: const Text('開始遊戲'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => WordRainGame(level: _level),
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
}

class _FallingWord {
  final String text;
  final bool isTarget;
  final double xFraction;
  final int seed;
  final DateTime startedAt;
  _FallingWord({
    required this.text,
    required this.isTarget,
    required this.xFraction,
    required this.seed,
    required this.startedAt,
  });
}

class WordRainGame extends StatefulWidget {
  final _RainLevel level;
  const WordRainGame({super.key, required this.level});

  @override
  State<WordRainGame> createState() => _WordRainGameState();
}

class _WordRainGameState extends State<WordRainGame> {
  final _rand = Random();
  final List<_FallingWord> _active = [];

  Timer? _spawnTimer;
  Timer? _tickTimer;
  _WordPair? _target;
  int _score = 0;
  int _lives = 3;
  bool _done = false;
  late ConfettiController _confetti;
  int _seedCounter = 0;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _newTarget();
    _spawnTimer = Timer.periodic(widget.level.spawnInterval, (_) {
      if (!_done) _spawn();
    });
    _tickTimer =
        Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
    _spawn();
    _spawn();
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _tickTimer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  void _newTarget() {
    _target = _words[_rand.nextInt(_words.length)];
  }

  void _spawn() {
    if (_target == null) return;
    final target = _target!;
    final spawnTarget = _active.where((w) => w.isTarget).isEmpty ||
        _rand.nextDouble() < 0.4;

    final text =
        spawnTarget ? target.en : _randomNonTargetWord(target.en).en;
    final isTarget = text == target.en;

    _active.add(_FallingWord(
      text: text,
      isTarget: isTarget,
      xFraction: 0.1 + _rand.nextDouble() * 0.8,
      seed: _seedCounter++,
      startedAt: DateTime.now(),
    ));
    setState(() {});
  }

  _WordPair _randomNonTargetWord(String excludeEn) {
    _WordPair w;
    do {
      w = _words[_rand.nextInt(_words.length)];
    } while (w.en == excludeEn);
    return w;
  }

  void _tick() {
    if (_done) return;
    final now = DateTime.now();
    final expired = <_FallingWord>[];
    for (final w in _active) {
      final t = now.difference(w.startedAt).inMilliseconds /
          (widget.level.fallSpeed * 1000);
      if (t >= 1.0) expired.add(w);
    }
    if (expired.isNotEmpty) {
      for (final w in expired) {
        if (w.isTarget) _loseLife();
      }
      _active.removeWhere((w) => expired.contains(w));
      if (mounted) setState(() {});
    } else if (mounted) {
      setState(() {});
    }
  }

  void _loseLife() {
    _lives--;
    if (_lives <= 0) _finish();
  }

  void _onTap(_FallingWord w) {
    if (_done) return;
    if (w.isTarget) {
      _score++;
      _active.remove(w);
      if (_score % 5 == 0) _confetti.play();
      _newTarget();
    } else {
      _loseLife();
      _active.remove(w);
    }
    setState(() {});
  }

  void _finish() {
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _result();

    const blue = Color(0xFF42A5F5);

    return Scaffold(
      appBar: AppBar(title: const Text('單字雨')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: blue.withOpacity(0.08),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('請找出',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      Text(
                        _target?.zh ?? '',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: blue,
                        ),
                      ),
                    ],
                  ),
                ),
                _indicator('分數', '$_score', Icons.star, Colors.amber),
                const SizedBox(width: 16),
                _indicator('生命', _hearts(_lives), Icons.favorite,
                    Colors.redAccent,
                    isText: true),
              ],
            ),
          ),
          Expanded(
            child: ClipRect(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    color: const Color(0xFFE3F2FD),
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Stack(
                      children: _active.map((w) {
                        final elapsed = DateTime.now()
                                .difference(w.startedAt)
                                .inMilliseconds /
                            (widget.level.fallSpeed * 1000);
                        final y = (elapsed.clamp(0.0, 1.0)) *
                            (constraints.maxHeight - 50);
                        return Positioned(
                          key: ValueKey(w.seed),
                          left:
                              w.xFraction * (constraints.maxWidth - 80),
                          top: y,
                          child: GestureDetector(
                            onTap: () => _onTap(w),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                  color: blue.withOpacity(0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                w.text,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicator(String label, String value, IconData icon, Color color,
      {bool isText = false}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
              fontSize: isText ? 16 : 18,
              fontWeight: FontWeight.w800,
            )),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  String _hearts(int n) {
    return List.generate(3, (i) => i < n ? '❤️' : '🤍').join('');
  }

  Widget _result() {
    const blue = Color(0xFF42A5F5);
    return Scaffold(
      appBar: AppBar(title: const Text('遊戲結束')),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _score >= 10 ? '🏆' : _score >= 5 ? '🎉' : '☔',
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _score >= 10
                        ? '單字王！'
                        : _score >= 5
                            ? '很棒！'
                            : '再玩一次！',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '本次分數：$_score',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('再玩'),
                          onPressed: () => Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                                  builder: (_) => WordRainGame(
                                      level: widget.level))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: blue),
                          icon: const Icon(Icons.home),
                          label: const Text('完成'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
    );
  }
}

