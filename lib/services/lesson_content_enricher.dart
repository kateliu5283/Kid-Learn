import '../models/lesson.dart';
import 'topic_content_data.dart';

/// 把 App 內已有的短課文，整理成完整、可獨立學習的結構化內容（不引用外部課本）。
class LessonContentEnricher {
  LessonContentEnricher._();

  /// 依課程 id 或標題關鍵字，取得完整內建課文（若有）。
  static String? catalogContent(Lesson lesson) {
    final topic = TopicContentData.forId(lesson.id);
    if (topic != null) return topic.content;
    return _byId[lesson.id] ?? _byTitleKeyword(lesson.title, lesson.summary);
  }

  static String enrich(Lesson lesson, String raw) {
    final catalog = catalogContent(lesson);
    if (catalog != null) return catalog;

    final lines = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return raw;

    final story = <String>[];
    final extras = <String>[];

    for (final line in lines) {
      if (line.startsWith('生字：') || line.startsWith('生字:')) {
        extras.addAll(_expandVocabLine(line));
      } else if (line.startsWith('生詞：') || line.startsWith('生詞:')) {
        extras.addAll(_expandVocabLine(line.replaceFirst('生詞', '生字')));
      } else {
        story.add(line);
      }
    }

    final buf = StringBuffer();
    buf.writeln('📖 ${lesson.title}');
    buf.writeln();
    if (story.isNotEmpty) {
      buf.writeln(story.join('\n'));
    }
    if (extras.isNotEmpty) {
      buf.writeln();
      buf.writeln('認識字詞：');
      buf.writeln(extras.join('\n'));
    }
    final topicBullets = _topicBullets(lesson);
    if (topicBullets.isNotEmpty) {
      buf.writeln();
      buf.writeln(topicBullets.join('\n'));
    }
    return buf.toString().trim();
  }

  static List<String> _expandVocabLine(String line) {
    final text = line.replaceFirst(RegExp(r'^生字[：:]\s*'), '');
    final chars = text.split(RegExp(r'[、，,\s]+')).where((c) => c.isNotEmpty);
    return chars.map((c) => '📝 $c──${_charHint(c)}').toList();
  }

  static String _charHint(String char) {
    const hints = {
      '升': '年級往上，例如「升上二年級」',
      '暑': '暑假的「暑」，代表夏天',
      '課': '上課、課堂的課',
      '用': '使用、用心努力',
      '幫': '幫助別人、互相幫忙',
      '友': '朋友，在一起玩、一起學',
      '情': '感情、心情',
      '心': '心裡的感受',
      '樂': '快樂、開心',
      '學': '學習、學校',
      '校': '學校，上學的地方',
    };
    return hints[char] ?? '和這一課有關的重要字';
  }

  static List<String> _topicBullets(Lesson lesson) {
    final t = '${lesson.title}${lesson.summary}';
    if (t.contains('二年級') || t.contains('新學期') || t.contains('升上')) {
      return [
        '😊 心情──新學期可能緊張也可能興奮，兩種感受都很正常',
        '🤝 學姊學長──二年級的同學可以幫助一年級的學弟妹適應',
        '🎒 準備──整理書包、認識新教室，讓開學更順利',
      ];
    }
    if (t.contains('朋友')) {
      return [
        '🤝 分享──和朋友一起玩耍、一起學習',
        '💬 溝通──有不同意見時，好好說出來',
        '❤️ 關心──朋友難過時，給他一句鼓勵',
      ];
    }
    return [];
  }

  static String? _byTitleKeyword(String title, String summary) {
    final key = '$title|$summary';
    for (final entry in _byKeyword.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return null;
  }

  static const _byId = {
    'cl-c-2-1-u1': '''
📖 我升上二年級

暑假過完了，我升上二年級。
今天是開學日，我背著書包走進教室。教室換到新的一樓，黑板擦得亮亮的，聞起來有淡淡的木頭味道。

我看到新老師站在講台前，笑著向大家說：「歡迎來到二年級！」
有些同學是熟面孔，也有新轉來的同學。大家互相介紹名字，有人緊張地小聲說話，也有人興奮地揮手。

我升上二年級了，心裡既期待又有點緊張。我告訴自己：我要更用心聽課、更勇敢舉手，也要像學姊學長一樣，幫助一年級的學弟妹。

認識字詞：
📝 升──年級往上，「升上二年級」就是長大了一歲
📝 暑──暑假的暑，代表夏天長長的假期
📝 課──上課、課堂，也指每天學習的內容
📝 幫──幫助別人，讓大家都能更順利

重點整理：
😊 心情──開學日可能緊張、興奮或期待，每種感受都正常
🤝 學姊學長──二年級可以主動跟一年級同學說「需要幫忙可以找我」
🎒 新學期──新教室、新老師、新同學，也是認識更多知识的開始

想一想：開學第一天，你最期待的一件事是什麼？
''',
  };

  static const _byKeyword = <String, String>{
    '生活自理': '''
🌱 生活自理

生活自理就是「能自己照顧自己」，不需要大人每一步都幫忙。學會之後，你會更有自信，爸媽也會更放心。

重點整理：
🪥 刷牙──早晚刷牙，每面刷 20 秒，牙刷記得定期更換
👕 穿衣服──認識正反面，釦子從下往上扣比較順
🎒 整理書包──依課表放課本、聯絡簿和文具，睡前先準備好
🧦 穿脫鞋襪──鞋子擺整齊，襪子不要反折以免腳不舒服
🍽️ 用餐──自己拿碗筷、吃完收好，不剩太多食物

跟著做：
1. 今晚睡前，自己整理明天的書包
2. 刷牙時用計時器數 20 秒
3. 選一件明天要穿的衣服，自己折好放整齊

想一想：這四項裡，你已經會哪兩項？還想練哪一項？
''',
    '有朋友真好': '''
📖 有朋友真好

下課鐘響了，小美和小杰一起下樓玩跳繩。
小美跳了三次就絆到了，她有點難過。小杰說：「沒關係，再試一次，我幫你數拍子！」

小美深吸一口氣，又跳了起來。這一次，她連續跳了五次。
兩個人開心地拍手，約好明天再一起練習。

認識字詞：
📝 友──朋友，可以一起玩、一起學習的人
📝 幫──幫助，在朋友需要時給他支持
📝 說──把想法用話語表達出來

重點整理：
🤝 分享──玩具、點心或想法，都可以和朋友分享
💬 好好說──有不同意見時，用「我覺得…」而不是責罵
❤️ 關心──朋友難過時，先聽他說，再給建議

想一想：你的好朋友是誰？你們最喜歡一起做什么？
''',
  };
}
