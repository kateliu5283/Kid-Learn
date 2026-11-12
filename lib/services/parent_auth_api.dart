import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ParentUser {
  const ParentUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.emailVerified = false,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final bool emailVerified;

  factory ParentUser.fromJson(Map<String, dynamic> json) {
    final verifiedFlag = json['email_verified'];
    final verifiedAt = json['email_verified_at'];
    final verified = verifiedFlag is bool
        ? verifiedFlag
        : (verifiedAt != null && verifiedAt.toString().isNotEmpty);
    return ParentUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      emailVerified: verified,
    );
  }
}

/// 雲端學生（`GET/POST /user/students` 與登入回傳的 `data.students`）。
class CloudStudent {
  const CloudStudent({
    required this.id,
    required this.name,
    required this.grade,
    this.avatar,
    this.deviceLocalId,
  });

  final int id;
  final String name;
  final int grade;
  final String? avatar;
  final String? deviceLocalId;

  factory CloudStudent.fromJson(Map<String, dynamic> json) {
    return CloudStudent(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      grade: (json['grade'] as num?)?.toInt() ?? 1,
      avatar: json['avatar'] as String?,
      deviceLocalId: json['device_local_id'] as String?,
    );
  }
}

typedef ParentAuthResult = ({
  ParentUser user,
  String token,
  List<CloudStudent> remoteStudents,
});

class ParentAuthException implements Exception {
  ParentAuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// 教師邀請 QR。連結 24 小時內有效，成功加入後即作廢。
class TeacherInviteLink {
  const TeacherInviteLink({required this.url, this.expiresAt});

  final String url;
  final DateTime? expiresAt;
}

/// App 家長帳號 API（對應 Laravel `POST /api/v1/user/*`）。
class ParentAuthApi {
  ParentAuthApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.defaultBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _u(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> _headers(String? bearerToken) {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (bearerToken != null && bearerToken.isNotEmpty) {
      h['Authorization'] = 'Bearer $bearerToken';
    }
    return h;
  }

  Future<ParentAuthResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    List<Map<String, dynamic>>? students,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    if (students != null && students.isNotEmpty) {
      body['students'] = students;
    }
    final res = await _client
        .post(
          _u('/user/register'),
          headers: _headers(null),
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);
    return _parseAuthResponse(res);
  }

  Future<ParentAuthResult> login({
    required String email,
    required String password,
  }) async {
    final res = await _client
        .post(
          _u('/user/login'),
          headers: _headers(null),
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        )
        .timeout(ApiConfig.timeout);
    return _parseAuthResponse(res);
  }

  /// 新增一筆雲端學生。若 `device_local_id` 與同家長既有資料衝突（422），回傳 `null`（視為已存在）。
  Future<CloudStudent?> createStudentOrSkipDuplicateDeviceId(
    String token, {
    required String name,
    required int grade,
    String? avatar,
    required String deviceLocalId,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'grade': grade,
      'device_local_id': deviceLocalId,
    };
    if (avatar != null && avatar.isNotEmpty) {
      body['avatar'] = avatar;
    }
    final res = await _client
        .post(
          _u('/user/students'),
          headers: _headers(token),
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);
    if (res.statusCode == 422) {
      dynamic decodedBody;
      try {
        decodedBody = jsonDecode(res.body);
      } catch (_) {
        throw ParentAuthException('資料驗證失敗');
      }
      if (decodedBody is Map<String, dynamic>) {
        final errors = decodedBody['errors'];
        if (errors is Map && errors['device_local_id'] != null) {
          return null;
        }
        final msg = _firstValidationMessage(decodedBody);
        throw ParentAuthException(msg ?? '資料驗證失敗');
      }
      throw ParentAuthException('資料驗證失敗');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ParentAuthException('無法新增學生（${res.statusCode}）');
    }
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>;
    return CloudStudent.fromJson(data);
  }

