import '../../models/lesson.dart';
import 'lesson_108_helpers.dart';

/// 英語、自然（二～六年級）、社會、綜合：國小 1～6 年級、每學期 6 單元，對應 108 課綱常見主題軸（不依特定版本教科書）。
List<Lesson> buildSupplementaryDomainLessons() {
  final out = <Lesson>[];
  for (var g = 1; g <= 6; g++) {
    out.addAll(_englishForGrade(g));
  }
  for (var g = 2; g <= 6; g++) {
    out.addAll(_scienceForGrade(g));
  }
  for (var g = 1; g <= 6; g++) {
    out.addAll(_socialForGrade(g));
    out.addAll(_lifeForGrade(g));
  }
  return out;
}

String _semContentIntro(int grade, Semester sem, String focus) {
  final s = sem == Semester.first ? '上學期' : '下學期';
  return '國小 $grade 年級 $s：$focus\n\n'
      '本單元對齊《十二年國民基本教育課程綱要》之學習重點，著重理解與生活應用；'
      '實際用語可能因學校選用之教材版本而略有差異。';
}

List<Lesson> _unitsFromTitles({
  required String subjectId,
  required String idPrefix,
  required int grade,
  required List<String> sem1,
  required List<String> sem2,
  String Function(int grade, Semester sem, int unit, String title)? extraLine,
}) {
  Lesson one(Semester sem, int unit, String title) {
    final semNum = sem == Semester.first ? 1 : 2;
    final id = '$idPrefix-$grade-$semNum-$unit';
    final focus = title;
    final content = _semContentIntro(grade, sem, focus) +
        (extraLine?.call(grade, sem, unit, title) ?? '');
    return lesson108Core(
      id: id,
      subjectId: subjectId,
      grade: grade,
      semester: sem,
      unit: unit,
      title: title,
      summary: '國小 $grade 年級「$title」之概念與應用。',
      content: content,
    );
  }

  return [
      for (var i = 0; i < sem1.length; i++) one(Semester.first, i + 1, sem1[i]),
      for (var i = 0; i < sem2.length; i++) one(Semester.second, i + 1, sem2[i]),
  ];
}

List<Lesson> _englishForGrade(int g) {
  final tables = <int, List<List<String>>>{
    1: [
      ['Hello 與問候', '字母 Aa–Mm', '字母 Nn–Zz', '數字 1–10', 'Colors 顏色', 'Classroom 教室'],
      ['Family 家人', 'Body 身體', 'Animals 動物', 'Food 食物', 'Weather 天氣', 'Fun Songs 歌謠'],
    ],
    2: [
      ['School Life 學校生活', 'Toys & Play 玩具', 'Clothes 服飾', 'Transportation 交通', 'Places 地點', 'Time 時間'],
      ['Hobbies 嗜好', 'Shopping 購物', 'Health 健康', 'Festivals 節慶', 'Nature 自然', 'Project 綜合活動'],
    ],
    3: [
      ['About Me 自我介紹', 'Daily Routine 一天生活', 'Months & Dates 月日', 'Weather & Seasons 季節', 'Countries 國家', 'Maps 地圖'],
      ['Past Tense 過去式（入門）', 'Future Plans 計畫', 'Jobs 職業', 'Rules 規則', 'Stories 故事', 'Review 複習'],
    ],
    4: [
      ['Asking for Help 請求協助', 'Comparisons 比較', 'Directions 方向', 'Phone English 電話用語', 'Email 寫信', 'Table Manners 餐桌'],
      ['Environment 環境', 'Recycling 回收', 'Energy 能源', 'Safety 安全', 'Camping 露營', 'Presentation 口說'],
    ],
    5: [
      ['Travel Plans 旅遊', 'Airport 機場', 'Hotel 飯店', 'Museum 博物館', 'Culture 文化', 'Customs 禮儀'],
      ['News 新聞入門', 'Opinions 表達意見', 'Charts 圖表', 'Interview 訪問', 'Poster 海報', 'Show & Tell'],
    ],
    6: [
      ['World Issues 全球議題', 'Volunteer 志工', 'Careers 生涯', 'STEM Words 科技詞彙', 'Debate 討論', 'Graduation 祝福'],
      ['Review 綜合複習', 'Reading Strategy 閱讀策略', 'Writing Process 寫作流程', 'Listening Tips 聽力', 'Speaking Tips 口說', 'Portfolio 學習檔案'],
    ],
  };
  final t = tables[g]!;
  return _unitsFromTitles(
    subjectId: 'english',
    idPrefix: 'ex-en',
    grade: g,
    sem1: t[0],
    sem2: t[1],
  );
}

