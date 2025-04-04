import 'package:flutter/material.dart';
import '../transition.dart';
import 'journal_page.dart';
import 'meditation_page.dart';
import 'goal_page.dart';
import 'motivation_page.dart';
import 'mood_tracker_page.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _iconTile(BuildContext context, String label, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, createRoute(page)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(label,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              Color.fromARGB(255, 248, 87, 140),
              Color.fromARGB(255, 247, 199, 215),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Row
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          Navigator.push(context, createRoute(ProfilePage())),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.menu, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          filled: true,
                          fillColor: Colors.white24,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.settings, color: Colors.white),
                  ],
                ),
              ),

              // Greeting and Mood Tracker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome!",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text("How are you feeling today?",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context, createRoute(MoodTrackerPage())),
                      child: Row(
                        children: [
                          Text("Mood tracker",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                          Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: ["😠", "🙂", "😭", "😴", "😃", "🥲"]
                          .map((emoji) => CircleAvatar(
                                backgroundColor: Colors.white24,
                                child: Text(emoji),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Let's explore",
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _iconTile(context, "Journal", JournalPage()),
                      _iconTile(context, "Guided Meditation", MeditationPage()),
                      _iconTile(context, "Goals", GoalPage()),
                      _iconTile(context, "Motivation Quotes", MotivationPage()),
                    ],
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
