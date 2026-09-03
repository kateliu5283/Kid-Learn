import 'dart:math';
import 'package:flutter/material.dart';

/// 學科卡上的底紋小圖案（圓點、星星、符號），讓色塊不那麼空。
class SubjectPatternPainter extends CustomPainter {
  final String subjectId;

  const SubjectPatternPainter({required this.subjectId});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(subjectId.hashCode);
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.14);
    for (var i = 0; i < 9; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        3 + rnd.nextDouble() * 10,
        dot,
      );
    }

    final accent = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    switch (subjectId) {
      case 'chinese':
        _strokeMarks(canvas, size, ['丶', '一', '丿'], accent);
      case 'english':
        _tinyStars(canvas, size, 4);
      case 'math':
        _mathMarks(canvas, size);
      case 'science':
        _bubbles(canvas, size);
      case 'social':
        _tinyRings(canvas, size);
      case 'life':
        _tinyHearts(canvas, size);
      default:
        break;
    }
  }

  void _strokeMarks(Canvas canvas, Size size, List<String> marks, Paint paint) {
    final positions = [
      Offset(size.width * 0.12, size.height * 0.22),
      Offset(size.width * 0.82, size.height * 0.18),
      Offset(size.width * 0.88, size.height * 0.58),
    ];
    for (var i = 0; i < marks.length; i++) {
      _paintGlyph(
        canvas,
        marks[i],
        positions[i],
        16,
        Colors.white.withValues(alpha: 0.22),
      );
    }
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 8, paint);
  }

  void _tinyStars(Canvas canvas, Size size, int count) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.22);
    final spots = [
      Offset(size.width * 0.14, size.height * 0.2),
      Offset(size.width * 0.86, size.height * 0.16),
      Offset(size.width * 0.9, size.height * 0.48),
      Offset(size.width * 0.18, size.height * 0.62),
    ];
    for (var i = 0; i < count; i++) {
      canvas.drawPath(_star(spots[i], 5.5, 4), paint);
    }
  }

  void _mathMarks(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final a = Offset(size.width * 0.12, size.height * 0.2);
    canvas.drawLine(a + const Offset(-5, 0), a + const Offset(5, 0), paint);
    canvas.drawLine(a + const Offset(0, -5), a + const Offset(0, 5), paint);
    final b = Offset(size.width * 0.88, size.height * 0.22);
    canvas.drawLine(b + const Offset(-5, 0), b + const Offset(5, 0), paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.55), 6, paint);
  }

  void _bubbles(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(Offset(size.width * 0.14, size.height * 0.22), 7, paint);
    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.18), 5, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.5), 9, paint);
  }

  void _tinyRings(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(Offset(size.width * 0.14, size.height * 0.2), 8, paint);
    canvas.drawCircle(Offset(size.width * 0.14, size.height * 0.2), 4, paint);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.2), 6, paint);
  }

  void _tinyHearts(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.2);
    canvas.drawPath(_heart(Offset(size.width * 0.14, size.height * 0.2), 6), paint);
    canvas.drawPath(_heart(Offset(size.width * 0.88, size.height * 0.18), 5), paint);
    canvas.drawPath(_heart(Offset(size.width * 0.9, size.height * 0.52), 4.5), paint);
  }

  @override
  bool shouldRepaint(covariant SubjectPatternPainter oldDelegate) =>
      oldDelegate.subjectId != subjectId;
}

/// 各科專屬小插圖：書本、積木、圖形、燒杯、地球、太陽。
class SubjectScenePainter extends CustomPainter {
  final String subjectId;

