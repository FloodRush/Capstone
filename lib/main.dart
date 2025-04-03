import 'package:flutter/material.dart';
import 'pages/test.dart';
import 'pages/temp_page.dart';
import 'pages/journal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FreshStart', //this is how the app will appear in task manager
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: LoginPage(),
    );
  }
}
