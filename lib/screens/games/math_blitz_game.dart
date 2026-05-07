import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../services/learning_record_sync.dart';
import '../../services/learning_records_api.dart' show LearningActivityTypes;

enum _MathMode {
  add('加法', Icons.add),
  sub('減法', Icons.remove),
  mul('乘法', Icons.close),
  mixed('綜合', Icons.shuffle);

  final String label;
  final IconData icon;
  const _MathMode(this.label, this.icon);
}

enum _Level {
  g1('一年級', 10),
  g2('二年級', 20),
  g3('三年級', 50),
  g4('四年級', 100);

  final String label;
  final int range;
  const _Level(this.label, this.range);
}

class MathBlitzSetupScreen extends StatefulWidget {
  const MathBlitzSetupScreen({super.key});

  @override
  State<MathBlitzSetupScreen> createState() => _MathBlitzSetupScreenState();
}

class _MathBlitzSetupScreenState extends State<MathBlitzSetupScreen> {
  _MathMode _mode = _MathMode.add;
  _Level _level = _Level.g1;

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFFA726);
    return Scaffold(
      appBar: AppBar(title: const Text('數學快閃')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFFFD54F)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.timer, color: Colors.white, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '60 秒時間\n答對越多題越厲害！',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('運算類型',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _MathMode.values
                  .map((m) => _choice(
                        label: m.label,
                        icon: m.icon,
                        selected: _mode == m,
                        color: orange,
                        onTap: () => setState(() => _mode = m),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text('難度',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _Level.values
                  .map((l) => _choice(
                        label: l.label,
                        selected: _level == l,
                        color: orange,
                        onTap: () => setState(() => _level = l),
                      ))
                  .toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: orange),
                icon: const Icon(Icons.play_arrow_rounded, size: 26),
                label: const Text('開始挑戰'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          MathBlitzGame(mode: _mode, level: _level),
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
    IconData? icon,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 16,
                  color: selected ? Colors.white : Colors.black54),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MathBlitzGame extends StatefulWidget {
  final _MathMode mode;
  final _Level level;
  const MathBlitzGame({
    super.key,
    required this.mode,
    required this.level,
  });

  @override
  State<MathBlitzGame> createState() => _MathBlitzGameState();
}

class _MathBlitzGameState extends State<MathBlitzGame> {
  final _rand = Random();
  int _remaining = 60;
  int _score = 0;
  int _wrong = 0;
  int _combo = 0;
  int _bestCombo = 0;
  Timer? _timer;
  late _Problem _problem;
  int? _selected;
  bool _done = false;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _problem = _nextProblem();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining > 0) {
          _remaining--;
          if (_remaining == 0) _finish();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  _Problem _nextProblem() {
    final mode = widget.mode == _MathMode.mixed
        ? _MathMode.values[_rand.nextInt(3)]
        : widget.mode;
    final range = widget.level.range;

    int a, b;
    String op;
    int ans;

    switch (mode) {
      case _MathMode.add:
        a = _rand.nextInt(range) + 1;
        b = _rand.nextInt(range) + 1;
        op = '+';
        ans = a + b;
        break;
      case _MathMode.sub:
        a = _rand.nextInt(range) + 1;
        b = _rand.nextInt(a) + 0;
        op = '−';
        ans = a - b;
        break;
      case _MathMode.mul:
        final mulMax = range <= 20 ? 5 : 9;
        a = _rand.nextInt(mulMax) + 1;
        b = _rand.nextInt(9) + 1;
        op = '×';
        ans = a * b;
        break;
      default:
        a = 1;
        b = 1;
        op = '+';
        ans = 2;
    }

    final options = <int>{ans};
    while (options.length < 4) {
      final delta = _rand.nextInt(10) + 1;
      final candidate =
          _rand.nextBool() ? ans + delta : max(0, ans - delta);
      options.add(candidate);
    }
    final optionList = options.toList()..shuffle(_rand);
    return _Problem(
      expr: '$a $op $b',
      answer: ans,
      options: optionList,
    );
  }

  Future<void> _pick(int i) async {
    if (_selected != null || _done) return;
    setState(() => _selected = i);
    final ok = _problem.options[i] == _problem.answer;
    if (ok) {
      _score++;
      _combo++;
      if (_combo > _bestCombo) _bestCombo = _combo;
    } else {
      _wrong++;
      _combo = 0;
    }
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {
      _selected = null;
      _problem = _nextProblem();
    });
  }

  void _finish() {
    _timer?.cancel();
    setState(() => _done = true);
    if (_score >= 10) _confetti.play();
    final total = _score + _wrong;
    LearningRecordSync.trySubmit(
      context,
      activityType: LearningActivityTypes.gameMathBlitz,
      title: '數學快閃（${widget.mode.label}／${widget.level.label}）',
      correctCount: _score,
      questionCount: total > 0 ? total : _score,
      durationSeconds: 60,
      meta: {
        'mode': widget.mode.name,
        'level': widget.level.name,
        'best_combo': _bestCombo,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFFA726);

    if (_done) return _resultScreen(orange);

    return Scaffold(
      appBar: AppBar(title: const Text('數學快閃')),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _remaining / 60,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _remaining <= 10 ? Colors.redAccent : orange,
            ),
            minHeight: 8,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('分數', '$_score', Icons.star, orange),
                _stat('連對', '$_combo', Icons.bolt, Colors.deepOrange),
                _stat('剩餘',
                    '$_remaining 秒',
                    Icons.timer,
                    _remaining <= 10 ? Colors.red : Colors.black54),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA726), Color(0xFFFFD54F)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: orange.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${_problem.expr} = ?',
                style: const TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemCount: _problem.options.length,
              itemBuilder: (context, i) {
                final v = _problem.options[i];
                Color bg = Colors.white;
                Color border = Colors.grey.shade300;
                if (_selected == i) {
                  final correct = v == _problem.answer;
                  bg = correct
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE);
                  border = correct ? Colors.green : Colors.red;
                }
                return InkWell(
                  onTap: () => _pick(i),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border, width: 2.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$v',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(value,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _resultScreen(Color color) {
    String title;
    String emoji;
    if (_score >= 25) {
      title = '數學小天才！';
      emoji = '🏆';
    } else if (_score >= 15) {
      title = '很厲害！';
      emoji = '🎉';
    } else if (_score >= 8) {
      title = '不錯喔！';
      emoji = '😊';
    } else {
      title = '再挑戰一次！';
      emoji = '💪';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('挑戰結果')),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        _row('答對題數', '$_score'),
                        const SizedBox(height: 8),
                        _row('答錯題數', '$_wrong'),
                        const SizedBox(height: 8),
                        _row('最高連對', '$_bestCombo 連'),
                        const SizedBox(height: 8),
                        _row(
                          '正確率',
                          '${_wrong + _score == 0 ? 0 : (_score * 100 / (_score + _wrong)).round()}%',
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('再挑戰'),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => MathBlitzGame(
                                  mode: widget.mode,
                                  level: widget.level,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: color),
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

  Widget _row(String k, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(v,
            style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _Problem {
  final String expr;
  final int answer;
  final List<int> options;
  const _Problem({
    required this.expr,
    required this.answer,
    required this.options,
  });
}
