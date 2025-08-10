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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.lightPink,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.darkPink,
          unselectedItemColor: const Color.fromARGB(255, 21, 21, 21),
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: _NavIconBox(
                icon: Icons.home,
                isActive: _currentIndex == 0,
                color: AppColors.darkPink,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: _NavIconBox(
                icon: Icons.book,
                isActive: _currentIndex == 1,
                color: AppColors.darkPink,
              ),
              label: "Journal",
            ),
            BottomNavigationBarItem(
              icon: _NavIconBox(
                icon: Icons.track_changes,
                isActive: _currentIndex == 2,
                color: AppColors.darkPink,
              ),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: _NavIconBox(
                icon: Icons.format_quote,
                isActive: _currentIndex == 3,
                color: AppColors.darkPink,
              ),
              label: 'Quotes',
            ),
            BottomNavigationBarItem(
              icon: _NavIconBox(
                icon: Icons.self_improvement,
                isActive: _currentIndex == 4,
                color: AppColors.darkPink,
              ),
              label: "Meditate",
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget for navigation icon with box highlight
class _NavIconBox extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color color;
  const _NavIconBox(
      {required this.icon, required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isActive
          ? BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      padding: const EdgeInsets.all(6),
      child: Icon(
        icon,
        color: isActive ? color : const Color.fromARGB(255, 21, 21, 21),
      ),
    );
  }
}

