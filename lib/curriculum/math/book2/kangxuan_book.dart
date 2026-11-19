import '../../../models/lesson.dart';
import '../book1/unit_builder.dart';

/// 康軒數學一下（單元順序對齊 115 學年度目錄）。
/// 例子與練習為自編，不摘錄課本原文。
final List<Lesson> kKangxuanMathBook2Lessons = [
  mathUnit(
    publisher: TextbookPublisher.kangxuan,
    semester: Semester.second,
    unit: 1,
    title: '50 以內的數',
    summary: '數到 50，並用十和一表示數量',
    opening: '一盒貼紙有 10 張。小安數到第三盒又多 6 張，就要說出 36，也要知道它是 3 個十和 6 個一。',
    method:
        '先十個十個數：10、20、30、40、50。也可以 2 個一數或 5 個一數。兩位數左邊是十位，右邊是個位。十位比較大的數就比較大；十位相同，再比個位。',
    examples: const [
      MathExample('3 個十和 6 個一', '就是 36'),
      MathExample('2 個一數：12、14、16', '下一個是 18'),
      MathExample('40 和 28', '40 的十位比較大，所以 40 比較大'),
    ],
    points: const [
      MathPoint('🔟', '幾個十', '10、20、30、40、50 都是整十，個位是 0。'),
      MathPoint('🔢', '十位和個位', '36 的 3 在十位，6 在個位。'),
      MathPoint('⚖️', '比大小', '先比十位，十位相同再比個位。'),
    ],
    steps: const [
      '從 1 唱數到 50，再從 50 倒著數回 1',
      '拿積木，練習 2 個一數、5 個一數和 10 個一數',
      '寫出 50 以內的數，說出它有幾個十、幾個一',
    ],
    tip: '學校課本用自己的圖來數。這裡用貼紙和積木，練習同樣的 50 以內。',
    objectives: const [
      '能數到 50，並做 2 個、5 個、10 個一數',
      '能用十位和個位表示 50 以內的數量',
      '能比較 50 以內兩個數的大小',
    ],
    keyPoints: const [
      '十位看有幾個十，個位看有幾個一',
      '2 個、5 個、10 個一數時，每次都加同樣的數',
      '先比十位，再比個位',
    ],
    vocabulary: const [
      VocabItem(term: '十位', meaning: '兩位數左邊那一格，表示有幾個十', example: '36 的十位是 3'),
      VocabItem(term: '個位', meaning: '兩位數右邊那一格，表示有幾個一', example: '36 的個位是 6'),
      VocabItem(term: '唱數', meaning: '照順序把數字念出來', example: '我們從 1 唱數到 50'),
    ],
    questions: const [
      MathQ(
        prompt: '36 有幾個十？',
        options: ['3', '6', '36', '30'],
        correctIndex: 0,
        explanation: '36 是 3 個十和 6 個一，十位是 3。',
      ),
      MathQ(
        prompt: '36 有幾個一？',
        options: ['3', '6', '9', '10'],
        correctIndex: 1,
        explanation: '個位是 6，所以有 6 個一。',
      ),
      MathQ(
        prompt: '28 的後一個數是多少？',
        options: ['27', '29', '30', '18'],
        correctIndex: 1,
        explanation: '28 再加 1 是 29。',
      ),
      MathQ(
        prompt: '2 個一數：6、8、10，下一個是多少？',
        options: ['11', '12', '14', '20'],
        correctIndex: 1,
        explanation: '每次加 2，10 的下一個是 12。',
      ),
      MathQ(
        prompt: '40 和 28，哪一個比較大？',
        options: ['28', '40', '一樣大', '不能比'],
        correctIndex: 1,
        explanation: '40 有 4 個十，28 只有 2 個十，40 比較大。',
      ),
      MathQ(
        prompt: '50 以內最大的數是？',
        options: ['49', '50', '51', '40'],
        correctIndex: 1,
        explanation: '這一單元數到 50，50 是最大的。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.kangxuan,
    semester: Semester.second,
    unit: 2,
    title: '18 以內的加法',
    summary: '和在 18 以內，並看出加數對調結果一樣',
    opening: '盒子裡有 9 顆彈珠，小安再放進 8 顆。9 比 10 少 1，可以先看成 10 + 8，再把多算的 1 拿回來。',
    method:
        '和超過 10 時，先湊成 10。例如 9 + 8：9 再 1 就是 10，8 剩下 7，所以是 10 + 7 = 17。加數對調，7 + 8 和 8 + 7 的和一樣。',
    examples: const [
      MathExample('9 + 8', '先湊 10，剩下 7，和是 17'),
      MathExample('7 + 8 和 8 + 7', '兩題的和都是 15'),
      MathExample('10 + 6', '10 再加 6，和是 16'),
    ],
    points: const [
      MathPoint('🔟', '先湊十', '靠近 10 的數先補成 10，再加剩下的。'),
      MathPoint('🔁', '對調一樣', '兩個加數交換位置，和不會變。'),
      MathPoint('➕', '和在 18 以內', '這一單元的結果不超過 18。'),
    ],
    steps: const [
      '用 9 顆和 8 顆彈珠，先湊成 10 再算出和',
      '同一題把兩個數對調再算一次，檢查和是否一樣',
      '從 10 + 1 練到 10 + 8，再說出對應的和',
    ],
    tip: '手指和彈珠都可以幫忙湊十。算完用倒過來的加法再檢查一次。',
    objectives: const [
      '能計算和在 18 以內的加法',
      '能用湊十的方法算出超過 10 的和',
      '能說出加數對調後和不變',
    ],
    keyPoints: const [
      '先湊 10，再加剩下的數',
      '7 + 8 和 8 + 7 的和一樣',
      '和最大到 18',
    ],
    vocabulary: const [
      VocabItem(
          term: '加數', meaning: '加法裡要加起來的數', example: '9 + 8 的兩個加數是 9 和 8'),
      VocabItem(term: '和', meaning: '加完以後的結果', example: '9 + 8 的和是 17'),
      VocabItem(term: '湊十', meaning: '先補成 10 再繼續加', example: '算 9 + 8 時可以先湊十'),
    ],
    questions: const [
      MathQ(
        prompt: '9 + 8 = ?',
        options: ['16', '17', '18', '19'],
        correctIndex: 1,
        explanation: '9 補 1 成 10，8 剩下 7，10 + 7 = 17。',
      ),
      MathQ(
        prompt: '7 + 6 = ?',
        options: ['12', '13', '14', '15'],
        correctIndex: 1,
        explanation: '7 + 6 = 13。',
      ),
      MathQ(
        prompt: '10 + 8 = ?',
        options: ['16', '17', '18', '19'],
        correctIndex: 2,
        explanation: '10 再加 8 是 18。',
      ),
      MathQ(
        prompt: '8 + 7 和 7 + 8 的和怎樣？',
        options: ['一樣', '8 + 7 比較大', '7 + 8 比較大', '都不能算'],
        correctIndex: 0,
        explanation: '加數對調，和都是 15。',
      ),
      MathQ(
        prompt: '有 9 顆彈珠，再放進 7 顆，一共幾顆？',
        options: ['15', '16', '17', '18'],
        correctIndex: 1,
        explanation: '9 + 7 = 16。',
      ),
      MathQ(
        prompt: '6 + 5 = ?',
        options: ['9', '10', '11', '12'],
        correctIndex: 2,
        explanation: '6 + 5 = 11。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.kangxuan,
    semester: Semester.second,
    unit: 3,
    title: '圖形與分類',
    summary: '找出形狀大小一樣的圖形，並照標準分類',
    opening: '小安把兩張紙片疊在一起。邊和角都對得齊，才算形狀和大小一樣；只是顏色相同還不夠。',
    method:
        '先看是圓形、三角形還是正方形，再看大或小。完全一樣的可以重疊。分類時要先說出標準，例如依形狀分，或依顏色分。排圖形時找出重複的規律，再接下去。',
    examples: const [
      MathExample('兩張一樣大的圓', '疊起來會重疊'),
      MathExample('大三角形和小三角形', '形狀一樣，但是大小不同'),
      MathExample('紅、藍、紅、藍', '下一個還是紅'),
    ],
    points: const [
      MathPoint('⭕', '形狀和大小', '兩邊都相同，才算完全一樣。'),
      MathPoint('🗂️', '先定標準', '分類前先決定看形狀、顏色或大小。'),
      MathPoint('🔁', '找規律', '重複的部分會告訴我們下一個是什麼。'),
    ],
    steps: const [
      '剪兩張圖形，疊一疊，看看能不能完全蓋住',
      '把桌上的物品依形狀分成幾堆',
      '用兩種圖形排一個會重複的規律，請家人接下去',
    ],
    tip: '轉一個方向或翻面，形狀和大小都不會變。顏色不拿來判斷是否完全一樣。',
    objectives: const [
      '能判斷兩個圖形的形狀和大小是否一樣',
      '能依一個標準把東西分類',
      '能依規律把下一個圖形接上去',
    ],
    keyPoints: const [
      '完全一樣要同時看形狀和大小',
      '分類前先說出標準',
      '規律是重複出現的部分',
    ],
    vocabulary: const [
      VocabItem(term: '重疊', meaning: '兩邊的邊和角都對在一起', example: '兩張一樣的圓疊起來會重疊'),
      VocabItem(term: '分類', meaning: '把相同的放在一起', example: '依形狀分類，圓形放一堆'),
      VocabItem(term: '規律', meaning: '會重複出現的順序', example: '紅、藍、紅、藍就是一種規律'),
    ],
    questions: const [
      MathQ(
        prompt: '兩張圖形要怎樣才算完全一樣？',
        options: ['形狀和大小都一樣', '只要顏色一樣', '只要都有角', '只要都是紙做的'],
        correctIndex: 0,
        explanation: '顏色可以不同，形狀和大小都要相同。',
      ),
      MathQ(
        prompt: '大圓和小圓可以完全重疊嗎？',
        options: ['可以', '不可以', '顏色一樣就可以', '轉一轉就一定可以'],
        correctIndex: 1,
        explanation: '大小不同，小圓蓋不滿大圓。',
      ),
      MathQ(
        prompt: '依形狀分類時，圓形應該和誰放一起？',
        options: ['其他圓形', '所有紅色的', '所有大的', '所有三角形'],
        correctIndex: 0,
        explanation: '標準是形狀，圓形和圓形同一類。',
      ),
      MathQ(
        prompt: '規律是三角、圓、三角、圓，下一個是？',
        options: ['三角', '圓', '正方形', '長方形'],
        correctIndex: 0,
        explanation: '三角和圓輪流，下一個回到三角。',
      ),
      MathQ(
        prompt: '把紅積木和藍積木分開，分類標準是？',
        options: ['顏色', '長短', '重量', '星期'],
        correctIndex: 0,
        explanation: '紅和藍是顏色。',
      ),
      MathQ(
        prompt: '正方形轉一個方向以後？',
        options: ['還是正方形', '變成圓形', '角變少', '不能再分類'],
        correctIndex: 0,
        explanation: '轉動不會改變它的邊和角。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.kangxuan,
    semester: Semester.second,
    unit: 4,
    title: '18 以內的減法',
    summary: '被減數在 18 以內，用加法檢查剩下多少',
    opening: '盤子上有 15 顆草莓，小安吃掉 7 顆。可以想：7 再加幾顆會回到 15。',
    method:
        '減法和加法是一組。15 - 7 可以想 7 + ? = 15，答案是 8。被減數超過 10 時，也可以先減到 10，再減剩下的。算完用加法加回去檢查。',
    examples: const [
      MathExample('15 - 7', '7 + 8 = 15，所以剩下 8'),
      MathExample('18 - 9', '9 + 9 = 18，剩下 9'),
      MathExample('13 - 4', '先減 3 到 10，再減 1，剩下 9'),
    ],
    points: const [
      MathPoint('➖', '剩下多少', '拿走、吃掉、用掉，都用減法。'),
      MathPoint('🔁', '用加法檢查', '減數加答案，要回到原來的數。'),
      MathPoint('🔟', '先減到十', '先減成 10，再減還沒減完的部分。'),
    ],
    steps: const [
      '拿出 15 個小物品，拿走 7 個，數剩下的',
      '用 7 + ? = 15 把同一題再算一次',
      '換 18 以內的其他題，算完都用加法檢查',
    ],
    tip: '想不出來就先減到 10。檢查時一定把減數和答案加回去。',
    objectives: const [
      '能計算 18 以內的減法',
      '能用對應的加法檢查答案',
      '能解決拿走、剩下的問題',
    ],
    keyPoints: const [
      '減法可以想對應的加法',
      '先減到 10，再減剩餘的數',
      '減數加答案要等於原來的數',
    ],
    vocabulary: const [
      VocabItem(term: '被減數', meaning: '一開始有的數量', example: '15 - 7 的被減數是 15'),
      VocabItem(term: '減數', meaning: '拿走或用掉的數量', example: '15 - 7 的減數是 7'),
      VocabItem(term: '差', meaning: '減完剩下的數量', example: '15 - 7 的差是 8'),
    ],
    questions: const [
      MathQ(
        prompt: '15 - 7 = ?',
        options: ['6', '7', '8', '9'],
        correctIndex: 2,
        explanation: '7 + 8 = 15，所以 15 - 7 = 8。',
      ),
      MathQ(
        prompt: '18 - 9 = ?',
        options: ['7', '8', '9', '10'],
        correctIndex: 2,
        explanation: '9 + 9 = 18，剩下 9。',
      ),
      MathQ(
        prompt: '13 - 6 = ?',
        options: ['5', '6', '7', '8'],
        correctIndex: 2,
        explanation: '6 + 7 = 13，所以剩下 7。',
      ),
      MathQ(
        prompt: '有 16 顆，吃掉 8 顆，還剩幾顆？',
        options: ['6', '7', '8', '9'],
        correctIndex: 2,
        explanation: '16 - 8 = 8。',
      ),
      MathQ(
        prompt: '14 - 5 = ?',
        options: ['8', '9', '10', '11'],
        correctIndex: 1,
        explanation: '5 + 9 = 14，所以 14 - 5 = 9。',
      ),
      MathQ(
        prompt: '11 - 4 = ?',
        options: ['5', '6', '7', '8'],
        correctIndex: 2,
        explanation: '4 + 7 = 11，剩下 7。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.kangxuan,
    semester: Semester.second,
    unit: 5,
    title: '有多長',
    summary: '用同樣的單位比長短，也可以把長度加起來',
    opening: '兩條繩子一條還捲著。小安先把它們拉直，一端靠在桌緣，再看另一端誰比較遠。',
    method:
        '比長短要拉直、一端對齊。量的時候選一種單位，例如一樣長的積木，一個接一個排，中間不留空。兩段接起來就相加，拿掉一段就相減。單位不同不能直接把數字加在一起。',
    examples: const [
      MathExample('一端靠齊，紅繩伸出', '紅繩比較長'),
      MathExample('4 根積木接 3 根', '一共 7 根積木長'),
      MathExample('8 個迴紋針拿掉 2 個長', '還剩 6 個迴紋針長'),
    ],
    points: const [
      MathPoint('📏', '先對齊', '拉直後把一端靠在一起，再看終點。'),
      MathPoint('🧱', '同一種單位', '積木就是積木，不要中途改用迴紋針。'),
      MathPoint('➕', '長度可以加減', '接起來用加，拿掉一段用減。'),
    ],
    steps: const [
      '把兩枝筆拉直、一端對齊，說出誰比較長',
      '用迴紋針量一枝鉛筆，數出有幾個長',
      '用積木接出兩段長度，再算接起來一共多長',
    ],
    tip: '這一冊先用身邊一樣長的東西當單位。單位要首尾相接，不能留下空隙。',
    objectives: const [
      '能把一端對齊後比較長短',
      '能用同一種單位量出長度',
      '能做長度的加法和減法',
    ],
    keyPoints: const [
      '拉直、一端對齊，再看另一端',
      '單位要相同，而且首尾相接',
      '接起來用加，拿掉用減',
    ],
    vocabulary: const [
      VocabItem(
          term: '單位', meaning: '用來量長度的同樣東西', example: '這枝筆是 5 個迴紋針，迴紋針就是單位'),
      VocabItem(term: '對齊', meaning: '把起點靠在同一個地方', example: '比長短時要先把一端對齊'),
      VocabItem(term: '長度', meaning: '從一端到另一端有多遠', example: '接起來以後，長度變長了'),
    ],
    questions: const [
      MathQ(
        prompt: '比長短時，彎曲的繩子要先？',
        options: ['拉直', '染色', '捲更緊', '剪成很多段'],
        correctIndex: 0,
        explanation: '彎著看不出真正的長度，要先拉直。',
      ),
      MathQ(
        prompt: '4 根積木接上 3 根，一共幾根長？',
        options: ['1', '7', '12', '43'],
        correctIndex: 1,
        explanation: '4 + 3 = 7，一共 7 根積木長。',
      ),
      MathQ(
        prompt: '用積木量到一半改用迴紋針，這樣可以嗎？',
        options: ['可以', '不可以', '迴紋針比較亮就可以', '只要繼續數就好'],
        correctIndex: 1,
        explanation: '單位換了，前後的數量不能加在一起。',
      ),
      MathQ(
        prompt: '8 個迴紋針長，拿掉 3 個長，還剩幾個長？',
        options: ['3', '5', '8', '11'],
        correctIndex: 1,
        explanation: '8 - 3 = 5。',
      ),
      MathQ(
        prompt: '兩端都對齊，表示兩樣東西？',
        options: ['一樣長', '左邊一定比較長', '要再看顏色', '不能比'],
        correctIndex: 0,
        explanation: '起點和終點都在一起，就是一樣長。',
      ),
      MathQ(
        prompt: '單位之間留空隙，量出來會？',
        options: ['比較準', '不準', '變成重量', '長度不變'],
        correctIndex: 1,
        explanation: '中間空一截，數出來的長度就不準。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.kangxuan,
    semester: Semester.second,
    unit: 6,
    title: '100 以內的數',
    summary: '數到 100，並看出十位和個位',
    opening: '10 條十個一捆的積木排好，就是 100。小安可以一個一個往上數，也可以從 100 一個一個往下數。',
    method:
        '100 是 10 個十，也是 100 個一。72 表示 7 個十和 2 個一。比較大小仍先看十位。99 的後一個是 100，100 的前一個是 99。',
    examples: const [
      MathExample('10 個十', '合起來是 100'),
      MathExample('72', '7 個十和 2 個一'),
      MathExample('80 和 79', '80 比較大，因為有 8 個十'),
    ],
    points: const [
      MathPoint('💯', '10 個十', '10、20 一直到 100，每增加 10 就是多一個十。'),
      MathPoint('🔢', '十位、個位', '左邊幾個十，右邊幾個一。'),
      MathPoint('⬇️', '往上也能往下', '可以從 1 數到 100，也可以從 100 倒數。'),
    ],
    steps: const [
      '十個十個數，從 10 數到 100',
      '寫下 100 以內的數，說出幾個十、幾個一',
      '從 100 往下數 10 個數',
    ],
    tip: '百數表可以幫忙找前後左右的數。往右加 1，往下通常加 10。',
    objectives: const [
      '能從 1 數到 100，也能從 100 往下數',
      '能說出 100 以內一個數的十位和個位',
      '能比較 100 以內兩個數的大小',
    ],
    keyPoints: const [
      '100 是 10 個十',
      '十位相同時再比個位',
      '99 的後一個是 100',
    ],
    vocabulary: const [
      VocabItem(term: '十位', meaning: '表示有幾個十的那一格', example: '72 的十位是 7'),
      VocabItem(term: '個位', meaning: '表示有幾個一的那一格', example: '72 的個位是 2'),
      VocabItem(term: '百', meaning: '10 個十合起來的數量', example: '1 個百就是 100'),
    ],
    questions: const [
      MathQ(
        prompt: '100 有幾個十？',
        options: ['1', '10', '50', '100'],
        correctIndex: 1,
        explanation: '10 個十是 100。',
      ),
      MathQ(
        prompt: '72 有幾個一？',
        options: ['2', '7', '9', '70'],
        correctIndex: 0,
        explanation: '72 的個位是 2。',
      ),
      MathQ(
        prompt: '99 的後一個數是多少？',
        options: ['98', '100', '101', '90'],
        correctIndex: 1,
        explanation: '99 再加 1 是 100。',
      ),
      MathQ(
        prompt: '80 和 79，哪一個比較大？',
        options: ['79', '80', '一樣大', '不能比'],
        correctIndex: 1,
        explanation: '80 有 8 個十，79 只有 7 個十。',
      ),
      MathQ(
        prompt: '10 個一數：70、80、90，下一個是多少？',
        options: ['91', '95', '100', '110'],
        correctIndex: 2,
        explanation: '每次加 10，90 的下一個是 100。',
      ),
      MathQ(
        prompt: '46 的前一個數是多少？',
        options: ['45', '47', '36', '56'],
        correctIndex: 0,
        explanation: '46 減 1 是 45。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.kangxuan,
    semester: Semester.second,
    unit: 7,
    title: '認識錢幣',
    summary: '認識 1 元、5 元、10 元、50 元和 100 元',
    opening: '小安要買 15 元的貼紙。他拿出 1 個 10 元和 1 個 5 元，合起來剛好是 15 元。',
    method:
        '先認出 1 元、5 元、10 元、50 元和 100 元。2 個 5 元是 10 元，5 個 10 元是 50 元，2 個 50 元是 100 元。算總共多少元時，把每個錢幣的數目加起來。',
    examples: const [
      MathExample('1 個 10 元和 1 個 5 元', '一共 15 元'),
      MathExample('5 個 10 元', '一共 50 元'),
      MathExample('2 個 50 元', '一共 100 元'),
    ],
    points: const [
      MathPoint('🪙', '先認面額', '看清楚是 1、5、10、50 還是 100。'),
      MathPoint('🔁', '可以兌換', '較小的錢幣湊滿，可以換成較大的。'),
      MathPoint('➕', '全部加起來', '每個錢幣的元數都要加進去。'),
    ],
    steps: const [
      '拿出幾枚錢幣，先說出每一枚是多少元',
      '用 5 元湊成 10 元，再用 10 元湊成 50 元',
      '算一算手上的錢一共多少元',
    ],
    tip: '看面額，不要只看顏色或大小。算的時候可以先加較大的錢幣。',
    objectives: const [
      '能認出 1 元、5 元、10 元、50 元和 100 元',
      '能用較小的錢幣湊成較大的面額',
      '能算出幾枚錢幣一共多少元',
    ],
    keyPoints: const [
      '2 個 5 元是 10 元',
      '5 個 10 元是 50 元',
      '總數是每個面額加起來',
    ],
    vocabulary: const [
      VocabItem(term: '面額', meaning: '一個錢幣代表多少元', example: '10 元硬幣的面額是 10 元'),
      VocabItem(term: '錢幣', meaning: '用來付錢的硬幣或紙鈔', example: '1 元和 5 元都是錢幣'),
      VocabItem(term: '一共', meaning: '全部加起來的結果', example: '10 元和 5 元一共 15 元'),
    ],
    questions: const [
      MathQ(
        prompt: '2 個 5 元合起來是多少元？',
        options: ['5 元', '10 元', '15 元', '25 元'],
        correctIndex: 1,
        explanation: '5 + 5 = 10，是 10 元。',
      ),
      MathQ(
        prompt: '1 個 10 元和 1 個 5 元，一共多少元？',
        options: ['5 元', '10 元', '15 元', '50 元'],
        correctIndex: 2,
        explanation: '10 + 5 = 15。',
      ),
      MathQ(
        prompt: '5 個 10 元是多少元？',
        options: ['15 元', '40 元', '50 元', '100 元'],
        correctIndex: 2,
        explanation: '10 加 5 次是 50 元。',
      ),
      MathQ(
        prompt: '2 個 50 元是多少元？',
        options: ['50 元', '52 元', '100 元', '150 元'],
        correctIndex: 2,
        explanation: '50 + 50 = 100。',
      ),
      MathQ(
        prompt: '1 個 50 元和 1 個 10 元，一共多少元？',
        options: ['15 元', '40 元', '60 元', '100 元'],
        correctIndex: 2,
        explanation: '50 + 10 = 60。',
      ),
      MathQ(
        prompt: '哪一個面額最大？',
        options: ['1 元', '10 元', '50 元', '100 元'],
        correctIndex: 3,
        explanation: '1、5、10、50、100 裡面，100 元最大。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.kangxuan,
    semester: Semester.second,
    unit: 8,
    title: '二位數的加減',
    summary: '個位和十位對齊，滿十要進位',
    opening: '小安先算 23 + 14。個位 3 + 4 = 7，十位 2 + 1 = 3，和是 37。個位若滿十，就要往十位進 1。',
    method:
        '兩位數相加或相減時，個位對個位、十位對十位。加法的個位滿 10，要進 1 到十位。這一冊的減法先練個位夠減、不用退位的題目。算完可以換一種方法再檢查。',
    examples: const [
      MathExample('23 + 14', '個位 7、十位 3，和是 37'),
      MathExample('28 + 5', '個位 13，寫 3 進 1，和是 33'),
      MathExample('57 - 24', '個位 3、十位 3，差是 33'),
    ],
    points: const [
      MathPoint('📐', '位數對齊', '個位和個位相加減，十位和十位相加減。'),
      MathPoint('⬆️', '滿十進一', '個位相加到 10 或超過 10，十位要多加 1。'),
      MathPoint('✅', '個位夠減', '個位比較大或一樣大，就可以直接減。'),
    ],
    steps: const [
      '先寫直式，確認個位和十位有沒有對齊',
      '練習一個不用進位、一個要進位的加法',
      '練習個位夠減的減法，再用加法檢查',
    ],
    tip: '進位的 1 要寫在十位上面，避免忘記加。個位不夠減的退位，以後再學。',
    objectives: const [
      '能做二位數不進位的加法',
      '能做個位滿十、需要進位的加法',
      '能做個位夠減、不用退位的減法',
    ],
    keyPoints: const [
      '個位對個位，十位對十位',
      '個位滿十要向十位進 1',
      '不用退位時，個位可以直接相減',
    ],
    vocabulary: const [
      VocabItem(term: '進位', meaning: '滿十後把 1 加到左邊那一位', example: '8 + 5 滿十，要進位'),
      VocabItem(term: '個位', meaning: '最右邊、表示幾個一的位置', example: '23 的個位是 3'),
      VocabItem(term: '十位', meaning: '個位左邊、表示幾個十的位置', example: '23 的十位是 2'),
    ],
    questions: const [
      MathQ(
        prompt: '23 + 14 = ?',
        options: ['27', '36', '37', '47'],
        correctIndex: 2,
        explanation: '個位 3 + 4 = 7，十位 2 + 1 = 3，和是 37。',
      ),
      MathQ(
        prompt: '28 + 5 = ?',
        options: ['23', '33', '35', '85'],
        correctIndex: 1,
        explanation: '8 + 5 = 13，寫 3 進 1，十位 2 + 1 = 3，和是 33。',
      ),
      MathQ(
        prompt: '46 + 17 = ?',
        options: ['53', '63', '67', '51'],
        correctIndex: 1,
        explanation: '6 + 7 = 13，寫 3 進 1，十位 4 + 1 + 1 = 6，和是 63。',
      ),
      MathQ(
        prompt: '57 - 24 = ?',
        options: ['23', '31', '33', '73'],
        correctIndex: 2,
        explanation: '個位 7 - 4 = 3，十位 5 - 2 = 3，差是 33。',
      ),
      MathQ(
        prompt: '80 - 30 = ?',
        options: ['40', '50', '60', '110'],
        correctIndex: 1,
        explanation: '8 個十減 3 個十是 5 個十，等於 50。',
      ),
      MathQ(
        prompt: '39 - 6 = ?',
        options: ['31', '33', '35', '45'],
        correctIndex: 1,
        explanation: '個位 9 - 6 = 3，十位仍是 3，答案是 33。',
      ),
    ],
  ),
  mathUnit(
    publisher: TextbookPublisher.kangxuan,
    semester: Semester.second,
    unit: 9,
    title: '幾月幾日星期幾',
    summary: '看月曆，說出日期和星期',
    opening: '月曆上寫著 5 月，小安找到 8 日，再看同一欄的開頭是星期幾，就知道 5 月 8 日是星期幾。',
    method:
        '一年有 12 個月，依序是 1 月到 12 月。一星期有 7 天。月曆直的一欄通常是同一個星期幾。今天的前一天是昨天，後一天是明天。日期先看月份，再看幾日。',
    examples: const [
      MathExample('5 月 8 日的明天', '5 月 9 日'),
      MathExample('星期一的後一天', '星期二'),
      MathExample('12 月的下一個月', '1 月'),
    ],
    points: const [
      MathPoint('📅', '月和日', '先說幾月，再說幾日。'),
      MathPoint('7️⃣', '七天一星期', '星期日到星期六，過完就換下一週。'),
      MathPoint('↔️', '昨天和明天', '前一天是昨天，後一天是明天。'),
    ],
    steps: const [
      '在月曆上找出今天的日期，說出幾月幾日星期幾',
      '指出昨天和明天各是幾日',
      '從 1 月按順序念到 12 月',
    ],
    tip: '直欄對齊的是同一個星期幾。換月的時候，日期要回到 1 日。',
    objectives: const [
      '能在月曆上讀出幾月幾日星期幾',
      '能說出昨天、今天和明天',
      '能按順序說出月份和一星期的七天',
    ],
    keyPoints: const [
      '一星期有 7 天',
      '12 月的下一個月是 1 月',
      '同一直欄通常是同一個星期幾',
    ],
    vocabulary: const [
      VocabItem(
          term: '月曆', meaning: '把一個月的日期和星期排好的表', example: '我們在月曆上找 5 月 8 日'),
      VocabItem(term: '星期', meaning: '七天為一週的名稱', example: '星期一的後一天是星期二'),
      VocabItem(term: '日期', meaning: '幾月幾日', example: '今天的日期是 5 月 8 日'),
    ],
    questions: const [
      MathQ(
        prompt: '一星期有幾天？',
        options: ['5 天', '6 天', '7 天', '12 天'],
        correctIndex: 2,
        explanation: '從星期日到星期六，一共 7 天。',
      ),
      MathQ(
        prompt: '星期一的後一天是？',
        options: ['星期日', '星期二', '星期三', '星期五'],
        correctIndex: 1,
        explanation: '星期一再過一天是星期二。',
      ),
      MathQ(
        prompt: '今天是 5 月 8 日，明天是？',
        options: ['5 月 7 日', '5 月 9 日', '6 月 8 日', '4 月 8 日'],
        correctIndex: 1,
        explanation: '同一個月份，日期加 1。',
      ),
      MathQ(
        prompt: '12 月的下一個月是？',
        options: ['11 月', '1 月', '10 月', '2 月'],
        correctIndex: 1,
        explanation: '12 月結束後，下一個月是 1 月。',
      ),
      MathQ(
        prompt: '今天的前一天叫做？',
        options: ['明天', '昨天', '下個月', '明年'],
        correctIndex: 1,
        explanation: '比今天早一天的是昨天。',
      ),
      MathQ(
        prompt: '月曆上直的一欄，常常是？',
        options: ['同一個星期幾', '同一天', '不同的年份', '只寫 1 日'],
        correctIndex: 0,
        explanation: '直欄對齊的日子通常星期相同。',
      ),
    ],
  ),
];
