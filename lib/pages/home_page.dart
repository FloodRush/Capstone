import 'package:flutter/material.dart';
import 'package:project/theme.dart';
import '../transition.dart';
import 'journal_page.dart';
import 'meditation_page.dart';
import 'goal_page.dart';
import 'motivation_page.dart';
import 'mood_tracker_page.dart';
import 'profile_page.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _exploreScrollController = ScrollController();
  late final List<Map<String, dynamic>> cardData;
  late final List<Map<String, dynamic>> activityCards;
  int _currentExploreIndex = 0;
  Timer? _autoScrollTimer;
  int _scrollSpeed = 1; // Default speed multiplier

  @override
  void initState() {
    super.initState();
    cardData = [
      {
        'label': 'Journal',
        'imagePath': 'assets/card/journal.PNG',
        'page': JournalPage(),
        'color': AppColors.lightJournal,
      },
      {
        'label': 'Meditation',
        'imagePath': 'assets/card/meditation.png',
        'page': MeditationPage(),
        'color': AppColors.lightMeditation,
      },
      {
        'label': 'Goals',
        'imagePath': 'assets/card/goals.png',
        'page': GoalPage(),
        'color': AppColors.lightGoals,
      },
      {
        'label': 'Motivation',
        'imagePath': 'assets/card/motivation.png',
        'page': MotivationPage(),
        'color': AppColors.lightMotivation,
      },
    ];
    activityCards = [
      {
        'title': 'Reflect & Release',
        'time': '10 mins',
        'desc': 'Journaling helps clear your mind and capture your thoughts. Write down one thing you’re grateful for today.',
        'button': 'Begin',
        'image': 'assets/card/journalCard.png',
        'page': JournalPage(),
      },
      {
        'title': 'Find Your Calm',
        'time': '5 mins',
        'desc': 'Take a deep breath and follow a short guided meditation to reset your energy.',
        'button': 'Play',
        'image': 'assets/card/meditationCard.png',
        'page': MeditationPage(),
      },
      {
        'title': 'Stay on Track',
        'time': 'Flexible',
        'desc': 'Choose one small goal for today. Taking small steps builds long-term success.',
        'button': 'Set Goal',
        'image': 'assets/card/goalCard.png',
        'page': GoalPage(),
      },
      {
        'title': 'Your Quote of the Day',
        'time': '2 mins',
        'desc': 'Pause and reflect: “Every day is a fresh start.” Carry this thought with you.',
        'button': 'Read More',
        'image': 'assets/card/motivationCard.png',
        'page': MotivationPage(),
      },
    ];
    Future.delayed(const Duration(milliseconds: 800), _startAutoScroll);
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (!mounted) return;
      double maxScroll = _exploreScrollController.position.maxScrollExtent;
      double current = _exploreScrollController.offset;
      double next = current + (0.7 * _scrollSpeed);
      if (next >= maxScroll) {
        _exploreScrollController.jumpTo(0);
      } else {
        _exploreScrollController.jumpTo(next);
      }
    });
  }

  void _boostScrollSpeed() {
    setState(() {
      _scrollSpeed = 3; // Increase speed
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _scrollSpeed = 1; // Reset speed
        });
      }
    });
  }

  void _scrollToNextExploreCard() {
    setState(() {
      _currentExploreIndex = (_currentExploreIndex + 1) % cardData.length;
    });
    _exploreScrollController.animateTo(
      _currentExploreIndex * 178.0, // 160 width + 18 margin
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _exploreScrollController.dispose();
    super.dispose();
  }

  Widget _featureCard(BuildContext context, String label, String imagePath,
      Widget page, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(context, createRoute(page)),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: color,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: appGradientBackground(isDark: themeProvider.isDarkMode),
            ),
            child: SafeArea(
              child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          Navigator.push(context, createRoute(ProfilePage())),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: themeProvider.isDarkMode 
                            ? AppColors.accentPurple.withOpacity(0.3)
                            : Colors.white,
                        child: Icon(Icons.person,
                            color: themeProvider.isDarkMode 
                                ? AppColors.darkText
                                : AppColors.hotPink, 
                            size: 32),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome Back!",
                              style: TextStyle(
                                  color: themeProvider.isDarkMode 
                                      ? AppColors.darkSecondaryText
                                      : Colors.white70, 
                                  fontSize: 16)),
                          Text("How are you today?",
                              style: TextStyle(
                                  color: themeProvider.isDarkMode 
                                      ? AppColors.darkText
                                      : Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return GestureDetector(
                          onTap: () => themeProvider.toggleTheme(),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode 
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              themeProvider.isDarkMode 
                                  ? Icons.light_mode 
                                  : Icons.dark_mode,
                              color: themeProvider.isDarkMode 
                                  ? AppColors.darkText
                                  : Colors.white,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mood Tracker
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          height: 210,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.72), // Slightly lighter background
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: themeProvider.isDarkMode 
                                    ? Colors.black26
                                    : Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Mood Tracker",
                                      style: TextStyle(
                                          color: themeProvider.isDarkMode 
                                              ? AppColors.darkText
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)), // Smaller text
                                  GestureDetector(
                                    onTap: () => Navigator.push(context,
                                        createRoute(MoodTrackerPage())),
                                    child: Icon(Icons.chevron_right,
                                        color: themeProvider.isDarkMode 
                                            ? AppColors.darkText
                                            : Colors.black),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              MoodSelectionRow(),
                            ],
                          ),
                        ),
                        SizedBox(height: 28),
                        // Let's explore section
                        Text(
                          "Let's explore",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 14),
                        Stack(
                          children: [
                            SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: ListView.builder(
                                controller: _exploreScrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: cardData.length,
                                itemBuilder: (context, index) {
                                  final card = cardData[index];
                                  return Container(
                                    width: 160,
                                    margin: EdgeInsets.only(right: 18),
                                    child: _featureCard(
                                      context,
                                      card['label'] as String,
                                      card['imagePath'] as String,
                                      card['page'] as Widget,
                                      card['color'] as Color,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.chevron_right, color: Colors.white, size: 32),
                                  onPressed: _boostScrollSpeed,
                                  tooltip: 'Next',
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18),
                        // Motivational Activity Feed (Vertical Scroll)
                        Text(
                          "Today's Activity",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        ListView.builder(
                          itemCount: activityCards.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final card = activityCards[index];
                            final buttonLabels = ["Write", "Start", "Set", "See"];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: themeProvider.isDarkMode 
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.white.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeProvider.isDarkMode 
                                        ? Colors.black26
                                        : Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(22),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 170,
                                      height: 210, // Higher height for image
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(22),
                                        child: Image.asset(
                                          card['image'] as String,
                                          width: 170,
                                          height: 210,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            card['title'] as String,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 22,
                                              color: Colors.black,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            card['desc'] as String,
                                            style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w400, letterSpacing: 0.1),
                                          ),
                                          const SizedBox(height: 18),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                backgroundColor: themeProvider.isDarkMode ? Colors.white.withOpacity(0.18) : AppColors.hotPink,
                                                foregroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                                elevation: 0,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(buttonLabels[index], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ], // Close Column children
          ), // Close Column
        ), // Close SafeArea
      ), // Close Container
    ); // Close Scaffold
    }, // Close builder function
  ); // Close Consumer
  }
}

