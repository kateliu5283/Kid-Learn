import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/question.dart';
import 'api_config.dart';
import 'curriculum_api.dart';

/// 結合「遠端 API」與「本地快取（SharedPreferences）」的題庫倉儲。
///
/// 使用方式：
/// ```
/// final repo = RemoteQuestionRepository();
/// await repo.warmUp();                  // app 啟動時呼叫一次
/// final qs = repo.questionsFor(subject: 'math', grade: 1, count: 10);
/// ```
class RemoteQuestionRepository {
  RemoteQuestionRepository({CurriculumApi? api})
      : _api = api ?? CurriculumApi();

  static const String _prefsKey = 'remote_questions_cache_v1';
  static const String _syncedAtKey = 'remote_questions_synced_at_v1';

  final CurriculumApi _api;
  List<RemoteQuestion> _cache = const [];
  DateTime? _cacheSyncedAt;

  bool get isReady => _cache.isNotEmpty;
  int get questionCount => _cache.length;
  DateTime? get lastSyncedAt => _cacheSyncedAt;

  /// app 啟動時呼叫：先載入本地快取；若過期再試著打 API。
  Future<void> warmUp() async {
    await _loadFromCache();
    if (_cacheSyncedAt == null ||
        DateTime.now().difference(_cacheSyncedAt!) > ApiConfig.cacheMaxAge) {
      // 背景嘗試同步，失敗沒關係（離線時用舊快取）
      unawaited(syncFromServer());
    }
  }

  /// 主動從 server 抓一份最新快照
  Future<bool> syncFromServer() async {
    try {
      final snap = await _api.fetchSnapshot();
      _cache = snap.questions;
      _cacheSyncedAt = snap.syncedAt;
      await _persist();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final syncedStr = prefs.getString(_syncedAtKey);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _cache = list
          .map((e) => RemoteQuestion.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _cache = const [];
    }
    if (syncedStr != null) {
      _cacheSyncedAt = DateTime.tryParse(syncedStr);
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, jsonEncode(_cache.map((q) => q.toJson()).toList()));
    if (_cacheSyncedAt != null) {
      await prefs.setString(_syncedAtKey, _cacheSyncedAt!.toIso8601String());
    }
  }

  /// 取得符合條件的題目（轉成 app 內 Question）
  List<Question> questionsFor({
    String? subject,
    int? grade,
    int count = 10,
    bool shuffle = true,
  }) {
    final filtered = _cache.where((q) {
      if (subject != null && q.subjectCode != subject) return false;
      if (grade != null && q.grade != grade) return false;
      return true;
    }).toList();

    if (shuffle) filtered.shuffle();
    return filtered.take(count).map((r) => r.toQuestion()).toList();
  }
}