  const SubjectScenePainter({required this.subjectId});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.52;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + h * 0.04),
        width: w * 0.92,
        height: h * 0.78,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );

    switch (subjectId) {
      case 'chinese':
        _paintChinese(canvas, size);
      case 'english':
        _paintEnglish(canvas, size);
      case 'math':
        _paintMath(canvas, size);
      case 'science':
        _paintScience(canvas, size);
      case 'social':
        _paintSocial(canvas, size);
      case 'life':
        _paintLife(canvas, size);
      default:
        _paintChinese(canvas, size);
    }
  }

  void _paintChinese(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.48;
    final top = h * 0.18;
    final pageH = h * 0.62;
    final pageW = w * 0.28;

    final shadow = Paint()..color = Colors.black.withValues(alpha: 0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - pageW + 3, top + 6, pageW * 2, pageH),
        const Radius.circular(6),
      ),
      shadow,
    );

    final left = Paint()..color = const Color(0xFFFFF8E8);
    final right = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - pageW, top + 4, pageW, pageH),
        const Radius.circular(5),
      ),
      left,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx, top, pageW, pageH),
        const Radius.circular(5),
      ),
      right,
    );

    final spine = Paint()
      ..color = const Color(0xFFEF9A9A)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, top + 4),
      Offset(cx, top + pageH),
      spine,
    );

    final ribbon = Path()
      ..moveTo(cx + pageW * 0.45, top)
      ..lineTo(cx + pageW * 0.58, top)
      ..lineTo(cx + pageW * 0.515, top + pageH * 0.38)
      ..close();
    canvas.drawPath(ribbon, Paint()..color = const Color(0xFFEF5350));

    _paintGlyph(
      canvas,
      '文',
      Offset(cx - pageW * 0.5, top + pageH * 0.48),
      pageW * 0.62,
      const Color(0xFFC62828),
    );
    _paintGlyph(
      canvas,
      '字',
      Offset(cx + pageW * 0.5, top + pageH * 0.44),
      pageW * 0.62,
      const Color(0xFF1565C0),
    );

    final pencil = Paint()..color = const Color(0xFFFFD54F);
    final p = Offset(cx + pageW + w * 0.08, top + pageH * 0.55);
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(-0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 8, height: h * 0.42),
        const Radius.circular(2),
      ),
      pencil,
    );
    canvas.drawPath(
      Path()
        ..moveTo(-4, h * 0.21)
        ..lineTo(0, h * 0.3)
        ..lineTo(4, h * 0.21)
        ..close(),
      Paint()..color = const Color(0xFFFFCC80),
    );
    canvas.restore();
  }

  void _paintEnglish(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    _letterBlock(
      canvas,
      Offset(w * 0.22, h * 0.58),
      w * 0.28,
      h * 0.52,
      const Color(0xFFFF8A80),
      'A',
    );
    _letterBlock(
      canvas,
      Offset(w * 0.5, h * 0.48),
      w * 0.32,
      h * 0.6,
      const Color(0xFFFFD54F),
      'B',
    );
    _letterBlock(
      canvas,
      Offset(w * 0.78, h * 0.58),
      w * 0.28,
      h * 0.52,
      const Color(0xFF80D8FF),
      'C',
    );
  }

  void _letterBlock(
    Canvas canvas,
    Offset center,
    double bw,
    double bh,
    Color color,
    String letter,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + const Offset(2, 3),
          width: bw,
          height: bh,
        ),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: bw, height: bh),
        const Radius.circular(8),
      ),
      Paint()..color = color,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center - Offset(0, bh * 0.08),
          width: bw * 0.72,
          height: bh * 0.22,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
    _paintGlyph(canvas, letter, center + Offset(0, bh * 0.04), bh * 0.52, Colors.white);
  }

  void _paintMath(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h * 0.42;

    canvas.drawCircle(Offset(w * 0.18, cy), h * 0.2, Paint()..color = const Color(0xFFFFF59D));
    final tri = Path()
      ..moveTo(w * 0.42, cy - h * 0.24)
      ..lineTo(w * 0.42 + h * 0.22, cy + h * 0.18)
      ..lineTo(w * 0.42 - h * 0.22, cy + h * 0.18)
      ..close();
    canvas.drawPath(tri, Paint()..color = const Color(0xFF80CBC4));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.66, cy + h * 0.02),
          width: h * 0.36,
          height: h * 0.36,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF90CAF9),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.52, h * 0.78),
          width: w * 0.62,
          height: h * 0.28,
        ),
        const Radius.circular(12),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
    _paintGlyph(
      canvas,
      '1＋2＝3',
      Offset(w * 0.52, h * 0.78),
      h * 0.2,
      Colors.white,
    );
  }

  void _paintScience(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fx = w * 0.38;
    final fy = h * 0.2;

    final neckW = w * 0.07;
    final flask = Path()
      ..moveTo(fx - neckW, fy)
      ..lineTo(fx - neckW, fy + h * 0.22)
      ..cubicTo(
        fx - w * 0.22,
        fy + h * 0.38,
        fx - w * 0.22,
        fy + h * 0.7,
        fx,
        fy + h * 0.72,
      )
      ..cubicTo(
        fx + w * 0.22,
        fy + h * 0.7,
        fx + w * 0.22,
        fy + h * 0.38,
        fx + neckW,
        fy + h * 0.22,
      )
      ..lineTo(fx + neckW, fy)
      ..close();

    canvas.drawPath(flask, Paint()..color = Colors.white.withValues(alpha: 0.88));

    final liquid = Path()
      ..moveTo(fx - w * 0.168, fy + h * 0.48)
      ..cubicTo(
        fx - w * 0.08,
        fy + h * 0.42,
        fx + w * 0.08,
        fy + h * 0.54,
        fx + w * 0.168,
        fy + h * 0.48,
      )
      ..cubicTo(
        fx + w * 0.2,
        fy + h * 0.66,
        fx + w * 0.12,
        fy + h * 0.7,
        fx,
        fy + h * 0.72,
      )
      ..cubicTo(
        fx - w * 0.12,
        fy + h * 0.7,
        fx - w * 0.2,
        fy + h * 0.66,
        fx - w * 0.168,
        fy + h * 0.48,
      )
      ..close();
    canvas.drawPath(liquid, Paint()..color = const Color(0xFF81C784));

    final rim = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawLine(
      Offset(fx - neckW - 2, fy),
      Offset(fx + neckW + 2, fy),
      rim,
    );

    final bubble = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(Offset(fx + w * 0.18, fy + h * 0.08), 5, bubble);
    canvas.drawCircle(Offset(fx + w * 0.28, fy - h * 0.02), 7, bubble);
    canvas.drawCircle(Offset(fx + w * 0.12, fy - h * 0.06), 4, bubble);

    _paintPlant(canvas, Offset(w * 0.78, h * 0.78), h * 0.42);
  }

  void _paintPlant(Canvas canvas, Offset base, double height) {
    final stem = Paint()
      ..color = const Color(0xFFA5D6A7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, base - Offset(0, height), stem);

    final leaf = Paint()..color = const Color(0xFF66BB6A);
    canvas.drawOval(
      Rect.fromCenter(
        center: base - Offset(height * 0.28, height * 0.45),
        width: height * 0.42,
        height: height * 0.22,
      ),
      leaf,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: base + Offset(height * 0.26, -height * 0.32),
        width: height * 0.38,
        height: height * 0.2,
      ),
      leaf,
    );
    canvas.drawCircle(
      base - Offset(0, height + 2),
      5,
      Paint()..color = const Color(0xFFFFF176),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: base + const Offset(0, 4), width: 22, height: 10),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFBCAAA4),
    );
  }

  void _paintSocial(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final c = Offset(w * 0.38, h * 0.5);
    final r = h * 0.36;

    canvas.drawCircle(c + const Offset(2, 3), r, Paint()..color = Colors.black.withValues(alpha: 0.1));
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF81D4FA));

    final land = Paint()..color = const Color(0xFF81C784);
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-r * 0.25, -r * 0.1), width: r * 0.9, height: r * 0.55),
      land,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(r * 0.35, r * 0.2), width: r * 0.55, height: r * 0.4),
      land,
    );

    final mer = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(c, r, mer);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 0.7, height: r * 2),
      mer,
    );
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), mer);

    _paintHouse(canvas, Offset(w * 0.78, h * 0.62), h * 0.42);
  }

  void _paintHouse(Canvas canvas, Offset center, double s) {
    final body = Rect.fromCenter(
      center: center + Offset(0, s * 0.12),
      width: s * 0.72,
      height: s * 0.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(3)),
      Paint()..color = const Color(0xFFFFF8E1),
    );
    final roof = Path()
      ..moveTo(center.dx - s * 0.48, center.dy - s * 0.08)
      ..lineTo(center.dx, center.dy - s * 0.48)
      ..lineTo(center.dx + s * 0.48, center.dy - s * 0.08)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFFEF9A9A));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, body.bottom - s * 0.12),
          width: s * 0.16,
          height: s * 0.26,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFFFCC80),
    );
    canvas.drawCircle(
      Offset(center.dx + s * 0.16, center.dy + s * 0.02),
      s * 0.07,
      Paint()..color = const Color(0xFF90CAF9),
    );
  }

  void _paintLife(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final sunC = Offset(w * 0.22, h * 0.38);
    canvas.drawCircle(sunC, h * 0.2, Paint()..color = const Color(0xFFFFF176));
    final ray = Paint()
      ..color = const Color(0xFFFFEE58)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final a = i * pi / 4;
      canvas.drawLine(
        sunC + Offset(cos(a), sin(a)) * h * 0.24,
        sunC + Offset(cos(a), sin(a)) * h * 0.34,
        ray,
      );
    }
    final face = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(sunC + Offset(-h * 0.06, -h * 0.02), 1.8, Paint()..color = const Color(0xFF6D4C41));
    canvas.drawCircle(sunC + Offset(h * 0.06, -h * 0.02), 1.8, Paint()..color = const Color(0xFF6D4C41));
    canvas.drawArc(
      Rect.fromCenter(center: sunC + Offset(0, h * 0.04), width: h * 0.16, height: h * 0.12),
      0.15,
      pi - 0.3,
      false,
      face,
    );

    final rainbowPaint = [
      const Color(0xFFEF9A9A),
      const Color(0xFFFFE082),
      const Color(0xFFA5D6A7),
    ];
    for (var i = 0; i < rainbowPaint.length; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(w * 0.58, h * 0.86),
          width: w * 0.68 - i * 12,
          height: h * 0.95 - i * 12,
        ),
        pi + 0.15,
        pi - 0.3,
        false,
        Paint()
          ..color = rainbowPaint[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.drawPath(
      _heart(Offset(w * 0.82, h * 0.28), h * 0.15),
      Paint()..color = const Color(0xFFFF8A80),
    );
  }

  @override
  bool shouldRepaint(covariant SubjectScenePainter oldDelegate) =>
      oldDelegate.subjectId != subjectId;
}

void _paintGlyph(
  Canvas canvas,
  String text,
  Offset center,
  double fontSize,
  Color color,
) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: color,
        height: 1,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
}

Path _star(Offset c, double r, int points) {
  final path = Path();
  for (var i = 0; i < points * 2; i++) {
    final radius = i.isEven ? r : r * 0.42;
    final a = -pi / 2 + i * pi / points;
    final p = Offset(c.dx + cos(a) * radius, c.dy + sin(a) * radius);
    if (i == 0) {
      path.moveTo(p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
  }
  path.close();
  return path;
}

Path _heart(Offset c, double s) {
  final path = Path();
  path.moveTo(c.dx, c.dy + s * 0.7);
  path.cubicTo(
    c.dx - s * 1.1,
    c.dy + s * 0.05,
    c.dx - s * 0.6,
    c.dy - s * 0.75,
    c.dx,
    c.dy - s * 0.22,
  );
  path.cubicTo(
    c.dx + s * 0.6,
    c.dy - s * 0.75,
    c.dx + s * 1.1,
    c.dy + s * 0.05,
    c.dx,
    c.dy + s * 0.7,
  );
  path.close();
  return path;
}
