import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/parent_auth_provider.dart';
import '../providers/progress_provider.dart';
import 'learning_records_api.dart';

/// 在測驗／複習／遊戲完成後背景上傳（未登入家長則略過）。
class LearningRecordSync {
  LearningRecordSync._();

  static final _random = Random();
  static final _api = LearningRecordsApi();

  static String _clientSubmissionId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(0x7fffffff)}';

  static Future<void> trySubmit(
    BuildContext context, {
    required String activityType,
    String? contextKey,
    String? title,
    required int correctCount,
    required int questionCount,
    int? durationSeconds,
    Map<String, dynamic>? meta,
  }) async {
    final auth = context.read<ParentAuthProvider>();
    if (!auth.isSignedIn || auth.token == null) return;

    final profile = context.read<ProgressProvider>().profile;
    final localId = profile.id;
    if (localId.isEmpty || localId == 'guest') return;

    try {
      await _api.submit(
        token: auth.token!,
        deviceLocalId: localId,
        activityType: activityType,
        contextKey: contextKey,
        title: title,
        correctCount: correctCount,
        questionCount: questionCount,
        durationSeconds: durationSeconds,
        meta: meta,
        clientSubmissionId: _clientSubmissionId(),
      );
    } catch (_) {
      // 背景同步：不阻斷兒童操作、不顯示錯誤
    }
  }
}
