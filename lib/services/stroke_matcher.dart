import 'dart:math';
import 'package:flutter/widgets.dart';

import '../curriculum/handwriting/stroke_templates.dart';

/// 單筆評分結果
class StrokeScore {
  StrokeScore({
    required this.overall,
    required this.startMatch,
    required this.endMatch,
    required this.directionMatch,
    required this.shapeMatch,
  });

  /// 綜合分數 0..100
  final double overall;

  /// 起筆位置相符度 0..1
  final double startMatch;

  /// 收筆位置相符度 0..1
  final double endMatch;

  /// 方向相符度 0..1（-1..1 的 cosθ 線性映射）
  final double directionMatch;

  /// 整體形狀相符度 0..1（等距取樣後平均距離反向映射）
  final double shapeMatch;

  /// 是否達到合格門檻（可依難度調整）
  bool get passed => overall >= 60;

  /// 較嚴苛：漂亮
  bool get excellent => overall >= 85;

  /// 圖示顏色
  Color get color {
    if (excellent) return const Color(0xFF43A047);
    if (passed) return const Color(0xFFFFA726);
    return const Color(0xFFE53935);
  }

  String get label {
    if (excellent) return '很棒！';
    if (passed) return '再練一下';
    return '重畫一次';
  }
}

/// 整個字（多筆劃）的比對結果
class CharacterScore {
  CharacterScore({
    required this.char,
    required this.perStroke,
    required this.expectedStrokes,
    required this.actualStrokes,
  });

  final String char;

  /// 對每一筆的評分；若 expected > actual 則缺的筆以 null 表示
  final List<StrokeScore?> perStroke;

  final int expectedStrokes;
  final int actualStrokes;

  /// 平均分數 0..100（缺的筆算 0；多的筆不扣分但降權）
  double get overall {
    final filled = perStroke.map((s) => s?.overall ?? 0.0).toList();
    if (filled.isEmpty) return 0;
    final sum = filled.fold<double>(0, (a, b) => a + b);
    final base = sum / filled.length;
    // 筆劃數差異 penalty（差 1 筆 -5 分，最多扣 20）
    final penalty = min((actualStrokes - expectedStrokes).abs() * 5, 20);
    return (base - penalty).clamp(0, 100).toDouble();
  }

  bool get passed => overall >= 60;
  int get stars {
    if (overall >= 90) return 3;
    if (overall >= 75) return 2;
    if (overall >= 50) return 1;
    return 0;
  }
}

/// 軌跡比對器。所有 user 筆劃以「畫布像素座標」傳入，內部會依 `canvasSize` 正規化到 0-1。
class StrokeMatcher {
  StrokeMatcher({this.sampleCount = 24});

  /// 等距重新取樣的點數
  final int sampleCount;

  // ============================================================
  // 單筆比對
  // ============================================================
  StrokeScore matchStroke({
    required List<Offset> userPoints,
    required Size canvasSize,
    required StrokeTemplate template,
  }) {
    final user = _normalize(userPoints, canvasSize);
    final ref = List<Offset>.from(template.points);
    if (user.length < 2) {
      return StrokeScore(
          overall: 0,
          startMatch: 0,
          endMatch: 0,
          directionMatch: 0,
          shapeMatch: 0);
    }
    if (ref.length < 2) {
      return StrokeScore(
          overall: 50,
          startMatch: 0.5,
          endMatch: 0.5,
          directionMatch: 0.5,
          shapeMatch: 0.5);
    }

    final uSamples = _resample(user, sampleCount);
    final rSamples = _resample(ref, sampleCount);

    // 1) 起筆/收筆位置差異（距離越小越好）
    final startMatch = _distanceScore(uSamples.first, rSamples.first);
    final endMatch = _distanceScore(uSamples.last, rSamples.last);

    // 2) 方向（起點→終點）餘弦相似度
    final uDir = _normalize2(uSamples.last - uSamples.first);
    final rDir = _normalize2(rSamples.last - rSamples.first);
    final cos = (uDir.dx * rDir.dx + uDir.dy * rDir.dy).clamp(-1.0, 1.0);
    final directionMatch = ((cos + 1) / 2).toDouble(); // [-1,1] -> [0,1]

    // 3) 整體形狀：點對點平均距離
    double sumD = 0;
    for (var i = 0; i < sampleCount; i++) {
      sumD += (uSamples[i] - rSamples[i]).distance;
    }
    final avgDist = sumD / sampleCount;
    // 0.0 -> 1.0, 0.5 -> 0.0（0.5 是畫布對角線的一半，夠差了）
    final shapeMatch = (1.0 - (avgDist / 0.5)).clamp(0.0, 1.0).toDouble();

    final overall = (startMatch * 20 +
            endMatch * 20 +
            directionMatch * 25 +
            shapeMatch * 35)
        .clamp(0.0, 100.0)
        .toDouble();

    return StrokeScore(
      overall: overall,
      startMatch: startMatch,
      endMatch: endMatch,
      directionMatch: directionMatch,
      shapeMatch: shapeMatch,
    );
  }

