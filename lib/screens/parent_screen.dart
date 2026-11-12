import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../curriculum/curriculum.dart';
import '../providers/parent_auth_provider.dart';
import '../providers/progress_provider.dart';
import '../services/learning_progress_sync.dart';
import '../services/parent_auth_api.dart';
import 'profile/profile_select_screen.dart';
import 'profile/profile_edit_sheet.dart';

class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final auth = context.watch<ParentAuthProvider>();
    final profile = progress.profile;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '家長專區',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            '追蹤孩子的學習狀況',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const _ParentCloudAccountCard(),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '孩子資料',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '共 ${progress.profiles.length} 位',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('暱稱', profile.name),
                  const SizedBox(height: 8),
                  _buildInfoRow('年級', '國小 ${profile.grade} 年級'),
                  const SizedBox(height: 8),
                  _buildInfoRow('頭像', profile.avatar),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('編輯'),
                          onPressed: () => _editCurrent(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.manage_accounts, size: 18),
                          label: const Text('管理帳號'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileSelectScreen(
                                  goToMainAfterSelect: false,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  if (auth.isSignedIn && profile.id != 'guest') ...[
                    const SizedBox(height: 10),
                    const Text(
                      '若孩子已同步至雲端，可產生 QR 讓老師（教師後台帳號）掃描加入教學清單，方便檢視上傳的學習紀錄。',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.qr_code_2, size: 20),
                      label: const Text('老師加入 QR'),
                      onPressed: () => _openTeacherInviteQr(
                        context,
                        bearerToken: auth.token!,
                        deviceLocalId: profile.id,
                        childName: profile.name,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '各科進度',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  ...kSubjects.map((s) {
                    final lessons = lessonsForSubject(s.id)
                        .where((l) => l.grade == profile.grade)
                        .toList();
                    final completed = lessons
                        .where((l) =>
                            progress.progressOf(l.id).completed)
                        .length;
                    final ratio = lessons.isEmpty
                        ? 0.0
                        : completed / lessons.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: s.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(s.icon, color: s.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      s.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '$completed / ${lessons.length}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    backgroundColor: s.color
                                        .withOpacity(0.12),
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            s.color),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '最近學習',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  ..._recentLessons(progress).map(
                    (e) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(subjectById(e.subjectId).icon,
                          color: subjectById(e.subjectId).color),
                      title: Text(e.title,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        progress.progressOf(e.id).lastStudiedAt != null
                            ? DateFormat('MM/dd HH:mm').format(
                                progress.progressOf(e.id).lastStudiedAt!,
                              )
                            : '',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          3,
                          (i) => Icon(
                            i < progress.progressOf(e.id).stars
                                ? Icons.star
                                : Icons.star_border,
                            color: i < progress.progressOf(e.id).stars
                                ? Colors.amber
                                : Colors.grey.shade400,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_recentLessons(progress).isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '還沒有學習紀錄，快鼓勵孩子開始吧！',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '與學校課程搭配',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '本 App 內容對應台灣 108 課綱之六大學習領域，可作為學校課後複習或預習使用。建議依老師每週教學進度，選擇對應單元練習。',
                    style: TextStyle(height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  List _recentLessons(ProgressProvider progress) {
    final learned = kLessons
        .where((l) => progress.progressOf(l.id).lastStudiedAt != null)
        .toList();
    learned.sort((a, b) => progress
        .progressOf(b.id)
        .lastStudiedAt!
        .compareTo(progress.progressOf(a.id).lastStudiedAt!));
    return learned.take(5).toList();
  }

  Future<void> _editCurrent(BuildContext context) async {
    final provider = context.read<ProgressProvider>();
    final result = await showProfileEditSheet(
      context,
      initial: provider.profile,
    );
    if (result == null) return;
    await provider.updateProfile(
      provider.profile.copyWith(
        name: result.name,
        grade: result.grade,
        avatar: result.avatar,
      ),
    );
  }

  void _openTeacherInviteQr(
    BuildContext context, {
    required String bearerToken,
    required String deviceLocalId,
    required String childName,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.paddingOf(ctx).bottom + 24,
        ),
        child: _TeacherInviteQrSheet(
          bearerToken: bearerToken,
          deviceLocalId: deviceLocalId,
          childName: childName,
        ),
      ),
    );
  }
}

class _TeacherInviteQrSheet extends StatefulWidget {
  const _TeacherInviteQrSheet({
    required this.bearerToken,
    required this.deviceLocalId,
    required this.childName,
  });

  final String bearerToken;
  final String deviceLocalId;
  final String childName;

  @override
  State<_TeacherInviteQrSheet> createState() => _TeacherInviteQrSheetState();
}

class _TeacherInviteQrSheetState extends State<_TeacherInviteQrSheet> {
  final _api = ParentAuthApi();
  bool _busy = true;
  String? _error;
  String? _joinUrl;
  DateTime? _expiresAt;
  int? _cloudStudentId;

  @override
  void initState() {
    super.initState();
    _load(regenerate: false);
  }

  Future<void> _load({required bool regenerate}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final list = await _api.listStudents(widget.bearerToken);
      CloudStudent? match;
      for (final s in list) {
        if (s.deviceLocalId != null &&
            s.deviceLocalId == widget.deviceLocalId) {
          match = s;
          break;
        }
      }
      if (match == null) {
        setState(() {
          _busy = false;
          _error =
              '雲端尚無與此孩子對應的資料（本機 id：${widget.deviceLocalId}）。請先登入／註冊雲端家長帳號並同步孩子，或從「管理帳號」確認已上傳。';
          _joinUrl = null;
          _expiresAt = null;
          _cloudStudentId = null;
        });
        return;
      }
      _cloudStudentId = match.id;
      final link = await _api.teacherInviteJoinUrl(
        widget.bearerToken,
        studentId: match.id,
        regenerate: regenerate,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _joinUrl = link.url;
        _expiresAt = link.expiresAt;
      });
    } on ParentAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = '無法載入，請確認網路與後端設定。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '老師加入：${widget.childName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '請老師用手機相機掃描 QR，會開啟網頁；以「教師」帳號登入後台後，此孩子會出現在教師的學習紀錄清單中。若 .env 的 APP_URL 無法從老師手機連到，請改為可連線的網址後再產生 QR。',
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.45),
          ),
          const SizedBox(height: 20),
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null) ...[
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _load(regenerate: false),
              child: const Text('重試'),
            ),
          ] else if (_joinUrl != null) ...[
            Center(
              child: QrImageView(
                data: _joinUrl!,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (_expiresAt != null)
              Text(
                '此連結將於 ${_formatExpiry(_expiresAt!)} 失效，老師加入後也會立即作廢。重新開啟不會延長期限。',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 8),
            SelectableText(
              _joinUrl!,
              style: const TextStyle(fontSize: 11, height: 1.35),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _cloudStudentId == null
                  ? null
                  : () => _load(regenerate: true),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('重新產生連結（舊 QR 失效）'),
            ),
          ],
        ],
      ),
    );
  }

  String _formatExpiry(DateTime value) {
    final local = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }
}

/// 雲端家長帳號（後端 `users.role=parent`）；註冊時可選將本機孩子基本資料同步至後端。
class _ParentCloudAccountCard extends StatefulWidget {
  const _ParentCloudAccountCard();

  @override
  State<_ParentCloudAccountCard> createState() =>
      _ParentCloudAccountCardState();
}

class _ParentCloudAccountCardState extends State<_ParentCloudAccountCard> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pw2Ctrl = TextEditingController();
  bool _registerMode = false;
  bool _busy = false;
  /// 註冊時一併上傳本機「孩子檔」（不含訪客預設檔）。
  bool _syncLocalProfilesOnRegister = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _pw2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ParentAuthProvider>();
    if (!auth.isReady) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (auth.isSignedIn) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '雲端家長帳號',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '已登入：${auth.displayName ?? ''}（${auth.displayEmail ?? ''}）',
                style: const TextStyle(height: 1.4),
              ),
              if (!auth.isEmailVerified) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '請至信箱完成 Email 驗證',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '驗證後才能上傳學習紀錄、還原進度與產生教師邀請 QR。本機開發時驗證信會寫入後端 log。',
                        style: TextStyle(fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () async {
                                    setState(() => _busy = true);
                                    final auth =
                                        context.read<ParentAuthProvider>();
                                    await auth.refreshMe();
                                    if (!context.mounted) return;
                                    if (auth.isEmailVerified &&
                                        auth.token != null) {
                                      await _restoreProgress(context,
                                          quiet: true);
                                    }
                                    if (context.mounted) {
                                      setState(() => _busy = false);
                                    }
                                  },
                            child: const Text('我已驗證，重新整理'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _busy
                                ? null
                                : () async {
                                    setState(() => _busy = true);
                                    final ok = await context
                                        .read<ParentAuthProvider>()
                                        .resendVerificationEmail();
                                    if (!context.mounted) return;
                                    setState(() => _busy = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ok ? '已重寄驗證信' : (context.read<ParentAuthProvider>().lastError ?? '重寄失敗'),
                                        ),
                                      ),
                                    );
                                  },
                            child: const Text('重寄驗證信'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 4),
              const Text(
                '已驗證的帳號會在登入後，把各課程的完成與星星從雲端還原到這台裝置。換手機時用同一個 Email 登入即可。',
                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  if (auth.isEmailVerified)
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _restoreProgress(context),
                      icon: const Icon(Icons.cloud_download_outlined, size: 18),
                      label: const Text('還原學習進度'),
                    ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _exportAccount(context),
                    icon: const Icon(Icons.ios_share, size: 18),
                    label: const Text('匯出我的資料'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () async {
                            setState(() => _busy = true);
                            await context.read<ParentAuthProvider>().logout();
                            if (context.mounted) {
                              setState(() => _busy = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已登出雲端帳號')),
                              );
                            }
                          },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('登出'),
                  ),
                  TextButton(
                    onPressed: _busy ? null : () => _confirmDeleteAccount(context),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('刪除雲端帳號'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final localKids = context.watch<ProgressProvider>().profiles
        .where((p) => p.id != 'guest')
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '雲端家長帳號',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              '註冊後可與網頁家長後台使用同一帳號。註冊時可選上傳本機孩子；登入時會自動比對雲端，將本機有而雲端尚無對應（依本機 id）的孩子補上，方便多支手機分開建立檔案後合併。',
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  label: Text('登入'),
                  icon: Icon(Icons.login, size: 18),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text('註冊'),
                  icon: Icon(Icons.person_add, size: 18),
                ),
              ],
              selected: {_registerMode},
              onSelectionChanged: (Set<bool> sel) {
                context.read<ParentAuthProvider>().clearError();
                setState(() => _registerMode = sel.contains(true));
              },
            ),
            const SizedBox(height: 12),
            if (_registerMode) ...[
              TextField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '您的稱呼',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pwCtrl,
              obscureText: true,
              textInputAction:
                  _registerMode ? TextInputAction.next : TextInputAction.done,
              decoration: const InputDecoration(
                labelText: '密碼',
                border: OutlineInputBorder(),
              ),
            ),
            if (_registerMode) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _pw2Ctrl,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: '確認密碼',
                  border: OutlineInputBorder(),
                ),
              ),
              if (localKids.isNotEmpty) ...[
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('註冊時上傳本機孩子至雲端'),
                  subtitle: Text(
                    '共 ${localKids.length} 位：${localKids.map((p) => p.name).join('、')}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: _syncLocalProfilesOnRegister,
                  onChanged: (v) =>
                      setState(() => _syncLocalProfilesOnRegister = v),
                ),
              ],
            ],
            if (auth.lastError != null) ...[
              const SizedBox(height: 8),
              Text(
                auth.lastError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : () => _submit(context),
              child: Text(_registerMode ? '註冊家長帳號' : '登入'),
            ),
            if (!_registerMode)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _busy ? null : () => _forgotPassword(context),
                  child: const Text('忘記密碼？'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final auth = context.read<ParentAuthProvider>();
    final localPayload = context
        .read<ProgressProvider>()
        .profiles
        .where((p) => p.id != 'guest')
        .map(
          (p) => <String, dynamic>{
            'name': p.name,
            'grade': p.grade,
            'avatar': p.avatar,
            'device_local_id': p.id,
          },
        )
        .toList();
    setState(() => _busy = true);
    bool ok;
    if (_registerMode) {
      List<Map<String, dynamic>>? students;
      if (_syncLocalProfilesOnRegister) {
        students = localPayload.isEmpty ? null : localPayload;
      }
      ok = await auth.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _pwCtrl.text,
        passwordConfirmation: _pw2Ctrl.text,
        students: students,
        localProfilesForMergeAfterAuth:
            _syncLocalProfilesOnRegister ? localPayload : null,
      );
    } else {
      ok = await auth.login(
        email: _emailCtrl.text.trim(),
        password: _pwCtrl.text,
        localProfilesForMergeAfterAuth: localPayload,
      );
    }
    if (!context.mounted) return;
    if (ok && auth.isEmailVerified && auth.token != null) {
      await _restoreProgress(context, quiet: true);
    }
    if (!context.mounted) return;
    setState(() => _busy = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _registerMode
                ? '註冊成功，請至信箱完成 Email 驗證'
                : (auth.isEmailVerified ? '登入成功' : '登入成功，請先完成 Email 驗證'),
          ),
        ),
      );
      _pwCtrl.clear();
      _pw2Ctrl.clear();
    }
  }

  Future<void> _forgotPassword(BuildContext context) async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先輸入 Email')),
      );
      return;
    }
    setState(() => _busy = true);
    final message =
        await context.read<ParentAuthProvider>().requestPasswordReset(email);
    if (!context.mounted) return;
    setState(() => _busy = false);
    final err = context.read<ParentAuthProvider>().lastError;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? err ?? '無法寄出信件')),
    );
  }

  Future<void> _restoreProgress(BuildContext context, {bool quiet = false}) async {
    if (!quiet) setState(() => _busy = true);
    final auth = context.read<ParentAuthProvider>();
    final progress = context.read<ProgressProvider>();
    final token = auth.token;
    var ok = false;
    if (auth.isEmailVerified && token != null) {
      ok = await LearningProgressSync.pull(token: token, progress: progress);
    }
    if (!context.mounted) return;
    if (quiet) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '已從雲端還原學習進度'
              : (auth.isEmailVerified ? '無法還原，請稍後再試' : '請先完成 Email 驗證'),
        ),
      ),
    );
  }

  Future<void> _exportAccount(BuildContext context) async {
    setState(() => _busy = true);
    final json = await context.read<ParentAuthProvider>().exportAccountJson();
    if (!context.mounted) return;
    setState(() => _busy = false);
    if (json == null) {
      final err = context.read<ParentAuthProvider>().lastError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? '無法匯出資料')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: json));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已複製到剪貼簿，可貼到備忘錄或郵件保存')),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final choice = await showDialog<_DeleteAccountChoice>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (choice == null || !context.mounted) return;
    setState(() => _busy = true);
    final ok = await context.read<ParentAuthProvider>().deleteAccount(
          password: choice.password,
        );
    if (!context.mounted) return;
    if (!ok) {
      setState(() => _busy = false);
      final err = context.read<ParentAuthProvider>().lastError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? '無法刪除帳號')),
      );
      return;
    }
    if (choice.wipeLocal) {
      await context.read<ProgressProvider>().clearAllLocalData();
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const ProfileSelectScreen(goToMainAfterSelect: true),
        ),
        (_) => false,
      );
      return;
    }
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('雲端帳號已刪除。這台裝置上的學習進度仍保留。')),
    );
  }
}

class _DeleteAccountChoice {
  const _DeleteAccountChoice({
    required this.password,
    required this.wipeLocal,
  });

  final String password;
  final bool wipeLocal;
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _wipe = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('刪除雲端帳號'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '會刪除家長帳號、雲端孩子資料與學習紀錄，而且無法復原。',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '目前的密碼',
                border: const OutlineInputBorder(),
                errorText: _error,
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _wipe,
              onChanged: (v) => setState(() => _wipe = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('一併清除這台裝置上的孩子檔案與學習進度'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () {
            if (_password.text.isEmpty) {
              setState(() => _error = '請輸入密碼');
              return;
            }
            Navigator.pop(
              context,
              _DeleteAccountChoice(
                password: _password.text,
                wipeLocal: _wipe,
              ),
            );
          },
          child: const Text('刪除'),
        ),
      ],
    );
  }
}
