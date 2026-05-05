import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ParentUser {
  const ParentUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final int id;
  final String name;
  final String email;
  final String role;

  factory ParentUser.fromJson(Map<String, dynamic> json) {
    return ParentUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
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
