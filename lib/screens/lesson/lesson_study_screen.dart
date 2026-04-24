import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../data/curriculum_data.dart';
import '../../models/lesson.dart';
import '../../widgets/kid_button.dart';
import '../quiz_screen.dart';

/// 課程學習畫面：純教學內容閱讀，讀完後可進入測驗。
class LessonStudyScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonStudyScreen({super.key, required this.lesson});

  @override
  State<LessonStudyScreen> createState() => _LessonStudyScreenState();
}

class _LessonStudyScreenState extends State<LessonStudyScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('zh-TW');
    _tts.setSpeechRate(0.45);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggleSpeak() async {
    if (_speaking) {
      await _tts.stop();
      setState(() => _speaking = false);
    } else {
      setState(() => _speaking = true);
      await _tts.speak('${widget.lesson.title}。${widget.lesson.content}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final subject = subjectById(lesson.subjectId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('課程'),
        backgroundColor: subject.color.withValues(alpha: 0.1),
        actions: [
          IconButton(
            icon: Icon(_speaking ? Icons.stop_circle : Icons.volume_up),
            onPressed: _toggleSpeak,
            tooltip: '朗讀',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  subject.color,
                  subject.color.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${subject.name} · ${lesson.grade} 年級',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lesson.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '課程內容',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                lesson.content,
                style: const TextStyle(fontSize: 16, height: 1.8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          KidButton(
            label: lesson.questions.isEmpty ? '完成閱讀' : '接下來：測驗',
            icon: lesson.questions.isEmpty
                ? Icons.done_all
                : Icons.arrow_forward,
            color: subject.color,
            expanded: true,
            onPressed: () async {
              if (lesson.questions.isEmpty) {
                Navigator.of(context).pop();
                return;
              }
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => QuizScreen(lesson: lesson),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
