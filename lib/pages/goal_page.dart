// lib/pages/GoalPage.dart
import 'package:flutter/material.dart';

class GoalPage extends StatelessWidget {
  const GoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Goals')),
      body: Center(child: Text('Welcome to the Goals Page')),
    );
  }
}
