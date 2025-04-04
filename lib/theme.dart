// theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color darkPink = Color.fromARGB(255, 231, 125, 160);
  static const Color hotPink = Color.fromARGB(255, 248, 87, 140);
  static const Color lightPink = Color.fromARGB(255, 247, 199, 215);
}

LinearGradient appGradientBackground() {
  return LinearGradient(
    colors: [AppColors.darkPink, AppColors.hotPink, AppColors.lightPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
