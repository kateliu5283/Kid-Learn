import 'package:flutter/material.dart';

/// 課程內容區塊類型（用於圖文教學呈現，非 App 操作說明）
enum LessonBlockKind {
  /// 開場／導言
  intro,

  /// 小標題
  heading,

  /// 一般段落
  paragraph,

  /// 條列重點（可含 emoji 前綴）
  bullet,

  /// 範例（如 🍎🍎🍎 → 3 顆蘋果）
  example,

  /// 步驟教學
  step,

  /// 注音／字詞對照格
  phonics,

  /// 小提醒
  tip,

  /// 比較（多 vs 少、大 vs 小）
  compare,
}

/// 單一課程教學區塊
class LessonBlock {
  final LessonBlockKind kind;
  final String text;
  final String? title;
  final String? leading;
  final String? trailing;
  final IconData? icon;

  const LessonBlock({
    required this.kind,
    required this.text,
    this.title,
    this.leading,
    this.trailing,
    this.icon,
  });
}
