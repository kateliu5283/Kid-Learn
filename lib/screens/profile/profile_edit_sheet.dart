import 'package:flutter/material.dart';
import '../../models/user_progress.dart';

const List<String> kAvatars = [
  '🦊', '🐻', '🐼', '🐨', '🐯', '🐸',
  '🐵', '🐰', '🐶', '🐱', '🦁', '🐮',
  '🐷', '🐧', '🐥', '🦄',
];

class ProfileEditResult {
  final String name;
  final int grade;
  final String avatar;
  const ProfileEditResult({
    required this.name,
    required this.grade,
    required this.avatar,
  });
}

/// 顯示新增或編輯帳號的底部彈窗
Future<ProfileEditResult?> showProfileEditSheet(
  BuildContext context, {
  UserProfile? initial,
  String? title,
}) {
  return showModalBottomSheet<ProfileEditResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => _ProfileEditSheet(
      initial: initial,
      title: title ?? (initial == null ? '新增小朋友' : '編輯小朋友'),
    ),
  );
}

class _ProfileEditSheet extends StatefulWidget {
  final UserProfile? initial;
  final String title;

  const _ProfileEditSheet({this.initial, required this.title});

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  late TextEditingController _nameCtrl;
  late int _grade;
  late String _avatar;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
    _grade = widget.initial?.grade ?? 1;
    _avatar = widget.initial?.avatar ?? kAvatars.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: Text(_avatar, style: const TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 12),
          const Text('選擇頭像',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kAvatars.map((a) {
              final sel = _avatar == a;
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _avatar = a),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: sel
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          sel ? Colors.transparent : Colors.grey.shade300,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(a, style: const TextStyle(fontSize: 24)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: '暱稱',
              hintText: '例如：小明',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            maxLength: 10,
          ),
          const SizedBox(height: 4),
          const Text('年級', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: List.generate(6, (i) {
              final g = i + 1;
              return ChoiceChip(
                label: Text('$g 年級'),
                selected: _grade == g,
                onSelected: (_) => setState(() => _grade = g),
              );
            }),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('儲存'),
              onPressed: () {
                Navigator.pop<ProfileEditResult>(
                  context,
                  ProfileEditResult(
                    name: _nameCtrl.text.trim().isEmpty
                        ? '小朋友'
                        : _nameCtrl.text.trim(),
                    grade: _grade,
                    avatar: _avatar,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
