import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../curriculum/curriculum.dart';
import '../../models/lesson.dart';
import '../../services/lesson_teaching.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/lesson_teaching_view.dart';
import '../quiz_screen.dart';

/// 課程學習畫面：以圖文卡片呈現單元教學內容。
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
    final text = LessonTeaching.effectiveContent(widget.lesson);
    if (_speaking) {
      await _tts.stop();
      setState(() => _speaking = false);
    } else {
      setState(() => _speaking = true);
      await _tts.speak('${widget.lesson.title}。$text');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final subject = subjectById(lesson.subjectId);
    final vocabulary = LessonTeaching.effectiveVocabulary(lesson);
    final keyPoints = LessonTeaching.effectiveKeyPoints(lesson);

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        backgroundColor: subject.color.withValues(alpha: 0.1),
        actions: [
          IconButton(
            icon: Icon(_speaking ? Icons.stop_circle : Icons.volume_up),
            onPressed: _toggleSpeak,
            tooltip: '語音朗讀',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LessonHeader(lesson: lesson, color: subject.color),
          const SizedBox(height: 20),
          LessonTeachingView(lesson: lesson, accent: subject.color),
          if (vocabulary.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionTitle(label: '重要字詞', icon: Icons.auto_stories_rounded, color: subject.color),
            const SizedBox(height: 8),
            ...vocabulary.map(
              (v) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _VocabCard(vocab: v, color: subject.color),
              ),
            ),
          ],
          if (keyPoints.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...keyPoints.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _KeyPointCard(text: p, color: subject.color),
              ),
            ),
          ],
          const SizedBox(height: 24),
          KidButton(
            label: lesson.questions.isEmpty ? '完成閱讀' : '讀完了，來測驗！',
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

class _LessonHeader extends StatelessWidget {
  final Lesson lesson;
  final Color color;

  const _LessonHeader({required this.lesson, required this.color});

  @override
  Widget build(BuildContext context) {
    final subject = subjectById(lesson.subjectId);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.editionLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${subject.name} · ${lesson.title}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lesson.summary,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SectionTitle({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _VocabCard extends StatelessWidget {
  final VocabItem vocab;
  final Color color;

  const _VocabCard({required this.vocab, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              vocab.term,
              style: TextStyle(
                color: color,
                fontSize: vocab.term.length > 2 ? 14 : 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vocab.meaning,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (vocab.example != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    vocab.example!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyPointCard extends StatelessWidget {
  final String text;
  final Color color;

  const _KeyPointCard({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: Color(0xFFFFB300), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
