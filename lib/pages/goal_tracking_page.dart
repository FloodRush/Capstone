import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyGoalPage extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const MyGoalPage({Key? key, this.onBackToHome}) : super(key: key);
  @override
  State<MyGoalPage> createState() => _MyGoalPageState();
}

class _MyGoalPageState extends State<MyGoalPage> {
  List<Map<String, dynamic>> healthGoals = [];
  List<Map<String, dynamic>> personalGoals = [];

  String healthTitle = 'HEALTH GOALS';
  String personalTitle = 'PERSONAL GOALS';

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      healthGoals = prefs.getString('healthGoals') != null
          ? List<Map<String, dynamic>>.from(
              json.decode(prefs.getString('healthGoals')!))
          : [
              {
                'label': 'Finish 3 workouts this week',
                'icon': Icons.flag.codePoint,
                'progress': 0.66,
                'done': true
              },
              {
                'label': 'Walk 10,000 steps a day',
                'icon': Icons.directions_walk.codePoint,
                'done': false
              },
            ];

      personalGoals = prefs.getString('personalGoals') != null
          ? List<Map<String, dynamic>>.from(
              json.decode(prefs.getString('personalGoals')!))
          : [
              {
                'label': 'Read 10 pages',
                'icon': Icons.emoji_events.codePoint,
                'done': false
              },
              {
                'label': 'Practice gratitude',
                'icon': Icons.flash_on.codePoint,
                'due': 'Sep 30',
                'done': false
              },
            ];
    });
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('healthGoals', json.encode(healthGoals));
    await prefs.setString('personalGoals', json.encode(personalGoals));
  }

  void _toggleGoal(List<Map<String, dynamic>> goals, int index) {
    setState(() {
      goals[index]['done'] = !goals[index]['done'];
    });
    _saveGoals();
  }

  void _changeSectionName(bool isHealth) {
    showDialog(
      context: context,
      builder: (ctx) {
        TextEditingController controller =
            TextEditingController(text: isHealth ? healthTitle : personalTitle);

        return AlertDialog(
          title: Text("Change Section Title"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (isHealth) {
                    healthTitle = controller.text;
                  } else {
                    personalTitle = controller.text;
                  }
                });
                Navigator.pop(ctx);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGoalTile(Map<String, dynamic> goal, bool isHealth, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(IconData(goal['icon'], fontFamily: 'MaterialIcons'),
                color: Colors.pink),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal['label'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
                if (goal.containsKey('progress'))
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: LinearProgressIndicator(
                      value: goal['progress'],
                      backgroundColor: Colors.grey[800],
                      color: Colors.pink,
                    ),
                  ),
                if (goal.containsKey('due'))
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text("Due: ${goal['due']}",
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey)),
                  )
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
              goal['done'] ? Icons.check_circle : Icons.radio_button_unchecked,
              color: Colors.white,
            ),
            onPressed: () =>
                _toggleGoal(isHealth ? healthGoals : personalGoals, index),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Goal Tracking',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(healthTitle,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.pink),
                  onPressed: () => _changeSectionName(true),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...healthGoals
                .asMap()
                .entries
                .map((e) => _buildGoalTile(e.value, true, e.key))
                .toList(),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(personalTitle,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.pink),
                  onPressed: () => _changeSectionName(false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...personalGoals
                .asMap()
                .entries
                .map((e) => _buildGoalTile(e.value, false, e.key))
                .toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, size: 30),
        onPressed: () {
          // TODO: Add functionality to create custom goals
        },
      ),
    );
  }
}