List<Lesson> _scienceForGrade(int g) {
  final tables = <int, List<List<String>>>{
    2: [
      ['植物觀察', '動物觀察', '磁鐵與吸力', '水的三態', '空氣與風', '天氣紀錄'],
      ['太陽與影子', '聲音的產生', '材料與用途', '資源回收', '愛護環境', '動手做實驗'],
    ],
    3: [
      ['植物的身體', '昆蟲與生活史', '地層與化石', '太陽與影子的變化', '水循環', '簡單電路'],
      ['導體與絕緣體', '生物的棲地', '天氣圖', '觀測與紀錄', '交通安全與科學', '綜合探究'],
    ],
    4: [
      ['燃燒與滅火', '酸鹼與生活', '月亮的形狀變化', '星座的故事', '摩擦力', '槓桿與滑輪'],
      ['水的浮力', '熱脹冷縮', '電流與生活', '生態系', '環境議題', '科學態度'],
    ],
    5: [
      ['生殖與成長', '遺傳與變異', '水溶液與導電', '熱的傳播', '力與運動', '天氣與氣候'],
      ['地表變化', '星空觀察', '能源與生活', '科技與社會', '環境保護', '專題探究'],
    ],
    6: [
      ['天氣變化與預報', '地表的變化', '燃燒與氧', '酸鹼鹽', '力與天文', '能源與永續'],
      ['科學史與科學方法', '實驗設計', '資料分析', '科學閱讀', '生活科技', '畢業探究'],
    ],
  };
  final t = tables[g]!;
  return _unitsFromTitles(
    subjectId: 'science',
    idPrefix: 'ex-sc',
    grade: g,
    sem1: t[0],
    sem2: t[1],
  );
}

List<Lesson> _socialForGrade(int g) {
  final tables = <int, List<List<String>>>{
    1: [
      ['我的學校生活', '認識社區', '家庭與角色', '地圖小探險', '節慶與文化', '安全小衛士'],
      ['愛護公共空間', '與人相處', '家鄉特色', '交通與生活', '資源與珍惜', '學習回顧'],
    ],
    2: [
      ['家鄉的自然環境', '家鄉的人文特色', '傳統與現代', '生活中的規範', '消費與選擇', '公共參與'],
      ['台灣的地理位置', '台灣的族群', '台灣的節慶', '愛護家鄉', '地圖與方位', '綜合活動'],
    ],
    3: [
      ['認識臺灣', '臺灣的行政區', '臺灣的交通', '臺灣的產業', '臺灣的環境', '公民初探'],
      ['社區參與', '媒體識讀入門', '全球連結', '文化尊重', '公平與正義', '學期回顧'],
    ],
    4: [
      ['臺灣的過去與現在', '原住民族文化', '臺灣與世界', '經濟與生活', '環境議題', '民主生活'],
      ['法律與生活', '人權教育', '公共議題', '消費者保護', '防災', '社會探究'],
    ],
    5: [
      ['世界區域概覽', '亞洲社會', '歐美社會', '全球環境', '國際組織', '永續發展'],
      ['臺灣的國際角色', '貿易與生活', '文化多樣性', '科技與社會', '公民行動', '專題探究'],
    ],
    6: [
      ['民主政治', '權力分立', '公民參與', '經濟制度', '全球化', '臺灣的挑戰與機會'],
      ['歷史與社會變遷', '地理與人地關係', '社會規範與價值', '生涯規劃', '綜合回顧', '畢業展望'],
    ],
  };
  final t = tables[g]!;
  return _unitsFromTitles(
    subjectId: 'social',
    idPrefix: 'ex-so',
    grade: g,
    sem1: t[0],
    sem2: t[1],
  );
}

List<Lesson> _lifeForGrade(int g) {
  final tables = <int, List<List<String>>>{
    1: [
      ['適應新環境', '認識自己', '情緒小管家', '健康習慣', '安全小達人', '愛護物品'],
      ['與同學合作', '整潔與秩序', '戶外活動安全', '愛護大自然', '感謝與分享', '學期回顧'],
    ],
    2: [
      ['生活自理', '時間管理', '誠實與負責', '尊重差異', '關懷他人', '團隊合作'],
      ['家庭溝通', '社區探索', '健康飲食', '運動與休閒', '環境保護', '綜合活動'],
    ],
    3: [
      ['問題解決', '目標設定', '挫折因應', '網路安全入門', '媒體素養', '公德心'],
      ['志工精神', '文化欣賞', '理財小觀念', '防災演練', '生命教育', '學期回顧'],
    ],
    4: [
      ['自我探索', '人際溝通', '性別平等', '人權與尊重', '法治觀念', '健康生活'],
      ['壓力調適', '創意與實作', '社會關懷', '職業認識', '永續生活', '專題分享'],
    ],
    5: [
      ['生涯興趣', '學習策略', '領導與服務', '公民責任', '全球視野', '科技倫理'],
      ['專案規劃', '合作學習', '反思與改進', '身心健康', '未來想像', '學期回顧'],
    ],
    6: [
      ['升學適應', '同儕關係', '價值澄清', '社會參與', '環境行動', '感恩與祝福'],
      ['回顧與展望', '團隊挑戰', '生活技能', '防護與求助', '畢業準備', '邁向國中'],
    ],
  };
  final t = tables[g]!;
  return _unitsFromTitles(
    subjectId: 'life',
    idPrefix: 'ex-li',
    grade: g,
    sem1: t[0],
    sem2: t[1],
  );
}
