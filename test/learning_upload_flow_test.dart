import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kid_learn/models/activity_stats.dart';
import 'package:kid_learn/providers/progress_provider.dart';
import 'package:kid_learn/services/learning_progress_sync.dart';
import 'package:kid_learn/services/learning_record_sync.dart';
import 'package:kid_learn/services/learning_records_api.dart';
import 'package:kid_learn/services/learning_upload_queue.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('queued plays retry, then restore without counting twice', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = ProgressProvider();
    await progress.load();
    final childId = (await progress.addProfile(
      name: '小華',
      grade: 2,
      avatar: '🦊',
    ))
        .id;

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final today = DateTime.now();
    final queue = LearningUploadQueue();
    await queue.enqueue(_record(
      id: 'daily-1',
      type: LearningActivityTypes.dailyReview,
      child: childId,
      correct: 8,
      total: 10,
      contextKey: 'math',
      at: yesterday,
    ));
    await queue.enqueue(_record(
      id: 'mem-404',
      type: LearningActivityTypes.gameMemoryMatch,
      child: 'missing-child',
      correct: 6,
      total: 6,
      duration: 40,
      at: today,
    ));
    await queue.enqueue(_record(
      id: 'bad-1',
      type: LearningActivityTypes.gameMathBlitz,
      child: childId,
      correct: 11,
      total: 10,
      at: today,
    ));
    await queue.enqueue(_record(
      id: 'rain-1',
      type: LearningActivityTypes.gameWordRain,
      child: childId,
      correct: 9,
      total: 9,
      at: today,
    ));
    await queue.enqueue(_record(
      id: 'math-1',
      type: LearningActivityTypes.gameMathBlitz,
      child: childId,
      correct: 18,
      total: 20,
      at: today,
    ));

    final first = _ScriptedRecordsApi([201, 404, 422, null]);
    await LearningRecordSync.flush(
      token: 'token',
      progress: progress,
      api: first,
      queue: queue,
    );

    expect(first.seen, ['daily-1', 'mem-404', 'bad-1', 'rain-1']);
    final waiting = await LearningUploadQueue().load();
    expect(
      waiting.map((item) => item.clientSubmissionId),
      ['mem-404', 'rain-1', 'math-1'],
    );

    final restarted = ProgressProvider();
    await restarted.load();
    final beforePull = restarted.activityOf(childId);
    expect(_attempts(beforePull, LearningActivityTypes.dailyReview), 1);
    expect(_attempts(beforePull, LearningActivityTypes.gameWordRain), 1);
    expect(_attempts(beforePull, LearningActivityTypes.gameMathBlitz), 1);
    expect(_best(beforePull, LearningActivityTypes.dailyReview), 8);
    expect(_best(beforePull, LearningActivityTypes.gameMathBlitz), 18);
    expect(restarted.activityOf('missing-child').activities.single.bestDurationSeconds, 40);
    expect(restarted.studyStreakOf(childId), 2);

    final remoteApi = _FlowApi(
      codes: const [404, 201, 201],
      children: [
        CloudChildProgress(
          studentId: 1,
          deviceLocalId: childId,
          name: '小華',
          grade: 2,
          lessons: [
            CloudLessonProgress(
              lessonId: 'math_g1_u1',
              stars: 3,
              lastScore: 9,
              questionCount: 10,
              lastStudiedAt: yesterday,
            ),
          ],
          activities: const [
            CloudActivitySummary(
              activityType: LearningActivityTypes.dailyReview,
              contextKey: 'math',
              bestCorrect: 8,
              bestQuestionCount: 10,
              bestPercent: 80,
              attempts: 1,
            ),
            CloudActivitySummary(
              activityType: LearningActivityTypes.gameMathBlitz,
              bestCorrect: 18,
              bestQuestionCount: 20,
              bestPercent: 90,
              attempts: 1,
            ),
            CloudActivitySummary(
              activityType: LearningActivityTypes.gameWordRain,
              bestCorrect: 9,
              bestQuestionCount: 9,
              bestPercent: 100,
              attempts: 1,
            ),
          ],
          studyDates: [studyDayKey(yesterday), studyDayKey(today)],
        ),
      ],
    );
    expect(
      await LearningProgressSync.pull(
        token: 'token',
        progress: restarted,
        api: remoteApi,
      ),
      isTrue,
    );
    expect(remoteApi.seen, ['mem-404', 'rain-1', 'math-1']);
    expect(
      (await LearningUploadQueue().load()).map((item) => item.clientSubmissionId),
      ['mem-404'],
    );

    final restored = restarted.activityOf(childId);
    expect(_attempts(restored, LearningActivityTypes.dailyReview), 1);
    expect(_attempts(restored, LearningActivityTypes.gameMathBlitz), 1);
    expect(_attempts(restored, LearningActivityTypes.gameWordRain), 1);
    expect(_best(restored, LearningActivityTypes.gameMathBlitz), 18);
    expect(restarted.progressOf('math_g1_u1').stars, 3);
    expect(restarted.studyStreakOf(childId), 2);
    expect(
      restarted.activityOf('missing-child').activities.single.bestDurationSeconds,
      40,
    );
  });
}

