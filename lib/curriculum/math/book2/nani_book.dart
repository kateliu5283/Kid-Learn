import '../../../models/lesson.dart';
import '../book1/unit_builder.dart';

/// 南一數學一下（單元順序對齊 115 學年度目錄）。
/// 例子與練習為自編，不摘錄課本原文。
final List<Lesson> kNaniMathBook2Lessons = [
  mathUnit(
    publisher: TextbookPublisher.nani,
    semester: Semester.second,
    unit: 1,
    title: '數到 100',
    summary: '一個一個、十個十個，數到 100',
    opening: '百數表像一張格子布。小安從 1 往右數，每換一列就多一個十，數到最下面就是 100。',
    method:
        '可以一個一個數，也可以 2 個、5 個或 10 個一數。72 是 7 個十和 2 個一。比大小時先看十位，十位相同再看個位。100 是 10 個十。',
    examples: const [
      MathExample('10 個十', '就是 100'),
      MathExample('58', '5 個十和 8 個一'),
      MathExample('5 個一數：65、70、75', '下一個是 80'),
    ],
    points: const [
      MathPoint('💯', '數到一百', '99 的後一個是 100，100 的前一個是 99。'),
      MathPoint('🔟', '幾個十', '十位告訴我們有幾個十。'),
      MathPoint('⚖️', '先比十位', '十位大的數比較大。'),
    ],
    steps: const [
      '看百數表，從 1 點到 100',
      '練習 5 個一數和 10 個一數',
      '抽出兩張 100 以內的數字卡，說出誰比較大',
    ],
    tip: '百數表往右加 1，往下加 10。迷路時先找整十的那一格。',
    objectives: const [
      '能數到 100，並做 2 個、5 個、10 個一數',
      '能說出一個數有幾個十、幾個一',
      '能比較 100 以內兩個數的大小',
    ],
    keyPoints: const [
      '100 是 10 個十',
      '先比十位，再比個位',
      '2 個、5 個、10 個一數都是每次加同樣的數',
    ],
    vocabulary: const [
      VocabItem(
          term: '百數表', meaning: '把 1 到 100 排成一張表', example: '我們在百數表上找到 58'),
      VocabItem(term: '十位', meaning: '表示有幾個十', example: '58 的十位是 5'),
      VocabItem(term: '個位', meaning: '表示有幾個一', example: '58 的個位是 8'),
    ],
    questions: const [
      MathQ(
        prompt: '100 有幾個十？',
        options: ['1', '10', '50', '100'],
        correctIndex: 1,
        explanation: '10 個十合起來是 100。',
      ),
      MathQ(
        prompt: '58 有幾個一？',
        options: ['5', '8', '13', '50'],
        correctIndex: 1,
        explanation: '58 的個位是 8。',
      ),
      MathQ(
        prompt: '64 的前一個數是多少？',
        options: ['63', '65', '54', '74'],
        correctIndex: 0,
        explanation: '64 減 1 是 63。',
      ),
      MathQ(
        prompt: '5 個一數：65、70、75，下一個是多少？',
        options: ['76', '80', '85', '100'],
        correctIndex: 1,
        explanation: '每次加 5，75 的下一個是 80。',
      ),
      MathQ(
        prompt: '90 和 89，哪一個比較大？',
        options: ['89', '90', '一樣大', '不能比'],
        correctIndex: 1,
        explanation: '90 有 9 個十，89 只有 8 個十。',
      ),
      MathQ(
        prompt: '99 的後一個數是多少？',
        options: ['98', '100', '109', '90'],
        correctIndex: 1,
        explanation: '99 再加 1 就是 100。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.nani,
    semester: Semester.second,
    unit: 2,
    title: '18 以內的加法',
    summary: '和在 18 以內，先湊十再加',
    opening: '盤子裡有 8 顆葡萄，媽媽再放 7 顆。8 再拿 2 顆就滿 10，7 顆裡還剩 5 顆。',
    method:
        '超過 10 的加法先湊十。8 + 7：8 + 2 = 10，7 用掉 2 還剩 5，所以 10 + 5 = 15。兩個數交換位置，和仍然一樣。',
    examples: const [
      MathExample('8 + 7', '先湊 10，剩下 5，和是 15'),
      MathExample('9 + 6', '9 補 1，剩下 5，和是 15'),
      MathExample('10 + 8', '和是 18'),
    ],
    points: const [
      MathPoint('🔟', '湊成十', '先補到 10，再加剩下的。'),
      MathPoint('🔁', '交換不變', '8 + 7 和 7 + 8 都是 15。'),
      MathPoint('➕', '不超過十八', '這一單元的和在 18 以內。'),
    ],
    steps: const [
      '用葡萄或積木做 8 + 7，先湊十',
      '把加數對調，再算一次',
      '自己出三題和在 18 以內的加法',
    ],
    tip: '湊十時要記得剩下的數，不要把已經拿去補十的部分再加一次。',
    objectives: const [
      '能計算和在 18 以內的加法',
      '能用湊十解決超過 10 的加法',
      '能說明加數交換後和不變',
    ],
    keyPoints: const [
      '先湊 10，再加剩餘',
      '加數交換，和不變',
      '和最大是 18',
    ],
    vocabulary: const [
      VocabItem(term: '湊十', meaning: '先把一邊補成 10', example: '算 8 + 7 時可以先湊十'),
      VocabItem(term: '加數', meaning: '要加在一起的數', example: '8 + 7 的加數是 8 和 7'),
      VocabItem(term: '和', meaning: '加完的結果', example: '8 + 7 的和是 15'),
    ],
    questions: const [
      MathQ(
        prompt: '8 + 7 = ?',
        options: ['13', '14', '15', '16'],
        correctIndex: 2,
        explanation: '8 + 2 = 10，還剩 5，10 + 5 = 15。',
      ),
      MathQ(
        prompt: '9 + 6 = ?',
        options: ['13', '14', '15', '16'],
        correctIndex: 2,
        explanation: '9 + 1 = 10，還剩 5，和是 15。',
      ),
      MathQ(
        prompt: '10 + 8 = ?',
        options: ['16', '17', '18', '19'],
        correctIndex: 2,
        explanation: '10 + 8 = 18。',
      ),
      MathQ(
        prompt: '7 + 9 和 9 + 7 的和怎樣？',
        options: ['一樣', '7 + 9 比較大', '9 + 7 比較大', '都超過 18'],
        correctIndex: 0,
        explanation: '兩題都是 16。',
      ),
      MathQ(
        prompt: '有 8 顆葡萄，再放 6 顆，一共幾顆？',
        options: ['12', '13', '14', '15'],
        correctIndex: 2,
        explanation: '8 + 6 = 14。',
      ),
      MathQ(
        prompt: '5 + 9 = ?',
        options: ['12', '13', '14', '15'],
        correctIndex: 2,
        explanation: '5 + 9 = 14。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.nani,
    semester: Semester.second,
    unit: 3,
    title: '長度',
    summary: '用同樣長的東西量一量，再比較和加減',
    opening: '兩條緞帶，一條還打著結。小安先把結打開、拉直，再把一端捏在一起比。',
    method: '一端對齊後，另一端比較遠的比較長。量的時候用同一種單位，例如一樣長的積木，首尾相接、中間不留空。兩段接起來用加法，剪掉一段用減法。',
    examples: const [
      MathExample('藍緞帶的終點比較遠', '藍緞帶比較長'),
      MathExample('5 根積木接 2 根', '一共 7 根積木長'),
      MathExample('9 個迴紋針剪掉 4 個長', '還剩 5 個迴紋針長'),
    ],
    points: const [
      MathPoint('📏', '拉直再比', '彎的或打結的要先拉直。'),
      MathPoint('🧱', '單位要相同', '不能一半用積木、一半用迴紋針。'),
      MathPoint('➕', '接起來就相加', '同一種單位的長度可以加，也可以減。'),
    ],
    steps: const [
      '把兩條緞帶拉直，一端對齊後說出誰比較長',
      '用迴紋針量一本書的短邊',
      '把兩段積木接起來，算出一共多長',
    ],
    tip: '單位之間若留下空隙，量到的長度會比實際短。',
    objectives: const [
      '能拉直並一端對齊後比較長度',
      '能用同一種單位表示長度',
      '能計算長度的加法和減法',
    ],
    keyPoints: const [
      '終點比較遠的比較長',
      '單位相同才能把數量相加',
      '接起來用加，剪掉用減',
    ],
    vocabulary: const [
      VocabItem(term: '長度', meaning: '從一端到另一端的距離', example: '拉直以後才能看出長度'),
      VocabItem(term: '單位', meaning: '量長度時重複使用的東西', example: '積木可以當作量長度的單位'),
      VocabItem(term: '對齊', meaning: '起點靠在同一個位置', example: '兩條緞帶要先一端對齊'),
    ],
    questions: const [
      MathQ(
        prompt: '一端對齊後，終點比較遠的那條？',
        options: ['比較長', '比較短', '一樣長', '不能比'],
        correctIndex: 0,
        explanation: '終點離起點比較遠，就是比較長。',
      ),
      MathQ(
        prompt: '5 根積木接上 2 根，一共幾根長？',
        options: ['3', '7', '10', '52'],
        correctIndex: 1,
        explanation: '5 + 2 = 7。',
      ),
      MathQ(
        prompt: '9 個迴紋針長，剪掉 4 個長，還剩幾個長？',
        options: ['4', '5', '13', '49'],
        correctIndex: 1,
        explanation: '9 - 4 = 5。',
      ),
      MathQ(
        prompt: '量到一半換成另一種單位，可以嗎？',
        options: ['不可以', '可以', '新的比較好看就可以', '只要總數變大就好'],
        correctIndex: 0,
        explanation: '單位不同，數字不能直接合在一起。',
      ),
      MathQ(
        prompt: '兩條緞帶的兩端都重疊，它們？',
        options: ['一樣長', '藍色比較長', '紅色比較短', '還沒開始比'],
        correctIndex: 0,
        explanation: '起點和終點都在一起，長度相同。',
      ),
      MathQ(
        prompt: '單位沒有首尾相接，結果會？',
        options: ['更準', '不準', '變成重量', '長度不會變'],
        correctIndex: 1,
        explanation: '中間有空隙，量出來就不準。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.nani,
    semester: Semester.second,
    unit: 4,
    title: '18 以內的減法',
    summary: '18 以內拿走一些，算出還剩多少',
    opening: '袋子裡有 16 顆玻璃珠，小安送給同學 9 顆。他想：9 再加幾顆會回到 16。',
    method:
        '減法可以想成缺少的加數。16 - 9 就是找 9 + ? = 16，答案是 7。也可以先減到 10，再減剩下的。算完把答案加回去，要等於原來的數。',
    examples: const [
      MathExample('16 - 9', '9 + 7 = 16，剩下 7'),
      MathExample('14 - 6', '6 + 8 = 14，剩下 8'),
      MathExample('18 - 8', '先剩下 10，不用再減，答案是 10'),
    ],
    points: const [
      MathPoint('➖', '找剩下的', '送人、拿走、用掉都用減法。'),
      MathPoint('🔟', '先回到十', '先減成 10，再處理還沒減的部分。'),
      MathPoint('✅', '加回去檢查', '減數加上差，要等於被減數。'),
    ],
    steps: const [
      '拿 16 顆珠子，拿走 9 顆，數剩下的',
      '用加法把答案加回去檢查',
      '再出兩題 18 以內的減法',
    ],
    tip: '若想到的加法不對，就換一個數再試，直到加回原來的數量。',
    objectives: const [
      '能計算 18 以內的減法',
      '能用加法找出差',
      '能檢查減完的答案',
    ],
    keyPoints: const [
      '差是減完剩下的數',
      '可以先減到 10',
      '用加法檢查減法',
    ],
    vocabulary: const [
      VocabItem(term: '被減數', meaning: '原來有的數量', example: '16 - 9 的被減數是 16'),
      VocabItem(term: '減數', meaning: '拿走的數量', example: '16 - 9 的減數是 9'),
      VocabItem(term: '差', meaning: '剩下的數量', example: '16 - 9 的差是 7'),
    ],
    questions: const [
      MathQ(
        prompt: '16 - 9 = ?',
        options: ['5', '6', '7', '8'],
        correctIndex: 2,
        explanation: '9 + 7 = 16，所以剩下 7。',
      ),
      MathQ(
        prompt: '14 - 6 = ?',
        options: ['6', '7', '8', '9'],
        correctIndex: 2,
        explanation: '6 + 8 = 14。',
      ),
      MathQ(
        prompt: '18 - 8 = ?',
        options: ['8', '9', '10', '11'],
        correctIndex: 2,
        explanation: '18 - 8 = 10。',
      ),
      MathQ(
        prompt: '有 17 顆，送出 9 顆，還剩幾顆？',
        options: ['6', '7', '8', '9'],
        correctIndex: 2,
        explanation: '17 - 9 = 8。',
      ),
      MathQ(
        prompt: '12 - 5 = ?',
        options: ['6', '7', '8', '9'],
        correctIndex: 1,
        explanation: '5 + 7 = 12，剩下 7。',
      ),
      MathQ(
        prompt: '13 - 8 = ?',
        options: ['4', '5', '6', '7'],
        correctIndex: 1,
        explanation: '8 + 5 = 13，所以 13 - 8 = 5。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.nani,
    semester: Semester.second,
    unit: 5,
    title: '圖形和形體',
    summary: '平面圖形可以重疊，立體形體可以堆疊',
    opening: '小安有兩塊一樣的三角積木，也有一顆皮球。三角積木能疊高，皮球一放上去就滾走。',
    method:
        '紙上或板子上的圓形、三角形、正方形是平面圖形。形狀和大小都一樣，就可以完全重疊。方盒有平平的面，可以堆疊；球沒有平面，不容易疊。圓罐立起來放得穩，放倒會滾。',
    examples: const [
      MathExample('兩塊一樣的三角板', '可以完全重疊'),
      MathExample('方盒', '有平面，可以往上疊'),
      MathExample('皮球', '沒有平面，會滾'),
    ],
    points: const [
      MathPoint('🔺', '平面圖形', '看邊和角，形狀、大小都相同才能重疊。'),
      MathPoint('📦', '立體形體', '可以拿起來轉，還要看有沒有平面。'),
      MathPoint('🎯', '滾或疊', '有平面才放得穩，彎彎的側面放倒會滾。'),
    ],
    steps: const [
      '找兩張圖形疊一疊，看是否完全一樣',
      '試著把書疊在盒子上，再試著疊在球上',
      '把圓罐立起來和放倒，各觀察一次',
    ],
    tip: '顏色不改變形狀。轉方向或翻面，圖形還是原來的圖形。',
    objectives: const [
      '能判斷平面圖形是否形狀相同、大小相同',
      '能說出方盒、圓罐和球哪一種放得穩',
      '能區分可以疊高和會滾動的形體',
    ],
    keyPoints: const [
      '完全重疊要形狀和大小都一樣',
      '有平面的形體比較能堆疊',
      '球沒有平面，所以不容易疊高',
    ],
    vocabulary: const [
      VocabItem(term: '重疊', meaning: '兩邊的邊和角對在一起', example: '一樣的三角板可以完全重疊'),
      VocabItem(term: '形體', meaning: '可以拿起來的立體東西', example: '方盒和球都是形體'),
      VocabItem(term: '平面', meaning: '平平的、可以放穩的面', example: '方盒有平面，所以能堆疊'),
    ],
    questions: const [
      MathQ(
        prompt: '兩塊三角板要怎樣才算完全一樣？',
        options: ['形狀和大小都一樣', '只要都是木做的', '只要顏色一樣', '只要有三個角就好，大小不管'],
        correctIndex: 0,
        explanation: '三個角只表示都是三角形，還要比大小。',
      ),
      MathQ(
        prompt: '書疊在皮球上，書會？',
        options: ['放得很穩', '滑下來', '變成方盒', '和疊在盒子上一樣穩'],
        correctIndex: 1,
        explanation: '球沒有平面，書放不住。',
      ),
      MathQ(
        prompt: '圓罐直立時可以？',
        options: ['放穩', '一定滾走', '變成三角形', '沒有底'],
        correctIndex: 0,
        explanation: '直立時底部是平的，可以放穩。',
      ),
      MathQ(
        prompt: '圓罐放倒以後？',
        options: ['會滾', '變成正方形', '不能移動', '角變多'],
        correctIndex: 0,
        explanation: '放倒時側面是彎的，就會滾。',
      ),
      MathQ(
        prompt: '大圓和小圓能完全重疊嗎？',
        options: ['能', '不能', '顏色一樣就能', '轉一轉就一定能'],
        correctIndex: 1,
        explanation: '大小不同，不能完全蓋住。',
      ),
      MathQ(
        prompt: '哪一個最容易往上疊？',
        options: ['方盒', '皮球', '放倒的圓罐', '一顆彈珠'],
        correctIndex: 0,
        explanation: '方盒的面是平的，上面可以再放東西。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.nani,
    semester: Semester.second,
    unit: 6,
    title: '幾月幾日',
    summary: '從月曆讀出月份、日期和前後一天',
    opening: '教室月曆翻到 6 月。小安先找 10 日，再看它的前一格和後一格，就是昨天和明天的日期。',
    method:
        '一年從 1 月排到 12 月，12 月的下一個月回到 1 月。一星期有 7 天。同一個月份裡，日期加 1 是後一天，減 1 是前一天。換月時，新的月份從 1 日開始。',
    examples: const [
      MathExample('6 月 10 日的前一天', '6 月 9 日'),
      MathExample('6 月 10 日的後一天', '6 月 11 日'),
      MathExample('1 月的前一個月', '12 月'),
    ],
    points: const [
      MathPoint('📅', '先月後日', '說日期時先講幾月，再講幾日。'),
      MathPoint('7️⃣', '七天', '一星期有七天，過完再循環。'),
      MathPoint('🔁', '月份會循環', '12 月之後是下一年的 1 月。'),
    ],
    steps: const [
      '在月曆找出今天是幾月幾日',
      '指出前一天和後一天',
      '從 1 月念到 12 月，再說出 12 月的下一個月',
    ],
    tip: '還在同一個月份時，只要把日期加 1 或減 1。到了月底，下一天就要換月。',
    objectives: const [
      '能讀出月曆上的幾月幾日',
      '能說出同一個月的前一天和後一天',
      '能按順序說出 12 個月',
    ],
    keyPoints: const [
      '一星期有 7 天',
      '同一個月的後一天，日期加 1',
      '12 月的下一個月是 1 月',
    ],
    vocabulary: const [
      VocabItem(term: '月曆', meaning: '一個月的日期排成的表', example: '月曆上找得到 6 月 10 日'),
      VocabItem(term: '日期', meaning: '幾月幾日', example: '今天的日期是 6 月 10 日'),
      VocabItem(term: '月份', meaning: '一年裡的第幾個月', example: '6 月的下一個月份是 7 月'),
    ],
    questions: const [
      MathQ(
        prompt: '一星期有幾天？',
        options: ['5 天', '7 天', '10 天', '12 天'],
        correctIndex: 1,
        explanation: '一星期有 7 天。',
      ),
      MathQ(
        prompt: '6 月 10 日的後一天是？',
        options: ['6 月 9 日', '6 月 11 日', '7 月 10 日', '5 月 10 日'],
        correctIndex: 1,
        explanation: '還在 6 月，日期加 1 是 11 日。',
      ),
      MathQ(
        prompt: '6 月 10 日的前一天是？',
        options: ['6 月 9 日', '6 月 11 日', '6 月 1 日', '5 月 10 日'],
        correctIndex: 0,
        explanation: '日期減 1 是 6 月 9 日。',
      ),
      MathQ(
        prompt: '12 月的下一個月是？',
        options: ['11 月', '1 月', '2 月', '10 月'],
        correctIndex: 1,
        explanation: '一年的最後一個月過了，就是 1 月。',
      ),
      MathQ(
        prompt: '7 月的前一個月是？',
        options: ['6 月', '8 月', '5 月', '9 月'],
        correctIndex: 0,
        explanation: '7 月前面是 6 月。',
      ),
      MathQ(
        prompt: '說日期時，要先說？',
        options: ['幾月', '星期幾的顏色', '誰先看到', '現在幾點'],
        correctIndex: 0,
        explanation: '先說月份，再說幾日。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.nani,
    semester: Semester.second,
    unit: 7,
    title: '錢幣',
    summary: '用 1 元、5 元、10 元、50 元和 100 元付錢',
    opening: '貼紙要 16 元。小安拿出 1 個 10 元、1 個 5 元和 1 個 1 元，加起來剛好。',
    method:
        '先看面額是 1、5、10、50 還是 100。2 個 5 元等於 1 個 10 元，5 個 10 元等於 1 個 50 元，2 個 50 元等於 1 個 100 元。算手上有多少元時，把所有面額加起來。',
    examples: const [
      MathExample('10 元、5 元和 1 元', '一共 16 元'),
      MathExample('2 個 5 元', '等於 1 個 10 元'),
      MathExample('1 個 50 元和 2 個 10 元', '一共 70 元'),
    ],
    points: const [
      MathPoint('🪙', '看面額', '不要只看大小或顏色。'),
      MathPoint('🔁', '可以兌換', '較小的錢幣可以湊成較大的面額。'),
      MathPoint('➕', '全部相加', '每一枚都要算進去。'),
    ],
    steps: const [
      '認識 1 元、5 元、10 元、50 元和 100 元',
      '用較小的錢幣湊出 10 元和 50 元',
      '算自己拿出的錢一共多少元',
    ],
    tip: '可以先加 10 元和 50 元，最後再加 1 元，比較不容易漏。',
    objectives: const [
      '能認出 1 元到 100 元的錢幣',
      '能把較小面額兌換成較大面額',
      '能算出幾枚錢幣的總和',
    ],
    keyPoints: const [
      '2 個 5 元是 10 元',
      '5 個 10 元是 50 元',
      '總元數是每個面額的和',
    ],
    vocabulary: const [
      VocabItem(term: '面額', meaning: '錢幣上表示的元數', example: '5 元硬幣的面額是 5 元'),
      VocabItem(term: '錢幣', meaning: '用來交易的硬幣或紙鈔', example: '10 元和 50 元都是錢幣'),
      VocabItem(
          term: '兌換', meaning: '換成總數相同的其他錢幣', example: '2 個 5 元可以兌換成 1 個 10 元'),
    ],
    questions: const [
      MathQ(
        prompt: '10 元、5 元和 1 元合起來是多少元？',
        options: ['15 元', '16 元', '51 元', '6 元'],
        correctIndex: 1,
        explanation: '10 + 5 + 1 = 16。',
      ),
      MathQ(
        prompt: '2 個 5 元可以兌換成？',
        options: ['1 個 1 元', '1 個 10 元', '1 個 50 元', '2 個 10 元'],
        correctIndex: 1,
        explanation: '5 + 5 = 10，等於 1 個 10 元。',
      ),
      MathQ(
        prompt: '5 個 10 元是多少元？',
        options: ['15 元', '50 元', '55 元', '100 元'],
        correctIndex: 1,
        explanation: '5 個十是 50 元。',
      ),
      MathQ(
        prompt: '1 個 50 元和 2 個 10 元，一共多少元？',
        options: ['52 元', '60 元', '70 元', '80 元'],
        correctIndex: 2,
        explanation: '50 + 10 + 10 = 70。',
      ),
      MathQ(
        prompt: '2 個 50 元是多少元？',
        options: ['52 元', '100 元', '150 元', '25 元'],
        correctIndex: 1,
        explanation: '50 + 50 = 100。',
      ),
      MathQ(
        prompt: '哪一個面額最小？',
        options: ['1 元', '5 元', '10 元', '50 元'],
        correctIndex: 0,
        explanation: '1 元比 5 元、10 元和 50 元都小。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.nani,
    semester: Semester.second,
    unit: 8,
    title: '二位數的加減',
    summary: '十位和個位分開算，滿十就進位',
    opening: '小安算 34 + 21。個位 4 + 1 = 5，十位 3 + 2 = 5，合起來是 55。若個位加起來滿十，十位就要多 1。',
    method:
        '寫直式時，個位對齊個位。不進位的加法，兩位分別相加即可。個位的和是 10 或更大，要寫下個位、把 1 進到十位。減法先練個位夠減的題目，減完可用加法檢查。',
    examples: const [
      MathExample('34 + 21', '個位 5、十位 5，和是 55'),
      MathExample('27 + 6', '個位 13，寫 3 進 1，和是 33'),
      MathExample('68 - 25', '個位 3、十位 4，差是 43'),
    ],
    points: const [
      MathPoint('📐', '對齊位數', '十位和十位算，個位和個位算。'),
      MathPoint('⬆️', '進位', '個位滿十，向十位進 1。'),
      MathPoint('✅', '不用退位', '個位夠減時，直接相減。'),
    ],
    steps: const [
      '用直式算一題不進位的加法',
      '再算一題個位會進位的加法',
      '算一題不用退位的減法，並用加法檢查',
    ],
    tip: '進位的 1 先寫小一點，加十位時才不會漏掉。',
    objectives: const [
      '能計算二位數不進位的加法',
      '能計算需要進位的加法',
      '能計算不用退位的二位數減法',
    ],
    keyPoints: const [
      '個位對個位，十位對十位',
      '個位滿十要進 1',
      '不用退位時，個位直接相減',
    ],
    vocabulary: const [
      VocabItem(term: '進位', meaning: '滿十後向左邊加 1', example: '7 + 6 滿十，需要進位'),
      VocabItem(term: '十位', meaning: '表示幾個十的位置', example: '34 的十位是 3'),
      VocabItem(term: '個位', meaning: '表示幾個一的位置', example: '34 的個位是 4'),
    ],
    questions: const [
      MathQ(
        prompt: '34 + 21 = ?',
        options: ['55', '45', '64', '53'],
        correctIndex: 0,
        explanation: '個位 4 + 1 = 5，十位 3 + 2 = 5，和是 55。',
      ),
      MathQ(
        prompt: '27 + 6 = ?',
        options: ['21', '31', '33', '87'],
        correctIndex: 2,
        explanation: '7 + 6 = 13，寫 3 進 1，十位變成 3，和是 33。',
      ),
      MathQ(
        prompt: '48 + 15 = ?',
        options: ['53', '63', '65', '51'],
        correctIndex: 1,
        explanation: '8 + 5 = 13，寫 3 進 1，十位 4 + 1 + 1 = 6，和是 63。',
      ),
      MathQ(
        prompt: '68 - 25 = ?',
        options: ['43', '45', '83', '33'],
        correctIndex: 0,
        explanation: '個位 8 - 5 = 3，十位 6 - 2 = 4，差是 43。',
      ),
      MathQ(
        prompt: '70 - 40 = ?',
        options: ['30', '40', '110', '20'],
        correctIndex: 0,
        explanation: '7 個十減 4 個十是 3 個十，等於 30。',
      ),
      MathQ(
        prompt: '59 - 4 = ?',
        options: ['53', '55', '63', '19'],
        correctIndex: 1,
        explanation: '個位 9 - 4 = 5，十位仍是 5，答案是 55。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.nani,
    semester: Semester.second,
    unit: 9,
    title: '做紀錄',
    summary: '先分類，再用畫記和表格記下數量',
    opening: '箱子裡有紅球和藍球。小安先分成兩堆，再一筆一筆畫記，最後把數量寫進表格。',
    method:
        '紀錄前先定分類標準。一個畫記代表一個，滿 5 個可以看成一組，比較好數。表格要有標題，並寫出每一類有幾個。比一比，就能說出哪一類最多、哪一類最少，或是不是一樣多。',
    examples: const [
      MathExample('紅球 |||| |', '5 + 1，是 6 個'),
      MathExample('紅球 6、藍球 4', '紅球比較多'),
      MathExample('貓 3、狗 3', '兩類一樣多'),
    ],
    points: const [
      MathPoint('🗂️', '先分類', '相同的放一起，再開始數。'),
      MathPoint('✏️', '一個畫記一個', '畫記的數目要和東西一樣多。'),
      MathPoint('📊', '寫進表格', '標題說明在記什麼，格子裡寫數量。'),
    ],
    steps: const [
      '挑一類物品，先分成兩堆',
      '用畫記記下每一堆有幾個',
      '把數量填進表，說出誰最多',
    ],
    tip: '五個畫記一組時，用 5 個 5 個加，最後再加不滿一組的。',
    objectives: const [
      '能依標準把東西分類',
      '能用畫記表示數量',
      '能從紀錄說出哪一類最多或最少',
    ],
    keyPoints: const [
      '一個畫記代表一個',
      '表格要寫出每一類的數量',
      '數量一樣就是一樣多',
    ],
    vocabulary: const [
      VocabItem(term: '畫記', meaning: '一個一個做記號來計數', example: '四條畫記表示 4 個'),
      VocabItem(term: '分類', meaning: '把相同的放在一起', example: '先把紅球和藍球分類'),
      VocabItem(term: '表格', meaning: '用來寫下每一類數量的表', example: '數量要填進表格'),
    ],
    questions: const [
      MathQ(
        prompt: '畫記 |||| 是幾個？',
        options: ['3 個', '4 個', '5 個', '6 個'],
        correctIndex: 1,
        explanation: '四條記號是 4 個。',
      ),
      MathQ(
        prompt: '紅球 6 個、藍球 4 個，比較多的是？',
        options: ['紅球', '藍球', '一樣多', '不能比'],
        correctIndex: 0,
        explanation: '6 比 4 大，紅球比較多。',
      ),
      MathQ(
        prompt: '貓 3 隻、狗 3 隻，結果是？',
        options: ['貓比較多', '狗比較多', '一樣多', '不能紀錄'],
        correctIndex: 2,
        explanation: '兩邊都是 3，一樣多。',
      ),
      MathQ(
        prompt: '紅球 3 顆、藍球 5 顆，一共幾顆？',
        options: ['2 顆', '8 顆', '15 顆', '35 顆'],
        correctIndex: 1,
        explanation: '3 + 5 = 8。',
      ),
      MathQ(
        prompt: '鉛筆 9 枝、橡皮 4 個，鉛筆比橡皮多幾個？',
        options: ['4 個', '5 個', '13 個', '9 個'],
        correctIndex: 1,
        explanation: '9 - 4 = 5。',
      ),
      MathQ(
        prompt: '做紀錄時要先？',
        options: ['分類', '把東西藏起來', '先看時鐘', '先比誰比較長'],
        correctIndex: 0,
        explanation: '先把相同的放一起，再數、再記錄。',
      ),
    ],
  ),
];
