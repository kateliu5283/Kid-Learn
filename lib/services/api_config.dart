/// 後端 API 設定。
///
/// 本地開發時，Flutter emulator 要連電腦上的 Laravel API Gateway：
///  - iOS 模擬器：`http://127.0.0.1:8000/api/v1`
/// 課程／題庫請求實際路徑為 `/api/v1/content/*`（由 CurriculumApi 組出）。
///  - Android 模擬器：`http://10.0.2.2:8000/api/v1`
///  - 真機：改成電腦內網 IP，例如 `http://192.168.1.100:8000/api/v1`
///  - Web：`http://127.0.0.1:8000/api/v1`
///
/// 啟動 Laravel：`cd backend && php artisan serve`
/// （埠號若非 8000，請用 `--dart-define=API_BASE_URL=...` 指向正確的 `/api/v1`。）
class ApiConfig {
  ApiConfig._();

  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  /// 連線 timeout
  static const Duration timeout = Duration(seconds: 8);

  /// 背景快取有效期（超過就重新同步；app 離線時仍可用舊快取）
  static const Duration cacheMaxAge = Duration(hours: 6);
}
