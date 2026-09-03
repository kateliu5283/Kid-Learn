#!/usr/bin/env python3
"""Generate lib/services/topic_content_data.dart with substantive lesson content."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "lib/services/topic_content_data.dart"

# ── English vocabulary by unit title ──────────────────────────────────────
ENGLISH_VOCAB: dict[str, list[tuple[str, str, str]]] = {
    "Hello 與問候": [
        ("Hello", "你好", "Hello! I'm Amy."),
        ("Hi", "嗨", "Hi, how are you?"),
        ("Good morning", "早安", "Good morning, teacher!"),
        ("Goodbye", "再見", "Goodbye! See you tomorrow."),
        ("Nice to meet you", "很高興認識你", "Nice to meet you, Tom."),
    ],
    "字母 Aa–Mm": [
        ("Apple", "蘋果", "A is for apple."),
        ("Ball", "球", "B is for ball."),
        ("Cat", "貓", "C is for cat."),
        ("Dog", "狗", "D is for dog."),
        ("Egg", "蛋", "E is for egg."),
        ("Fish", "魚", "F is for fish."),
    ],
    "字母 Nn–Zz": [
        ("Nest", "鳥巢", "N is for nest."),
        ("Orange", "橘子", "O is for orange."),
        ("Pig", "豬", "P is for pig."),
        ("Queen", "女王", "Q is for queen."),
        ("Sun", "太陽", "S is for sun."),
        ("Zoo", "動物園", "Z is for zoo."),
    ],
    "數字 1–10": [
        ("one", "一", "I have one book."),
        ("two", "二", "Two cats are playing."),
        ("three", "三", "Three apples on the table."),
        ("five", "五", "I am five years old."),
        ("ten", "十", "Ten fingers on my hands."),
    ],
    "Colors 顏色": [
        ("red", "紅色", "The apple is red."),
        ("blue", "藍色", "The sky is blue."),
        ("yellow", "黃色", "The banana is yellow."),
        ("green", "綠色", "The grass is green."),
        ("black", "黑色", "My shoes are black."),
        ("white", "白色", "The cloud is white."),
    ],
    "Classroom 教室": [
        ("desk", "書桌", "This is my desk."),
        ("chair", "椅子", "Sit on the chair, please."),
        ("book", "書", "Open your book."),
        ("pencil", "鉛筆", "I need a pencil."),
        ("ruler", "尺", "Use a ruler to draw a line."),
        ("teacher", "老師", "The teacher is kind."),
    ],
    "Family 家人": [
        ("father", "爸爸", "My father is tall."),
        ("mother", "媽媽", "My mother cooks dinner."),
        ("brother", "兄弟", "I have one brother."),
        ("sister", "姐妹", "My sister is cute."),
        ("grandpa", "爺爺", "Grandpa tells stories."),
        ("grandma", "奶奶", "Grandma bakes cookies."),
    ],
    "Body 身體": [
        ("head", "頭", "Touch your head."),
        ("eyes", "眼睛", "I have two eyes."),
        ("nose", "鼻子", "Smell with your nose."),
        ("mouth", "嘴巴", "Open your mouth."),
        ("hand", "手", "Wash your hands."),
        ("foot", "腳", "My foot hurts."),
    ],
    "Animals 動物": [
        ("dog", "狗", "The dog is barking."),
        ("cat", "貓", "The cat is sleeping."),
        ("bird", "鳥", "A bird is flying."),
        ("fish", "魚", "Fish swim in water."),
        ("rabbit", "兔子", "The rabbit is white."),
        ("monkey", "猴子", "The monkey is funny."),
    ],
    "Food 食物": [
        ("rice", "飯", "I eat rice for lunch."),
        ("bread", "麵包", "I like bread."),
        ("milk", "牛奶", "Drink your milk."),
        ("egg", "蛋", "An egg for breakfast."),
        ("apple", "蘋果", "An apple a day."),
        ("water", "水", "Drink more water."),
    ],
    "Weather 天氣": [
        ("sunny", "晴天", "It's sunny today."),
        ("rainy", "雨天", "Take an umbrella. It's rainy."),
        ("cloudy", "多雲", "The sky is cloudy."),
        ("windy", "有風", "It's windy outside."),
        ("hot", "熱", "Summer is hot."),
        ("cold", "冷", "Winter is cold."),
    ],
    "Fun Songs 歌謠": [
        ("sing", "唱歌", "Let's sing a song."),
        ("dance", "跳舞", "Dance with me."),
        ("clap", "拍手", "Clap your hands."),
        ("happy", "快樂", "We are happy."),
        ("music", "音樂", "I love music."),
    ],
    "School Life 學校生活": [
        ("school", "學校", "I go to school every day."),
        ("class", "班級", "We are in Class 2A."),
        ("homework", "作業", "Do your homework."),
        ("lunch", "午餐", "Lunch time is at twelve."),
        ("friend", "朋友", "She is my friend."),
        ("playground", "操場", "We play on the playground."),
    ],
    "Toys & Play 玩具": [
        ("ball", "球", "Let's play with a ball."),
        ("doll", "洋娃娃", "She has a doll."),
        ("car", "玩具車", "The toy car is red."),
        ("robot", "機器人", "I like robots."),
        ("puzzle", "拼圖", "Let's do a puzzle."),
        ("kite", "風箏", "Fly a kite in the park."),
    ],
    "Clothes 服飾": [
        ("shirt", "襯衫", "I wear a blue shirt."),
        ("pants", "長褲", "These pants are too long."),
        ("dress", "洋裝", "She wears a pink dress."),
        ("shoes", "鞋子", "Put on your shoes."),
        ("hat", "帽子", "Wear a hat in the sun."),
        ("socks", "襪子", "My socks are white."),
    ],
    "Transportation 交通": [
        ("bus", "公車", "I take the bus to school."),
        ("car", "汽車", "My father drives a car."),
        ("bike", "腳踏車", "I ride a bike."),
        ("train", "火車", "The train is fast."),
        ("plane", "飛機", "We fly on a plane."),
        ("walk", "走路", "Let's walk to the park."),
    ],
    "Places 地點": [
        ("park", "公園", "We play in the park."),
        ("library", "圖書館", "Read books in the library."),
        ("hospital", "醫院", "Go to the hospital when sick."),
        ("store", "商店", "Buy food at the store."),
        ("home", "家", "I go home after school."),
        ("zoo", "動物園", "See animals at the zoo."),
    ],
    "Time 時間": [
        ("morning", "早上", "I get up in the morning."),
        ("afternoon", "下午", "We have PE in the afternoon."),
        ("evening", "傍晚", "Dinner is in the evening."),
        ("night", "夜晚", "Good night! Sleep well."),
        ("today", "今天", "Today is Monday."),
        ("tomorrow", "明天", "See you tomorrow."),
    ],
    "Hobbies 嗜好": [
        ("read", "閱讀", "I like to read books."),
        ("draw", "畫畫", "She likes to draw."),
        ("swim", "游泳", "He can swim well."),
        ("run", "跑步", "Let's run in the park."),
        ("cook", "烹飪", "Mom likes to cook."),
        ("music", "音樂", "I play music every day."),
    ],
    "Shopping 購物": [
        ("buy", "購買", "I want to buy a book."),
        ("sell", "販賣", "They sell fruit here."),
        ("money", "錢", "How much money do you have?"),
        ("cheap", "便宜", "This toy is cheap."),
        ("expensive", "貴", "That bag is expensive."),
        ("store", "商店", "Let's go to the store."),
    ],
    "Health 健康": [
        ("healthy", "健康的", "Eat vegetables to stay healthy."),
        ("sick", "生病", "He is sick today."),
        ("doctor", "醫生", "The doctor helps us."),
        ("exercise", "運動", "Exercise every day."),
        ("sleep", "睡覺", "Sleep eight hours a night."),
        ("wash", "清洗", "Wash your hands before eating."),
    ],
    "Festivals 節慶": [
        ("birthday", "生日", "Happy birthday to you!"),
        ("Christmas", "聖誕節", "Merry Christmas!"),
        ("New Year", "新年", "Happy New Year!"),
        ("gift", "禮物", "I got a gift."),
        ("party", "派對", "We have a party."),
        ("celebrate", "慶祝", "Let's celebrate together."),
    ],
    "Nature 自然": [
        ("tree", "樹", "The tree is tall."),
        ("flower", "花", "The flower is beautiful."),
        ("river", "河流", "Fish live in the river."),
        ("mountain", "山", "The mountain is high."),
        ("sea", "海", "We swim in the sea."),
        ("sky", "天空", "Birds fly in the sky."),
    ],
    "Project 綜合活動": [
        ("team", "團隊", "We work as a team."),
        ("plan", "計畫", "Let's make a plan."),
        ("share", "分享", "Share your ideas."),
        ("present", "發表", "Present your project."),
        ("help", "幫助", "Help each other."),
    ],
    "About Me 自我介紹": [
        ("name", "名字", "My name is Kevin."),
        ("age", "年齡", "I am eight years old."),
        ("like", "喜歡", "I like playing basketball."),
        ("from", "來自", "I am from Taiwan."),
        ("hobby", "嗜好", "My hobby is reading."),
    ],
    "Daily Routine 一天生活": [
        ("wake up", "起床", "I wake up at seven."),
        ("brush teeth", "刷牙", "Brush your teeth every morning."),
        ("breakfast", "早餐", "I eat breakfast at home."),
        ("go to bed", "上床睡覺", "I go to bed at nine."),
        ("study", "讀書", "I study after school."),
    ],
    "Months & Dates 月日": [
        ("January", "一月", "January is the first month."),
        ("March", "三月", "My birthday is in March."),
        ("Monday", "星期一", "School starts on Monday."),
        ("Friday", "星期五", "Friday is fun."),
        ("date", "日期", "What's the date today?"),
    ],
    "Weather & Seasons 季節": [
        ("spring", "春天", "Flowers bloom in spring."),
        ("summer", "夏天", "Summer is hot and sunny."),
        ("autumn", "秋天", "Leaves fall in autumn."),
        ("winter", "冬天", "Winter is cold."),
        ("season", "季節", "There are four seasons."),
    ],
    "Countries 國家": [
        ("Taiwan", "台灣", "I live in Taiwan."),
        ("Japan", "日本", "Japan is near Taiwan."),
        ("America", "美國", "America is far away."),
        ("country", "國家", "How many countries do you know?"),
        ("flag", "國旗", "Every country has a flag."),
    ],
    "Maps 地圖": [
        ("map", "地圖", "Look at the map."),
        ("north", "北方", "Taipei is in the north."),
        ("south", "南方", "Kaohsiung is in the south."),
        ("east", "東方", "The sun rises in the east."),
        ("west", "西方", "The sun sets in the west."),
    ],
    "Past Tense 過去式（入門）": [
        ("went", "去（過去）", "I went to the park yesterday."),
        ("ate", "吃（過去）", "I ate an apple."),
        ("played", "玩（過去）", "We played soccer."),
        ("was", "是（過去）", "It was sunny yesterday."),
        ("yesterday", "昨天", "I studied English yesterday."),
    ],
    "Future Plans 計畫": [
        ("will", "將要", "I will visit my grandma."),
        ("plan", "計畫", "What is your plan?"),
        ("tomorrow", "明天", "We will go tomorrow."),
        ("next week", "下週", "The test is next week."),
        ("hope", "希望", "I hope to travel."),
    ],
    "Jobs 職業": [
        ("teacher", "老師", "She is a teacher."),
        ("doctor", "醫生", "Doctors help sick people."),
        ("nurse", "護士", "The nurse is kind."),
        ("police", "警察", "Police keep us safe."),
        ("farmer", "農夫", "Farmers grow food."),
    ],
    "Rules 規則": [
        ("rule", "規則", "Follow the rules."),
        ("quiet", "安靜", "Be quiet in the library."),
        ("listen", "聆聽", "Listen to the teacher."),
        ("wait", "等待", "Wait in line, please."),
        ("respect", "尊重", "Respect others."),
    ],
    "Stories 故事": [
        ("once upon a time", "從前", "Once upon a time, there was a king."),
        ("beginning", "開頭", "At the beginning of the story…"),
        ("end", "結尾", "At the end, they were happy."),
        ("character", "角色", "Who is your favorite character?"),
        ("story", "故事", "Tell me a story."),
    ],
    "Review 複習": [
        ("review", "複習", "Let's review what we learned."),
        ("remember", "記得", "Remember the new words."),
        ("practice", "練習", "Practice makes perfect."),
        ("test", "測驗", "The test is on Friday."),
        ("learn", "學習", "We learn English every day."),
    ],
    "Asking for Help 請求協助": [
        ("help", "幫助", "Can you help me, please?"),
        ("please", "請", "Please open the door."),
        ("excuse me", "不好意思", "Excuse me, where is the library?"),
        ("thank you", "謝謝", "Thank you for your help."),
        ("sorry", "對不起", "Sorry, I'm late."),
    ],
    "Comparisons 比較": [
        ("bigger", "比較大", "An elephant is bigger than a mouse."),
        ("smaller", "比較小", "This box is smaller."),
        ("taller", "比較高", "He is taller than me."),
        ("faster", "比較快", "A car is faster than a bike."),
        ("than", "比", "She is smarter than him."),
    ],
    "Directions 方向": [
        ("turn left", "左轉", "Turn left at the corner."),
        ("turn right", "右轉", "Turn right at the light."),
        ("go straight", "直走", "Go straight for two blocks."),
        ("near", "附近", "The school is near my home."),
        ("far", "遠", "The beach is far from here."),
    ],
    "Phone English 電話用語": [
        ("Hello", "喂", "Hello, this is Amy speaking."),
        ("call", "打電話", "I'll call you later."),
        ("message", "訊息", "Leave a message, please."),
        ("number", "號碼", "What's your phone number?"),
        ("speaking", "我是…", "May I speak to Tom?"),
    ],
    "Email 寫信": [
        ("email", "電子郵件", "Send me an email."),
        ("dear", "親愛的", "Dear friend,"),
        ("subject", "主旨", "Write a clear subject."),
        ("write", "寫", "Write a short email."),
        ("send", "寄送", "Send the email when done."),
    ],
    "Table Manners 餐桌": [
        ("please", "請", "Please pass the salt."),
        ("thank you", "謝謝", "Thank you for the meal."),
        ("napkin", "餐巾", "Put the napkin on your lap."),
        ("chew", "咀嚼", "Chew your food slowly."),
        ("polite", "有禮貌", "Be polite at the table."),
    ],
    "Environment 環境": [
        ("environment", "環境", "Protect the environment."),
        ("pollution", "污染", "Pollution hurts the earth."),
        ("clean", "乾淨", "Keep the beach clean."),
        ("protect", "保護", "We must protect nature."),
        ("earth", "地球", "The earth is our home."),
    ],
    "Recycling 回收": [
        ("recycle", "回收", "Recycle paper and plastic."),
        ("reuse", "再利用", "Reuse shopping bags."),
        ("reduce", "減少", "Reduce waste every day."),
        ("trash", "垃圾", "Put trash in the bin."),
        ("bottle", "瓶子", "Recycle the bottle."),
    ],
    "Energy 能源": [
        ("energy", "能源", "Save energy at home."),
        ("electricity", "電力", "Turn off the lights."),
        ("solar", "太陽能", "Solar power is clean."),
        ("save", "節省", "Save water and electricity."),
        ("power", "電力", "The power is off."),
    ],
    "Safety 安全": [
        ("safe", "安全", "Stay safe on the road."),
        ("danger", "危險", "Danger! Don't touch."),
        ("helmet", "安全帽", "Wear a helmet when biking."),
        ("careful", "小心", "Be careful crossing the street."),
        ("emergency", "緊急", "Call 119 in an emergency."),
    ],
    "Camping 露營": [
        ("tent", "帳篷", "We sleep in a tent."),
        ("campfire", "營火", "Sit around the campfire."),
        ("hike", "健行", "Let's hike in the mountains."),
        ("backpack", "背包", "Pack your backpack."),
        ("nature", "大自然", "Enjoy nature when camping."),
    ],
    "Presentation 口說": [
        ("present", "發表", "Present your topic clearly."),
        ("audience", "聽眾", "Look at the audience."),
        ("slide", "投影片", "Use slides to help explain."),
        ("introduce", "介紹", "Introduce yourself first."),
        ("conclude", "結論", "Conclude with a summary."),
    ],
    "Travel Plans 旅遊": [
        ("travel", "旅行", "We will travel to Japan."),
        ("ticket", "票", "Buy a train ticket."),
        ("hotel", "飯店", "We stay at a hotel."),
        ("passport", "護照", "Don't forget your passport."),
        ("trip", "旅程", "Have a nice trip!"),
    ],
    "Airport 機場": [
        ("airport", "機場", "We arrive at the airport."),
        ("flight", "航班", "Our flight is at ten."),
        ("luggage", "行李", "Check your luggage."),
        ("gate", "登機門", "Go to gate 5."),
        ("boarding", "登機", "Boarding starts now."),
    ],
    "Hotel 飯店": [
        ("hotel", "飯店", "The hotel is near the beach."),
        ("room", "房間", "Our room has a view."),
        ("key", "鑰匙", "Here is your room key."),
        ("check in", "入住", "Check in at the front desk."),
        ("breakfast", "早餐", "Breakfast is included."),
    ],
    "Museum 博物館": [
        ("museum", "博物館", "Visit the science museum."),
        ("exhibit", "展覽", "See the dinosaur exhibit."),
        ("history", "歷史", "Learn about history."),
        ("guide", "導覽", "Follow the tour guide."),
        ("artifact", "文物", "Don't touch the artifacts."),
    ],
    "Culture 文化": [
        ("culture", "文化", "Every country has its culture."),
        ("tradition", "傳統", "Respect local traditions."),
        ("custom", "習俗", "Learn about local customs."),
        ("festival", "節慶", "Join the festival."),
        ("language", "語言", "Language is part of culture."),
    ],
    "Customs 禮儀": [
        ("polite", "有禮貌", "Be polite when visiting."),
        ("greet", "問候", "Greet people with a smile."),
        ("gift", "禮物", "Bring a small gift."),
        ("bow", "鞠躬", "Bow in some countries."),
        ("respect", "尊重", "Respect different customs."),
    ],
    "News 新聞入門": [
        ("news", "新聞", "I read the news every morning."),
        ("headline", "標題", "Read the headline first."),
        ("report", "報導", "The report is about weather."),
        ("fact", "事實", "Check if it is a fact."),
        ("source", "來源", "Know your news source."),
    ],
    "Opinions 表達意見": [
        ("think", "認為", "I think we should recycle more."),
        ("agree", "同意", "I agree with you."),
        ("disagree", "不同意", "I disagree because…"),
        ("opinion", "意見", "Share your opinion."),
        ("because", "因為", "I like it because it's fun."),
    ],
    "Charts 圖表": [
        ("chart", "圖表", "Look at the bar chart."),
        ("graph", "圖形", "The graph shows growth."),
        ("data", "資料", "Collect data first."),
        ("compare", "比較", "Compare the numbers."),
        ("increase", "增加", "Sales increased this year."),
    ],
    "Interview 訪問": [
        ("interview", "訪談", "I will interview my teacher."),
        ("question", "問題", "Prepare good questions."),
        ("answer", "回答", "Answer clearly."),
        ("record", "記錄", "Record the interview."),
        ("introduce", "介紹", "Introduce the guest."),
    ],
    "Poster 海報": [
        ("poster", "海報", "Make a colorful poster."),
        ("title", "標題", "Write a big title."),
        ("picture", "圖片", "Add pictures to your poster."),
        ("message", "訊息", "The message should be clear."),
        ("design", "設計", "Design it carefully."),
    ],
    "Show & Tell": [
        ("show", "展示", "Show your favorite thing."),
        ("tell", "講述", "Tell us why you like it."),
        ("describe", "描述", "Describe it in detail."),
        ("audience", "聽眾", "Speak to the audience."),
        ("favorite", "最喜歡", "This is my favorite book."),
    ],
    "World Issues 全球議題": [
        ("climate", "氣候", "Climate change affects everyone."),
        ("poverty", "貧窮", "Help fight poverty."),
        ("peace", "和平", "We hope for world peace."),
        ("global", "全球", "This is a global issue."),
        ("solution", "解決方案", "Find a solution together."),
    ],
    "Volunteer 志工": [
        ("volunteer", "志工", "Be a volunteer on weekends."),
        ("help", "幫助", "Volunteers help the community."),
        ("community", "社區", "Serve your community."),
        ("donate", "捐贈", "Donate books to the library."),
        ("service", "服務", "Community service is important."),
    ],
    "Careers 生涯": [
        ("career", "生涯", "Think about your future career."),
        ("job", "工作", "What job interests you?"),
        ("skill", "技能", "Learn useful skills."),
        ("goal", "目標", "Set a career goal."),
        ("future", "未來", "Plan for the future."),
    ],
    "STEM Words 科技詞彙": [
        ("science", "科學", "Science helps us understand the world."),
        ("technology", "科技", "Technology changes our lives."),
        ("engineer", "工程師", "Engineers build bridges."),
        ("experiment", "實驗", "Do an experiment carefully."),
        ("invent", "發明", "Invent something new."),
    ],
    "Debate 討論": [
        ("debate", "辯論", "We had a class debate."),
        ("argument", "論點", "Support your argument with facts."),
        ("evidence", "證據", "Use evidence to persuade."),
        ("counter", "反駁", "Listen before you counter."),
        ("conclude", "結論", "Conclude your side clearly."),
    ],
    "Graduation 祝福": [
        ("graduate", "畢業", "We will graduate soon."),
        ("congratulations", "恭喜", "Congratulations!"),
        ("memory", "回憶", "Keep good memories."),
        ("future", "未來", "Wish you a bright future."),
        ("farewell", "告別", "Farewell, elementary school!"),
    ],
    "Reading Strategy 閱讀策略": [
        ("predict", "預測", "Predict what happens next."),
        ("summarize", "摘要", "Summarize the main idea."),
        ("scan", "略讀", "Scan for key words."),
        ("infer", "推論", "Infer meaning from context."),
        ("context", "上下文", "Use context clues."),
    ],
    "Writing Process 寫作流程": [
        ("draft", "草稿", "Write a first draft."),
        ("revise", "修改", "Revise your writing."),
        ("edit", "編輯", "Edit for spelling."),
        ("publish", "發表", "Publish your final work."),
        ("brainstorm", "發想", "Brainstorm ideas first."),
    ],
    "Listening Tips 聽力": [
        ("listen", "聽", "Listen for key words."),
        ("note", "筆記", "Take notes while listening."),
        ("repeat", "複述", "Repeat what you heard."),
        ("focus", "專注", "Focus on the speaker."),
        ("understand", "理解", "Try to understand the gist."),
    ],
    "Speaking Tips 口說": [
        ("speak", "說", "Speak clearly and slowly."),
        ("pronounce", "發音", "Practice pronunciation."),
        ("pause", "停頓", "Pause between sentences."),
        ("express", "表達", "Express your ideas confidently."),
        ("practice", "練習", "Practice speaking every day."),
    ],
    "Portfolio 學習檔案": [
        ("portfolio", "作品集", "Keep a learning portfolio."),
        ("collect", "收集", "Collect your best work."),
        ("reflect", "反思", "Reflect on what you learned."),
        ("organize", "整理", "Organize your files."),
        ("share", "分享", "Share your portfolio."),
    ],
}


def english_content(grade: int, title: str) -> dict:
    words = ENGLISH_VOCAB.get(title, [])
    if not words:
        key = title.split(" ")[0].split("&")[0].strip()
        words = ENGLISH_VOCAB.get(key, [
            ("learn", "學習", f"Let's learn about {title}."),
            ("practice", "練習", "Practice every day."),
            ("speak", "說", "Speak English with friends."),
        ])
    lines = [f"📖 {title}", "", "本課單字："]
    for en, zh, sent in words:
        lines.append(f"🔤 {en} {zh} ── {sent}")
    lines += ["", "句型練習："]
    for en, zh, sent in words[:3]:
        lines.append(f"• {sent}")
    lines += [
        "",
        "對話範例：",
        f"A: Do you know about {words[0][0]}?",
        f"B: Yes! {words[0][2]}",
        "",
        "跟著做：",
        "1. 聽每個單字的發音，跟著念三遍",
        "2. 用兩個今天學的單字各造一個句子",
        "3. 和同學練習上面的對話",
    ]
    kp = [f"{en} {zh}" for en, zh, _ in words[:4]]
    vocab = [{"term": en, "meaning": zh, "example": sent} for en, zh, sent in words]
    return {"content": "\n".join(lines), "keyPoints": kp, "vocabulary": vocab}


def science_content(grade: int, title: str) -> dict:
    facts = SCIENCE_FACTS.get(title, _generic_science_facts(title))
    lines = [f"📖 {title}", "", facts["intro"], "", "重點整理："]
    lines.extend(facts["bullets"])
    lines += ["", "動手做：", facts["activity"], "", "想一想：", facts["think"]]
    return {
        "content": "\n".join(lines),
        "keyPoints": facts["key_points"],
        "vocabulary": [],
    }


def _generic_science_facts(title: str) -> dict:
    return {
        "intro": f"「{title}」和我們 everyday 生活密切相關。跟著下面的重點，在 App 裡就能完成觀察與理解。",
        "bullets": [
            f"🔍 觀察──注意和「{title}」有關的現象",
            "❓ 提問──「為什麼會這樣？」「如果改變條件呢？」",
            "📝 紀錄──用圖或文字記下你看到的",
            "💡 結論──說出你發現的規律",
        ],
        "activity": f"找一個和「{title}」有關的例子，畫圖或拍照，寫 1～2 句說明。",
        "think": f"你能舉一個生活中和「{title}」有關的例子嗎？",
        "key_points": [f"認識「{title}」的基本概念", "能觀察並提出問題", "能把發現連結到生活"],
    }


SCIENCE_FACTS: dict[str, dict] = {
    "植物觀察": {
        "intro": "植物就在你我身邊──教室裡的盆栽、操場的大樹、回家路上的花草，都可以觀察。",
        "bullets": [
            "🌱 根──固定植物、吸收水分和養分",
            "🌿 莖──支撐植物，運送水分",
            "🍃 葉──製造養分，進行光合作用",
            "🌸 花──有些植物會開花，之後可能結果",
        ],
        "activity": "選一株植物，畫出根、莖、葉、花（如果有），並標示各部分的功能。",
        "think": "如果沒有陽光，植物的葉片會有什麼變化？",
        "key_points": ["認識植物的主要構造", "了解根、莖、葉的基本功能", "能安全地觀察植物"],
    },
    "動物觀察": {
        "intro": "動物種類很多：會飛的鳥、會游的魚、會跑的狗貓，各有不同的身體構造。",
        "bullets": [
            "🐦 鳥類──有羽毛、會下蛋、大多會飛",
            "🐟 魚類──用鰓呼吸、用鰭游泳",
            "🐕 哺乳類──有毛、胎生、用肺呼吸",
            "🐛 昆蟲──六隻腳、身體分頭胸腹",
        ],
        "activity": "觀察一種常見動物（如螞蟻、麻雀），畫圖並寫出 2 個特徵。",
        "think": "為什麼魚不能離開水太久？",
        "key_points": ["能分辨不同動物類群", "觀察動物的身體特徵", "了解特徵與生活方式的關係"],
    },
    "磁鐵與吸力": {
        "intro": "磁鐵能吸引某些金屬，這種力量叫做「磁力」。",
        "bullets": [
            "🧲 磁鐵──能吸引鐵、鎳、鈷等物質",
            "➡️ 磁極──磁鐵有 N 極和 S 極，同極相斥、異極相吸",
            "📎 測試──用磁鐵靠近不同物品，看哪些會被吸住",
            "⚠️ 安全──不要把磁鐵靠近手機、信用卡",
        ],
        "activity": "準備磁鐵和幾種物品（鐵釘、銅幣、塑膠尺），測試哪些會被吸引。",
        "think": "為什麼磁鐵無法吸引所有金屬？",
        "key_points": ["磁鐵能吸引特定金屬", "認識磁極相吸相斥", "能設計簡單測試"],
    },
    "水的三態": {
        "intro": "水在自然界中有三種狀態：固態（冰）、液態（水）、氣態（水蒸氣）。",
        "bullets": [
            "🧊 固態──溫度夠低時，水結成冰",
            "💧 液態──平常看到的水",
            "☁️ 氣態──加熱後變成看不見的水蒸氣",
            "🔄 變化──加熱或降溫會改變狀態",
        ],
        "activity": "觀察冰塊融化成水，或水燒開產生水蒸氣（需大人協助）。",
        "think": "冬天窗戶上的水珠是怎麼形成的？",
        "key_points": ["認識水的三態", "了解狀態變化與溫度有關", "能舉生活中的例子"],
    },
}


def social_content(grade: int, title: str) -> dict:
    body = SOCIAL_BODY.get(title, _generic_social(grade, title))
    lines = [f"📖 {title}", "", body["intro"], "", "重點整理："]
    lines.extend(body["bullets"])
    lines += ["", "生活連結：", body["life"], "", "想一想：", body["think"]]
    return {"content": "\n".join(lines), "keyPoints": body["key_points"], "vocabulary": []}


def _generic_social(grade: int, title: str) -> dict:
    return {
        "intro": f"國小 {grade} 年級的「{title}」幫助我們認識自己、社區和台灣。",
        "bullets": [
            f"🗺️ 認識──「{title}」和我們的生活有什麼關係",
            "📸 例子──想想你見過或經歷過的類似情況",
            "🤝 討論──和同學分享不同看法，互相尊重",
            "✅ 整理──用 1～2 句話說出這一課的重點",
        ],
        "life": f"回家後，和家人聊聊「{title}」在你生活中的例子。",
        "think": f"「{title}」對你來說最重要的是什麼？",
        "key_points": [f"理解「{title}」的基本概念", "能連結生活經驗", "能表達自己的想法"],
    }


SOCIAL_BODY: dict[str, dict] = {
    "我的學校生活": {
        "intro": "學校是我們每天學習、交朋友的地方。認識學校的各個空間和規範，能讓校園生活更順利。",
        "bullets": [
            "🏫 教室──上課、讀書、和同學一起學習",
            "📚 圖書館──借書、閱讀，保持安靜",
            "🏃 操場──體育課和下課活動的地方",
            "🍱 午餐──定時用餐，不浪費食物",
        ],
        "life": "明天上學時，留意你經過哪些空間、做了哪些事。",
        "think": "你最喜歡學校的哪個地方？為什麼？",
        "key_points": ["認識學校主要空間", "了解基本校規", "能描述一天的學校生活"],
    },
    "認識社區": {
        "intro": "社區是我們家附近的生活圈，有商店、公園、郵局、診所等，提供日常生活需要的服務。",
        "bullets": [
            "🏪 商店──買日常用品",
            "🏥 診所／醫院──生病時就醫",
            "📮 郵局──寄信、寄包裹",
            "🌳 公園──休閒、運動",
        ],
        "life": "放學後和家人散步，指認社區裡的設施。",
        "think": "社區裡哪個地方對你最重要？",
        "key_points": ["認識社區常見設施", "了解設施的功能", "知道如何向社區求助"],
    },
    "台灣的地理位置": {
        "intro": "台灣是太平洋上的一座島嶼，北有基隆、南有高雄，四周環海，地形多山。",
        "bullets": [
            "🌊 海島──四面環海，有豐富的海洋資源",
            "⛰️ 山地──中央山脈縱貫，地形起伏大",
            "🌡️ 氣候──副熱帶，有明顯的季節變化",
            "📍 位置──在東亞，鄰近日本、菲律賓",
        ],
        "life": "看地圖找出你所在的城市在台灣的哪個位置。",
        "think": "台灣的地理位置對生活有什麼影響？",
        "key_points": ["知道台灣是海島", "認識基本地形與氣候", "能在地圖上找到台灣"],
    },
}


def life_content(grade: int, title: str) -> dict:
    body = LIFE_BODY.get(title, _generic_life(grade, title))
    lines = [f"📖 {title}", "", body["intro"], "", "重點整理："]
    lines.extend(body["bullets"])
    lines += ["", "跟著做：", body["activity"], "", "想一想：", body["think"]]
    return {"content": "\n".join(lines), "keyPoints": body["key_points"], "vocabulary": []}


def _generic_life(grade: int, title: str) -> dict:
    return {
        "intro": f"「{title}」是國小 {grade} 年級重要的生活能力，能幫助我們更好地照顧自己、與人相處。",
        "bullets": [
            f"👀 觀察──想想「{title}」和你每天的生活有什麼關係",
            "✋ 試試看──讀完後立刻做一件相關的小事",
            "💬 說說看──用一句話描述你學到了什麼",
            "📝 記下來──完成測驗，看看自己記住了多少",
        ],
        "activity": f"今天試著在生活里實踐「{title}」的一個小步驟。",
        "think": f"「{title}」對你來說最難的部分是什麼？",
        "key_points": [f"理解「{title}」的意義", "能嘗試在生活中應用", "能反思自己的進步"],
    }


LIFE_BODY: dict[str, dict] = {
    "適應新環境": {
        "intro": "升上新年級或到新學校，可能會緊張。適應新環境需要時間，但你可以主動認識新同學、新規則。",
        "bullets": [
            "😊 心情──緊張和興奮都是正常的",
            "🎒 準備──整理書包、認識新教室",
            "🤝 主動──跟同桌或鄰座同學說「你好」",
            "❓ 求助──不懂的地方可以問老師或學長姐",
        ],
        "activity": "列出 3 件你對新環境的期待，以及 1 件你想先認識的事。",
        "think": "開學第一週，你做了哪件事讓自己更適應？",
        "key_points": ["知道適應需要時間", "能主動認識新環境", "會向他人求助"],
    },
    "情緒小管家": {
        "intro": "開心、生氣、難過、緊張都是正常的情緒。學會認識和管理情緒，是照顧自己的重要能力。",
        "bullets": [
            "😊 認識──各種情緒沒有對錯，重要的是如何表達",
            "🫁 深呼吸──生氣或緊張時，先吸氣再慢慢吐氣",
            "💬 說感受──用「我覺得…」表達心情",
            "🎨 紓解──畫畫、散步或找信任的人聊聊",
        ],
        "activity": "今天如果感到生氣或緊張，試試深呼吸 3 次再說話。",
        "think": "你通常用什麼方法讓自己平靜下來？",
        "key_points": ["能辨識不同情緒", "知道基本的情緒調節方法", "能用「我覺得…」表達感受"],
    },
    "生活自理": {
        "intro": "生活自理就是「能自己照顧自己」，不需要大人每一步都幫忙。",
        "bullets": [
            "🪥 刷牙──早晚刷牙，每面刷 20 秒",
            "👕 穿衣服──認識正反面，自己扣扣子",
            "🎒 整理書包──依課表放好課本和文具",
            "🧦 穿脫鞋襪──自己穿鞋子、擺好拖鞋",
        ],
        "activity": "今晚睡前自己整理明天的書包，並檢查是否依課表準備。",
        "think": "這四項裡，你已經會哪兩項？還想練哪一項？",
        "key_points": ["認識生活自理項目", "能嘗試自己完成", "養成每日習慣"],
    },
}


def chinese_content(grade: int, title: str) -> dict:
    body = CHINESE_BODY.get(title, _generic_chinese(grade, title))
    lines = [f"📖 {title}", "", body["passage"], "", "重點整理："]
    lines.extend(body["bullets"])
    lines += ["", "練習：", body["practice"]]
    vocab = body.get("vocabulary", [])
    return {"content": "\n".join(lines), "keyPoints": body["key_points"], "vocabulary": vocab}


def _generic_chinese(grade: int, title: str) -> dict:
    return {
        "passage": f"「{title}」是國小 {grade} 年級國語的重要學習內容。\n\n"
        f"閱讀時，先找出段落大意，再思考作者想傳達什麼。寫作時，先列大綱，再逐段擴寫。\n\n"
        f"例：讀到「他跑向操場」這一句，可以問──誰跑向操場？為什麼？這就是「{title}」的基礎練習。",
        "bullets": [
            f"📖 閱讀──標示「{title}」相關的關鍵句",
            "✏️ 寫作──先列 3 個重點再寫成段落",
            "💬 口語──用自己的話說出重點",
            "🔍 思考──這段文字想告訴我們什麼？",
        ],
        "practice": "選一段短文字，用本課方法標出重點句，並寫 1 句摘要。",
        "key_points": [f"理解「{title}」的基本概念", "能標示關鍵句", "能寫出簡短摘要"],
        "vocabulary": [],
    }


CHINESE_BODY: dict[str, dict] = {
    "寓言與寓意": {
        "passage": "從前，有一隻驕傲的兔子向烏龜挑戰賽跑。兔子半路睡著，烏龜一步一步堅持到終點。\n\n"
        "這個故事告訴我們：驕傲可能讓人失敗，持續努力才能成功。寓言用簡短的故事，說出深刻的道理。",
        "bullets": [
            "📖 寓言──用故事說道理，人物常是動物",
            "💡 寓意──故事想告訴我們的道理",
            "🔍 找寓意──想想主角做了什麼、結果如何",
            "✏️ 練習──讀完後用一句話說出寓意",
        ],
        "practice": "讀〈龜兔賽跑〉，寫出寓意，並舉一個生活中的例子。",
        "key_points": ["認識寓言文體", "能找出故事寓意", "能連結生活經驗"],
        "vocabulary": [
            {"term": "寓言", "meaning": "用故事說道理", "example": "龜兔賽跑是寓言"},
            {"term": "寓意", "meaning": "故事的道理", "example": "驕傲會失敗"},
        ],
    },
    "記敘文要點": {
        "passage": "記敘文寫人、寫事、寫景或寫物。讀記敘文時，可以找出：時間、地點、人物、經過、結果。\n\n"
        "例：「開學日，我背著書包走進新教室，認識了新同學，心裡既緊張又期待。」\n"
        "時間＝開學日，地點＝教室，人物＝我、新同學，經過＝走進教室、認識同學，結果＝又緊張又期待。",
        "bullets": [
            "⏰ 時間──事情發生什麼時候",
            "📍 地點──在哪裡發生",
            "👤 人物──誰參與",
            "📝 經過──發生了什麼事",
        ],
        "practice": "選一篇記敘文，填寫時間、地點、人物、經過、結果。",
        "key_points": ["認識記敘文要素", "能找出時間地點人物", "能整理事件經過"],
        "vocabulary": [
            {"term": "記敘", "meaning": "記述事情經過", "example": "寫開學日的故事"},
            {"term": "經過", "meaning": "事情發展過程", "example": "先…再…最後…"},
        ],
    },
}


def math_content(grade: int, title: str, summary: str) -> dict:
    body = MATH_BODY.get(title, _generic_math(grade, title, summary))
    lines = [f"📖 {title}", "", body["intro"], "", "重點整理："]
    lines.extend(body["bullets"])
    lines += ["", "例題：", body["example"], "", "跟著做：", body["practice"]]
    return {"content": "\n".join(lines), "keyPoints": body["key_points"], "vocabulary": []}


def _generic_math(grade: int, title: str, summary: str) -> dict:
    return {
        "intro": f"這一課學習「{title}」。{summary}",
        "bullets": [
            f"📊 概念──理解「{title}」的數學意義",
            "🖐️ 動手──用圖或实物幫助理解",
            "🔁 練習──完成本課測驗題",
            "🏠 連結──想想生活中的類似例子",
        ],
        "example": f"請參考本課測驗題，練習「{title}」的計算。",
        "practice": "用家裡的小東西（積木、水果）數一數，對照本課概念。",
        "key_points": [f"理解「{title}」", summary, "能列式計算並檢查答案"],
    }


MATH_BODY: dict[str, dict] = {
    "三位數的加減": {
        "intro": "三位數的加減要用直式計算，注意進位和退位。",
        "bullets": [
            "➕ 加法──個位滿十向十位進 1，十位滿十向百位進 1",
            "➖ 減法──個位不夠減向十位借 1",
            "✅ 檢查──估算答案是否合理",
        ],
        "example": "256 + 178 = 434\n個位 6+8=14，寫 4 進 1\n十位 5+7+1=13，寫 3 進 1\n百位 2+1+1=4",
        "practice": "計算 345 + 267，並用估算檢查答案。",
        "key_points": ["三位數直式加減", "進位與退位", "估算檢查"],
    },
    "乘法（一）": {
        "intro": "一位數乘兩、三位數，理解乘法就是「幾個相同數量的加總」。",
        "bullets": [
            "✖️ 意義──3×4 表示 3 個 4 相加",
            "📝 直式──從個位開始乘，注意進位",
            "🔢 位值──十位上的乘積要寫在十位",
        ],
        "example": "23 × 4 = 92\n3×4=12，寫 2 進 1\n2×4=8，加 1 得 9",
        "practice": "計算 15 × 6 和 124 × 3。",
        "key_points": ["一位數乘兩三位數", "直式進位", "乘法意義"],
    },
    "200 以內的數": {
        "intro": "10 個十合起來是 1 個百。認識百位、十位、個位的意義。",
        "bullets": [
            "🔢 百位──最左邊，表示「幾個百」",
            "🔢 十位──中間，表示「幾個十」",
            "🔢 個位──最右邊，表示「幾個一」",
            "⚖️ 比大小──先比百位，再比十位，最後比個位",
        ],
        "example": "125 = 1 個百 + 2 個十 + 5 個一\n138 和 125 比：百位都是 1，十位 3>2，所以 138 較大",
        "practice": "寫出 146 的百、十、個位各是多少，並和 152 比大小。",
        "key_points": ["10 個十是 1 個百", "百位數的讀寫", "200 以內比大小"],
    },
}


# ── Build all lesson IDs ──────────────────────────────────────────────────

def _english_tables():
    return {
        1: (["Hello 與問候", "字母 Aa–Mm", "字母 Nn–Zz", "數字 1–10", "Colors 顏色", "Classroom 教室"],
            ["Family 家人", "Body 身體", "Animals 動物", "Food 食物", "Weather 天氣", "Fun Songs 歌謠"]),
        2: (["School Life 學校生活", "Toys & Play 玩具", "Clothes 服飾", "Transportation 交通", "Places 地點", "Time 時間"],
            ["Hobbies 嗜好", "Shopping 購物", "Health 健康", "Festivals 節慶", "Nature 自然", "Project 綜合活動"]),
        3: (["About Me 自我介紹", "Daily Routine 一天生活", "Months & Dates 月日", "Weather & Seasons 季節", "Countries 國家", "Maps 地圖"],
            ["Past Tense 過去式（入門）", "Future Plans 計畫", "Jobs 職業", "Rules 規則", "Stories 故事", "Review 複習"]),
        4: (["Asking for Help 請求協助", "Comparisons 比較", "Directions 方向", "Phone English 電話用語", "Email 寫信", "Table Manners 餐桌"],
            ["Environment 環境", "Recycling 回收", "Energy 能源", "Safety 安全", "Camping 露營", "Presentation 口說"]),
        5: (["Travel Plans 旅遊", "Airport 機場", "Hotel 飯店", "Museum 博物館", "Culture 文化", "Customs 禮儀"],
            ["News 新聞入門", "Opinions 表達意見", "Charts 圖表", "Interview 訪問", "Poster 海報", "Show & Tell"]),
        6: (["World Issues 全球議題", "Volunteer 志工", "Careers 生涯", "STEM Words 科技詞彙", "Debate 討論", "Graduation 祝福"],
            ["Review 綜合複習", "Reading Strategy 閱讀策略", "Writing Process 寫作流程", "Listening Tips 聽力", "Speaking Tips 口說", "Portfolio 學習檔案"]),
    }


def _science_tables():
    return {
        2: (["植物觀察", "動物觀察", "磁鐵與吸力", "水的三態", "空氣與風", "天氣紀錄"],
            ["太陽與影子", "聲音的產生", "材料與用途", "資源回收", "愛護環境", "動手做實驗"]),
        3: (["植物的身體", "昆蟲與生活史", "地層與化石", "太陽與影子的變化", "水循環", "簡單電路"],
            ["導體與絕緣體", "生物的棲地", "天氣圖", "觀測與紀錄", "交通安全與科學", "綜合探究"]),
        4: (["燃燒與滅火", "酸鹼與生活", "月亮的形狀變化", "星座的故事", "摩擦力", "槓桿與滑輪"],
            ["水的浮力", "熱脹冷縮", "電流與生活", "生態系", "環境議題", "科學態度"]),
        5: (["生殖與成長", "遺傳與變異", "水溶液與導電", "熱的傳播", "力與運動", "天氣與氣候"],
            ["地表變化", "星空觀察", "能源與生活", "科技與社會", "環境保護", "專題探究"]),
        6: (["天氣變化與預報", "地表的變化", "燃燒與氧", "酸鹼鹽", "力與天文", "能源與永續"],
            ["科學史與科學方法", "實驗設計", "資料分析", "科學閱讀", "生活科技", "畢業探究"]),
    }


def _social_tables():
    return {
        1: (["我的學校生活", "認識社區", "家庭與角色", "地圖小探險", "節慶與文化", "安全小衛士"],
            ["愛護公共空間", "與人相處", "家鄉特色", "交通與生活", "資源與珍惜", "學習回顧"]),
        2: (["家鄉的自然環境", "家鄉的人文特色", "傳統與現代", "生活中的規範", "消費與選擇", "公共參與"],
            ["台灣的地理位置", "台灣的族群", "台灣的節慶", "愛護家鄉", "地圖與方位", "綜合活動"]),
        3: (["認識臺灣", "臺灣的行政區", "臺灣的交通", "臺灣的產業", "臺灣的環境", "公民初探"],
            ["社區參與", "媒體識讀入門", "全球連結", "文化尊重", "公平與正義", "學期回顧"]),
        4: (["臺灣的過去與現在", "原住民族文化", "臺灣與世界", "經濟與生活", "環境議題", "民主生活"],
            ["法律與生活", "人權教育", "公共議題", "消費者保護", "防災", "社會探究"]),
        5: (["世界區域概覽", "亞洲社會", "歐美社會", "全球環境", "國際組織", "永續發展"],
            ["臺灣的國際角色", "貿易與生活", "文化多樣性", "科技與社會", "公民行動", "專題探究"]),
        6: (["民主政治", "權力分立", "公民參與", "經濟制度", "全球化", "臺灣的挑戰與機會"],
            ["歷史與社會變遷", "地理與人地關係", "社會規範與價值", "生涯規劃", "綜合回顧", "畢業展望"]),
    }


def _life_tables():
    return {
        1: (["適應新環境", "認識自己", "情緒小管家", "健康習慣", "安全小達人", "愛護物品"],
            ["與同學合作", "整潔與秩序", "戶外活動安全", "愛護大自然", "感謝與分享", "學期回顧"]),
        2: (["生活自理", "時間管理", "誠實與負責", "尊重差異", "關懷他人", "團隊合作"],
            ["家庭溝通", "社區探索", "健康飲食", "運動與休閒", "環境保護", "綜合活動"]),
        3: (["問題解決", "目標設定", "挫折因應", "網路安全入門", "媒體素養", "公德心"],
            ["志工精神", "文化欣賞", "理財小觀念", "防災演練", "生命教育", "學期回顧"]),
        4: (["自我探索", "人際溝通", "性別平等", "人權與尊重", "法治觀念", "健康生活"],
            ["壓力調適", "創意與實作", "社會關懷", "職業認識", "永續生活", "專題分享"]),
        5: (["生涯興趣", "學習策略", "領導與服務", "公民責任", "全球視野", "科技倫理"],
            ["專案規劃", "合作學習", "反思與改進", "身心健康", "未來想像", "學期回顧"]),
        6: (["升學適應", "同儕關係", "價值澄清", "社會參與", "環境行動", "感恩與祝福"],
            ["回顧與展望", "團隊挑戰", "生活技能", "防護與求助", "畢業準備", "邁向國中"]),
    }


def _chinese_tables():
    return {
        5: (["寓言與寓意", "記敘文要點", "說明文閱讀", "字詞辨析與成語", "古詩選讀（一）", "媒體識讀入門"],
            ["抒情文與感受", "段落大意與主旨", "應用文：通知與啟事", "標點與句子", "閱讀策略：預測與提問", "綜合練習"]),
        6: (["小說與人物", "議論文初探", "說明方法：舉例、比較", "文言短文入門", "詩歌的意象", "專題閱讀"],
            ["寫作：立意與取材", "寫作：組織與修辭", "口語表達與報告", "跨文本閱讀", "字音字形統整", "銜接國中語文"]),
    }


MATH_SPECS = [
    (3, 1, 1, "三位數的加減", "直式計算與併式"),
    (3, 1, 2, "乘法（一）", "一位數乘兩、三位數"),
    (3, 1, 3, "除法（一）", "除法與餘數"),
    (3, 1, 4, "角與形", "角的大小、三角形與四邊形"),
    (3, 1, 5, "分數（一）", "同分母分數"),
    (3, 1, 6, "公升與毫升", "容量"),
    (3, 2, 1, "乘法（二）", "兩位數相乘"),
    (3, 2, 2, "除法（二）", "除數為兩位數"),
    (3, 2, 3, "公斤與公克", "重量"),
    (3, 2, 4, "面積（一）", "平方公分"),
    (3, 2, 5, "年、月、日與時間", "24 小時制"),
    (3, 2, 6, "統計圖表", "條形圖"),
    (4, 1, 1, "大數與位值", "萬、億"),
    (4, 1, 2, "四則混合", "併式與括號"),
    (4, 1, 3, "分數（二）", "異分母加減"),
    (4, 1, 4, "小數（一）", "一位小數"),
    (4, 1, 5, "角度與垂直平行", "角與線"),
    (4, 1, 6, "面積（二）", "長方形與正方形"),
    (4, 2, 1, "概數", "四捨五入"),
    (4, 2, 2, "兩步驟問題", "解題策略"),
    (4, 2, 3, "小數（二）", "兩位小數"),
    (4, 2, 4, "圓", "圓心、半徑、直徑"),
    (4, 2, 5, "折線圖", "統計"),
    (4, 2, 6, "規律與關係", "數列規律"),
    (5, 1, 1, "倍數與因數", "質數與合數"),
    (5, 1, 2, "分數除法", "分數除以整數"),
    (5, 1, 3, "小數乘法", "小數相乘"),
    (5, 1, 4, "面積（三）", "三角形、平行四邊形"),
    (5, 1, 5, "體積", "立方公分"),
    (5, 1, 6, "比率與百分率", "入門"),
    (5, 2, 1, "小數除法", "除到小數"),
    (5, 2, 2, "立體圖形", "角柱與角錐"),
    (5, 2, 3, "整數的四則運算", "正負入門（選讀）"),
    (5, 2, 4, "可能性", "機率入門"),
    (5, 2, 5, "速率", "路程時間"),
    (5, 2, 6, "解題統整", "綜合應用"),
    (6, 1, 1, "分數的四則", "混合運算"),
    (6, 1, 2, "比與比例", "比例式"),
    (6, 1, 3, "小數與分數", "互換與比較"),
    (6, 1, 4, "圓面積與圓周長", "π 的應用"),
    (6, 1, 5, "柱體體積", "角柱"),
    (6, 1, 6, "統計與平均數", "平均數、中位數"),
    (6, 2, 1, "兩量關係", "正比與反比入門"),
    (6, 2, 2, "速率與比", "綜合應用"),
    (6, 2, 3, "規律與代數", "符號表示式"),
    (6, 2, 4, "縮放與比例尺", "圖形放大縮小"),
    (6, 2, 5, "數學解題策略", "假設、列表、逆推"),
    (6, 2, 6, "總複習", "銜接國中"),
]


def build_all() -> dict[str, dict]:
    data: dict[str, dict] = {}

    for g, (s1, s2) in _english_tables().items():
        for sem, titles in [(1, s1), (2, s2)]:
            for u, title in enumerate(titles, 1):
                lid = f"ex-en-{g}-{sem}-{u}"
                data[lid] = english_content(g, title)

    for g, (s1, s2) in _science_tables().items():
        for sem, titles in [(1, s1), (2, s2)]:
            for u, title in enumerate(titles, 1):
                lid = f"ex-sc-{g}-{sem}-{u}"
                data[lid] = science_content(g, title)

    for g, (s1, s2) in _social_tables().items():
        for sem, titles in [(1, s1), (2, s2)]:
            for u, title in enumerate(titles, 1):
                lid = f"ex-so-{g}-{sem}-{u}"
                data[lid] = social_content(g, title)

    for g, (s1, s2) in _life_tables().items():
        for sem, titles in [(1, s1), (2, s2)]:
            for u, title in enumerate(titles, 1):
                lid = f"ex-li-{g}-{sem}-{u}"
                data[lid] = life_content(g, title)

    for g, (s1, s2) in _chinese_tables().items():
        for sem, titles in [(1, s1), (2, s2)]:
            for u, title in enumerate(titles, 1):
                lid = f"ex-cn-{g}-{sem}-{u}"
                data[lid] = chinese_content(g, title)

    for grade, sem, unit, title, summary in MATH_SPECS:
        lid = f"ex-ma-{grade}-{sem}-{unit}"
        data[lid] = math_content(grade, title, summary)

    return data


def dart_escape(s: str) -> str:
    return s.replace("\\", "\\\\").replace("$", "\\$").replace("'", "\\'")


def emit_dart(data: dict[str, dict]) -> str:
    lines = [
        "// GENERATED by tool/generate_topic_content.py — do not edit by hand.",
        "import '../models/lesson.dart';",
        "",
        "class TopicContentBundle {",
        "  const TopicContentBundle({",
        "    required this.content,",
        "    this.keyPoints = const [],",
        "    this.vocabulary = const [],",
        "  });",
        "  final String content;",
        "  final List<String> keyPoints;",
        "  final List<VocabItem> vocabulary;",
        "}",
        "",
        "class TopicContentData {",
        "  TopicContentData._();",
        "",
        "  static const _data = <String, TopicContentBundle>{",
    ]
    for lid, bundle in sorted(data.items()):
        content = dart_escape(bundle["content"])
        kp = ", ".join(f"'{dart_escape(k)}'" for k in bundle["keyPoints"])
        vocab_items = []
        for v in bundle.get("vocabulary", []):
            ex = v.get("example", "")
            ex_part = f", example: '{dart_escape(ex)}'" if ex else ""
            vocab_items.append(
                f"VocabItem(term: '{dart_escape(v['term'])}', meaning: '{dart_escape(v['meaning'])}'{ex_part})"
            )
        vocab = ", ".join(vocab_items)
        lines.append(f"    '{lid}': TopicContentBundle(")
        lines.append(f"      content: '''{content}''',")
        lines.append(f"      keyPoints: [{kp}],")
        lines.append(f"      vocabulary: [{vocab}],")
        lines.append("    ),")
    lines += [
        "  };",
        "",
        "  static TopicContentBundle? forId(String id) => _data[id];",
        "",
        "  static bool has(String id) => _data.containsKey(id);",
        "}",
        "",
    ]
    return "\n".join(lines)


def main():
    data = build_all()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(emit_dart(data), encoding="utf-8")
    print(f"Wrote {len(data)} lessons to {OUT}")


if __name__ == "__main__":
    main()
