import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project/firebase_options.dart';
import 'pages/main_navigation.dart';
import 'package:project/theme.dart';
import 'pages/startUp_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'pages/mood_tracker_page.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Mental Health App',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme,
          home: LoginPage(),
        );
      },
    );
  }
}
