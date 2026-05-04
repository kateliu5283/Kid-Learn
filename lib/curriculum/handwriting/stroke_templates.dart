import 'package:flutter/widgets.dart';

/// 單一筆劃的標準範例。
///
/// `points` 是在 `[0,1] × [0,1]` 正規化座標系（左上角為 (0,0)，右下角為 (1,1)）
/// 內的點序列，表示該筆從起點到終點的軌跡。
///
/// 通常 5~7 個關鍵點就足夠表達筆型（直、橫、撇、捺、彎、勾等）。
class StrokeTemplate {
  const StrokeTemplate({
    required this.points,
    this.name,
  });

  /// 0-1 normalized
  final List<Offset> points;

  /// 筆畫名稱（例：「橫」「豎」「撇」「捺」），選填，只用於除錯或 tooltip。
  final String? name;

  Offset get start => points.first;
  Offset get end => points.last;
}

/// 某一個字的標準筆順（由多筆 [StrokeTemplate] 組成，順序就是正確筆順）。
class CharacterTemplate {
  const CharacterTemplate({
    required this.char,
    required this.strokes,
  });

  final String char;
  final List<StrokeTemplate> strokes;

  int get strokeCount => strokes.length;
}

/// 內建筆順資料庫 – 常用基礎字。
///
/// 目前已建資料：一、二、三、十、七、八、九、人、口、山、大、小、中、日、月、
/// 木、水、火、土、上、下、工、天、王、田、白、石、目、耳、手、力、刀、入、
/// 又、己、子、女、牛、羊。
///
/// 沒有在此表的字，會回到「只做筆劃數比對 + 覆蓋範圍比對」的簡化評分。
final Map<String, CharacterTemplate> kStrokeTemplates = {
  //
  // 1 畫 ---
  //
  '一': const CharacterTemplate(char: '一', strokes: [
    StrokeTemplate(name: '橫', points: [Offset(0.10, 0.50), Offset(0.90, 0.50)]),
  ]),

  //
  // 2 畫 ---
  //
  '二': const CharacterTemplate(char: '二', strokes: [
    StrokeTemplate(name: '橫', points: [Offset(0.20, 0.30), Offset(0.80, 0.30)]),
    StrokeTemplate(name: '橫', points: [Offset(0.10, 0.72), Offset(0.90, 0.72)]),
  ]),
  '十': const CharacterTemplate(char: '十', strokes: [
    StrokeTemplate(name: '橫', points: [Offset(0.10, 0.50), Offset(0.90, 0.50)]),
    StrokeTemplate(name: '豎', points: [Offset(0.50, 0.10), Offset(0.50, 0.90)]),
  ]),
  '七': const CharacterTemplate(char: '七', strokes: [
    StrokeTemplate(name: '橫', points: [Offset(0.15, 0.45), Offset(0.85, 0.45)]),
    StrokeTemplate(name: '豎彎鉤', points: [
      Offset(0.55, 0.15),
      Offset(0.50, 0.50),
      Offset(0.55, 0.80),
      Offset(0.85, 0.85),
    ]),
  ]),
  '八': const CharacterTemplate(char: '八', strokes: [
    StrokeTemplate(name: '撇', points: [Offset(0.50, 0.15), Offset(0.15, 0.90)]),
    StrokeTemplate(name: '捺', points: [Offset(0.50, 0.15), Offset(0.85, 0.90)]),
  ]),
  '九': const CharacterTemplate(char: '九', strokes: [
    StrokeTemplate(name: '撇', points: [Offset(0.70, 0.15), Offset(0.20, 0.85)]),
    StrokeTemplate(name: '橫折彎鉤', points: [
      Offset(0.20, 0.30),
      Offset(0.80, 0.30),
      Offset(0.80, 0.70),
      Offset(0.90, 0.85),
    ]),
  ]),
  '人': const CharacterTemplate(char: '人', strokes: [
    StrokeTemplate(name: '撇', points: [Offset(0.50, 0.10), Offset(0.15, 0.90)]),
    StrokeTemplate(name: '捺', points: [Offset(0.50, 0.45), Offset(0.85, 0.90)]),
  ]),
  '入': const CharacterTemplate(char: '入', strokes: [
    StrokeTemplate(name: '撇', points: [Offset(0.50, 0.10), Offset(0.20, 0.70)]),
    StrokeTemplate(name: '捺', points: [Offset(0.35, 0.40), Offset(0.85, 0.90)]),
  ]),
  '力': const CharacterTemplate(char: '力', strokes: [
    StrokeTemplate(name: '橫折鉤', points: [
      Offset(0.20, 0.15),
      Offset(0.80, 0.20),
      Offset(0.70, 0.80),
      Offset(0.40, 0.90),
    ]),
    StrokeTemplate(name: '撇', points: [Offset(0.55, 0.30), Offset(0.10, 0.90)]),
  ]),
  '刀': const CharacterTemplate(char: '刀', strokes: [
    StrokeTemplate(name: '橫折鉤', points: [
      Offset(0.20, 0.15),
      Offset(0.80, 0.15),
      Offset(0.80, 0.70),
      Offset(0.60, 0.85),
    ]),
    StrokeTemplate(name: '撇', points: [Offset(0.65, 0.25), Offset(0.15, 0.90)]),
  ]),
  '又': const CharacterTemplate(char: '又', strokes: [
    StrokeTemplate(name: '橫撇', points: [
      Offset(0.20, 0.25),
      Offset(0.75, 0.25),
      Offset(0.25, 0.90),
    ]),
    StrokeTemplate(name: '捺', points: [Offset(0.35, 0.55), Offset(0.90, 0.90)]),
  ]),

  //
  // 3 畫 ---
  //
  '三': const CharacterTemplate(char: '三', strokes: [
    StrokeTemplate(name: '橫', points: [Offset(0.20, 0.22), Offset(0.75, 0.22)]),
    StrokeTemplate(name: '橫', points: [Offset(0.30, 0.50), Offset(0.70, 0.50)]),
    StrokeTemplate(name: '橫', points: [Offset(0.10, 0.78), Offset(0.90, 0.78)]),
  ]),
  '口': const CharacterTemplate(char: '口', strokes: [
    StrokeTemplate(name: '豎', points: [Offset(0.18, 0.18), Offset(0.18, 0.85)]),
    StrokeTemplate(name: '橫折', points: [
      Offset(0.18, 0.18),
      Offset(0.82, 0.18),
      Offset(0.82, 0.82),
    ]),
    StrokeTemplate(name: '橫', points: [Offset(0.18, 0.82), Offset(0.82, 0.82)]),
  ]),
  '山': const CharacterTemplate(char: '山', strokes: [
    StrokeTemplate(name: '豎', points: [Offset(0.50, 0.25), Offset(0.50, 0.80)]),
    StrokeTemplate(name: '豎折', points: [
      Offset(0.15, 0.40),
      Offset(0.15, 0.85),
      Offset(0.85, 0.85),
    ]),
    StrokeTemplate(name: '豎', points: [Offset(0.85, 0.40), Offset(0.85, 0.85)]),
  ]),
  '大': const CharacterTemplate(char: '大', strokes: [
    StrokeTemplate(name: '橫', points: [Offset(0.15, 0.35), Offset(0.85, 0.35)]),
    StrokeTemplate(name: '撇', points: [Offset(0.50, 0.15), Offset(0.10, 0.90)]),
    StrokeTemplate(name: '捺', points: [Offset(0.50, 0.35), Offset(0.90, 0.90)]),
  ]),
  '小': const CharacterTemplate(char: '小', strokes: [
    StrokeTemplate(name: '豎鉤', points: [
      Offset(0.50, 0.18),
      Offset(0.50, 0.75),
      Offset(0.35, 0.85),
    ]),
    StrokeTemplate(name: '撇', points: [Offset(0.30, 0.40), Offset(0.15, 0.80)]),
    StrokeTemplate(name: '點', points: [Offset(0.70, 0.40), Offset(0.85, 0.80)]),
  ]),
  '土': const CharacterTemplate(char: '土', strokes: [
    StrokeTemplate(name: '橫', points: [Offset(0.25, 0.30), Offset(0.75, 0.30)]),
    StrokeTemplate(name: '豎', points: [Offset(0.50, 0.20), Offset(0.50, 0.80)]),
    StrokeTemplate(name: '橫', points: [Offset(0.10, 0.80), Offset(0.90, 0.80)]),
  ]),
  '上': const CharacterTemplate(char: '上', strokes: [
    StrokeTemplate(name: '豎', points: [Offset(0.50, 0.20), Offset(0.50, 0.80)]),
    StrokeTemplate(name: '橫', points: [Offset(0.50, 0.55), Offset(0.80, 0.55)]),
    StrokeTemplate(name: '橫', points: [Offset(0.15, 0.80), Offset(0.85, 0.80)]),
  ]),
  '下': const CharacterTemplate(char: '下', strokes: [
    StrokeTemplate(name: '橫', points: [Offset(0.15, 0.25), Offset(0.85, 0.25)]),
    StrokeTemplate(name: '豎', points: [Offset(0.50, 0.25), Offset(0.50, 0.85)]),
    StrokeTemplate(name: '點', points: [Offset(0.50, 0.55), Offset(0.75, 0.55)]),
  ]),
  '工': const CharacterTemplate(char: '工', strokes: [
    StrokeTemplate(name: '橫', points: [Offset(0.20, 0.25), Offset(0.80, 0.25)]),
    StrokeTemplate(name: '豎', points: [Offset(0.50, 0.25), Offset(0.50, 0.75)]),
    StrokeTemplate(name: '橫', points: [Offset(0.10, 0.75), Offset(0.90, 0.75)]),
  ]),
  '子': const CharacterTemplate(char: '子', strokes: [
    StrokeTemplate(name: '橫撇', points: [
      Offset(0.20, 0.20),
      Offset(0.80, 0.20),
      Offset(0.55, 0.40),
    ]),
    StrokeTemplate(name: '豎鉤', points: [
      Offset(0.55, 0.30),
      Offset(0.55, 0.80),
      Offset(0.40, 0.90),
    ]),
    StrokeTemplate(name: '橫', points: [Offset(0.15, 0.55), Offset(0.85, 0.55)]),
  ]),
  '女': const CharacterTemplate(char: '女', strokes: [
    StrokeTemplate(name: '撇點', points: [
      Offset(0.30, 0.15),
      Offset(0.15, 0.55),
      Offset(0.55, 0.65),
    ]),
    StrokeTemplate(name: '撇', points: [Offset(0.60, 0.30), Offset(0.20, 0.90)]),
    StrokeTemplate(name: '橫', points: [Offset(0.10, 0.65), Offset(0.90, 0.65)]),
  ]),
  '己': const CharacterTemplate(char: '己', strokes: [
    StrokeTemplate(name: '橫折', points: [
      Offset(0.20, 0.20),
      Offset(0.80, 0.20),
      Offset(0.80, 0.45),
    ]),
    StrokeTemplate(name: '橫', points: [Offset(0.20, 0.45), Offset(0.80, 0.45)]),
    StrokeTemplate(name: '豎彎鉤', points: [
      Offset(0.20, 0.20),
      Offset(0.20, 0.80),
      Offset(0.85, 0.85),
    ]),
  ]),

  //
  // 4 畫 ---
  //
  '日': const CharacterTemplate(char: '日', strokes: [
    StrokeTemplate(name: '豎', points: [Offset(0.25, 0.15), Offset(0.25, 0.85)]),
    StrokeTemplate(name: '橫折', points: [
      Offset(0.25, 0.15),
      Offset(0.75, 0.15),
      Offset(0.75, 0.85),
    ]),
    StrokeTemplate(name: '橫', points: [Offset(0.25, 0.50), Offset(0.75, 0.50)]),
    StrokeTemplate(name: '橫', points: [Offset(0.25, 0.85), Offset(0.75, 0.85)]),
  ]),
  '月': const CharacterTemplate(char: '月', strokes: [
    StrokeTemplate(name: '撇', points: [Offset(0.35, 0.15), Offset(0.15, 0.90)]),
    StrokeTemplate(name: '橫折鉤', points: [
      Offset(0.35, 0.15),
      Offset(0.75, 0.15),
      Offset(0.75, 0.85),
      Offset(0.55, 0.90),
    ]),
    StrokeTemplate(name: '橫', points: [Offset(0.35, 0.40), Offset(0.75, 0.40)]),
    StrokeTemplate(name: '橫', points: [Offset(0.35, 0.65), Offset(0.75, 0.65)]),
  ]),
  '木': const CharacterTemplate(char: '木', strokes: [
    StrokeTemplate(name: '橫', points: [Offset(0.15, 0.35), Offset(0.85, 0.35)]),
    StrokeTemplate(name: '豎', points: [Offset(0.50, 0.15), Offset(0.50, 0.90)]),
    StrokeTemplate(name: '撇', points: [Offset(0.50, 0.45), Offset(0.15, 0.85)]),
    StrokeTemplate(name: '捺', points: [Offset(0.50, 0.45), Offset(0.85, 0.85)]),
  ]),
  '水': const CharacterTemplate(char: '水', strokes: [
    StrokeTemplate(name: '豎鉤', points: [
      Offset(0.50, 0.15),
      Offset(0.50, 0.75),
      Offset(0.35, 0.85),
    ]),
    StrokeTemplate(name: '撇', points: [Offset(0.35, 0.35), Offset(0.15, 0.60)]),
    StrokeTemplate(name: '撇', points: [Offset(0.30, 0.55), Offset(0.15, 0.85)]),
    StrokeTemplate(name: '捺', points: [Offset(0.55, 0.35), Offset(0.90, 0.85)]),
  ]),
  '火': const CharacterTemplate(char: '火', strokes: [
    StrokeTemplate(name: '點', points: [Offset(0.35, 0.15), Offset(0.20, 0.35)]),
    StrokeTemplate(name: '撇', points: [Offset(0.65, 0.20), Offset(0.75, 0.40)]),
    StrokeTemplate(name: '撇', points: [Offset(0.50, 0.30), Offset(0.15, 0.90)]),
    StrokeTemplate(name: '捺', points: [Offset(0.50, 0.30), Offset(0.90, 0.90)]),
  ]),
  '中': const CharacterTemplate(char: '中', strokes: [
    StrokeTemplate(name: '豎', points: [Offset(0.30, 0.20), Offset(0.30, 0.75)]),
    StrokeTemplate(name: '橫折', points: [
      Offset(0.30, 0.20),
      Offset(0.70, 0.20),
      Offset(0.70, 0.75),
    ]),
    StrokeTemplate(name: '橫', points: [Offset(0.30, 0.75), Offset(0.70, 0.75)]),
    StrokeTemplate(name: '豎', points: [Offset(0.50, 0.10), Offset(0.50, 0.90)]),
  ]),
  '牛': const CharacterTemplate(char: '牛', strokes: [
    StrokeTemplate(name: '撇', points: [Offset(0.45, 0.15), Offset(0.25, 0.40)]),
    StrokeTemplate(name: '橫', points: [Offset(0.20, 0.35), Offset(0.75, 0.35)]),
    StrokeTemplate(name: '橫', points: [Offset(0.15, 0.58), Offset(0.85, 0.58)]),
    StrokeTemplate(name: '豎', points: [Offset(0.50, 0.25), Offset(0.50, 0.90)]),
  ]),

  //
  // 5 畫 ---
  //
  '白': const CharacterTemplate(char: '白', strokes: [
    StrokeTemplate(name: '撇', points: [Offset(0.55, 0.10), Offset(0.35, 0.25)]),
    StrokeTemplate(name: '豎', points: [Offset(0.25, 0.22), Offset(0.25, 0.85)]),
    StrokeTemplate(name: '橫折', points: [
      Offset(0.25, 0.22),
      Offset(0.75, 0.22),
      Offset(0.75, 0.85),
    ]),
    StrokeTemplate(name: '橫', points: [Offset(0.25, 0.55), Offset(0.75, 0.55)]),
    StrokeTemplate(name: '橫', points: [Offset(0.25, 0.85), Offset(0.75, 0.85)]),
  ]),
  '石': const CharacterTemplate(char: '石', strokes: [
    StrokeTemplate(name: '橫', points: [Offset(0.25, 0.20), Offset(0.85, 0.20)]),
    StrokeTemplate(name: '撇', points: [Offset(0.55, 0.15), Offset(0.15, 0.85)]),
    StrokeTemplate(name: '豎', points: [Offset(0.35, 0.45), Offset(0.35, 0.85)]),
    StrokeTemplate(name: '橫折', points: [
      Offset(0.35, 0.45),
      Offset(0.80, 0.45),
      Offset(0.80, 0.85),
    ]),
    StrokeTemplate(name: '橫', points: [Offset(0.35, 0.85), Offset(0.80, 0.85)]),
  ]),
  '目': const CharacterTemplate(char: '目', strokes: [
    StrokeTemplate(name: '豎', points: [Offset(0.30, 0.10), Offset(0.30, 0.90)]),
    StrokeTemplate(name: '橫折', points: [
      Offset(0.30, 0.10),
      Offset(0.70, 0.10),
      Offset(0.70, 0.90),
    ]),
    StrokeTemplate(name: '橫', points: [Offset(0.30, 0.35), Offset(0.70, 0.35)]),
    StrokeTemplate(name: '橫', points: [Offset(0.30, 0.60), Offset(0.70, 0.60)]),
    StrokeTemplate(name: '橫', points: [Offset(0.30, 0.90), Offset(0.70, 0.90)]),
  ]),
  '田': const CharacterTemplate(char: '田', strokes: [
    StrokeTemplate(name: '豎', points: [Offset(0.20, 0.15), Offset(0.20, 0.85)]),
    StrokeTemplate(name: '橫折', points: [
      Offset(0.20, 0.15),
      Offset(0.80, 0.15),
      Offset(0.80, 0.85),
    ]),
    StrokeTemplate(name: '橫', points: [Offset(0.20, 0.50), Offset(0.80, 0.50)]),
    StrokeTemplate(name: '豎', points: [Offset(0.50, 0.15), Offset(0.50, 0.85)]),
    StrokeTemplate(name: '橫', points: [Offset(0.20, 0.85), Offset(0.80, 0.85)]),
  ]),

  //
  // 6 畫 ---
  //
  '耳': const CharacterTemplate(char: '耳', strokes: [
    StrokeTemplate(name: '橫', points: [Offset(0.25, 0.15), Offset(0.75, 0.15)]),
    StrokeTemplate(name: '豎', points: [Offset(0.30, 0.15), Offset(0.30, 0.85)]),
    StrokeTemplate(name: '豎', points: [Offset(0.70, 0.15), Offset(0.70, 0.85)]),
    StrokeTemplate(name: '橫', points: [Offset(0.30, 0.38), Offset(0.70, 0.38)]),
    StrokeTemplate(name: '橫', points: [Offset(0.30, 0.60), Offset(0.70, 0.60)]),
    StrokeTemplate(name: '橫', points: [Offset(0.15, 0.85), Offset(0.85, 0.85)]),
  ]),
  '羊': const CharacterTemplate(char: '羊', strokes: [
    StrokeTemplate(name: '點', points: [Offset(0.35, 0.15), Offset(0.25, 0.28)]),
    StrokeTemplate(name: '撇', points: [Offset(0.65, 0.15), Offset(0.75, 0.28)]),
    StrokeTemplate(name: '橫', points: [Offset(0.20, 0.35), Offset(0.80, 0.35)]),
    StrokeTemplate(name: '橫', points: [Offset(0.25, 0.55), Offset(0.75, 0.55)]),
    StrokeTemplate(name: '橫', points: [Offset(0.15, 0.75), Offset(0.85, 0.75)]),
    StrokeTemplate(name: '豎', points: [Offset(0.50, 0.25), Offset(0.50, 0.90)]),
  ]),

  //
  // 4-6 畫 (人稱代詞等常用字) ---
  //
  '手': const CharacterTemplate(char: '手', strokes: [
    StrokeTemplate(name: '撇', points: [Offset(0.55, 0.10), Offset(0.15, 0.25)]),
    StrokeTemplate(name: '橫', points: [Offset(0.20, 0.30), Offset(0.80, 0.30)]),
    StrokeTemplate(name: '橫', points: [Offset(0.15, 0.55), Offset(0.85, 0.55)]),
    StrokeTemplate(name: '豎鉤', points: [
      Offset(0.50, 0.20),
      Offset(0.50, 0.80),
      Offset(0.35, 0.90),
    ]),
  ]),
  '天': const CharacterTemplate(char: '天', strokes: [
    StrokeTemplate(name: '橫', points: [Offset(0.25, 0.20), Offset(0.75, 0.20)]),
    StrokeTemplate(name: '橫', points: [Offset(0.15, 0.45), Offset(0.85, 0.45)]),
    StrokeTemplate(name: '撇', points: [Offset(0.50, 0.45), Offset(0.10, 0.90)]),
    StrokeTemplate(name: '捺', points: [Offset(0.50, 0.45), Offset(0.90, 0.90)]),
  ]),
  '王': const CharacterTemplate(char: '王', strokes: [
    StrokeTemplate(name: '橫', points: [Offset(0.20, 0.20), Offset(0.80, 0.20)]),
    StrokeTemplate(name: '橫', points: [Offset(0.25, 0.50), Offset(0.75, 0.50)]),
    StrokeTemplate(name: '豎', points: [Offset(0.50, 0.20), Offset(0.50, 0.80)]),
    StrokeTemplate(name: '橫', points: [Offset(0.10, 0.80), Offset(0.90, 0.80)]),
  ]),
};

CharacterTemplate? templateFor(String char) => kStrokeTemplates[char];
bool hasTemplate(String char) => kStrokeTemplates.containsKey(char);
