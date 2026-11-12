import 'package:flutter/foundation.dart';

/// 後端 API 設定。
///
/// 本地開發時，Flutter emulator 要連電腦上的 Laravel API Gateway：
///  - iOS 模擬器：`http://127.0.0.1:8000/api/v1`
///  - Android 模擬器：`http://10.0.2.2:8000/api/v1`
///  - 真機：改成電腦內網 IP，例如 `http://192.168.1.100:8000/api/v1`
///  - Web：`http://127.0.0.1:8000/api/v1`
///
/// 生產／release 建置**必須**使用 HTTPS：
/// `--dart-define=API_BASE_URL=https://api.example.com/api/v1`
///
/// 啟動 Laravel：`cd backend && php artisan serve`
class ApiConfig {
  ApiConfig._();

  static const String _rawBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  /// 已驗證的 API 根路徑。Release 建置禁止明文 HTTP。
  static String get defaultBaseUrl {
    final url = _rawBaseUrl.trim();
    if (kReleaseMode && !url.toLowerCase().startsWith('https://')) {
      throw StateError(
        'Release 建置必須以 HTTPS 設定 API_BASE_URL，目前為: $url',
      );
    }
    return url;
  }

  /// 連線 timeout
  static const Duration timeout = Duration(seconds: 8);

  /// 背景快取有效期（超過就重新同步；app 離線時仍可用舊快取）
  static const Duration cacheMaxAge = Duration(hours: 6);
}
