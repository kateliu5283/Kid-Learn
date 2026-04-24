import 'package:flutter/material.dart';

class Subject {
  final String id;
  final String name;
  final String englishName;
  final IconData icon;
  final Color color;
  final String description;

  const Subject({
    required this.id,
    required this.name,
    required this.englishName,
    required this.icon,
    required this.color,
    required this.description,
  });
}
