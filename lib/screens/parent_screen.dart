import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../curriculum/curriculum.dart';
import '../providers/parent_auth_provider.dart';
import '../providers/progress_provider.dart';
import 'profile/profile_select_screen.dart';
import 'profile/profile_edit_sheet.dart';

class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
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
              const SizedBox(height: 4),
              const Text(
                '題庫仍會從後端自動更新；學習進度在本機。若註冊時已上傳孩子基本資料，後台與教師可對應雲端學生（家教／小班）。',
                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
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
    setState(() => _busy = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_registerMode ? '註冊成功' : '登入成功'),
        ),
      );
      _pwCtrl.clear();
      _pw2Ctrl.clear();
    }
  }
}
