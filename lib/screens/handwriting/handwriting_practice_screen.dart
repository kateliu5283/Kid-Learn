import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../curriculum/handwriting/character_sets.dart';
import '../../curriculum/handwriting/stroke_templates.dart';
import '../../services/stroke_matcher.dart';
import 'handwriting_canvas.dart';
import 'stroke_order_challenge_screen.dart';

class HandwritingPracticeScreen extends StatefulWidget {
  final CharacterSet set;
  final int initialIndex;

  const HandwritingPracticeScreen({
    super.key,
    required this.set,
    this.initialIndex = 0,
  });

  @override
  State<HandwritingPracticeScreen> createState() =>
      _HandwritingPracticeScreenState();
}

class _HandwritingPracticeScreenState
    extends State<HandwritingPracticeScreen> {
  late int _index;
  final List<Stroke> _strokes = [];
  bool _showHint = true;
  bool _showGuide = true;
  double _brushWidth = 14;
  Color _brushColor = const Color(0xFF2A2A3C);

  final FlutterTts _tts = FlutterTts();

  final GlobalKey _canvasKey = GlobalKey();
  final StrokeMatcher _matcher = StrokeMatcher();

  /// 軌跡／筆順評分結果（按「評分」後更新）
  CharacterScore? _evalScore;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.set.characters.length - 1);
    _tts.setLanguage('zh-TW');
    _tts.setSpeechRate(0.4);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  CharacterItem get _current => widget.set.characters[_index];

  void _clear() {
    setState(() {
      _strokes.clear();
      _evalScore = null;
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.removeLast();
      _evalScore = null;
    });
  }

  void _prev() {
    if (_index == 0) return;
    setState(() {
      _index--;
      _strokes.clear();
      _evalScore = null;
    });
  }

  void _next() {
    if (_index >= widget.set.characters.length - 1) {
      _showFinishDialog();
      return;
    }
    setState(() {
      _index++;
      _strokes.clear();
      _evalScore = null;
    });
  }

  Future<void> _speak() async {
    await _tts.stop();
    await _tts.speak(_current.char);
  }

  /// 以軌跡辨識比對標準筆順（需該字有標準筆順資料）。
  void _evaluateWriting() {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('先畫幾筆，再按評分喔'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!hasTemplate(_current.char)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('這個字尚無標準筆順資料，無法比對軌跡'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final size = box?.size ?? const Size(320, 320);
    final cs = _matcher.matchCharacter(
      char: _current.char,
      userStrokes: _strokes.map((s) => s.points).toList(),
      canvasSize: size,
    );
    setState(() => _evalScore = cs);
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('太棒了！'),
        content: Text(
          '「${widget.set.name}」所有字都練習完了！\n再來一次嗎？',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('返回'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _index = 0;
                _strokes.clear();
                _evalScore = null;
              });
            },
            child: const Text('從頭練'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.set.characters.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.set.name),
        actions: [
          if (widget.set.characters.any((c) => hasTemplate(c.char)))
            IconButton(
              tooltip: '筆順挑戰',
              icon: const Icon(Icons.auto_awesome),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        StrokeOrderChallengeScreen(set: widget.set),
                  ),
                );
              },
            ),
          IconButton(
            tooltip: '發音',
            icon: const Icon(Icons.volume_up),
            onPressed: _speak,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfo(total),
                const SizedBox(height: 12),
                KeyedSubtree(
                  key: _canvasKey,
                  child: HandwritingCanvas(
                    targetChar: _current.char,
                    strokes: _strokes,
                    brushWidth: _brushWidth,
                    brushColor: _brushColor,
                    showGuide: _showGuide,
                    showHint: _showHint,
                    onStrokesChanged: () =>
                        setState(() => _evalScore = null),
                  ),
                ),
                const SizedBox(height: 12),
                _buildToolbar(),
                if (hasTemplate(_current.char)) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          _strokes.isEmpty ? null : _evaluateWriting,
                      icon: const Icon(Icons.auto_fix_high, size: 20),
                      label: const Text(
                        '軌跡／筆順評分',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: const Color(0xFF1565C0),
                        side: const BorderSide(color: Color(0xFF42A5F5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '將你的筆畫與標準筆順做位置、方向與形狀比對',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_evalScore != null) ...[
                  const SizedBox(height: 12),
                  _buildEvalCard(_evalScore!),
                ],
                const SizedBox(height: 12),
                _buildActions(total),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfo(int total) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF5350), Color(0xFFFF8A65)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              _current.char,
              style: const TextStyle(
                fontSize: 32,
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
                      _current.char,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _current.zhuyin,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '意思：${_current.meaning}　筆劃數：${_current.strokes}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${_index + 1}/$total',
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

  Widget _buildToolbar() {
    const colors = <Color>[
      Color(0xFF2A2A3C),
      Color(0xFFEF5350),
      Color(0xFF42A5F5),
      Color(0xFF66BB6A),
      Color(0xFFFFA726),
      Color(0xFF7C4DFF),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('顏色', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              ...colors.map((c) {
                final sel = c.value == _brushColor.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _brushColor = c),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: sel ? Colors.black87 : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('粗細', style: TextStyle(fontSize: 13)),
              Expanded(
                child: Slider(
                  min: 4,
                  max: 30,
                  divisions: 26,
                  label: _brushWidth.toStringAsFixed(0),
                  value: _brushWidth,
                  onChanged: (v) => setState(() => _brushWidth = v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  value: _showHint,
                  onChanged: (v) =>
                      setState(() => _showHint = v ?? true),
                  title: const Text('淺字提示',
                      style: TextStyle(fontSize: 13)),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  value: _showGuide,
                  onChanged: (v) =>
                      setState(() => _showGuide = v ?? true),
                  title: const Text('九宮格',
                      style: TextStyle(fontSize: 13)),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvalCard(CharacterScore cs) {
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
                cs.passed ? Icons.auto_graph : Icons.info_outline,
                color: cs.passed
                    ? const Color(0xFF43A047)
                    : const Color(0xFFE53935),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cs.passed
                      ? '整體 ${cs.overall.round()} 分'
                      : '整體 ${cs.overall.round()} 分，再試試看',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
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
                ? '筆劃數：${cs.actualStrokes} 筆'
                : '筆劃數：你寫了 ${cs.actualStrokes} 筆，標準為 ${cs.expectedStrokes} 筆',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          const Text(
            '每一筆（軌跡相似度）',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 6),
          ...List.generate(cs.perStroke.length, (i) {
            final s = cs.perStroke[i];
            final label = '第 ${i + 1} 筆';
            if (s == null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(child: Text('$label：缺筆')),
                    const Icon(Icons.remove_circle_outline,
                        color: Colors.grey, size: 18),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$label　總分 ${s.overall.round()}　${s.label}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: s.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: s.pathTangentMatch.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                  Text(
                    '沿路方向吻合 ${(s.pathTangentMatch * 100).round()}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActions(int total) {
    return Row(
      children: [
        _iconButton(
          icon: Icons.undo,
          label: '上一步',
          onTap: _strokes.isEmpty ? null : _undo,
        ),
        const SizedBox(width: 8),
        _iconButton(
          icon: Icons.delete_outline,
          label: '清除',
          onTap: _strokes.isEmpty ? null : _clear,
          color: Colors.red,
        ),
        const SizedBox(width: 8),
        _iconButton(
          icon: Icons.arrow_back,
          label: '上一字',
          onTap: _index == 0 ? null : _prev,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(
              _index >= total - 1 ? Icons.check : Icons.arrow_forward,
              size: 20,
            ),
            label: Text(
              _index >= total - 1 ? '完成' : '下一字',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFFEF5350),
            ),
            onPressed: _next,
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
              color:
                  disabled ? Colors.grey.shade200 : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: disabled
                    ? Colors.grey
                    : (color ?? Colors.black87),
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: disabled
                      ? Colors.grey
                      : (color ?? Colors.black87),
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
