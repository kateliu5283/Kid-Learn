import '../models/lesson.dart';
import '../models/question.dart';
import 'chinese/chinese_lessons.dart';
import 'math/math_lessons.dart';
import 'science/science_g1_lessons.dart';

/// 內嵌示範單元 + 對標 108 課綱之單元列表（國語／數學等見 `chinese/`、`math/`）。
///
/// 學科列表與 [subjectById] 見 `subjects.dart`。
final List<Lesson> kLessons = [
  // === 國語 ===
  Lesson(
    id: 'chinese-g1-zhuyin',
    subjectId: 'chinese',
    grade: 1,
    title: '認識注音符號',
    summary: '學習 37 個注音符號的發音',
    content: '注音符號是中文發音的基礎。\n\nㄅ（b）像一座小房子\nㄆ（p）像一面旗子\nㄇ（m）像一座門\nㄈ（f）像拐杖\n\n跟著老師一起念：ㄅㄆㄇㄈ、ㄉㄊㄋㄌ…',
    estimatedMinutes: 8,
    objectives: [
      '認識 37 個注音符號',
      '能夠讀出簡單的注音拼音',
      '會用注音標示自己會的字',
    ],
    keyPoints: [
      '注音由 21 個聲母 + 16 個韻母組成',
      '聲調分為 1、2、3、4 聲與輕聲',
      '拼音順序：聲母 + 介音 + 韻母 + 聲調',
    ],
    vocabulary: [
      VocabItem(term: 'ㄅ', meaning: '發 b 音', example: '爸爸 ㄅㄚˋ'),
      VocabItem(term: 'ㄆ', meaning: '發 p 音', example: '蘋果 ㄆㄧㄥˊ'),
      VocabItem(term: 'ㄇ', meaning: '發 m 音', example: '媽媽 ㄇㄚ'),
      VocabItem(term: 'ㄈ', meaning: '發 f 音', example: '飛 ㄈㄟ'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '「ㄇ」的發音是？',
        options: ['b', 'p', 'm', 'f'],
        correctIndex: 2,
        explanation: 'ㄇ 對應注音發音「m」，像是「媽媽」的開頭音。',
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '「蘋果」的「蘋」用注音怎麼拼？',
        options: ['ㄆㄧㄥˊ', 'ㄅㄧㄥˊ', 'ㄇㄧㄥˊ', 'ㄈㄧㄥˊ'],
        correctIndex: 0,
        explanation: '「蘋」= ㄆ + ㄧ + ㄥ，聲調是第二聲。',
      ),
      Question(
        id: 'q3',
        type: QuestionType.multipleChoice,
        prompt: '注音聲調共有幾種？',
        options: ['3 種', '4 種', '5 種', '6 種'],
        correctIndex: 2,
        explanation: '注音有第 1、2、3、4 聲和輕聲，共 5 種。',
      ),
      Question(
        id: 'q4',
        type: QuestionType.multipleChoice,
        prompt: '下面哪個是聲母？',
        options: ['ㄧ', 'ㄨ', 'ㄅ', 'ㄩ'],
        correctIndex: 2,
        explanation: 'ㄅ 是聲母，ㄧㄨㄩ 是介音。',
      ),
    ],
  ),
  Lesson(
    id: 'chinese-g2-idiom',
    subjectId: 'chinese',
    grade: 2,
    title: '生活中的成語',
    summary: '認識簡單的四字成語',
    content:
        '成語是由四個字組成的短句，常常用在文章裡。\n\n• 一心一意：專心做一件事\n• 五顏六色：很多種顏色\n• 七上八下：心情不安\n• 眉開眼笑：非常開心的樣子\n• 馬馬虎虎：普通、不認真',
    objectives: [
      '認識 5 個常用四字成語',
      '能在句子中正確使用成語',
      '理解成語背後的意思',
    ],
    keyPoints: [
      '成語多由四個字組成',
      '成語常來自古代故事或經典',
      '使用成語讓文章更精采',
    ],
    vocabulary: [
      VocabItem(term: '一心一意', meaning: '專心做一件事', example: '他一心一意讀書。'),
      VocabItem(term: '五顏六色', meaning: '顏色很多', example: '花園裡有五顏六色的花。'),
      VocabItem(term: '七上八下', meaning: '心情不安', example: '考試前我七上八下。'),
      VocabItem(term: '眉開眼笑', meaning: '非常開心', example: '收到禮物她眉開眼笑。'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '「五顏六色」是形容什麼？',
        options: ['時間很長', '顏色很多', '人很聰明', '天氣很好'],
        correctIndex: 1,
        explanation: '五顏六色用來形容色彩繽紛、種類很多。',
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '「一心一意」適合形容哪一種狀況？',
        options: ['想很多事情', '專心做事', '到處玩', '很生氣'],
        correctIndex: 1,
        explanation: '「一心一意」代表專注、不分心。',
      ),
      Question(
        id: 'q3',
        type: QuestionType.multipleChoice,
        prompt: '「眉開眼笑」是什麼意思？',
        options: ['難過', '疑惑', '非常開心', '生氣'],
        correctIndex: 2,
        explanation: '眉毛和眼睛都笑，形容非常高興。',
      ),
      Question(
        id: 'q4',
        type: QuestionType.multipleChoice,
        prompt: '考試前心情緊張可以用哪個成語？',
        options: ['眉開眼笑', '七上八下', '一心一意', '五顏六色'],
        correctIndex: 1,
        explanation: '七上八下形容心裡忐忑不安。',
      ),
    ],
  ),
  Lesson(
    id: 'chinese-g3-compose',
    subjectId: 'chinese',
    grade: 3,
    title: '寫出好句子',
    summary: '學習形容詞的使用',
    content: '形容詞可以讓句子更生動！\n\n普通：天空有雲。\n升級：藍藍的天空有一朵朵白白的雲。',
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '下列哪個詞是形容詞？',
        options: ['跑步', '美麗', '吃飯', '桌子'],
        correctIndex: 1,
        explanation: '「美麗」用來形容事物，是形容詞。',
      ),
    ],
  ),

  // === 英語 ===
  Lesson(
    id: 'english-g1-abc',
    subjectId: 'english',
    grade: 1,
    title: 'ABC 字母歌',
    summary: '認識 26 個英文字母',
    content:
        'A B C D E F G\nH I J K L M N O P\nQ R S T U V\nW X Y Z\n\n唱唱看字母歌吧！',
    objectives: [
      '認識 26 個英文字母',
      '分辨大小寫',
      '能哼唱字母歌',
    ],
    keyPoints: [
      '英文字母共 26 個',
      '每個字母有大寫與小寫',
      '字母有固定的順序，與單字拼法有關',
    ],
    vocabulary: [
      VocabItem(term: 'A a', meaning: 'Apple 蘋果', example: 'A is for Apple.'),
      VocabItem(term: 'B b', meaning: 'Banana 香蕉', example: 'B is for Banana.'),
      VocabItem(term: 'C c', meaning: 'Cat 貓', example: 'C is for Cat.'),
      VocabItem(term: 'D d', meaning: 'Dog 狗', example: 'D is for Dog.'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: 'Apple 的開頭字母是？',
        options: ['A', 'B', 'P', 'E'],
        correctIndex: 0,
        explanation: 'Apple 開頭發音 /æ/，字母是 A。',
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '字母 C 的大寫是？',
        options: ['c', 'C', 'G', 'O'],
        correctIndex: 1,
      ),
      Question(
        id: 'q3',
        type: QuestionType.multipleChoice,
        prompt: '英文一共有幾個字母？',
        options: ['20', '24', '26', '28'],
        correctIndex: 2,
      ),
      Question(
        id: 'q4',
        type: QuestionType.multipleChoice,
        prompt: '在 ABC 中，B 的後面是?',
        options: ['A', 'C', 'D', 'E'],
        correctIndex: 1,
      ),
    ],
  ),
  Lesson(
    id: 'english-g2-colors',
    subjectId: 'english',
    grade: 2,
    title: 'Colors 顏色',
    summary: '學習各種顏色的英文',
    content:
        'Red 紅色  Blue 藍色  Yellow 黃色\nGreen 綠色  Pink 粉紅  Black 黑色\n\nWhat color do you like?',
    objectives: [
      '學會 6 種常見顏色單字',
      '能問與回答 What color…?',
      '把顏色單字用在句子裡',
    ],
    keyPoints: [
      '問句：What color is it?',
      '回答：It is + 顏色.',
      '顏色單字是形容詞，放在名詞前',
    ],
    vocabulary: [
      VocabItem(term: 'Red', meaning: '紅色', example: 'The apple is red.'),
      VocabItem(term: 'Blue', meaning: '藍色', example: 'The sky is blue.'),
      VocabItem(term: 'Yellow', meaning: '黃色', example: 'The sun is yellow.'),
      VocabItem(term: 'Green', meaning: '綠色', example: 'The leaf is green.'),
      VocabItem(term: 'Black', meaning: '黑色'),
      VocabItem(term: 'Pink', meaning: '粉紅色'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '「藍色」的英文是？',
        options: ['Red', 'Blue', 'Green', 'Yellow'],
        correctIndex: 1,
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: 'Yellow 是什麼顏色？',
        options: ['黑色', '紅色', '黃色', '綠色'],
        correctIndex: 2,
      ),
      Question(
        id: 'q3',
        type: QuestionType.multipleChoice,
        prompt: '草莓是 red 還是 blue?',
        options: ['red', 'blue', 'green', 'yellow'],
        correctIndex: 0,
      ),
      Question(
        id: 'q4',
        type: QuestionType.multipleChoice,
        prompt: '"What color is the sky?" 回答?',
        options: ['It is red.', 'It is blue.', 'It is pink.', 'It is black.'],
        correctIndex: 1,
      ),
    ],
  ),
  Lesson(
    id: 'english-g3-greetings',
    subjectId: 'english',
    grade: 3,
    title: '打招呼 Greetings',
    summary: '學會基本問候語',
    content: 'Hello! 你好！\nGood morning. 早安\nHow are you? 你好嗎？\nI\'m fine, thank you. 我很好，謝謝',
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '早上遇到老師應該說？',
        options: ['Good night', 'Good morning', 'Goodbye', 'Hi bye'],
        correctIndex: 1,
      ),
    ],
  ),

  // === 數學 ===
  Lesson(
    id: 'math-g1-add',
    subjectId: 'math',
    grade: 1,
    title: '10 以內的加法',
    summary: '學會基本加法運算',
    content: '加法就是把東西合在一起。\n\n🍎 + 🍎 = 🍎🍎\n1 + 1 = 2\n\n2 + 3 = 5\n4 + 5 = 9',
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '3 + 4 = ?',
        options: ['6', '7', '8', '9'],
        correctIndex: 1,
        explanation: '3 + 4 = 7',
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '小明有 2 顆糖，媽媽給他 5 顆，一共有幾顆？',
        options: ['5', '6', '7', '8'],
        correctIndex: 2,
        explanation: '2 + 5 = 7 顆',
      ),
    ],
  ),
  Lesson(
    id: 'math-g2-multiply',
    subjectId: 'math',
    grade: 2,
    title: '九九乘法表（二）',
    summary: '學習 2 的乘法',
    content: '2 × 1 = 2\n2 × 2 = 4\n2 × 3 = 6\n2 × 4 = 8\n2 × 5 = 10\n2 × 6 = 12\n2 × 7 = 14\n2 × 8 = 16\n2 × 9 = 18',
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '2 × 7 = ?',
        options: ['12', '14', '16', '18'],
        correctIndex: 1,
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '一雙鞋 2 隻，4 雙鞋一共幾隻？',
        options: ['6', '8', '10', '12'],
        correctIndex: 1,
        explanation: '2 × 4 = 8 隻',
      ),
    ],
  ),
  Lesson(
    id: 'math-g3-shape',
    subjectId: 'math',
    grade: 3,
    title: '認識平面圖形',
    summary: '三角形、正方形、圓形',
    content: '• 三角形：3 個邊\n• 正方形：4 個等長的邊\n• 長方形：4 個邊（對邊相等）\n• 圓形：沒有邊',
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '三角形有幾個邊？',
        options: ['2', '3', '4', '5'],
        correctIndex: 1,
      ),
    ],
  ),
  Lesson(
    id: 'math-g4-fraction',
    subjectId: 'math',
    grade: 4,
    title: '認識分數',
    summary: '分數的意義與讀法',
    content: '把一個東西平分成幾份，其中幾份就是分數。\n\n1/2 讀作「二分之一」，就是一半\n1/4 讀作「四分之一」',
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '把一個披薩平分成 4 份，吃了 1 份是多少？',
        options: ['1/2', '1/3', '1/4', '1/5'],
        correctIndex: 2,
        explanation: '分成 4 份吃 1 份 = 1/4',
      ),
    ],
  ),

  // === 自然（小一：science_g1_lessons.dart）===
  ...kScienceG1Lessons,
  Lesson(
    id: 'science-g2-weather',
    subjectId: 'science',
    grade: 2,
    title: '天氣的變化',
    summary: '晴、陰、雨、風',
    content: '☀️ 晴天：太陽出來了\n☁️ 陰天：有雲遮住太陽\n🌧️ 雨天：雲裡的水變成雨\n🌬️ 有風：空氣在流動',
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '下雨的水從哪裡來？',
        options: ['地下', '雲裡', '太陽', '樹上'],
        correctIndex: 1,
        explanation: '水蒸氣到天空變成雲，雲裡的水落下就是雨。',
      ),
    ],
  ),
  Lesson(
    id: 'science-g3-body',
    subjectId: 'science',
    grade: 3,
    title: '我們的身體',
    summary: '認識五官與器官',
    content: '眼睛 👀 看東西\n耳朵 👂 聽聲音\n鼻子 👃 聞味道\n嘴巴 👄 吃東西、說話\n\n心臟 ❤️ 幫身體運送血液\n肺 🫁 呼吸空氣',
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '我們用哪個器官呼吸？',
        options: ['眼睛', '耳朵', '肺', '心臟'],
        correctIndex: 2,
      ),
    ],
  ),

  // === 社會 ===
  Lesson(
    id: 'social-g1-family',
    subjectId: 'social',
    grade: 1,
    title: '我的家庭',
    summary: '認識家人關係',
    content: '家庭成員可能有：\n爸爸、媽媽、兄弟姊妹\n爺爺、奶奶、外公、外婆\n\n大家要互相關心！',
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '爸爸的爸爸是？',
        options: ['伯伯', '叔叔', '爺爺', '舅舅'],
        correctIndex: 2,
      ),
    ],
  ),
  Lesson(
    id: 'social-g3-taiwan',
    subjectId: 'social',
    grade: 3,
    title: '認識台灣',
    summary: '台灣的地理位置與特色',
    content: '台灣位於亞洲東部、太平洋上的一座島嶼。\n\n首都：台北\n最高山：玉山\n最長河：濁水溪\n\n台灣有五大山脈、許多美麗的海岸線。',
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '台灣最高的山是？',
        options: ['阿里山', '玉山', '合歡山', '陽明山'],
        correctIndex: 1,
        explanation: '玉山海拔 3952 公尺，是台灣最高峰。',
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '台灣的首都在哪裡？',
        options: ['台中', '台南', '台北', '高雄'],
        correctIndex: 2,
      ),
    ],
  ),

  // === 綜合 ===
  Lesson(
    id: 'life-g1-safety',
    subjectId: 'life',
    grade: 1,
    title: '過馬路要小心',
    summary: '交通安全常識',
    content: '🚦 紅燈停、綠燈行\n🚸 走斑馬線\n👀 左右看，沒車才過\n\n牽著大人的手最安全！',
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '看到紅燈應該？',
        options: ['快點過', '停下來', '跑過去', '騎腳踏車'],
        correctIndex: 1,
      ),
    ],
  ),
  Lesson(
    id: 'life-g2-friends',
    subjectId: 'life',
    grade: 2,
    title: '好朋友',
    summary: '學習人際相處',
    content: '和朋友相處的好習慣：\n• 互相幫助\n• 分享玩具\n• 有禮貌\n• 不打架\n• 說「請、謝謝、對不起」',
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '朋友哭了，你應該？',
        options: ['笑他', '不理他', '安慰他', '走開'],
        correctIndex: 2,
      ),
    ],
  ),

  // ===== 對標 108 課綱之單元課程 =====
  ...kChineseLessons,
  ...kMathLessons,
];

/// 取得目前所有可用的課綱主題軸（依學科 + 年級 過濾）
List<CurriculumTrack> tracksFor({String? subjectId, int? grade}) {
  final set = <CurriculumTrack>{};
  for (final l in kLessons) {
    if (subjectId != null && l.subjectId != subjectId) continue;
    if (grade != null && l.grade != grade) continue;
    set.add(l.track);
  }
  final list = set.toList();
  list.sort((a, b) => a.index.compareTo(b.index));
  return list;
}

List<Lesson> lessonsFor(String subjectId, int grade) {
  return kLessons
      .where((l) => l.subjectId == subjectId && l.grade == grade)
      .toList();
}

List<Lesson> lessonsForSubject(String subjectId) {
  return kLessons.where((l) => l.subjectId == subjectId).toList();
}

Lesson? lessonById(String id) {
  try {
    return kLessons.firstWhere((l) => l.id == id);
  } catch (_) {
    return null;
  }
}

const List<String> kDailyQuotes = [
  '今天也要開開心心學習喔！',
  '失敗是成功之母，再試一次！',
  '閱讀是打開世界的鑰匙 🔑',
  '每一天，進步一點點！',
  '好習慣從今天開始養成 🌱',
  '相信自己，你可以的！',
];
