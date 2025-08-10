// theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color darkPink = Color.fromARGB(255, 248, 159, 187);
  static const Color hotPink = Color.fromARGB(255, 246, 175, 181);
  static const Color lightPink = Color.fromARGB(255, 248, 220, 229);
}

LinearGradient appGradientBackground() {
  return LinearGradient(
    colors: [AppColors.darkPink, AppColors.hotPink, AppColors.lightPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
