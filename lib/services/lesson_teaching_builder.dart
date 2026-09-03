import '../models/lesson.dart';
import 'lesson_content_enricher.dart';

/// 為僅有課綱套話、沒有實際課文的單元，產生可在 App 內完整閱讀的結構化內容。
class LessonTeachingBuilder {
  LessonTeachingBuilder._();

  static String buildTeachingContent(Lesson lesson) {
    final catalog = LessonContentEnricher.catalogContent(lesson);
    if (catalog != null) return catalog;

    return _contentFor(
      subjectId: lesson.subjectId,
      grade: lesson.grade,
      title: lesson.title,
      summary: lesson.summary,
    );
  }

  static List<VocabItem> buildVocabulary(Lesson lesson) {
    final fromLesson = _vocabFromContent(lesson);
    if (fromLesson.isNotEmpty) return fromLesson;

    final title = lesson.title;
    return [
      VocabItem(
        term: _mainTerm(title),
        meaning: _termMeaning(title, lesson.subjectId),
        example: _termExample(title, lesson.subjectId),
      ),
    ];
  }

  static List<VocabItem> _vocabFromContent(Lesson lesson) {
    final content = lesson.content;
    if (!content.contains('生字') && !content.contains('生詞')) return [];
    final line = content.split('\n').firstWhere(
          (l) => l.contains('生字') || l.contains('生詞'),
          orElse: () => '',
        );
    if (line.isEmpty) return [];
    final text = line.replaceFirst(RegExp(r'^生[字詞][：:]\s*'), '');
    return text
        .split(RegExp(r'[、，,\s]+'))
        .where((c) => c.isNotEmpty && c.length <= 2)
        .map(
          (c) => VocabItem(
            term: c,
            meaning: '本課重要字',
            example: '在課文裡找找「$c」這個字',
          ),
        )
        .toList();
  }

  static String _contentFor({
    required String subjectId,
    required int grade,
    required String title,
    required String summary,
  }) {
    final story = _miniStory(title, summary, subjectId, grade);
    final bullets = _bulletLines(title, summary, subjectId, grade);
    final activity = _inAppActivity(title, subjectId);

    return [
      '📖 $title',
      '',
      story,
      '',
      '重點整理：',
      bullets.join('\n'),
      '',
      activity,
    ].where((s) => s.trim().isNotEmpty).join('\n');
  }

  static String _miniStory(
    String title,
    String summary,
    String subjectId,
    int grade,
  ) {
    if (summary.isNotEmpty && !summary.contains('之概念與應用')) {
      return switch (subjectId) {
        'english' =>
          'Today we learn about 「$title」.\nLet\'s read, listen, and say the words together in this app—no textbook needed!',
        'math' =>
          '這一課要認識「$title」。\n我們會用圖片、例子和題目，在 App 裡一步一步弄懂。',
        'science' =>
          '「$title」就在你我身邊。\n跟著下面的觀察重點，在 App 裡就能完成這一課的學習。',
        _ =>
          '這一課的主題是「$title」。\n$summary\n\n下面有完整說明和例子，讀完就可以做測驗，不需要另外準備課本。',
      };
    }
    return '國小 $grade 年級的「$title」：在 App 裡閱讀、練習、測驗，就能完整學會這一課。';
  }

