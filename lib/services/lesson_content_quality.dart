import '../models/lesson.dart';

/// 判斷課程資料是否為空泛的課綱套話（非實際教學內容）。
class LessonContentQuality {
  LessonContentQuality._();

  static bool isBoilerplateObjective(String text) {
    return text.contains('與生活或社會情境的關聯') ||
        text.contains('能運用本單元關鍵詞彙') ||
        text.contains('能與他人合作、聆聽意見') ||
        text.contains('能理解本單元課文或語料') ||
        text.contains('能辨識與運用相關字詞') ||
        text.contains('能口述或寫出一句與主題') ||
        text.contains('的核心概念與關鍵詞彙') ||
        text.contains('能於生活或學習情境中舉例') ||
        text.contains('能與同儕合作完成探究') ||
        text.contains('能正確完成本課的測驗') ||
        (text.contains('認識「') && text.contains('」的主要內容'));
  }

  static bool isBoilerplateKeyPoint(String text) {
    return text.contains('本單元對應國小') ||
        (text.contains('對應國小') && text.contains('學習重點')) ||
        text.contains('善用圖表、實例') ||
        text.contains('整理筆記有助') ||
        text.contains('閱讀時先掌握段落大意') ||
        text.contains('書寫時注意筆順') ||
        text.contains('口語發表要語句完整') ||
        text.contains('建議搭配圖表、實例') ||
        text.contains('完成學習單或學習日誌');
  }

  static bool isBoilerplateVocab(VocabItem v) {
    return v.meaning == '本單元主題詞' ||
        v.meaning == '本課所屬學習領域' ||
        v.meaning == '本單元探究主題' ||
        v.meaning == '課程領域名稱' ||
        v.term == '學習單' ||
        (v.term == '探究' && v.meaning.contains('觀察、提問')) ||
        v.example?.contains('108 課綱') == true ||
        v.example?.contains('對照課本目標') == true;
  }

  static bool isThinContent(String content) {
    return is108TemplateOnly(content);
  }

  /// 僅含 108 課綱模板、沒有實際可讀課文的內容。
  static bool is108TemplateOnly(String content) {
    final t = content.trim();
    if (t.isEmpty) return true;
    return t.contains('本單元對齊《十二年國民基本教育課程綱要》') ||
        t.contains('本單元呼應《十二年國民基本教育課程綱要》') ||
        t.contains('實際用語可能因學校選用之教材版本') ||
        (t.contains('108 課綱') && t.length < 120) ||
        (t.contains('之概念與應用') && t.length < 200);
  }

  static List<String> filterObjectives(List<String> items) =>
      items.where((o) => !isBoilerplateObjective(o)).toList();

  static List<String> filterKeyPoints(List<String> items) =>
      items.where((p) => !isBoilerplateKeyPoint(p)).toList();

  static List<VocabItem> filterVocabulary(List<VocabItem> items) =>
      items.where((v) => !isBoilerplateVocab(v)).toList();

  static bool hasSubstantiveObjectives(Lesson lesson) =>
      filterObjectives(lesson.objectives).isNotEmpty;

  static bool hasSubstantiveKeyPoints(Lesson lesson) =>
      filterKeyPoints(lesson.keyPoints).isNotEmpty;

  static bool hasSubstantiveVocabulary(Lesson lesson) =>
      filterVocabulary(lesson.vocabulary).isNotEmpty;
}
