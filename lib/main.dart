import 'package:flutter/material.dart';
import 'pages/test.dart';
//import 'pages/temp_page.dart';
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
      debugShowCheckedModeBanner: false,
      title: 'FreshStart', //this is how the app will appear in task manager
      theme: ThemeData(
         fontFamily: 'Poppins',
        primaryColor: AppColors.hotPink,
      ),
      home: MainNavigation(),
    );
  }
}