  /// 列出雲端學生（需家長 token）。
  Future<List<CloudStudent>> listStudents(String token) async {
    final res = await _client
        .get(
          _u('/user/students'),
          headers: _headers(token),
        )
        .timeout(ApiConfig.timeout);
    if (res.statusCode == 401) {
      throw ParentAuthException('登入已過期，請重新登入。');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ParentAuthException('無法取得孩子清單（${res.statusCode}）');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data is! List<dynamic>) {
      return [];
    }
    return data
        .map((e) => CloudStudent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 取得讓教師掃描加入的邀請網址（QR 內容）。`regenerate: true` 會作廢舊 QR。
  Future<TeacherInviteLink> teacherInviteJoinUrl(
    String token, {
    required int studentId,
    bool regenerate = false,
  }) async {
    final res = await _client
        .post(
          _u('/user/students/$studentId/teacher-invite'),
          headers: _headers(token),
          body: jsonEncode(<String, dynamic>{
            if (regenerate) 'regenerate': true,
          }),
        )
        .timeout(ApiConfig.timeout);
    if (res.statusCode == 401) {
      throw ParentAuthException('登入已過期，請重新登入。');
    }
    if (res.statusCode == 403) {
      try {
        final body = jsonDecode(res.body);
        if (body is Map && body['code'] == 'email_unverified') {
          throw ParentAuthException('請先完成 Email 驗證後再產生邀請。');
        }
        if (body is Map && body['message'] is String) {
          throw ParentAuthException(body['message'] as String);
        }
      } catch (e) {
        if (e is ParentAuthException) rethrow;
      }
      throw ParentAuthException('無權限產生邀請連結');
    }
    if (res.statusCode == 422 && jsonDecode(res.body) is Map<String, dynamic>) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw ParentAuthException(_firstValidationMessage(body) ?? '資料驗證失敗');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ParentAuthException('無法產生邀請連結（${res.statusCode}）');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>?;
    final url = data?['join_url'] as String?;
    if (url == null || url.isEmpty) {
      throw ParentAuthException('回應缺少 join_url');
    }
    final rawExpiry = data?['expires_at'] as String?;
    return TeacherInviteLink(
      url: url,
      expiresAt: rawExpiry == null ? null : DateTime.tryParse(rawExpiry),
    );
  }

  Future<void> logout(String token) async {
    final res = await _client
        .post(
          _u('/user/logout'),
          headers: _headers(token),
        )
        .timeout(ApiConfig.timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ParentAuthException('登出失敗（${res.statusCode}）');
    }
  }

  Future<ParentUser> me(String token) async {
    final res = await _client
        .get(
          _u('/user/me'),
          headers: _headers(token),
        )
        .timeout(ApiConfig.timeout);
    if (res.statusCode == 401) {
      throw ParentAuthException('登入已過期，請重新登入。');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ParentAuthException('無法取得帳號資料（${res.statusCode}）');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    final u = data['user'] as Map<String, dynamic>;
    return ParentUser.fromJson(u);
  }

  /// 寄出重設密碼信。不論 Email 是否存在，成功時都回同一句說明。
  Future<String> requestPasswordReset(String email) async {
    final res = await _client
        .post(
          _u('/user/forgot-password'),
          headers: _headers(null),
          body: jsonEncode({'email': email}),
        )
        .timeout(ApiConfig.timeout);
    return _readMessage(res, fallback: '若此 Email 已註冊，請至信箱重設密碼。');
  }

  /// 匯出家長、孩子與學習紀錄的 JSON 原文。
  Future<String> exportAccount(String token) async {
    final res = await _client
        .get(
          _u('/user/export'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 20));
    if (res.statusCode == 401) {
      throw ParentAuthException('登入已過期，請重新登入。');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ParentAuthException('無法匯出資料（${res.statusCode}）');
    }
    return res.body;
  }

  /// 以目前密碼刪除雲端家長帳號。
  Future<void> deleteAccount(String token, {required String password}) async {
    final res = await _client
        .delete(
          _u('/user/account'),
          headers: _headers(token),
          body: jsonEncode({'password': password}),
        )
        .timeout(ApiConfig.timeout);
    if (res.statusCode == 401) {
      throw ParentAuthException('登入已過期，請重新登入。');
    }
    if (res.statusCode == 429) {
      throw ParentAuthException(_messageFromBody(res.body) ?? '嘗試次數過多，請稍後再試。');
    }
    if (res.statusCode == 422) {
      dynamic decoded;
      try {
        decoded = jsonDecode(res.body);
      } catch (_) {
        throw ParentAuthException('密碼不正確。');
      }
      if (decoded is Map<String, dynamic>) {
        throw ParentAuthException(_firstValidationMessage(decoded) ?? '密碼不正確。');
      }
      throw ParentAuthException('密碼不正確。');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ParentAuthException('無法刪除帳號（${res.statusCode}）');
    }
  }

  Future<void> resendVerificationEmail(String token) async {
    final res = await _client
        .post(
          _u('/user/email/resend'),
          headers: _headers(token),
        )
        .timeout(ApiConfig.timeout);
    if (res.statusCode == 401) {
      throw ParentAuthException('登入已過期，請重新登入。');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ParentAuthException('無法重寄驗證信（${res.statusCode}）');
    }
  }

  ParentAuthResult _parseAuthResponse(http.Response res) {
    if (res.statusCode == 404) {
      throw ParentAuthException(
        '找不到 API（404）。請確認後端埠號與 App 的 API_BASE_URL 一致（預設為 8000；若使用 php artisan serve --port=8001 請設為 http://127.0.0.1:8001/api/v1）。',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ParentAuthException('請求失敗（${res.statusCode}）');
      }
      throw ParentAuthException('回應格式錯誤');
    }

    final body = decoded;
    if (res.statusCode == 422 && body is Map<String, dynamic>) {
      final msg = _firstValidationMessage(body);
      throw ParentAuthException(msg ?? '資料驗證失敗');
    }
    if (res.statusCode == 403 && body is Map<String, dynamic>) {
      final m = body['message'] as String?;
      throw ParentAuthException(m ?? '無法登入');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ParentAuthException('請求失敗（${res.statusCode}）');
    }
    if (body is! Map<String, dynamic>) {
      throw ParentAuthException('回應格式錯誤');
    }
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw ParentAuthException('回應缺少 data');
    }
    final u = data['user'] as Map<String, dynamic>?;
    final token = data['token'] as String?;
    if (u == null || token == null) {
      throw ParentAuthException('回應缺少 user 或 token');
    }
    final remoteStudents = _parseStudentsList(data['students']);
    return (
      user: ParentUser.fromJson(u),
      token: token,
      remoteStudents: remoteStudents,
    );
  }

  List<CloudStudent> _parseStudentsList(dynamic raw) {
    if (raw is! List<dynamic>) return [];
    return raw
        .map((e) => CloudStudent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> _readMessage(http.Response res, {required String fallback}) async {
    if (res.statusCode == 429) {
      throw ParentAuthException(_messageFromBody(res.body) ?? '嘗試次數過多，請稍後再試。');
    }
    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ParentAuthException('請求失敗（${res.statusCode}）');
      }
      return fallback;
    }
    if (res.statusCode == 422 && decoded is Map<String, dynamic>) {
      throw ParentAuthException(_firstValidationMessage(decoded) ?? '資料驗證失敗');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ParentAuthException('請求失敗（${res.statusCode}）');
    }
    if (decoded is Map && decoded['message'] is String) {
      return decoded['message'] as String;
    }
    return fallback;
  }

  String? _messageFromBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } catch (_) {}
    return null;
  }

  String? _firstValidationMessage(Map<String, dynamic> body) {
    final errors = body['errors'];
    if (errors is! Map) return body['message'] as String?;
    for (final entry in errors.entries) {
      final v = entry.value;
      if (v is List && v.isNotEmpty) {
        return v.first as String?;
      }
    }
    return body['message'] as String?;
  }
}
