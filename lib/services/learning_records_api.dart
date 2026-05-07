import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// 與後端 `activity_type` 對齊（`POST /learning/records`）。
abstract final class LearningActivityTypes {
  static const String lessonQuiz = 'lesson_quiz';
  static const String lessonReview = 'lesson_review';
  static const String dailyReview = 'daily_review';
  static const String gameMathBlitz = 'game_math_blitz';
  static const String gameMemoryMatch = 'game_memory_match';
  static const String gameWordRain = 'game_word_rain';
}

/// 上傳單筆答題／遊戲成績（需家長 Sanctum token）。
class LearningRecordsApi {
  LearningRecordsApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.defaultBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _u(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> _headers(String bearerToken) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      };

  /// 以 `device_local_id`（本機孩子 profile id）對應雲端學生。
  Future<void> submit({
    required String token,
    required String deviceLocalId,
    required String activityType,
    String? contextKey,
    String? title,
    required int correctCount,
    required int questionCount,
    int? durationSeconds,
    Map<String, dynamic>? meta,
    String? clientSubmissionId,
    DateTime? recordedAt,
  }) async {
    final body = <String, dynamic>{
      'device_local_id': deviceLocalId,
      'activity_type': activityType,
      'correct_count': correctCount,
      'question_count': questionCount,
    };
    if (contextKey != null && contextKey.isNotEmpty) {
      body['context_key'] = contextKey;
    }
    if (title != null && title.isNotEmpty) {
      body['title'] = title;
    }
    if (durationSeconds != null) {
      body['duration_seconds'] = durationSeconds;
    }
    if (meta != null && meta.isNotEmpty) {
      body['meta'] = meta;
    }
    if (clientSubmissionId != null && clientSubmissionId.isNotEmpty) {
      body['client_submission_id'] = clientSubmissionId;
    }
    if (recordedAt != null) {
      body['recorded_at'] = recordedAt.toUtc().toIso8601String();
    }

    final res = await _client
        .post(
          _u('/learning/records'),
          headers: _headers(token),
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);

    if (res.statusCode == 401) {
      throw LearningRecordApiException('登入已過期');
    }
    if (res.statusCode == 404) {
      throw LearningRecordApiException('找不到雲端學生，請確認已登入家長帳號並同步孩子。');
    }
    if (res.statusCode == 403) {
      throw LearningRecordApiException('無權限上傳');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String? msg;
      try {
        final m = jsonDecode(res.body);
        if (m is Map && m['message'] is String) {
          msg = m['message'] as String;
        }
      } catch (_) {}
      throw LearningRecordApiException(msg ?? '上傳失敗（${res.statusCode}）');
    }
  }
}

class LearningRecordApiException implements Exception {
  LearningRecordApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
