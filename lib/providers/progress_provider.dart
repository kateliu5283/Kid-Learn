import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';

/// 管理多帳號 + 各帳號的學習進度
class ProgressProvider extends ChangeNotifier {
  static const _kProfilesKey = 'profiles_v2';
  static const _kCurrentIdKey = 'current_profile_id';
  static const _kProgressPrefix = 'progress_';

  // 舊版單帳號的 keys（用於遷移）
  static const _kLegacyProfileKey = 'user_profile';
  static const _kLegacyProgressKey = 'lesson_progress';

  List<UserProfile> _profiles = [];
  String? _currentId;

  /// profileId -> (lessonId -> LessonProgress)
  final Map<String, Map<String, LessonProgress>> _progressByProfile = {};

  bool _loaded = false;

  List<UserProfile> get profiles => List.unmodifiable(_profiles);
  bool get loaded => _loaded;
  bool get hasAnyProfile => _profiles.isNotEmpty;

  UserProfile get profile {
    if (_currentId != null) {
      final found = _profiles.where((p) => p.id == _currentId);
      if (found.isNotEmpty) return found.first;
    }
    if (_profiles.isNotEmpty) return _profiles.first;
    return UserProfile(
      id: 'guest',
      name: '小朋友',
      grade: 1,
      createdAt: DateTime.now(),
    );
  }

  Map<String, LessonProgress> get _currentProgress =>
      _progressByProfile.putIfAbsent(profile.id, () => {});

  int get totalStars =>
      _currentProgress.values.fold(0, (sum, p) => sum + p.stars);

  int get completedCount =>
      _currentProgress.values.where((p) => p.completed).length;

  LessonProgress progressOf(String lessonId) =>
      _currentProgress[lessonId] ?? LessonProgress(lessonId: lessonId);

  double subjectProgress(Iterable<String> lessonIds) {
    if (lessonIds.isEmpty) return 0;
    final done = lessonIds.where((id) => progressOf(id).completed).length;
    return done / lessonIds.length;
  }

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();

    // 讀取帳號清單
    final profilesJson = sp.getString(_kProfilesKey);
    if (profilesJson != null) {
      final list = jsonDecode(profilesJson) as List<dynamic>;
      _profiles = list
          .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    _currentId = sp.getString(_kCurrentIdKey);

    // 舊版資料遷移（只遷移一次）
    if (_profiles.isEmpty) {
      final legacyProfile = sp.getString(_kLegacyProfileKey);
      if (legacyProfile != null) {
        final legacy =
            jsonDecode(legacyProfile) as Map<String, dynamic>;
        final migrated = UserProfile(
          id: _generateId(),
          name: legacy['name'] as String? ?? '小朋友',
          grade: legacy['grade'] as int? ?? 1,
          avatar: legacy['avatar'] as String? ?? '🦊',
          createdAt: DateTime.now(),
        );
        _profiles.add(migrated);
        _currentId = migrated.id;

        final legacyProgress = sp.getString(_kLegacyProgressKey);
        if (legacyProgress != null) {
          final decoded =
              jsonDecode(legacyProgress) as Map<String, dynamic>;
          final map = decoded.map(
            (k, v) => MapEntry(
              k,
              LessonProgress.fromJson(v as Map<String, dynamic>),
            ),
          );
          _progressByProfile[migrated.id] = map;
        }

        await _save(sp);
        await sp.remove(_kLegacyProfileKey);
        await sp.remove(_kLegacyProgressKey);
      }
    }

    // 載入每個 profile 的進度
    for (final p in _profiles) {
      final key = '$_kProgressPrefix${p.id}';
      final raw = sp.getString(key);
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _progressByProfile[p.id] = decoded.map(
          (k, v) => MapEntry(
            k,
            LessonProgress.fromJson(v as Map<String, dynamic>),
          ),
        );
      } else {
        _progressByProfile.putIfAbsent(p.id, () => {});
      }
    }

    if (_currentId == null && _profiles.isNotEmpty) {
      _currentId = _profiles.first.id;
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> _save(SharedPreferences sp) async {
    await sp.setString(
      _kProfilesKey,
      jsonEncode(_profiles.map((e) => e.toJson()).toList()),
    );
    if (_currentId != null) {
      await sp.setString(_kCurrentIdKey, _currentId!);
    }
  }

  Future<void> _saveCurrentProgress() async {
    final sp = await SharedPreferences.getInstance();
    final id = profile.id;
    final map = _progressByProfile[id] ?? {};
    await sp.setString(
      '$_kProgressPrefix$id',
      jsonEncode(map.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }

  Future<UserProfile> addProfile({
    required String name,
    required int grade,
    required String avatar,
    bool makeCurrent = true,
  }) async {
    final profile = UserProfile(
      id: _generateId(),
      name: name.trim().isEmpty ? '小朋友' : name.trim(),
      grade: grade,
      avatar: avatar,
      createdAt: DateTime.now(),
    );
    _profiles.add(profile);
    _progressByProfile[profile.id] = {};
    if (makeCurrent) _currentId = profile.id;

    final sp = await SharedPreferences.getInstance();
    await _save(sp);
    notifyListeners();
    return profile;
  }

  Future<void> updateProfile(UserProfile updated) async {
    final idx = _profiles.indexWhere((p) => p.id == updated.id);
    if (idx >= 0) {
      _profiles[idx] = updated;
      final sp = await SharedPreferences.getInstance();
      await _save(sp);
      notifyListeners();
    }
  }

  Future<void> switchTo(String id) async {
    if (_profiles.any((p) => p.id == id)) {
      _currentId = id;
      final sp = await SharedPreferences.getInstance();
      await _save(sp);
      notifyListeners();
    }
  }

  Future<void> deleteProfile(String id) async {
    if (_profiles.length <= 1) return; // 至少保留一個
    _profiles.removeWhere((p) => p.id == id);
    _progressByProfile.remove(id);
    if (_currentId == id) {
      _currentId = _profiles.first.id;
    }
    final sp = await SharedPreferences.getInstance();
    await _save(sp);
    await sp.remove('$_kProgressPrefix$id');
    notifyListeners();
  }

  Future<void> setLessonResult({
    required String lessonId,
    required int score,
    required int total,
  }) async {
    final stars = _calcStars(score, total);
    final prev = progressOf(lessonId);
    _currentProgress[lessonId] = prev.copyWith(
      completed: true,
      stars: stars > prev.stars ? stars : prev.stars,
      lastScore: score,
      lastStudiedAt: DateTime.now(),
    );
    notifyListeners();
    await _saveCurrentProgress();
  }

  int _calcStars(int score, int total) {
    if (total == 0) return 0;
    final ratio = score / total;
    if (ratio >= 0.9) return 3;
    if (ratio >= 0.7) return 2;
    if (ratio >= 0.5) return 1;
    return 0;
  }

  String _generateId() =>
      'p_${DateTime.now().microsecondsSinceEpoch}_${_profiles.length}';
}
