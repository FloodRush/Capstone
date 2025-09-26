// pubspec.yaml:
// Add this under dependencies:
// shared_preferences: ^2.0.15

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyGoalPage extends StatefulWidget {
  @override
  State<MyGoalPage> createState() => _MyGoalPageState();
}

class _MyGoalPageState extends State<MyGoalPage> {
  List<Map<String, dynamic>> healthGoals = [];
  List<Map<String, dynamic>> personalGoals = [];
  String healthLabel = 'Health Goals';
  String personalLabel = 'Personal Goals';

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      healthGoals = List<Map<String, dynamic>>.from(
        jsonDecode(prefs.getString('healthGoals') ?? '[]'),
      );
      personalGoals = List<Map<String, dynamic>>.from(
        jsonDecode(prefs.getString('personalGoals') ?? '[]'),
      );
      healthLabel = prefs.getString('healthLabel') ?? 'Health Goals';
      personalLabel = prefs.getString('personalLabel') ?? 'Personal Goals';
    });
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('healthGoals', jsonEncode(healthGoals));
    await prefs.setString('personalGoals', jsonEncode(personalGoals));
    await prefs.setString('healthLabel', healthLabel);
    await prefs.setString('personalLabel', personalLabel);
  }

  void _toggleGoal(List<Map<String, dynamic>> list, int index) {
    setState(() {
      list[index]['done'] = !list[index]['done'];
      _saveGoals();
    });
  }

  void _editSectionName(String type) async {
    String? newName = await showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(
            text: type == 'health' ? healthLabel : personalLabel);
        return AlertDialog(
          title: Text("Rename $type section"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text("Save"),
            )
          ],
        );
      },
    );

    if (newName != null && newName.trim().isNotEmpty) {
      setState(() {
        if (type == 'health') {
          healthLabel = newName.trim();
        } else {
          personalLabel = newName.trim();
        }
        _saveGoals();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Goal Tracking', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildHeader(healthLabel, 'health'),
            ...healthGoals.asMap().entries.map(
              (entry) => _buildTile(entry.value, () => _toggleGoal(healthGoals, entry.key)),
            ),
            SizedBox(height: 30),
            _buildHeader(personalLabel, 'personal'),
            ...personalGoals.asMap().entries.map(
              (entry) => _buildTile(entry.value, () => _toggleGoal(personalGoals, entry.key)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        child: Icon(Icons.add),
        onPressed: () => _addGoalDialog(),
      ),
    );
  }

  Widget _buildHeader(String label, String type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          icon: Icon(Icons.edit, color: Colors.grey),
          onPressed: () => _editSectionName(type),
        ),
      ],
    );
  }

  Widget _buildTile(Map<String, dynamic> goal, VoidCallback onToggle) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4),
      title: Text(goal['label']),
      trailing: Checkbox(
        value: goal['done'],
        onChanged: (_) => onToggle(),
      ),
    );
  }

  void _addGoalDialog() async {
    String? type;
    String? label;
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("New Goal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: type,
              isExpanded: true,
              hint: Text("Select Type"),
              onChanged: (val) => setState(() => type = val),
              items: ["health", "personal"]
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
            ),
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: "Goal label"),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (type != null && controller.text.trim().isNotEmpty) {
                setState(() {
                  var newGoal = {
                    'label': controller.text.trim(),
                    'done': false
                  };
                  if (type == 'health') {
                    healthGoals.add(newGoal);
                  } else {
                    personalGoals.add(newGoal);
                  }
                  _saveGoals();
                });
              }
            },
            child: Text("Add"),
          )
        ],
      ),
    );
  }
}
