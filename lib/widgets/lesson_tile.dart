import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../models/subject.dart';
import '../models/user_progress.dart';

class LessonTile extends StatelessWidget {
  final Lesson lesson;
  final Subject subject;
  final LessonProgress progress;
  final VoidCallback onTap;

  const LessonTile({
    super.key,
    required this.lesson,
    required this.subject,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: subject.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(subject.icon, color: subject.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (lesson.track != CurriculumTrack.general) ...[
                          _buildTrackBadge(lesson),
                          const SizedBox(width: 8),
                        ],
                        const Icon(Icons.schedule,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.estimatedMinutes} 分鐘',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildStars(progress.stars),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                progress.completed
                    ? Icons.check_circle
                    : Icons.chevron_right,
                color: progress.completed
                    ? const Color(0xFF43A047)
                    : Colors.grey,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackBadge(Lesson lesson) {
    final sem = lesson.semester?.label ?? '';
    final unit = lesson.unit != null ? ' 第 ${lesson.unit} 單元' : '';
    final label = sem.isEmpty
        ? lesson.track.label
        : '${lesson.grade}$sem$unit';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: lesson.track.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: lesson.track.color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: lesson.track.color,
        ),
      ),
    );
  }

  Widget _buildStars(int stars) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => Icon(
          i < stars ? Icons.star : Icons.star_border,
          size: 14,
          color: i < stars ? Colors.amber : Colors.grey.shade400,
        ),
      ),
    );
  }
}