PendingLearningRecord _record({
  required String id,
  required String type,
  required String child,
  required int correct,
  required int total,
  required DateTime at,
  String? contextKey,
  int? duration,
}) {
  return PendingLearningRecord(
    clientSubmissionId: id,
    deviceLocalId: child,
    activityType: type,
    contextKey: contextKey,
    correctCount: correct,
    questionCount: total,
    durationSeconds: duration,
    recordedAt: at,
  );
}

int _attempts(ChildActivityStats stats, String type) {
  return stats.activities
      .where((item) => item.activityType == type)
      .fold(0, (sum, item) => sum + item.attempts);
}

int _best(ChildActivityStats stats, String type) {
  return stats.activities
      .where((item) => item.activityType == type)
      .fold(0, (best, item) => item.bestCorrect > best ? item.bestCorrect : best);
}

class _ScriptedRecordsApi extends LearningRecordsApi {
  _ScriptedRecordsApi(this._codes) : super(client: http.Client());

  final List<int?> _codes;
  final seen = <String>[];

  @override
  Future<void> submit({
    required String token,
    required String deviceLocalId,
    required String activityType,
    String? contextKey,
    String? title,
    required int correctCount,
    required int questionCount,
    List<LearningAnswer>? answers,
    int? durationSeconds,
    Map<String, dynamic>? meta,
    String? clientSubmissionId,
    DateTime? recordedAt,
  }) async {
    final code = _codes[seen.length];
    seen.add(clientSubmissionId ?? '');
    if (code != null && code >= 200 && code < 300) return;
    if (code == null) throw Exception('offline');
    throw LearningRecordApiException('fail', statusCode: code);
  }
}

class _FlowApi extends LearningRecordsApi {
  _FlowApi({
    required this.codes,
    required this.children,
  }) : super(client: http.Client());

  final List<int?> codes;
  final List<CloudChildProgress> children;
  final seen = <String>[];

  @override
  Future<void> submit({
    required String token,
    required String deviceLocalId,
    required String activityType,
    String? contextKey,
    String? title,
    required int correctCount,
    required int questionCount,
    List<LearningAnswer>? answers,
    int? durationSeconds,
    Map<String, dynamic>? meta,
    String? clientSubmissionId,
    DateTime? recordedAt,
  }) async {
    final code = codes[seen.length];
    seen.add(clientSubmissionId ?? '');
    if (code != null && code >= 200 && code < 300) return;
    if (code == null) throw Exception('offline');
    throw LearningRecordApiException('fail', statusCode: code);
  }

  @override
  Future<List<CloudChildProgress>> fetchProgress(String token) async {
    return children;
  }
}
