import '../../models/lesson.dart';
import '../../models/question.dart';

/// 自然科・小一單元（對齊 108 課綱「自然科學」低年級：觀察、記錄、愛護環境）
///
/// 內容以「觀察與描述」為主，避免過深抽象概念；每單元含預習目標、重點與關鍵詞。
///
/// **後台同步**：Laravel 種子 `backend/database/data/science_g1_sync.php` 須與
/// `lib/curriculum/science/science_g1_lessons.dart` 內容一致；
/// 課程 `id`、標題、正文、詞彙、題目一致；`Lesson.id` = 後端 `lessons.code`。
const List<Lesson> kScienceG1Lessons = [
  Lesson(
    id: 'science-g1-plants',
    subjectId: 'science',
    grade: 1,
    track: CurriculumTrack.core,
    semester: Semester.first,
    unit: 1,
    title: '植物的生長',
    summary: '植物需要什麼？種子怎麼變大？',
    content:
        '植物和我們一樣會「長大」。\n\n植物通常需要：\n☀️ 陽光──幫忙製造養分\n💧 水──讓身體有水分\n🌱 土壤（或水培）──站穩、吸收養分\n🌬️ 空氣裡的氣體──參與製造養分\n\n觀察小盆栽：種子 → 發芽 → 長根長葉。可以用圖畫或照片記錄「今天長高了多少」。',
    estimatedMinutes: 12,
    objectives: [
      '能說出植物成長需要的幾項條件',
      '能描述種子發芽到長葉的順序',
      '願意照顧植物並做簡單觀察記錄',
    ],
    keyPoints: [
      '多數植物需要陽光、水、空氣與適合的生長環境',
      '發芽代表種子開始長成新植物',
      '觀察時可以比較「高度、葉片數、顏色」',
    ],
    vocabulary: [
      VocabItem(term: '發芽', meaning: '種子開始長出根和芽', example: '綠豆泡水後會發芽'),
      VocabItem(term: '陽光', meaning: '太陽的光', example: '植物需要陽光'),
      VocabItem(term: '土壤', meaning: '種植物的地土', example: '小盆栽裡的土壤'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '植物長大「不需要」下列哪一個？',
        options: ['陽光', '水', '電視', '空氣'],
        correctIndex: 2,
        explanation: '植物需要陽光、水和空氣，不需要電視。',
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '種子長出小芽，我們常說它怎麼了？',
        options: ['睡著了', '發芽了', '飛走了', '變成石頭了'],
        correctIndex: 1,
      ),
      Question(
        id: 'q3',
        type: QuestionType.multipleChoice,
        prompt: '照顧小盆栽時，下列哪個習慣比較好？',
        options: ['天天澆超多水', '完全不澆水', '依老師說明適量澆水', '把植物放進冰箱'],
        correctIndex: 2,
      ),
      Question(
        id: 'q4',
        type: QuestionType.multipleChoice,
        prompt: '把植物放在完全黑暗的櫃子裡，最可能發生什麼事？',
        options: ['長得特別快', '可能長不好或枯萎', '會開出彩虹花', '變成動物'],
        correctIndex: 1,
        explanation: '多數植物需要陽光，長期沒有陽光通常長不好。',
      ),
    ],
  ),
  Lesson(
    id: 'science-g1-plant-animal',
    subjectId: 'science',
    grade: 1,
    track: CurriculumTrack.core,
    semester: Semester.first,
    unit: 2,
    title: '植物與動物',
    summary: '怎麼分辨？各有哪些特色？',
    content:
        '大自然裡有「植物」也有「動物」。\n\n植物：多半長在固定地方，有根、莖、葉，很多會行光合作用。\n動物：會移動、需要吃食物，身體構造很多樣（例如昆蟲有六隻腳）。\n\n到校園走走：找找看樹是植物，螞蟻是動物。想一想：小狗是植物還是動物？小草呢？',
    estimatedMinutes: 10,
    objectives: [
      '能說出植物與動物各一項差異',
      '能舉出生活中常見的植物與動物例子',
    ],
    keyPoints: [
      '植物大多固定生長；動物大多會移動、需要食物',
      '觀察時注意安全，不要傷害生物',
    ],
    vocabulary: [
      VocabItem(term: '植物', meaning: '像樹、草、花這類生物', example: '校園的大樹'),
      VocabItem(term: '動物', meaning: '像狗、魚、鳥、昆蟲這類生物', example: '池塘裡的魚'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '下列哪一個「比較像」植物？',
        options: ['小狗', '小樹', '小貓', '小鳥'],
        correctIndex: 1,
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '下列哪一個「比較像」動物？',
        options: ['小草', '小花', '小魚', '小盆栽'],
        correctIndex: 2,
      ),
      Question(
        id: 'q3',
        type: QuestionType.multipleChoice,
        prompt: '觀察小昆蟲時，我們應該？',
        options: ['用力抓傷牠', '安靜觀察、不傷害牠', '把牠帶回家養很多隻', '用石頭丟牠'],
        correctIndex: 1,
      ),
    ],
  ),
  Lesson(
    id: 'science-g1-animals-habitats',
    subjectId: 'science',
    grade: 1,
    track: CurriculumTrack.core,
    semester: Semester.first,
    unit: 3,
    title: '動物住哪裡？',
    summary: '水裡、陸上、天空中的動物',
    content:
        '動物住在不同地方。\n\n🐟 魚：多半住在水裡，用鰓呼吸。\n🐦 鳥：有翅膀，很多會在天空飛或樹上休息。\n🐕 狗、貓：常和我們一起生活在陸地上。\n\n想一想：青蛙有時在水邊、有時在陸上，牠們需要潮濕環境。觀察圖片或影片時，可以說出「牠住在哪裡」。',
    estimatedMinutes: 10,
    objectives: [
      '能依例子說出動物可能居住或活動的環境',
      '知道觀察動物時要尊重生命',
    ],
    keyPoints: [
      '不同動物適合不同的棲息環境',
      '不要隨意餵食野生動物，以免影響健康與生態',
    ],
    vocabulary: [
      VocabItem(term: '棲息', meaning: '動物生活、休息的地方', example: '鳥在樹上棲息'),
      VocabItem(term: '水裡', meaning: '在水中', example: '魚在水裡游泳'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '魚多半住在哪裡？',
        options: ['天空', '水裡', '沙漠地底', '月球'],
        correctIndex: 1,
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '下列哪一種動物「常會飛」？',
        options: ['魚', '蝸牛', '蝴蝶', '蚯蚓'],
        correctIndex: 2,
      ),
      Question(
        id: 'q3',
        type: QuestionType.multipleChoice,
        prompt: '在公園看到野鳥，比較好的做法是？',
        options: ['大聲嚇牠', '丟石頭', '遠遠安靜觀察', '抓回家'],
        correctIndex: 2,
      ),
    ],
  ),
  Lesson(
    id: 'science-g1-sun-moon',
    subjectId: 'science',
    grade: 1,
    track: CurriculumTrack.core,
    semester: Semester.first,
    unit: 4,
    title: '太陽與月亮',
    summary: '白天看到太陽，夜晚看到月亮',
    content:
        '抬頭看天空：\n\n☀️ 白天常常看得到太陽。太陽很亮、很熱，不要直視以免受傷。\n🌙 夜晚常看得到月亮。月亮的形狀有時像香蕉、有時比較圓，會慢慢變化。\n\n我們在地球上，看到太陽與月亮「好像」在天空中移動，這和地球自轉有關（長大會再學更仔細）。小一先練習「觀察並畫下今天的月亮形狀」。',
    estimatedMinutes: 10,
    objectives: [
      '能區分白天較常見太陽、夜晚較常見月亮的觀察經驗',
      '知道不要直視太陽',
    ],
    keyPoints: [
      '太陽提供光和熱，對生物很重要',
      '月亮形狀會變化，可以連續幾天觀察記錄',
    ],
    vocabulary: [
      VocabItem(term: '太陽', meaning: '離地球很遠的恆星，白天很亮', example: '曬太陽要擦防曬'),
      VocabItem(term: '月亮', meaning: '繞地球轉的衛星，夜晚看得到', example: '中秋節看月亮'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '下列哪一個是「白天」常看到的天空主角？',
        options: ['月亮', '太陽', '流星', '彗星'],
        correctIndex: 1,
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '看太陽時，哪一個做法比較安全？',
        options: ['直視太陽', '用望遠鏡直看太陽', '不直視，必要時用安全方式觀測', '盯著太陽比賽'],
        correctIndex: 2,
      ),
      Question(
        id: 'q3',
        type: QuestionType.multipleChoice,
        prompt: '月亮的形狀會不會改變？',
        options: ['不會，永遠一樣', '會，有時候圓有時候缺一角', '只有週末會變', '只有下雨才變'],
        correctIndex: 1,
      ),
    ],
  ),
  Lesson(
    id: 'science-g1-day-night',
    subjectId: 'science',
    grade: 1,
    track: CurriculumTrack.core,
    semester: Semester.first,
    unit: 5,
    title: '白天與夜晚',
    summary: '天空與生活有什麼不同？',
    content:
        '地球自轉讓我們感受到「白天」和「夜晚」。\n\n白天：天空比較亮，適合戶外活動、植物行光合作用。\n夜晚：天空變暗，需要路燈或手電筒照明；很多動物在晚上活動。\n\n想一想：你晚上睡覺前，會做哪些事？早上上學前，又會做哪些事？',
    estimatedMinutes: 8,
    objectives: [
      '能說出白天與夜晚各一項不同感受或活動',
    ],
    keyPoints: [
      '白天與夜晚的光線強弱不同',
      '規律作息對健康有幫助',
    ],
    vocabulary: [
      VocabItem(term: '白天', meaning: '太陽升起後到天黑前', example: '白天上課'),
      VocabItem(term: '夜晚', meaning: '天黑到天亮前', example: '夜晚看星星'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '下列哪一項比較像「夜晚」會出現的情況？',
        options: ['天空很亮在上體育課', '天空變暗需要開燈', '中午吃營養午餐', '早上升旗'],
        correctIndex: 1,
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '太陽「大致上」從哪個方向升起？（以臺灣常見說法）',
        options: ['東邊', '西邊', '北邊', '地底下'],
        correctIndex: 0,
        explanation: '一般觀察經驗：太陽從東邊升起、西邊落下。',
      ),
    ],
  ),
  Lesson(
    id: 'science-g1-water-everywhere',
    subjectId: 'science',
    grade: 1,
    track: CurriculumTrack.core,
    semester: Semester.second,
    unit: 1,
    title: '生活中的水',
    summary: '水在哪裡？水有什麼用途？',
    content:
        '水很重要！\n\n我們喝的水、洗手的水、下雨的水，都是「水」以不同方式出現。\n\n找找看：家裡水龍頭、飲水機、雨後的水窪、河邊……水會流動，沒有固定形狀（裝在杯子裡就變成杯子的形狀）。\n\n節約用水：洗手時關小水、刷牙時不要一直讓水流著。',
    estimatedMinutes: 10,
    objectives: [
      '能舉出生活中看得到或用到水的例子',
      '能說出一項節約用水的方法',
    ],
    keyPoints: [
      '生物需要水；人每天要喝適量的水',
      '水會流動，珍惜水資源',
    ],
    vocabulary: [
      VocabItem(term: '流動', meaning: '液體會從高往低或沿著容器流', example: '水從水管流出來'),
      VocabItem(term: '節約', meaning: '不浪費', example: '節約用水'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '下列哪一個「不是」水在我們生活中的用途？',
        options: ['洗手', '喝水', '當作電池的電', '澆花'],
        correctIndex: 2,
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '哪一個習慣比較節約用水？',
        options: ['刷牙時水龍頭一直開很大', '洗手擦肥皂時先關水', '洗車用很多水管狂噴', '玩水槍一直開著'],
        correctIndex: 1,
      ),
      Question(
        id: 'q3',
        type: QuestionType.multipleChoice,
        prompt: '把水倒進不同形狀的杯子，水的形狀會怎樣？',
        options: ['永遠是圓形', '跟著杯子改變', '永遠是方形', '變成固體木頭'],
        correctIndex: 1,
      ),
    ],
  ),
  Lesson(
    id: 'science-g1-water-states',
    subjectId: 'science',
    grade: 1,
    track: CurriculumTrack.core,
    semester: Semester.second,
    unit: 2,
    title: '水的變化（冰與水蒸氣）',
    summary: '冰、水、水蒸氣都是水嗎？',
    content:
        '水有三種常見狀態：\n\n🧊 冰：水變冷結成固體，硬硬的。\n💧 水：平常流動的液體。\n💨 水蒸氣：水受熱後變成看不見或很淡的氣體（例如壺口冒的「白霧」是水蒸氣遇冷形成的小水滴）。\n\n小實驗（請大人陪同）：冰塊放桌上，過一會兒會變小──變成水了。',
    estimatedMinutes: 12,
    objectives: [
      '能說出冰、水、水蒸氣和水有關',
      '能描述冰變成水的簡單現象',
    ],
    keyPoints: [
      '溫度改變時，水的狀態可能跟著改變',
      '做實驗要注意安全，請大人協助',
    ],
    vocabulary: [
      VocabItem(term: '固體', meaning: '像冰一樣有固定形狀', example: '冰塊是固體'),
      VocabItem(term: '液體', meaning: '像水會流動', example: '水是液體'),
      VocabItem(term: '氣體', meaning: '像空氣會散開', example: '水蒸氣是氣體'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '冰塊放在室溫下慢慢變小，最可能變成什麼？',
        options: ['變成石頭', '變成水', '變成沙子', '消失成什麼都沒有'],
        correctIndex: 1,
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '水的三種狀態「不包括」下列哪一個？',
        options: ['冰', '水', '木頭', '水蒸氣'],
        correctIndex: 2,
      ),
      Question(
        id: 'q3',
        type: QuestionType.multipleChoice,
        prompt: '煮開水時，壺口冒出的「白霧」比較接近什麼概念？（小一簡化）',
        options: ['水跟空氣有關的變化現象', '壺子壞掉冒煙', '完全是毒氣', '跟水無關'],
        correctIndex: 0,
        explanation: '白霧多半是小水滴，和水蒸氣遇冷有關，長大會學更完整。',
      ),
    ],
  ),
  Lesson(
    id: 'science-g1-senses',
    subjectId: 'science',
    grade: 1,
    track: CurriculumTrack.core,
    semester: Semester.second,
    unit: 3,
    title: '用感官來觀察',
    summary: '眼睛、耳朵、鼻子、皮膚、舌頭（注意安全）',
    content:
        '科學觀察常從「感官」開始：\n\n👀 眼睛：看顏色、形狀、大小\n👂 耳朵：聽聲音大小、高低\n👃 鼻子：聞氣味（不明物品不要亂聞）\n✋ 皮膚：摸粗糙或光滑、冷或熱\n👅 舌頭：味道（不認識的食物要請大人確認）\n\n做觀察時，也可以用尺、計時器幫忙，更準確。',
    estimatedMinutes: 10,
    objectives: [
      '能說出至少兩種感官與其用途',
      '知道不明物品不要隨意聞或放入口中',
    ],
    keyPoints: [
      '感官幫助我們蒐集資訊',
      '安全最重要：實驗與觀察要遵守規範',
    ],
    vocabulary: [
      VocabItem(term: '觀察', meaning: '仔細用感官或工具去看、去記錄', example: '觀察葉子的形狀'),
      VocabItem(term: '記錄', meaning: '把看到的寫下來或畫下來', example: '記錄今天的氣溫'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '我們用哪一個感官「聽聲音」？',
        options: ['眼睛', '耳朵', '鼻子', '舌頭'],
        correctIndex: 1,
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '下列哪一個比較安全？',
        options: ['把實驗室藥水拿起來聞', '不明液體先請老師或大人處理', '把野果放嘴裡嚐味道', '把電池放嘴裡'],
        correctIndex: 1,
      ),
      Question(
        id: 'q3',
        type: QuestionType.multipleChoice,
        prompt: '「摸一摸」樹皮粗不粗糙，主要用哪個感官？',
        options: ['耳朵', '皮膚（觸覺）', '舌頭', '鼻子'],
        correctIndex: 1,
      ),
    ],
  ),
  Lesson(
    id: 'science-g1-weather',
    subjectId: 'science',
    grade: 1,
    track: CurriculumTrack.core,
    semester: Semester.second,
    unit: 4,
    title: '認識天氣',
    summary: '晴、陰、雨、風與生活',
    content:
        '每天天氣可能不同：\n\n☀️ 晴天：太陽明顯，影子清楚\n☁️ 陰天：雲比較多，陽光較弱\n🌧️ 雨天：會下雨，要帶雨具\n🌬️ 有風：旗子會飄、頭髮會飛\n\n可以看氣象預報決定穿著。下大雨時注意淹水與安全。',
    estimatedMinutes: 10,
    objectives: [
      '能說出常見天氣名稱與一項生活影響',
    ],
    keyPoints: [
      '天氣會變化，出門前可看預報',
      '雨天路滑，走路要小心',
    ],
    vocabulary: [
      VocabItem(term: '氣象', meaning: '大氣的狀態與變化', example: '看氣象預報'),
      VocabItem(term: '預報', meaning: '事先推測未來的天氣', example: '明天會不會下雨'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '下雨天出門，比較適合帶什麼？',
        options: ['墨鏡', '雨傘或雨衣', '游泳圈', '雪球'],
        correctIndex: 1,
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '下列哪一個比較像「晴天」？',
        options: ['天空很暗在打雷', '太陽明顯、影子清楚', '一直下大雨', '窗戶結冰'],
        correctIndex: 1,
      ),
      Question(
        id: 'q3',
        type: QuestionType.multipleChoice,
        prompt: '風很大時，下列哪一個比較可能發生？',
        options: ['旗子不會動', '旗子會飄動', '水一定結冰', '太陽消失'],
        correctIndex: 1,
      ),
    ],
  ),
  Lesson(
    id: 'science-g1-magnet',
    subjectId: 'science',
    grade: 1,
    track: CurriculumTrack.core,
    semester: Semester.second,
    unit: 5,
    title: '好玩的磁鐵',
    summary: '磁鐵會吸什麼？',
    content:
        '磁鐵有「磁力」，會吸引某些金屬（例如鐵製品）。\n\n常見物品：迴紋針、鐵釘比較容易被吸起來；木頭、塑膠、紙張通常不會被吸。\n\n注意：不要把磁鐵靠近手機、信用卡磁條，可能損壞；小顆磁鐵勿吞食。',
    estimatedMinutes: 10,
    objectives: [
      '能說出磁鐵比較容易吸引哪類物品（以鐵為例）',
      '知道使用磁鐵的安全注意事項',
    ],
    keyPoints: [
      '磁力是磁鐵的性質之一',
      '不是所有東西都會被磁鐵吸引',
    ],
    vocabulary: [
      VocabItem(term: '磁力', meaning: '磁鐵吸引某些金屬的力量', example: '磁鐵吸住迴紋針'),
      VocabItem(term: '吸引', meaning: '把東西拉近', example: '磁鐵吸引鐵釘'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '磁鐵「比較不會」吸起下列哪一個？',
        options: ['迴紋針', '木頭', '鐵釘', '部分螺絲'],
        correctIndex: 1,
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '玩小顆磁鐵時，要注意什麼？',
        options: ['可以吞下去試試', '不要靠近嘴巴、避免吞食', '一定要丟向別人', '泡在水裡一整天'],
        correctIndex: 1,
      ),
    ],
  ),
  Lesson(
    id: 'science-g1-earth-care',
    subjectId: 'science',
    grade: 1,
    track: CurriculumTrack.extended,
    semester: Semester.second,
    unit: 6,
    title: '愛護地球環境',
    summary: '減少垃圾、資源回收',
    content:
        '地球是我們的家。\n\n減少使用一次性餐具、做好資源回收、隨手關燈省能源，都是保護環境的方法。\n\n到戶外不要亂丟垃圾，也不要破壞植物與動物的家。',
    estimatedMinutes: 8,
    objectives: [
      '能說出一項自己可以做到的環保行動',
    ],
    keyPoints: [
      '垃圾減量與分類回收能減少污染',
      '節能省電也有助於環境',
    ],
    vocabulary: [
      VocabItem(term: '回收', meaning: '把可再利用的物品分類收集', example: '寶特瓶回收'),
      VocabItem(term: '資源', meaning: '大自然或人類可利用的物質與能源', example: '水是很珍貴的資源'),
    ],
    questions: [
      Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: '下列哪一個比較愛護環境？',
        options: ['把垃圾丟在河裡', '垃圾分類丟垃圾桶', '亂摘公園所有花', '一直開燈不關'],
        correctIndex: 1,
      ),
      Question(
        id: 'q2',
        type: QuestionType.multipleChoice,
        prompt: '「資源回收」的目的比較接近什麼？',
        options: ['讓垃圾變多', '減少浪費、讓可再利用的東西再利用', '把回收桶當玩具丟', '不用分類'],
        correctIndex: 1,
      ),
    ],
  ),
];