  static List<String> _bulletLines(
    String title,
    String summary,
    String subjectId,
    int grade,
  ) {
    final specific = _specificBullets(title, summary);
    if (specific.isNotEmpty) return specific;

    return switch (subjectId) {
      'life' => [
        '👀 觀察──想想這個能力和你每天的生活有什麼關係',
        '✋ 試試看──在 App 裡讀完後，立刻做一件相關的小事',
        '💬 說說看──用一句話描述你學到了什麼',
        '📝 記下來──完成測驗，看看自己記住了多少',
      ],
      'social' => [
        '🗺️ 認識──這個主題和我們社區、台灣有什麼關係',
        '📸 例子──從 App 裡的例子出發，想想你見過的類似情況',
        '🤝 討論──和同學分享你的想法，聽聽不同的看法',
        '✅ 整理──用 1～2 句話說出這一課的重點',
      ],
      'science' => [
        '🔍 觀察──注意現象：看、聽、摸（安全範圍內）',
        '❓ 提問──「為什麼會這樣？」「如果改變條件呢？」',
        '🧪 紀錄──在紙上畫圖或寫下你看到的',
        '💡 結論──說出你發現的規律',
      ],
      'english' => [
        '👂 聽一聽──按 App 的喇叭，聽正確發音',
        '🗣️ 跟著說──大聲念出單字和句子',
        '✏️ 寫一寫──用手指在螢幕上描字或抄寫',
        '🎯 用用看──用今天學的單字造一個句子',
      ],
      'math' => [
        '🖐️ 動手數──用手指或畫圖幫助理解',
        '📊 看圖──觀察 App 裡的圖示和數量關係',
        '🔁 練習──完成本課測驗題',
        '🏠 連結──想想家裡或購物時的類似例子',
      ],
      'chinese' => [
        '📖 讀故事──從上面的課文開始，大聲朗讀一遍',
        '📝 認字詞──記住重點字的意思和用法',
        '💬 說一說──用自己的話講述課文內容',
        '✅ 測一測──完成本課題目檢查理解',
      ],
      _ => [
        '📖 閱讀──從上面的內容開始，在 App 裡讀完',
        '📝 整理──記住 2～3 個重點',
        '💬 複述──用自己的話說一遍',
        '✅ 測驗──完成本課題目',
      ],
    };
  }

  static List<String> _specificBullets(String title, String summary) {
    final key = '$title|$summary';
    const map = {
      '生活自理': [
        '🪥 刷牙──早晚刷牙，每面刷 20 秒',
        '👕 穿衣服──認識正反面，自己扣扣子',
        '🎒 整理書包──依課表放好課本和文具',
        '🧦 穿脫鞋襪──自己穿鞋子、擺好拖鞋',
      ],
      '情緒小管家': [
        '😊 認識情緒──開心、生氣、難過、緊張都是正常的',
        '🫁 深呼吸──生氣或緊張時先吸氣再慢慢吐氣',
        '💬 說感受──用「我覺得…」表達心情',
        '🎨 紓解──畫畫、散步或找信任的人聊聊',
      ],
      '新學期': [
        '😊 心情──開學可能緊張或興奮，都很正常',
        '🎒 準備──整理書包、認識新教室',
        '🤝 互相幫助──高年級可以關心低年級同學',
      ],
      '升上': [
        '📈 升級──年級變高，要學的內容也會更多',
        '💪 更用心──上課專心、按時完成作業',
        '🤝 幫助──學長姐可以帶領學弟妹',
      ],
    };
    for (final entry in map.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return [];
  }

  static String _inAppActivity(String title, String subjectId) {
    return switch (subjectId) {
      'english' => '開口練：在 App 裡跟著朗讀 3 個單字，各造一個句子。',
      'math' => '動手做：用家裡的小東西（如積木、水果）數一數，對照本課概念。',
      'science' => '小觀察：找一個和「$title」有關的例子，畫圖或拍照記錄。',
      'chinese' => '想一想：讀完課文，用一句話說說你的感受或想法。',
      _ => '想一想：讀完上面的內容，你能說出 1 個重點嗎？',
    };
  }

  static String _mainTerm(String title) {
    final clean = title.split(RegExp(r'[（(]')).first.trim();
    return clean.length > 12 ? clean.substring(0, 12) : clean;
  }

  static String _termMeaning(String title, String subjectId) {
    final main = _mainTerm(title);
    return switch (subjectId) {
      'life' => '和「$main」有關的生活能力',
      'english' => '本課英文主題「$main」',
      'science' => '與「$main」有關的自然現象',
      _ => '本課重點：$main',
    };
  }

  static String _termExample(String title, String subjectId) {
    return switch (subjectId) {
      'english' => 'Hello! My name is …',
      'life' => '我會自己整理書包',
      _ => '在課文裡找找這個詞',
    };
  }
}
