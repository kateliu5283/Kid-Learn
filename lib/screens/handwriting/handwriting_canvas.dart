import 'package:flutter/material.dart';

/// 使用者筆劃：每一筆是一條點序列
class Stroke {
  final List<Offset> points;
  final double width;
  final Color color;

  Stroke({
    required this.points,
    required this.width,
    required this.color,
  });
}

/// 顯示在畫布上的「參考筆」–– 用於筆順挑戰模式，讓學生看著輪廓照描。
class GhostStroke {
  const GhostStroke({
    required this.points,
    this.color = const Color(0x802196F3),
    this.width = 16,
    this.showArrow = true,
  });

  /// 0-1 正規化座標（畫布大小會自動換算）
  final List<Offset> points;
  final Color color;
  final double width;

  /// 是否在終點畫箭頭表示筆劃方向
  final bool showArrow;
}

/// 手寫畫布：支援多筆劃繪製、九宮格輔助線、淺字背景提示。
class HandwritingCanvas extends StatefulWidget {
  final String targetChar;
  final double brushWidth;
  final Color brushColor;
  final bool showGuide;
  final bool showHint;

  /// 父層控制筆劃資料，讓外部能呼叫「清除」「上一步」
  final List<Stroke> strokes;
  final VoidCallback? onStrokesChanged;

  /// 當前筆劃結束時回呼（把該筆的點座標帶回父層做比對）
  final ValueChanged<Stroke>? onStrokeCompleted;

  /// 若有指定，畫布上會顯示這筆的虛線參考軌跡（0-1 正規化座標）
  final GhostStroke? ghost;

  /// 是否鎖定畫布（筆順挑戰過關時鎖住避免繼續畫）
  final bool locked;

  const HandwritingCanvas({
    super.key,
    required this.targetChar,
    required this.strokes,
    this.brushWidth = 14,
    this.brushColor = const Color(0xFF2A2A3C),
    this.showGuide = true,
    this.showHint = true,
    this.onStrokesChanged,
    this.onStrokeCompleted,
    this.ghost,
    this.locked = false,
  });

  @override
  State<HandwritingCanvas> createState() => _HandwritingCanvasState();
}

class _HandwritingCanvasState extends State<HandwritingCanvas> {
  Stroke? _current;

  void _startStroke(Offset p) {
    setState(() {
      _current = Stroke(
        points: [p],
        width: widget.brushWidth,
        color: widget.brushColor,
      );
    });
  }

  void _updateStroke(Offset p) {
    if (_current == null) return;
    setState(() {
      _current!.points.add(p);
    });
  }

