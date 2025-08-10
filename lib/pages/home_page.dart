import 'package:flutter/material.dart';
import 'package:project/theme.dart';
import '../transition.dart';
import 'journal_page.dart';
import 'meditation_page.dart';
import 'goal_page.dart';
import 'motivation_page.dart';
import 'mood_tracker_page.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _featureCard(BuildContext context, String label, String imagePath,
      Widget page, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(context, createRoute(page)),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: color,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  color.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 231, 125, 160),
              AppColors.hotPink,
              Color.fromARGB(255, 247, 199, 215),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            color: AppColors.hotPink, size: 32),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome Back!",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                          Text("How are you today?",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Icon(Icons.settings, color: Colors.white),
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
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Mood Tracker",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  GestureDetector(
                                    onTap: () => Navigator.push(context,
                                        createRoute(MoodTrackerPage())),
                                    child: Icon(Icons.chevron_right,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: ["😠", "🙂", "😭", "😴", "😃", "🥲"]
                                    .map((emoji) => GestureDetector(
                                          onTap: () {},
                                          child: CircleAvatar(
                                            backgroundColor: Colors.white24,
                                            radius: 22,
                                            child: Text(emoji,
                                                style: TextStyle(fontSize: 22)),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 28),
                        Text("Let's explore",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 14),
                        SizedBox(height: 20), // Added extra spacing
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: 1, // Make cards square
                          children: [
                            _featureCard(
                                context,
                                "Journal",
                                "assets/card/journal.PNG",
                                JournalPage(),
                                AppColors.hotPink),
                            _featureCard(
                                context,
                                "Meditation",
                                "assets/card/meditation.png",
                                MeditationPage(),
                                Color(0xFFB388FF)),
                            _featureCard(
                                context,
                                "Goals",
                                "assets/card/goals.png",
                                GoalPage(),
                                Color(0xFF80CBC4)),
                            _featureCard(
                                context,
                                "Motivation",
                                "assets/card/motivation.png",
                                MotivationPage(),
                                Color(0xFFFFAB91)),
                          ],
                        ),
                        SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
