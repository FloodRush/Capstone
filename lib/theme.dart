// theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors
  static const Color darkPink = Color.fromARGB(255, 248, 159, 187);
  static const Color hotPink = Color.fromARGB(255, 246, 175, 181);
  static const Color lightPink = Color.fromARGB(255, 248, 220, 229);
  
  // Dark theme colors - Dark Purple Theme
  static const Color darkPurple = Color(0xFF1a1a2e);      // Deep dark purple
  static const Color mediumPurple = Color(0xFF16213e);     // Medium purple
  static const Color lightPurple = Color(0xFF0f3460);     // Lighter purple
  static const Color accentPurple = Color(0xFF533483);    // Accent purple
  
  // Feature card colors for light mode
  static const Color lightJournal = Color(0xFFB388FF);
  static const Color lightMeditation = Color(0xFF80CBC4);
  static const Color lightGoals = Color(0xFF81C784);
  static const Color lightMotivation = Color(0xFFFFAB91);
  
  // Feature card colors for dark mode
  static const Color darkJournal = Color(0xFF2D1B69);
  static const Color darkMeditation = Color(0xFF004D40);
  static const Color darkGoals = Color(0xFF1B5E20);
  static const Color darkMotivation = Color(0xFF3E2723);
  
  // Text colors
  static const Color lightText = Color(0xDD000000); // Colors.black87
  static const Color darkText = Color(0xDEFFFFFF); // Colors.white87
  static const Color lightSecondaryText = Color(0x99000000); // Colors.black54
  static const Color darkSecondaryText = Color(0x99FFFFFF); // Colors.white54
}

LinearGradient appGradientBackground({bool isDark = false}) {
  if (isDark) {
    return LinearGradient(
      colors: [AppColors.darkPurple, AppColors.mediumPurple, AppColors.accentPurple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  return LinearGradient(
    colors: [AppColors.darkPink, AppColors.hotPink, AppColors.lightPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    primaryColor: AppColors.hotPink,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.hotPink,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightText),
      bodyMedium: TextStyle(color: AppColors.lightText),
      titleLarge: TextStyle(color: AppColors.lightText),
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.hotPink,
      secondary: AppColors.darkPink,
      surface: Colors.white,
      background: Colors.white,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    primaryColor: AppColors.mediumPurple,
    scaffoldBackgroundColor: AppColors.darkPurple,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.mediumPurple,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.mediumPurple,
      elevation: 2,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkText),
      titleLarge: TextStyle(color: AppColors.darkText),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.mediumPurple,
      secondary: AppColors.lightPurple,
      surface: AppColors.mediumPurple,
      background: AppColors.darkPurple,
    ),
  );
}
