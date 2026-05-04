import 'package:flutter/material.dart';

import '../models/subject.dart';

/// 六大學習領域（對應台灣國小 108 課綱）
const List<Subject> kSubjects = [
  Subject(
    id: 'chinese',
    name: '國語',
    englishName: 'Chinese',
    icon: Icons.menu_book_rounded,
    color: Color(0xFFEF5350),
    description: '識字、注音、閱讀、寫作',
  ),
  Subject(
    id: 'english',
    name: '英語',
    englishName: 'English',
    icon: Icons.translate_rounded,
    color: Color(0xFF42A5F5),
    description: '字母、單字、會話',
  ),
  Subject(
    id: 'math',
    name: '數學',
    englishName: 'Math',
    icon: Icons.calculate_rounded,
    color: Color(0xFF66BB6A),
    description: '數與量、圖形、運算',
  ),
  Subject(
    id: 'science',
    name: '自然',
    englishName: 'Science',
    icon: Icons.science_rounded,
    color: Color(0xFFAB47BC),
    description: '生物、物理、觀察',
  ),
  Subject(
    id: 'social',
    name: '社會',
    englishName: 'Social',
    icon: Icons.public_rounded,
    color: Color(0xFFFFA726),
    description: '認識台灣、世界、公民',
  ),
  Subject(
    id: 'life',
    name: '綜合',
    englishName: 'Life',
    icon: Icons.favorite_rounded,
    color: Color(0xFFEC407A),
    description: '生活、品德、探索',
  ),
];

Subject subjectById(String id) =>
    kSubjects.firstWhere((s) => s.id == id, orElse: () => kSubjects.first);
