import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/parent_auth_provider.dart';
import '../providers/progress_provider.dart';
import 'learning_records_api.dart';
import 'learning_upload_queue.dart';

/// 測驗、複習與遊戲完成後先記入本機佇列，已驗證且有網路時再補傳。
class LearningRecordSync {
  LearningRecordSync._();

  static final _random = Random();
  static final _api = LearningRecordsApi();
  static const _maxPerFlush = 15;

  static String _clientSubmissionId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(0x7fffffff)}';

  static Future<void> trySubmit(
    BuildContext context, {
    required String activityType,
    String? contextKey,
    String? title,
    required int correctCount,
    required int questionCount,
    List<LearningAnswer>? answers,
    int? durationSeconds,
    Map<String, dynamic>? meta,
  }) async {
    final auth = context.read<ParentAuthProvider>();
    final progress = context.read<ProgressProvider>();
    final localId = progress.profile.id;
    if (localId.isEmpty || localId == 'guest') return;

    final queue = LearningUploadQueue();
    final pending = await queue.enqueue(PendingLearningRecord(
      clientSubmissionId: _clientSubmissionId(),
      deviceLocalId: localId,
      activityType: activityType,
      contextKey: contextKey,
      title: title,
      correctCount: correctCount,
      questionCount: questionCount,
      answers: answers ?? const [],
      durationSeconds: durationSeconds,
      meta: meta,
      recordedAt: DateTime.now(),
    ));
    await progress.setPendingActivities(pending);

    final token = auth.token;
    if (!auth.isSignedIn || token == null || !auth.isEmailVerified) return;
    await flush(token: token, progress: progress, queue: queue);
  }

  /// 依序補傳。網路錯誤、401、未驗證會停下並保留佇列；422 視為無法再送而捨棄。
  static Future<void> flush({
    required String token,
    required ProgressProvider progress,
    LearningRecordsApi? api,
    LearningUploadQueue? queue,
  }) async {
    final q = queue ?? LearningUploadQueue();
    final client = api ?? _api;
    final items = await q.load();
    if (items.isEmpty) {
      await progress.setPendingActivities(const []);
      return;
    }

    final remaining = <PendingLearningRecord>[];
    var sent = 0;
    var stop = false;
    for (final item in items) {
      if (stop || sent >= _maxPerFlush) {
        remaining.add(item);
        continue;
      }
      sent++;
      try {
        await client.submit(
          token: token,
          deviceLocalId: item.deviceLocalId,
          activityType: item.activityType,
          contextKey: item.contextKey,
          title: item.title,
          correctCount: item.correctCount,
          questionCount: item.questionCount,
          answers: item.answers,
          durationSeconds: item.durationSeconds,
          meta: item.meta,
          clientSubmissionId: item.clientSubmissionId,
          recordedAt: item.recordedAt,
        );
        await progress.absorbUploaded(item);
      } on LearningRecordApiException catch (e) {
        if (e.statusCode == 422) continue;
        remaining.add(item);
        if (e.statusCode != 404) stop = true;
      } catch (_) {
        remaining.add(item);
        stop = true;
      }
    }

    await q.save(remaining);
    await progress.setPendingActivities(remaining);
  }
}
