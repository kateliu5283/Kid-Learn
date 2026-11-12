import '../providers/progress_provider.dart';
import 'learning_records_api.dart';

/// 把已驗證家長帳號上的課程完成與星星合併進本機。
class LearningProgressSync {
  LearningProgressSync._();

  static final _api = LearningRecordsApi();

  /// 成功回傳 true。未驗證、離線或伺服器錯誤回傳 false，不丟出例外。
  static Future<bool> pull({
    required String token,
    required ProgressProvider progress,
    LearningRecordsApi? api,
  }) async {
    try {
      final remote = await (api ?? _api).fetchProgress(token);
      await progress.applyCloudProgress(remote);
      return true;
    } catch (_) {
      return false;
    }
  }
}