class MoodSelectionRow extends StatefulWidget {
  @override
  State<MoodSelectionRow> createState() => _MoodSelectionRowState();
}

class _MoodSelectionRowState extends State<MoodSelectionRow>
    with SingleTickerProviderStateMixin {
  int? selectedIndex;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  final List<String> moodImages = [
    'sad.png',
    'happy.png',
    'angry.png',
    'sleepy.png',
    'stressed.png',
    'loved.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.13)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(int index) async {
    setState(() {
      selectedIndex = index;
    });
    await _controller.forward();
    await _controller.reverse();
    Future.delayed(const Duration(milliseconds: 250), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MoodTrackerPage()),
      ).then((_) {
        setState(() {
          selectedIndex = null;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (i) {
            final isSelected = selectedIndex == i;
            double imgSize = (i == 2 || i == 3) ? 64 : 54; // Angry & Sleepy bigger
            return GestureDetector(
              onTap: () => _onTap(i),
              child: AnimatedBuilder(
                animation: _controller,
                child: Image.asset(
                  'assets/icons/' + moodImages[i],
                  width: imgSize,
                  height: imgSize,
                  fit: BoxFit.contain,
                ),
                builder: (context, child) {
                  double scale = isSelected ? _scaleAnim.value : 1.0;
                  double opacity = (selectedIndex == null || isSelected) ? 1.0 : 0.85;
                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  );
                },
              ),
            );
          }),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (i) {
            final idx = i + 3;
            final isSelected = selectedIndex == idx;
            double imgSize = (idx == 3 || idx == 4 || idx == 5) ? 64 : 54; // Sleepy, Stressed & Loved bigger
            return GestureDetector(
              onTap: () => _onTap(idx),
              child: AnimatedBuilder(
                animation: _controller,
                child: Image.asset(
                  'assets/icons/' + moodImages[idx],
                  width: imgSize,
                  height: imgSize,
                  fit: BoxFit.contain,
                ),
                builder: (context, child) {
                  double scale = isSelected ? _scaleAnim.value : 1.0;
                  double opacity = (selectedIndex == null || isSelected) ? 1.0 : 0.85;
                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
