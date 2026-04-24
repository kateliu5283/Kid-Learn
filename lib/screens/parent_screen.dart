import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/curriculum_data.dart';
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
