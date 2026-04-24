import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'subjects_screen.dart';
import 'games/games_hub_screen.dart';
import 'achievements_screen.dart';
import 'parent_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    SubjectsScreen(),
    GamesHubScreen(),
    AchievementsScreen(),
    ParentScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: '學科',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_rounded),
            label: '遊戲',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_rounded),
            label: '成就',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom_rounded),
            label: '家長',
          ),
        ],
      ),
    );
  }
}
