import 'package:flutter/material.dart';
import 'package:project/theme.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;

  const MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black
            : AppColors.lightPink, // Adjust background color for dark mode
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(
        left: 15,
        bottom: 15,
      ),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionName,
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black, // Set text color based on dark mode
                ),
              ),
              // Edit button
              IconButton(
                onPressed: onPressed, // Pass the onPressed function here
                icon: Icon(
                  Icons.settings,
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black, // Set icon color based on dark mode
                ),
              ),
            ],
          ),
          Text(
            text,
            style: TextStyle(
              color: isDarkMode
                  ? Colors.white
                  : Colors.black, // Set text color based on dark mode
            ),
          ),
        ],
      ),
    );
  }
}
