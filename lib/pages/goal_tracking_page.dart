import 'package:flutter/material.dart';
import 'package:project/theme.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';


class MyGoalPage extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const MyGoalPage({Key? key, this.onBackToHome}) : super(key: key);

  @override
  State<MyGoalPage> createState() => _MyGoalPageState();
}

class _MyGoalPageState extends State<MyGoalPage> {
  final List<Map<String, dynamic>> _taskList = [];
  final _goalInputController = TextEditingController();

  void _insertGoal() {
    final inputText = _goalInputController.text.trim();
    if (inputText.isNotEmpty) {
      setState(() {
        _taskList.add({'label': inputText, 'done': false});
        _goalInputController.clear();
      });
    }
  }

  void _markGoal(int i) {
    setState(() {
      _taskList[i]['done'] = !_taskList[i]['done'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return WillPopScope(
          onWillPop: () async {
            if (Navigator.of(context).canPop()) return true;
            if (widget.onBackToHome != null) { widget.onBackToHome!(); return false; }
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Daily Goals'),
              centerTitle: true,
              backgroundColor: themeProvider.isDarkMode
                  ? AppColors.mediumPurple
                  : AppColors.lightPink,
              foregroundColor: themeProvider.isDarkMode
                  ? AppColors.darkText
                  : Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else if (widget.onBackToHome != null) {
                    widget.onBackToHome!();
                  }
                },
              ),
            ),
            backgroundColor: themeProvider.isDarkMode
                ? AppColors.darkPurple
                : Colors.white,
            body: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextField(
                    controller: _goalInputController,
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? AppColors.darkText
                          : AppColors.lightText,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Add a goal',
                      labelStyle: TextStyle(
                        color: themeProvider.isDarkMode
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText,
                      ),
                      suffixIcon: IconButton(
                        onPressed: _insertGoal,
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: themeProvider.isDarkMode
                              ? AppColors.accentPurple
                              : AppColors.hotPink,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: themeProvider.isDarkMode
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: themeProvider.isDarkMode
                              ? AppColors.accentPurple
                              : AppColors.hotPink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _taskList.length,
                      itemBuilder: (ctx, idx) {
                        final item = _taskList[idx];
                        return ListTile(
                          title: Text(
                            item['label'],
                            style: TextStyle(
                              decoration:
                                  item['done'] ? TextDecoration.lineThrough : null,
                              color: themeProvider.isDarkMode
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                            ),
                          ),
                          trailing: Checkbox(
                            value: item['done'],
                            onChanged: (_) => _markGoal(idx),
                            activeColor: themeProvider.isDarkMode
                                ? AppColors.accentPurple
                                : AppColors.hotPink,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
