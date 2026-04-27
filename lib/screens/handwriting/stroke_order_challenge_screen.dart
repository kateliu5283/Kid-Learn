import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../curriculum/handwriting/character_sets.dart';
import '../../curriculum/handwriting/stroke_templates.dart';
import '../../services/stroke_matcher.dart';
import 'handwriting_canvas.dart';

/// 筆順挑戰：一筆一筆照著虛線寫，系統即時評分。
class StrokeOrderChallengeScreen extends StatefulWidget {
  const StrokeOrderChallengeScreen({
    super.key,
    required this.set,
    this.initialIndex = 0,
  });

  final CharacterSet set;
  final int initialIndex;

  @override
  State<StrokeOrderChallengeScreen> createState() =>
      _StrokeOrderChallengeScreenState();
}

class _StrokeOrderChallengeScreenState
    extends State<StrokeOrderChallengeScreen> {
  late int _charIndex;
  final _matcher = StrokeMatcher();
  final _tts = FlutterTts();
  final _confetti = ConfettiController(duration: const Duration(seconds: 1));

  final GlobalKey _canvasKey = GlobalKey();

  /// 使用者當前字已經寫好的筆劃
  final List<Stroke> _strokes = [];

  /// 每筆的評分（與 _strokes 對齊）
  final List<StrokeScore> _strokeScores = [];

  /// 是否已完成當前字
  bool _finishedChar = false;

  /// 當前字的總分（完成後才有值）
  CharacterScore? _charScore;

  @override
  void initState() {
    super.initState();
    _charIndex = widget.initialIndex.clamp(0, _writableChars.length - 1);
    _tts.setLanguage('zh-TW');
    _tts.setSpeechRate(0.4);
  }

  @override
  void dispose() {
    _tts.stop();
    _confetti.dispose();
    super.dispose();
  }

  /// 過濾出這個 set 中有 template 的字（沒有 template 就沒辦法做挑戰）
  List<CharacterItem> get _writableChars =>
      widget.set.characters.where((c) => hasTemplate(c.char)).toList();

  CharacterItem get _currentItem => _writableChars[_charIndex];
  CharacterTemplate get _currentTemplate => templateFor(_currentItem.char)!;

  int get _nextStrokeIndex => _strokes.length;
  bool get _allStrokesDone =>
      _nextStrokeIndex >= _currentTemplate.strokes.length;

  GhostStroke? _ghostForNext() {
    if (_allStrokesDone || _finishedChar) return null;
    final t = _currentTemplate.strokes[_nextStrokeIndex];
    return GhostStroke(
      points: t.points,
      color: const Color(0xFF2196F3).withValues(alpha: 0.55),
    );
  }

  // ==== 回呼：使用者完成一筆 ====
  void _onStrokeCompleted(Stroke s) {
    if (_finishedChar) return;
    if (_nextStrokeIndex - 1 >= _currentTemplate.strokes.length) {
      // 多畫了（比模板筆數多），仍然給 0 分提示
      setState(() {
        _strokeScores.add(StrokeScore(
          overall: 0,
          startMatch: 0,
          endMatch: 0,
          directionMatch: 0,
          shapeMatch: 0,
        ));
      });
      return;
    }
    final tmpl = _currentTemplate.strokes[_nextStrokeIndex - 1];
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final size = box?.size ?? const Size(320, 320);
    final score = _matcher.matchStroke(
      userPoints: s.points,
      canvasSize: size,
      template: tmpl,
    );
    setState(() {
      _strokeScores.add(score);
    });

    // 筆劃全寫完 → 結算整字
    if (_nextStrokeIndex >= _currentTemplate.strokes.length) {
      _finalizeChar();
    } else if (!score.passed) {
      // 該筆沒過，震動一下（視覺提示即可，不強制重畫，讓使用者決定）
      _flash('這筆有點不太像哦，可以按「上一步」重寫');
    }
  }

  void _finalizeChar() {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final size = box?.size ?? const Size(320, 320);
    final cs = _matcher.matchCharacter(
      char: _currentItem.char,
      userStrokes: _strokes.map((s) => s.points).toList(),
      canvasSize: size,
    );
    setState(() {
      _charScore = cs;
      _finishedChar = true;
    });
    if (cs.stars >= 2) {
      _confetti.play();
    }
  }

  // ==== 動作 ====
  void _undo() {
    if (_strokes.isEmpty || _finishedChar) return;
    setState(() {
      _strokes.removeLast();
      if (_strokeScores.isNotEmpty) _strokeScores.removeLast();
    });
  }

  void _clear() {
    if (_finishedChar) {
      setState(() {
        _strokes.clear();
        _strokeScores.clear();
        _charScore = null;
        _finishedChar = false;
      });
      return;
    }
    setState(() {
      _strokes.clear();
      _strokeScores.clear();
    });
  }

  void _next() {
    if (_charIndex >= _writableChars.length - 1) {
      _showAllDoneDialog();
      return;
    }
    setState(() {
      _charIndex++;
      _strokes.clear();
      _strokeScores.clear();
      _charScore = null;
      _finishedChar = false;
    });
  }

  void _prev() {
    if (_charIndex == 0) return;
    setState(() {
      _charIndex--;
      _strokes.clear();
      _strokeScores.clear();
      _charScore = null;
      _finishedChar = false;
    });
  }

  Future<void> _speak() async {
    await _tts.stop();
    await _tts.speak(_currentItem.char);
  }

  void _flash(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
      ));
  }

  void _showAllDoneDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('挑戰完成！'),
        content: Text('「${widget.set.name}」所有可挑戰字都寫完了，好厲害！'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('返回')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _charIndex = 0;
                _strokes.clear();
                _strokeScores.clear();
                _charScore = null;
                _finishedChar = false;
              });
            },
            child: const Text('再挑戰一次'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_writableChars.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.set.name}・筆順挑戰')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              '這個字庫目前還沒有標準筆順資料，請改用一般練習模式。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.set.name}・筆順挑戰'),
        actions: [
          IconButton(
            tooltip: '發音',
            icon: const Icon(Icons.volume_up),
            onPressed: _speak,
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                KeyedSubtree(
                  key: _canvasKey,
                  child: HandwritingCanvas(
                    targetChar: _currentItem.char,
                    strokes: _strokes,
                    onStrokesChanged: () => setState(() {}),
                    onStrokeCompleted: _onStrokeCompleted,
                    ghost: _ghostForNext(),
                    locked: _finishedChar,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStepIndicator(),
                const SizedBox(height: 12),
                if (_finishedChar && _charScore != null)
                  _buildResultCard(_charScore!),
                if (!_finishedChar) _buildHintCard(),
                const SizedBox(height: 12),
                _buildActions(),
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirection: 1.5708, // downward
            emissionFrequency: 0.08,
            numberOfParticles: 18,
            maxBlastForce: 25,
            minBlastForce: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final total = _writableChars.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5E35B1), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              _currentItem.char,
              style: const TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _currentItem.char,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _currentItem.zhuyin,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '共 ${_currentTemplate.strokeCount} 筆・第 ${_strokes.length.clamp(0, _currentTemplate.strokeCount)}/${_currentTemplate.strokeCount} 筆',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${_charIndex + 1}/$total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                '進度',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final total = _currentTemplate.strokeCount;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(total, (i) {
        final done = i < _strokeScores.length;
        final score = done ? _strokeScores[i] : null;
        final isNext = i == _strokes.length && !_finishedChar;
        final color = score?.color ??
            (isNext ? const Color(0xFF2196F3) : Colors.grey.shade300);
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            done
                ? (score!.overall.round().toString())
                : '${i + 1}',
            style: TextStyle(
              fontSize: done ? 12 : 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHintCard() {
    if (_allStrokesDone) return const SizedBox.shrink();
    final next = _currentTemplate.strokes[_nextStrokeIndex];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app, color: Color(0xFF1976D2)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '第 ${_nextStrokeIndex + 1} 筆：${next.name ?? ''}  '
              '從藍色圓點起筆，沿虛線寫到箭頭。',
              style: const TextStyle(fontSize: 13, color: Color(0xFF0D47A1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(CharacterScore cs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.passed
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.passed
              ? const Color(0xFF66BB6A)
              : const Color(0xFFEF5350),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                cs.passed ? Icons.emoji_events : Icons.error_outline,
                color: cs.passed
                    ? const Color(0xFF43A047)
                    : const Color(0xFFE53935),
              ),
              const SizedBox(width: 8),
              Text(
                cs.passed ? '完成！得分 ${cs.overall.round()}' : '還差一點 ${cs.overall.round()} 分',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(3, (i) {
                  final filled = i < cs.stars;
                  return Icon(
                    filled ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFB300),
                    size: 22,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            cs.expectedStrokes == cs.actualStrokes
                ? '筆劃數正確（${cs.actualStrokes} 筆）'
                : '筆劃數不對：應該是 ${cs.expectedStrokes} 筆，你寫了 ${cs.actualStrokes} 筆',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final atLast = _charIndex >= _writableChars.length - 1;
    return Row(
      children: [
        _iconButton(
          icon: Icons.undo,
          label: '上一步',
          onTap: _strokes.isEmpty || _finishedChar ? null : _undo,
        ),
        const SizedBox(width: 8),
        _iconButton(
          icon: Icons.refresh,
          label: '重寫',
          onTap: _strokes.isEmpty && !_finishedChar ? null : _clear,
          color: const Color(0xFFEF5350),
        ),
        const SizedBox(width: 8),
        _iconButton(
          icon: Icons.arrow_back,
          label: '上一字',
          onTap: _charIndex == 0 ? null : _prev,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(atLast ? Icons.check : Icons.arrow_forward, size: 20),
            label: Text(
              atLast ? '完成' : (_finishedChar ? '下一字' : '先完成這個字'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF5E35B1),
            ),
            onPressed: _finishedChar ? _next : null,
          ),
        ),
      ],
    );
  }

  Widget _iconButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
  }) {
    final disabled = onTap == null;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: disabled ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: disabled ? Colors.grey.shade200 : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: disabled ? Colors.grey : (color ?? Colors.black87),
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: disabled ? Colors.grey : (color ?? Colors.black87),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
