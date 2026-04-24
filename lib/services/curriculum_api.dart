import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/question.dart';
import 'api_config.dart';

/// 從 Laravel 後端取得題庫／課程的 service。
///
/// 介面對應 backend `routes/api.php`：
///   GET  /v1/subjects
///   GET  /v1/lessons
///   GET  /v1/lessons/{code}
///   GET  /v1/questions
///   GET  /v1/snapshot
class CurriculumApi {
  CurriculumApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.defaultBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _u(String path, [Map<String, dynamic>? query]) {
    final qs = query?.map((k, v) => MapEntry(k, '$v'));
    return Uri.parse('$_baseUrl$path').replace(queryParameters: qs);
  }

  Future<bool> ping() async {
    try {
      final res = await _client
          .get(_u('/ping'))
          .timeout(ApiConfig.timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 取得題目（可過濾）
  Future<List<RemoteQuestion>> fetchQuestions({
    String? subjectCode,
    int? grade,
    String? lessonCode,
    String? difficulty,
    bool random = false,
    int limit = 50,
  }) async {
    final res = await _client
        .get(_u('/questions', {
          if (subjectCode != null) 'subject': subjectCode,
          if (grade != null) 'grade': grade,
          if (lessonCode != null) 'lesson': lessonCode,
          if (difficulty != null) 'difficulty': difficulty,
          'random': random ? 1 : 0,
          'limit': limit,
        }))
        .timeout(ApiConfig.timeout);

    _throwIfError(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .map((e) => RemoteQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 一次抓整份快照（subjects + lessons + 免費題目）
  Future<CurriculumSnapshot> fetchSnapshot() async {
    final res = await _client
        .get(_u('/snapshot'))
        .timeout(ApiConfig.timeout);
    _throwIfError(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return CurriculumSnapshot.fromJson(body);
  }

  void _throwIfError(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('API error ${res.statusCode}: ${res.body}');
    }
  }

  void close() => _client.close();
}

/// 從後端拉下的題目 DTO（可以轉成 app 內的 [Question]）
class RemoteQuestion {
  RemoteQuestion({
    required this.code,
    required this.subjectCode,
    required this.grade,
    required this.lessonCode,
    required this.type,
    required this.difficulty,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.imageUrl,
    this.isPremium = false,
  });

  final String code;
  final String? subjectCode;
  final int grade;
  final String? lessonCode;
  final String type;
  final String difficulty;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String? imageUrl;
  final bool isPremium;

  Question toQuestion() => Question(
        id: code,
        type: _parseType(type),
        prompt: prompt,
        options: options,
        correctIndex: correctIndex,
        explanation: explanation,
      );

  static QuestionType _parseType(String t) => switch (t) {
        'true_false' => QuestionType.trueFalse,
        'fill_blank' => QuestionType.fillBlank,
        _ => QuestionType.multipleChoice,
      };

  factory RemoteQuestion.fromJson(Map<String, dynamic> j) => RemoteQuestion(
        code: j['code'] as String,
        subjectCode: j['subject_code'] as String?,
        grade: (j['grade'] as num).toInt(),
        lessonCode: j['lesson_code'] as String?,
        type: j['type'] as String? ?? 'multiple_choice',
        difficulty: j['difficulty'] as String? ?? 'normal',
        prompt: j['prompt'] as String,
        options: (j['options'] as List<dynamic>).cast<String>(),
        correctIndex: (j['correct_index'] as num).toInt(),
        explanation: j['explanation'] as String?,
        imageUrl: j['image_url'] as String?,
        isPremium: j['is_premium'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'subject_code': subjectCode,
        'grade': grade,
        'lesson_code': lessonCode,
        'type': type,
        'difficulty': difficulty,
        'prompt': prompt,
        'options': options,
        'correct_index': correctIndex,
        'explanation': explanation,
        'image_url': imageUrl,
        'is_premium': isPremium,
      };
}

class CurriculumSnapshot {
  CurriculumSnapshot({
    required this.questions,
    required this.syncedAt,
  });

  final List<RemoteQuestion> questions;
  final DateTime syncedAt;

  factory CurriculumSnapshot.fromJson(Map<String, dynamic> j) {
    final qs = (j['questions'] as List<dynamic>? ?? [])
        .map((e) => RemoteQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    final sa = j['meta']?['synced_at'];
    return CurriculumSnapshot(
      questions: qs,
      syncedAt: sa is String
          ? (DateTime.tryParse(sa) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}
