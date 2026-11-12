import 'package:flutter_test/flutter_test.dart';
import 'package:kid_learn/models/user_progress.dart';

void main() {
  test('keeps higher stars and newer score', () {
    final local = LessonProgress(
      lessonId: 'math_g1_u1',
      completed: true,
      stars: 3,
      lastScore: 10,
      lastStudiedAt: DateTime.utc(2026, 1, 1),
    );
    final merged = mergeRemoteLesson(
      local,
      RemoteLessonSnapshot(
        lessonId: 'math_g1_u1',
        stars: 1,
        lastScore: 5,
        lastStudiedAt: DateTime.utc(2026, 2, 1),
      ),
    );

    expect(merged.stars, 3);
    expect(merged.lastScore, 5);
    expect(merged.completed, isTrue);
    expect(merged.lastStudiedAt, DateTime.utc(2026, 2, 1));
  });

  test('does not replace a newer local score with an older cloud score', () {
    final local = LessonProgress(
      lessonId: 'chi_g1_u1',
      completed: true,
      stars: 2,
      lastScore: 8,
      lastStudiedAt: DateTime.utc(2026, 3, 1),
    );
    final merged = mergeRemoteLesson(
      local,
      RemoteLessonSnapshot(
        lessonId: 'chi_g1_u1',
        stars: 3,
        lastScore: 10,
        lastStudiedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    expect(merged.stars, 3);
    expect(merged.lastScore, 8);
    expect(merged.lastStudiedAt, DateTime.utc(2026, 3, 1));
  });
}
