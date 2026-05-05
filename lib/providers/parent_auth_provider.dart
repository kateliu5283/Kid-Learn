import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/parent_auth_api.dart';

const _kToken = 'parent_auth_token_v1';
const _kEmail = 'parent_auth_email_v1';
const _kName = 'parent_auth_name_v1';

/// 雲端家長帳號（與本機「孩子暱稱」分離；題庫仍走 [CurriculumApi]）。
class ParentAuthProvider extends ChangeNotifier {
  ParentAuthProvider({ParentAuthApi? api}) : _api = api ?? ParentAuthApi() {
    _restore();
  }

  final ParentAuthApi _api;

  String? _token;
  String? _email;
  String? _name;
  bool _ready = false;
  String? _lastError;

  bool get isReady => _ready;
  bool get isSignedIn => _token != null && _token!.isNotEmpty;
  String? get displayEmail => _email;
  String? get displayName => _name;
  String? get lastError => _lastError;
  String? get token => _token;

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kToken);
    _email = prefs.getString(_kEmail);
    _name = prefs.getString(_kName);
    _ready = true;
    notifyListeners();
  }

  Future<void> _persist(String token, ParentUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString(_kEmail, user.email);
    await prefs.setString(_kName, user.name);
    _token = token;
    _email = user.email;
    _name = user.name;
    notifyListeners();
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kEmail);
    await prefs.remove(_kName);
    _token = null;
    _email = null;
    _name = null;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    List<Map<String, dynamic>>? students,
    /// 註冊成功後，將本機有、雲端尚無對應 `device_local_id` 的孩子補上（與「註冊表單是否帶 students」分開；關閉上傳開關時請傳 `null`）。
    List<Map<String, dynamic>>? localProfilesForMergeAfterAuth,
  }) async {
    _lastError = null;
    notifyListeners();
    try {
      final r = await _api.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        students: students,
      );
      if (localProfilesForMergeAfterAuth != null &&
          localProfilesForMergeAfterAuth.isNotEmpty) {
        await _mergeLocalStudentsMissingOnCloud(
          token: r.token,
          initialRemote: r.remoteStudents,
          localProfiles: localProfilesForMergeAfterAuth,
        );
      }
      await _persist(r.token, r.user);
      return true;
    } on ParentAuthException catch (e) {
      _lastError = e.message;
      return false;
    } catch (_) {
      _lastError = '網路錯誤，請稍後再試';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    /// 登入成功後，依 `device_local_id` 比對雲端，補上尚未存在的本機孩子。
    required List<Map<String, dynamic>> localProfilesForMergeAfterAuth,
  }) async {
    _lastError = null;
    notifyListeners();
    try {
      final r = await _api.login(email: email, password: password);
      if (localProfilesForMergeAfterAuth.isNotEmpty) {
        await _mergeLocalStudentsMissingOnCloud(
          token: r.token,
          initialRemote: r.remoteStudents,
          localProfiles: localProfilesForMergeAfterAuth,
        );
      }
      await _persist(r.token, r.user);
      return true;
    } on ParentAuthException catch (e) {
      _lastError = e.message;
      return false;
    } catch (_) {
      _lastError = '網路錯誤，請稍後再試';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> _mergeLocalStudentsMissingOnCloud({
    required String token,
    required List<CloudStudent> initialRemote,
    required List<Map<String, dynamic>> localProfiles,
  }) async {
    final knownIds = <String>{
      for (final s in initialRemote)
        if (s.deviceLocalId != null && s.deviceLocalId!.isNotEmpty)
          s.deviceLocalId!,
    };
    for (final row in localProfiles) {
      final id = row['device_local_id'] as String?;
      if (id == null || id.isEmpty || id == 'guest') continue;
      if (knownIds.contains(id)) continue;
      final name = row['name'] as String?;
      if (name == null || name.trim().isEmpty) continue;
      final grade = (row['grade'] as num?)?.toInt() ?? 1;
      final avatar = row['avatar'] as String?;
      await _api.createStudentOrSkipDuplicateDeviceId(
        token,
        name: name.trim(),
        grade: grade,
        avatar: avatar,
        deviceLocalId: id,
      );
      knownIds.add(id);
    }
  }

  Future<void> logout() async {
    final t = _token;
    if (t == null) return;
    try {
      await _api.logout(t);
    } catch (_) {
      // 仍清除本機權杖
    }
    await _clearPrefs();
  }

  /// 啟動時可選：驗證 token 是否仍有效。
  Future<void> refreshMe() async {
    final t = _token;
    if (t == null || !_ready) return;
    try {
      final user = await _api.me(t);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kEmail, user.email);
      await prefs.setString(_kName, user.name);
      _email = user.email;
      _name = user.name;
      notifyListeners();
    } on ParentAuthException {
      await _clearPrefs();
    } catch (_) {
      // 離線時略過
    }
  }
}
