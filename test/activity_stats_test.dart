import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_learn/models/activity_stats.dart';
import 'package:kid_learn/services/learning_records_api.dart';
import 'package:kid_learn/services/learning_upload_queue.dart';

void main() {
  test('study streak counts today, or yesterday when today is empty', () {
    final today = DateTime(2026, 11, 16);
    expect(
      studyStreak({'2026-11-14', '2026-11-15', '2026-11-16'}, today),
      3,
    );
    expect(studyStreak({'2026-11-14', '2026-11-15'}, today), 2);
    expect(studyStreak({'2026-11-16'}, today), 1);
    expect(studyStreak({'2026-11-14'}, today), 0);
    expect(studyStreak({}, today), 0);
  });

  test('fold adds a pending play once, and drops it after absorb', () {
    final server = ChildActivityStats(
      studyDates: const ['2026-11-15'],
      activities: [
        ActivitySnapshot(
          activityType: LearningActivityTypes.gameMathBlitz,
          contextKey: '',
          bestCorrect: 12,
          bestQuestionCount: 20,
          bestPercent: 60,
          attempts: 2,
          lastRecordedAt: DateTime.utc(2026, 11, 15),
        ),
      ],
    );
    final pending = PendingLearningRecord(
      clientSubmissionId: 'sub-1',
      deviceLocalId: 'p1',
      activityType: LearningActivityTypes.gameMathBlitz,
      correctCount: 15,
      questionCount: 20,
      recordedAt: DateTime(2026, 11, 16, 8),
    );

    final folded = foldActivities(server, [pending]);
    expect(folded.activities.single.attempts, 3);
    expect(folded.activities.single.bestCorrect, 15);
    expect(folded.activities.single.bestQuestionCount, 20);
    expect(folded.studyDates, ['2026-11-15', '2026-11-16']);

    final absorbed = foldActivities(server, [pending]);
    final display = foldActivities(absorbed, const []);
    expect(display.activities.single.attempts, 3);
    expect(display.activities.single.bestCorrect, 15);
  });

  test('pending lesson quiz updates the study date without a game row', () {
    final pending = PendingLearningRecord(
      clientSubmissionId: 'sub-2',
      deviceLocalId: 'p1',
      activityType: LearningActivityTypes.lessonQuiz,
      contextKey: 'math_g1_u1',
      correctCount: 8,
      questionCount: 10,
      recordedAt: DateTime(2026, 11, 16, 9),
    );
    final folded = foldActivities(ChildActivityStats.empty, [pending]);
    expect(folded.activities, isEmpty);
    expect(folded.studyDates, ['2026-11-16']);
  });

  test('pending record json round trip keeps the submission id', () {
    final original = PendingLearningRecord(
      clientSubmissionId: 'sub-3',
      deviceLocalId: 'p1',
      activityType: LearningActivityTypes.gameMemoryMatch,
      title: '記憶翻牌',
      correctCount: 6,
      questionCount: 6,
      answers: const [
        LearningAnswer(questionCode: 'q1', selectedIndex: 2),
      ],
      durationSeconds: 25,
      meta: const {'topic': 'animals', 'moves': 12},
      recordedAt: DateTime.utc(2026, 11, 16, 1, 30),
    );

    final restored = PendingLearningRecord.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(jsonEncode(original.toJson())) as Map,
      ),
    );
    expect(restored.clientSubmissionId, 'sub-3');
    expect(restored.deviceLocalId, 'p1');
    expect(restored.activityType, LearningActivityTypes.gameMemoryMatch);
    expect(restored.correctCount, 6);
    expect(restored.durationSeconds, 25);
    expect(restored.answers.single.questionCode, 'q1');
    expect(restored.answers.single.selectedIndex, 2);
    expect(restored.meta?['moves'], 12);
    expect(restored.recordedAt.toUtc(), original.recordedAt.toUtc());
  });
}
