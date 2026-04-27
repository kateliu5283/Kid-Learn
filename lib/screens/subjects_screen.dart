import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../curriculum/curriculum.dart';
import '../providers/progress_provider.dart';
import '../widgets/subject_card.dart';
import 'lesson_list_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final grade = progress.profile.grade;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '學科分類',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _buildGradeSelector(context, grade),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kSubjects.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, i) {
                final subject = kSubjects[i];
                final lessons = lessonsForSubject(subject.id)
                    .where((l) => l.grade == grade)
                    .map((l) => l.id)
                    .toList();
                return SubjectCard(
                  subject: subject,
                  progress: progress.subjectProgress(lessons),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonListScreen(
                          subject: subject,
                          grade: grade,
                        ),
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

  Widget _buildGradeSelector(BuildContext context, int currentGrade) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final g = i + 1;
          final selected = g == currentGrade;
          return ChoiceChip(
            label: Text('$g 年級'),
            selected: selected,
            onSelected: (_) async {
              final profile = context.read<ProgressProvider>().profile;
              await context
                  .read<ProgressProvider>()
                  .updateProfile(profile.copyWith(grade: g));
            },
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w700,
            ),
            selectedColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
              ),
            ),
          );
        },
      ),
    );
  }
}
