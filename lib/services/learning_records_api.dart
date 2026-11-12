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

/// 單題作答（伺服器依 `question_code` 對題庫評分）。
class LearningAnswer {
  const LearningAnswer({
    required this.questionCode,
    required this.selectedIndex,
  });

  final String questionCode;
  final int selectedIndex;

  Map<String, dynamic> toJson() => {
        'question_code': questionCode,
        'selected_index': selectedIndex,
      };
}

/// 上傳單筆答題／遊戲成績（需家長 Sanctum token + Email 已驗證）。
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
  /// 測驗／複習請帶 [answers]；雲端題庫題目由伺服器評分。
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
    if (answers != null && answers.isNotEmpty) {
      body['answers'] = answers.map((a) => a.toJson()).toList();
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
      String? code;
      try {
        final m = jsonDecode(res.body);
        if (m is Map && m['code'] is String) code = m['code'] as String;
      } catch (_) {}
      if (code == 'email_unverified') {
        throw LearningRecordApiException('請先完成 Email 驗證');
      }
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

  /// 已驗證家長的孩子與課程完成摘要（`GET /learning/progress`）。
  Future<List<CloudChildProgress>> fetchProgress(String token) async {
    final res = await _client
        .get(
          _u('/learning/progress'),
          headers: _headers(token),
        )
        .timeout(ApiConfig.timeout);

    if (res.statusCode == 401) {
      throw LearningRecordApiException('登入已過期');
    }
    if (res.statusCode == 403) {
      throw LearningRecordApiException('請先完成 Email 驗證');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw LearningRecordApiException('無法還原學習進度（${res.statusCode}）');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw LearningRecordApiException('回應格式錯誤');
    }
    final data = decoded['data'];
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => CloudChildProgress.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class CloudLessonProgress {
  const CloudLessonProgress({
    required this.lessonId,
    required this.stars,
    required this.lastScore,
    this.questionCount = 0,
    this.lastStudiedAt,
  });

  final String lessonId;
  final int stars;
  final int lastScore;
  final int questionCount;
  final DateTime? lastStudiedAt;

  factory CloudLessonProgress.fromJson(Map<String, dynamic> json) {
    return CloudLessonProgress(
      lessonId: json['lesson_id'] as String? ?? '',
      stars: (json['stars'] as num?)?.toInt() ?? 0,
      lastScore: (json['last_score'] as num?)?.toInt() ?? 0,
      questionCount: (json['question_count'] as num?)?.toInt() ?? 0,
      lastStudiedAt: json['last_studied_at'] == null
          ? null
          : DateTime.tryParse(json['last_studied_at'] as String),
    );
  }
}

class CloudChildProgress {
  const CloudChildProgress({
    required this.studentId,
    required this.name,
    required this.grade,
    required this.lessons,
    this.deviceLocalId,
    this.avatar,
  });

  final int studentId;
  final String? deviceLocalId;
  final String name;
  final int grade;
  final String? avatar;
  final List<CloudLessonProgress> lessons;

  factory CloudChildProgress.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessons'];
    final lessons = rawLessons is List
        ? rawLessons
            .whereType<Map>()
            .map((e) => CloudLessonProgress.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList()
        : <CloudLessonProgress>[];
    return CloudChildProgress(
      studentId: (json['student_id'] as num).toInt(),
      deviceLocalId: json['device_local_id'] as String?,
      name: json['name'] as String? ?? '小朋友',
      grade: (json['grade'] as num?)?.toInt() ?? 1,
      avatar: json['avatar'] as String?,
      lessons: lessons,
    );
  }
}

class LearningRecordApiException implements Exception {
  LearningRecordApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