  void _endStroke() {
    if (_current != null && _current!.points.isNotEmpty) {
      final completed = _current!;
      widget.strokes.add(completed);
      widget.onStrokesChanged?.call();
      widget.onStrokeCompleted?.call(completed);
    }
    setState(() {
      _current = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              if (widget.showHint)
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.92,
                    heightFactor: 0.92,
                    child: FittedBox(
                      child: Text(
                        widget.targetChar,
                        style: TextStyle(
                          fontSize: 200,
                          color: Colors.grey.shade200,
                          fontWeight: FontWeight.w300,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.showGuide)
                CustomPaint(
                  size: Size.infinite,
                  painter: _GridPainter(),
                ),
              if (widget.ghost != null)
                CustomPaint(
                  size: Size.infinite,
                  painter: _GhostPainter(ghost: widget.ghost!),
                ),
              CustomPaint(
                size: Size.infinite,
                painter: _StrokesPainter(
                  strokes: [
                    ...widget.strokes,
                    if (_current != null) _current!,
                  ],
                ),
              ),
              if (!widget.locked)
                Positioned.fill(
                  child: GestureDetector(
                    onPanStart: (d) => _startStroke(d.localPosition),
                    onPanUpdate: (d) => _updateStroke(d.localPosition),
                    onPanEnd: (_) => _endStroke(),
                    onTapDown: (d) {
                      _startStroke(d.localPosition);
                      _updateStroke(d.localPosition.translate(0.1, 0.1));
                      _endStroke();
                    },
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dashed = Paint()
      ..color = const Color(0xFFE53935).withValues(alpha: 0.35)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 外框
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = const Color(0xFFE53935).withValues(alpha: 0.2)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    const dashWidth = 6.0;
    const dashSpace = 6.0;

    void dashedLine(Offset a, Offset b) {
      final dx = b.dx - a.dx;
      final dy = b.dy - a.dy;
      final total = (Offset(dx, dy)).distance;
      final steps = (total / (dashWidth + dashSpace)).floor();
      for (var i = 0; i < steps; i++) {
        final t1 = i * (dashWidth + dashSpace) / total;
        final t2 = (i * (dashWidth + dashSpace) + dashWidth) / total;
        canvas.drawLine(
          Offset(a.dx + dx * t1, a.dy + dy * t1),
          Offset(a.dx + dx * t2, a.dy + dy * t2),
          dashed,
        );
      }
    }

    // 十字
    dashedLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height));
    dashedLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2));
    // 對角
    dashedLine(const Offset(0, 0), Offset(size.width, size.height));
    dashedLine(Offset(size.width, 0), Offset(0, size.height));
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}

/// 畫虛線參考軌跡 + 箭頭
class _GhostPainter extends CustomPainter {
  _GhostPainter({required this.ghost});
  final GhostStroke ghost;

  @override
  void paint(Canvas canvas, Size size) {
    if (ghost.points.length < 2) return;

    final paint = Paint()
      ..color = ghost.color
      ..strokeWidth = ghost.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // 先把 0-1 座標展開到畫布大小
    final pxPoints = ghost.points
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    // 虛線 path（每 12px 實 + 8px 空）
    const dashOn = 12.0;
    const dashOff = 8.0;
    final fullPath = Path()..moveTo(pxPoints.first.dx, pxPoints.first.dy);
    for (var i = 1; i < pxPoints.length; i++) {
      fullPath.lineTo(pxPoints[i].dx, pxPoints[i].dy);
    }
    final metrics = fullPath.computeMetrics().toList();
    for (final m in metrics) {
      var distance = 0.0;
      while (distance < m.length) {
        final next = distance + dashOn;
        canvas.drawPath(
            m.extractPath(distance, next.clamp(0, m.length)), paint);
        distance = next + dashOff;
      }
    }

    // 起點大圓：提示「從這裡開始」
    canvas.drawCircle(
      pxPoints.first,
      ghost.width * 0.7,
      Paint()
        ..color = ghost.color.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      pxPoints.first,
      ghost.width * 0.3,
      Paint()..color = Colors.white,
    );

    // 終點箭頭
    if (ghost.showArrow && pxPoints.length >= 2) {
      final p2 = pxPoints.last;
      final p1 = pxPoints[pxPoints.length - 2];
      final v = p2 - p1;
      final len = v.distance;
      if (len > 0) {
        final dir = Offset(v.dx / len, v.dy / len);
        final perp = Offset(-dir.dy, dir.dx);
        const arrow = 18.0;
        final a = p2 - dir * arrow + perp * (arrow / 2);
        final b = p2 - dir * arrow - perp * (arrow / 2);
        final path = Path()
          ..moveTo(p2.dx, p2.dy)
          ..lineTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..close();
        canvas.drawPath(
          path,
          Paint()
            ..color = ghost.color.withValues(alpha: 0.9)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GhostPainter oldDelegate) =>
      oldDelegate.ghost != ghost;
}

class _StrokesPainter extends CustomPainter {
  final List<Stroke> strokes;
  _StrokesPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      if (s.points.isEmpty) continue;
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (s.points.length == 1) {
        canvas.drawCircle(s.points.first, s.width / 2, paint..style = PaintingStyle.fill);
        continue;
      }

      final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
      for (var i = 1; i < s.points.length; i++) {
        path.lineTo(s.points[i].dx, s.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokesPainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}
