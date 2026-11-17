import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../curriculum/curriculum.dart';
import '../models/lesson.dart' show Semester, TextbookPublisher;
import '../models/subject.dart';
import '../providers/progress_provider.dart';
import '../widgets/lesson_tile.dart';
import 'lesson_detail_screen.dart';

class LessonListScreen extends StatefulWidget {
  final Subject subject;
  final int grade;

  const LessonListScreen({
    super.key,
    required this.subject,
    required this.grade,
  });

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  Semester? _semesterFilter;
  TextbookPublisher? _publisherFilter;

  @override
  void initState() {
    super.initState();
    final hasPublisher = lessonsFor(widget.subject.id, widget.grade)
        .any((l) => l.publisher != null);
    if (hasPublisher) {
      _publisherFilter = TextbookPublisher.kangxuan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final allLessons = lessonsFor(widget.subject.id, widget.grade);
    final inSemester = allLessons.where((l) {
      if (_semesterFilter != null && l.semester != _semesterFilter) {
        return false;
      }
      return true;
    }).toList();
    final showPublisher = inSemester.any((l) => l.publisher != null);

    final filtered = inSemester.where((l) {
      if (!showPublisher || _publisherFilter == null) return true;
      return l.publisher == null || l.publisher == _publisherFilter;
    }).toList()
      ..sort((a, b) {
        final semCmp =
            (a.semester?.index ?? 99).compareTo(b.semester?.index ?? 99);
        if (semCmp != 0) return semCmp;
        final pubCmp =
            (a.publisher?.index ?? 99).compareTo(b.publisher?.index ?? 99);
        if (pubCmp != 0) return pubCmp;
        return (a.unit ?? 99).compareTo(b.unit ?? 99);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject.name} · ${widget.grade} 年級'),
        backgroundColor: widget.subject.color.withOpacity(0.1),
      ),
      body: Column(
        children: [
          _buildFilterRow<Semester>(
            label: '學期',
            options: const [Semester.first, Semester.second],
            current: _semesterFilter,
            labelBuilder: (s) => s == Semester.first ? '上學期' : '下學期',
            colorBuilder: (_) => widget.subject.color,
            onChanged: (s) => setState(() => _semesterFilter = s),
          ),
          if (showPublisher)
            _buildFilterRow<TextbookPublisher>(
              label: '版本',
              options: TextbookPublisher.values,
              current: _publisherFilter,
              labelBuilder: (p) => p.label,
              colorBuilder: (_) => widget.subject.color,
              onChanged: (p) => setState(() => _publisherFilter = p),
            ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final lesson = filtered[i];
                      return LessonTile(
                        lesson: lesson,
                        subject: widget.subject,
                        progress: progress.progressOf(lesson.id),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  LessonDetailScreen(lesson: lesson),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow<T>({
    required String label,
    required List<T> options,
    required T? current,
    required String Function(T) labelBuilder,
    required Color Function(T) colorBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip(
                    text: '全部',
                    selected: current == null,
                    color: Colors.grey,
                    onTap: () => onChanged(null),
                  ),
                  const SizedBox(width: 6),
                  ...options.expand((o) => [
                        _chip(
                          text: labelBuilder(o),
                          selected: current == o,
                          color: colorBuilder(o),
                          onTap: () => onChanged(o),
                        ),
                        const SizedBox(width: 6),
                      ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String text,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            '此篩選條件下尚無課程，\n試試其他學期吧！',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
