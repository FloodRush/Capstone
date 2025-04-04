import 'package:flutter/material.dart';

class MoodTrackerPage extends StatelessWidget {
  const MoodTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mood Tracker')),
      body: Center(child: Text('Welcome to the Mood Tracker Page')),
    );
  }
}
