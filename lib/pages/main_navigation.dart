import 'package:flutter/material.dart';
import 'package:project/theme.dart';
import 'home_page.dart';
import 'journal_page.dart';
import 'meditation_page.dart';
import 'goal_tracking_page.dart';
import 'motivation_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final pages = [
    HomePage(),
    JournalPage(),
    MyGoalPage(),
    MotivationPage(),
    MeditationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        backgroundColor: AppColors.lightPink,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: const Color.fromARGB(255, 21, 21, 21),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Journal"),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'Quotes',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement), label: "Meditate"),
        ],
      ),
    );
  }
}
