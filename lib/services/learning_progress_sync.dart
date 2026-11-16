import '../providers/progress_provider.dart';
import 'learning_record_sync.dart';
import 'learning_records_api.dart';

/// 先補傳本機佇列，再把雲端課程、每日複習、遊戲與學習日期合併進本機。
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
      await LearningRecordSync.flush(token: token, progress: progress);
    } catch (_) {}
    try {
      final remote = await (api ?? _api).fetchProgress(token);
      await progress.applyCloudProgress(remote);
      return true;
    } catch (_) {
      return false;
    }
  }
}
