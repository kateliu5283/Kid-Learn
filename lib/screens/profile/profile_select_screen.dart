import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_progress.dart';
import '../../providers/progress_provider.dart';
import '../../theme/app_theme.dart';
import '../main_scaffold.dart';
import 'profile_edit_sheet.dart';

/// 首次啟動 / 手動切換時顯示的帳號選擇畫面。
/// - 無任何帳號時：強制建立第一位小朋友。
/// - 有帳號時：以卡片列表呈現，可新增、切換、編輯、刪除。
class ProfileSelectScreen extends StatelessWidget {
  /// 是否在選擇後自動進入主畫面（首次啟動時為 true；從設定切換時為 false）
  final bool goToMainAfterSelect;

  const ProfileSelectScreen({super.key, this.goToMainAfterSelect = true});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final profiles = progress.profiles;
    final isEmpty = profiles.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEmpty ? '歡迎使用' : '選擇小朋友'),
        automaticallyImplyLeading: !isEmpty && !goToMainAfterSelect,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isEmpty)
                const Text(
                  '第一次使用，先建立一位小朋友吧！',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                )
              else
                Text(
                  '目前有 ${profiles.length} 位小朋友',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: isEmpty
                    ? _buildCreateHero(context)
                    : _buildProfileList(context, progress, profiles),
              ),
              if (!isEmpty)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('新增小朋友'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () => _addProfile(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateHero(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 72),
          ),
          const SizedBox(height: 28),
          const Text(
            '一起開始學習吧！',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            '先告訴我小朋友的名字和年級，\n之後就可以進入學習世界囉！',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add, size: 22),
            label: const Text('建立第一位小朋友'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => _addProfile(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList(
    BuildContext context,
    ProgressProvider provider,
    List<UserProfile> profiles,
  ) {
    final currentId = provider.profile.id;
    return ListView.separated(
      itemCount: profiles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final p = profiles[i];
        final isCurrent = p.id == currentId;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              await provider.switchTo(p.id);
              if (goToMainAfterSelect && context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) => const MainScaffold()),
                );
              } else if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCurrent
                      ? AppTheme.primaryColor
                      : Colors.grey.shade200,
                  width: isCurrent ? 2.5 : 1,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color:
                              AppTheme.primaryColor.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCurrent
                            ? [
                                AppTheme.primaryColor,
                                AppTheme.primaryColor.withOpacity(0.7),
                              ]
                            : [
                                Colors.grey.shade200,
                                Colors.grey.shade100,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(p.avatar,
                        style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '使用中',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '國小 ${p.grade} 年級',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await _editProfile(context, provider, p);
                      } else if (value == 'delete') {
                        await _confirmDelete(context, provider, p);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('編輯'),
                          ],
                        ),
                      ),
                      if (provider.profiles.length > 1)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete,
                                  size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('刪除',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addProfile(BuildContext context) async {
    final result = await showProfileEditSheet(context);
    if (result == null || !context.mounted) return;
    final provider = context.read<ProgressProvider>();
    await provider.addProfile(
      name: result.name,
      grade: result.grade,
      avatar: result.avatar,
    );
    if (goToMainAfterSelect && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    }
  }

  Future<void> _editProfile(
    BuildContext context,
    ProgressProvider provider,
    UserProfile profile,
  ) async {
    final result =
        await showProfileEditSheet(context, initial: profile);
    if (result == null) return;
    await provider.updateProfile(
      profile.copyWith(
        name: result.name,
        grade: result.grade,
        avatar: result.avatar,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProgressProvider provider,
    UserProfile profile,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('確定刪除？'),
        content: Text(
          '刪除後「${profile.name}」的所有學習進度都會消失，確定要刪除嗎？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await provider.deleteProfile(profile.id);
    }
  }
}
