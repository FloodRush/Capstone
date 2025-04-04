import 'package:flutter/material.dart';
import 'pages/main_navigation.dart';
import 'package:project/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: AppColors.hotPink,
      ),
      home: MainNavigation(),
    );
  }
}
