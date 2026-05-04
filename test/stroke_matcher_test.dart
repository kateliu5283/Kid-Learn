import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kid_learn/services/stroke_matcher.dart';
import 'package:kid_learn/curriculum/handwriting/stroke_templates.dart';

void main() {
  group('StrokeMatcher', () {
    test('identical stroke vs template scores high', () {
      final tmpl = StrokeTemplate(points: const [
        Offset(0.1, 0.5),
        Offset(0.5, 0.5),
        Offset(0.9, 0.5),
      ]);
      final user = [
        Offset(10, 50),
        Offset(50, 50),
        Offset(90, 50),
      ];
      final m = StrokeMatcher(sampleCount: 16);
      final s = m.matchStroke(
        userPoints: user,
        canvasSize: const Size(100, 100),
        template: tmpl,
      );
      expect(s.overall, greaterThan(85));
      expect(s.pathTangentMatch, greaterThan(0.9));
    });

    test('orthogonal direction lowers chord alignment', () {
      final tmpl = StrokeTemplate(points: const [
        Offset(0.2, 0.5),
        Offset(0.8, 0.5),
      ]);
      final user = [
        Offset(50, 20),
        Offset(50, 80),
      ];
      final m = StrokeMatcher(sampleCount: 24);
      final s = m.matchStroke(
        userPoints: user,
        canvasSize: const Size(100, 100),
        template: tmpl,
      );
      expect(s.directionMatch, lessThan(0.55));
    });
  });
}
