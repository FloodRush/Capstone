import 'package:flutter/material.dart';

class MyGoalPage extends StatefulWidget {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Goals'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _goalInputController,
              decoration: InputDecoration(
                labelText: 'Add a goal',
                suffixIcon: IconButton(
                  onPressed: _insertGoal,
                  icon: const Icon(Icons.add_circle_outline),
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
                        decoration: item['done'] ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    trailing: Checkbox(
                      value: item['done'],
                      onChanged: (_) => _markGoal(idx),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