  // ============================================================
  // 整字比對
  // ============================================================
  CharacterScore matchCharacter({
    required String char,
    required List<List<Offset>> userStrokes,
    required Size canvasSize,
  }) {
    final template = templateFor(char);
    if (template == null) {
      // 沒有 template：退化為「筆劃數差異 + 整體覆蓋」簡化評分
      return _fallbackScore(char, userStrokes, canvasSize);
    }

    final scores = <StrokeScore?>[];
    final expected = template.strokes.length;
    for (var i = 0; i < expected; i++) {
      if (i < userStrokes.length) {
        scores.add(matchStroke(
          userPoints: userStrokes[i],
          canvasSize: canvasSize,
          template: template.strokes[i],
        ));
      } else {
        scores.add(null);
      }
    }
    return CharacterScore(
      char: char,
      perStroke: scores,
      expectedStrokes: expected,
      actualStrokes: userStrokes.length,
    );
  }

  CharacterScore _fallbackScore(
      String char, List<List<Offset>> userStrokes, Size canvasSize) {
    // 每筆都給 55 分（及格邊緣），並以筆劃數差異作為 penalty 機制
    final s = StrokeScore(
      overall: 55,
      startMatch: 0.5,
      endMatch: 0.5,
      directionMatch: 0.5,
      shapeMatch: 0.5,
    );
    return CharacterScore(
      char: char,
      perStroke: List.filled(userStrokes.length, s),
      expectedStrokes: userStrokes.length,
      actualStrokes: userStrokes.length,
    );
  }

  // ============================================================
  // Helpers
  // ============================================================

  /// 把筆劃從畫布座標正規化到 0-1
  List<Offset> _normalize(List<Offset> pts, Size size) {
    return pts
        .map((p) => Offset(
              (p.dx / size.width).clamp(0.0, 1.0),
              (p.dy / size.height).clamp(0.0, 1.0),
            ))
        .toList(growable: false);
  }

  /// 把 polyline 重新取樣成 n 個等距點
  List<Offset> _resample(List<Offset> pts, int n) {
    if (pts.length == 1) return List.filled(n, pts.first);
    // 計算累計長度
    final lens = <double>[0];
    for (var i = 1; i < pts.length; i++) {
      lens.add(lens.last + (pts[i] - pts[i - 1]).distance);
    }
    final total = lens.last;
    if (total == 0) return List.filled(n, pts.first);
    final step = total / (n - 1);
    final out = <Offset>[pts.first];
    var cursor = step;
    var i = 1;
    while (out.length < n - 1) {
      while (i < pts.length - 1 && lens[i] < cursor) {
        i++;
      }
      final segLen = lens[i] - lens[i - 1];
      final t = segLen == 0 ? 0.0 : (cursor - lens[i - 1]) / segLen;
      out.add(Offset.lerp(pts[i - 1], pts[i], t)!);
      cursor += step;
    }
    out.add(pts.last);
    return out;
  }

  /// Offset 的距離轉換成 0..1 分數（距離越小分越高）
  double _distanceScore(Offset a, Offset b) {
    final d = (a - b).distance;
    // 0 -> 1, 0.35 -> 0（35% 畫布距離已算是非常錯）
    return (1.0 - (d / 0.35)).clamp(0.0, 1.0).toDouble();
  }

  Offset _normalize2(Offset v) {
    final m = v.distance;
    if (m == 0) return Offset.zero;
    return Offset(v.dx / m, v.dy / m);
  }
}
