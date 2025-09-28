import 'package:flutter/material.dart';
import 'package:project/theme.dart';
import 'home_page.dart';
import 'journal_list_page.dart';
import 'meditation_page.dart';
import 'goal_tracking_page.dart';
import 'motivation_page.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const HomePage(),
      JournalListPage(onBackToHome: _goHome),
      MyGoalPage(),
      MotivationPage(onBackToHome: _goHome),
      MeditationPage(onBackToHome: _goHome), // Leave as-is per instructions
    ];
  }

  void _goHome() {
    if (!mounted) return;
    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: pages[_currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? AppColors.mediumPurple
                  : AppColors.lightPink,
              boxShadow: [
                BoxShadow(
                  color: themeProvider.isDarkMode ? Colors.black26 : Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: themeProvider.isDarkMode
                  ? AppColors.accentPurple
                  : AppColors.darkPink,
              unselectedItemColor: themeProvider.isDarkMode
                  ? AppColors.darkSecondaryText
                  : const Color.fromARGB(255, 21, 21, 21),
              onTap: (index) => setState(() => _currentIndex = index),
              items: [
                BottomNavigationBarItem(
                  icon: _NavIconBox(
                    icon: Icons.home,
                    isActive: _currentIndex == 0,
                    color: themeProvider.isDarkMode ? AppColors.accentPurple : AppColors.darkPink,
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: _NavIconBox(
                    icon: Icons.book,
                    isActive: _currentIndex == 1,
                    color: themeProvider.isDarkMode ? AppColors.accentPurple : AppColors.darkPink,
                  ),
                  label: "Journal",
                ),
                BottomNavigationBarItem(
                  icon: _NavIconBox(
                    icon: Icons.track_changes,
                    isActive: _currentIndex == 2,
                    color: themeProvider.isDarkMode ? AppColors.accentPurple : AppColors.darkPink,
                  ),
                  label: 'Goals',
                ),
                BottomNavigationBarItem(
                  icon: _NavIconBox(
                    icon: Icons.format_quote,
                    isActive: _currentIndex == 3,
                    color: themeProvider.isDarkMode ? AppColors.accentPurple : AppColors.darkPink,
                  ),
                  label: 'Quotes',
                ),
                BottomNavigationBarItem(
                  icon: _NavIconBox(
                    icon: Icons.self_improvement,
                    isActive: _currentIndex == 4,
                    color: themeProvider.isDarkMode ? AppColors.accentPurple : AppColors.darkPink,
                  ),
                  label: "Meditate",
                ),
              ],
            ),
          ),
        );
      },
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
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
            color: isActive 
                ? color 
                : (themeProvider.isDarkMode 
                    ? AppColors.darkSecondaryText
                    : const Color.fromARGB(255, 21, 21, 21)),
          ),
        );
      },
    );
  }
}

