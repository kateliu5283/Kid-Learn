import '../models/lesson.dart';
import 'lesson_content_enricher.dart';
import 'lesson_content_quality.dart';
import 'lesson_teaching_builder.dart';
import 'topic_content_data.dart';

/// 取得適合兒童閱讀的課程教學內容（過濾套話、補強薄內容）。
class LessonTeaching {
  LessonTeaching._();

  static String effectiveContent(Lesson lesson) {
    final topic = TopicContentData.forId(lesson.id);
    if (topic != null) return topic.content;

    final raw = lesson.content.trim();

    // 108 課綱套話模板 → 產生完整 App 內課文
    if (LessonContentQuality.is108TemplateOnly(raw)) {
      return LessonTeachingBuilder.buildTeachingContent(lesson);
    }

    // 已有實際課文（故事、例子）→ 保留並結構化擴充，不替換成套話
    if (raw.isNotEmpty) {
      return LessonContentEnricher.enrich(lesson, raw);
    }

    return LessonTeachingBuilder.buildTeachingContent(lesson);
  }

  /// 僅國語、英語在預習／學習流程中顯示字詞卡；數學等科目以圖文重點為主。
  static bool showsVocabulary(Lesson lesson) {
    return lesson.subjectId == 'chinese' || lesson.subjectId == 'english';
  }

  static List<VocabItem> effectiveVocabulary(Lesson lesson) {
    if (!showsVocabulary(lesson)) return const [];

    final topic = TopicContentData.forId(lesson.id);
    if (topic != null && topic.vocabulary.isNotEmpty) {
      return LessonContentQuality.filterVocabulary(topic.vocabulary);
    }

    final filtered = LessonContentQuality.filterVocabulary(lesson.vocabulary);
    if (filtered.isNotEmpty) return filtered;

    final fromContent = LessonTeachingBuilder.buildVocabulary(lesson);
    if (fromContent.isNotEmpty) return fromContent;

    return lesson.vocabulary;
  }

  static List<String> effectiveKeyPoints(Lesson lesson) {
    final topic = TopicContentData.forId(lesson.id);
    if (topic != null && topic.keyPoints.isNotEmpty) {
      return topic.keyPoints;
    }

    final filtered = LessonContentQuality.filterKeyPoints(lesson.keyPoints);
    if (filtered.isNotEmpty) return filtered;
    return [];
  }
}
