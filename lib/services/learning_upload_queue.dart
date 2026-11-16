import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'learning_records_api.dart';

/// 尚未成功送到雲端的一筆學習紀錄。`clientSubmissionId` 固定，重送不會變成兩筆。
class PendingLearningRecord {
  const PendingLearningRecord({
    required this.clientSubmissionId,
    required this.deviceLocalId,
    required this.activityType,
    required this.correctCount,
    required this.questionCount,
    required this.recordedAt,
    this.contextKey,
    this.title,
    this.answers = const [],
    this.durationSeconds,
    this.meta,
  });

  final String clientSubmissionId;
  final String deviceLocalId;
  final String activityType;
  final String? contextKey;
  final String? title;
  final int correctCount;
  final int questionCount;
  final List<LearningAnswer> answers;
  final int? durationSeconds;
  final Map<String, dynamic>? meta;
  final DateTime recordedAt;

  Map<String, dynamic> toJson() => {
        'clientSubmissionId': clientSubmissionId,
        'deviceLocalId': deviceLocalId,
        'activityType': activityType,
        'contextKey': contextKey,
        'title': title,
        'correctCount': correctCount,
        'questionCount': questionCount,
        'answers': answers.map((a) => a.toJson()).toList(),
        'durationSeconds': durationSeconds,
        'meta': meta,
        'recordedAt': recordedAt.toIso8601String(),
      };

  factory PendingLearningRecord.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    final answers = rawAnswers is List
        ? rawAnswers.whereType<Map>().map((e) {
            final map = Map<String, dynamic>.from(e);
            return LearningAnswer(
              questionCode: map['question_code'] as String? ?? '',
              selectedIndex: (map['selected_index'] as num?)?.toInt() ?? 0,
            );
          }).toList()
        : <LearningAnswer>[];
    final rawMeta = json['meta'];
    return PendingLearningRecord(
      clientSubmissionId: json['clientSubmissionId'] as String? ?? '',
      deviceLocalId: json['deviceLocalId'] as String? ?? '',
      activityType: json['activityType'] as String? ?? '',
      contextKey: json['contextKey'] as String?,
      title: json['title'] as String?,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
      answers: answers,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      meta: rawMeta is Map ? Map<String, dynamic>.from(rawMeta) : null,
      recordedAt: DateTime.tryParse(json['recordedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// 本機補傳佇列。上傳成功或確定無法再送（422）才移除。
class LearningUploadQueue {
  LearningUploadQueue({SharedPreferences? preferences})
      : _preferences = preferences;

  static const storageKey = 'learning_upload_queue_v1';
  static const maxItems = 100;

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ?? await SharedPreferences.getInstance();

  Future<List<PendingLearningRecord>> load() async {
    final raw = (await _prefs).getString(storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => PendingLearningRecord.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .where((e) =>
              e.clientSubmissionId.isNotEmpty && e.deviceLocalId.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<PendingLearningRecord> items) async {
    final trimmed = items.length <= maxItems
        ? items
        : items.sublist(items.length - maxItems);
    await (await _prefs).setString(
      storageKey,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<PendingLearningRecord>> enqueue(PendingLearningRecord item) async {
    final items = await load();
    items.add(item);
    await save(items);
    return load();
  }

  Future<void> clear() async {
    await (await _prefs).remove(storageKey);
  }
}
