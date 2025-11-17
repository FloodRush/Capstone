import 'package:flutter/material.dart';
import 'package:project/theme.dart';
import 'package:project/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<String>> _moodEntries = {};

  final List<String> emotionList = [
    'Happy', 'Sad', 'Angry', 'Excited', 'Calm', 'Anxious', 'Tired', 'Grateful'
  ];

  Map<String, bool> _checkedActivities = {};

  final Map<String, int> moodActivities = {
    'Happy': -3,
    'Sad': 1,
    'Angry': 3,
    'Excited': -2,
    'Calm': -1,
    'Anxious': 2,
    'Tired': 1,
    'Grateful': -2,
  };

  List<String> allActivities = [
    'Journal',
    'Meditate',
    'Get Inspired',
    'Check Your Goals',
  ];

  List<String> currentActivities = [];
  Map<String, bool> checked = {};

  void updateActivities(int score) {
    setState(() {
      if (score > 0) {
        for (int i = 0; i < score; i++) {
          if (currentActivities.length < allActivities.length) {
            String activityToAdd = allActivities[currentActivities.length];
            currentActivities.add(activityToAdd);
            checked[activityToAdd] = false;
          }
        }
      } else if (score < 0) {
        for (int i = 0; i < score.abs(); i++) {
          if (currentActivities.isNotEmpty) {
            String removedActivity = currentActivities.removeLast();
            checked.remove(removedActivity);
          }
        }
      }
    });
  }

  List<String> _getMoodsForDay(DateTime day) {
    return _moodEntries[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _selectMoodsForDay(DateTime day) async {
    final selectedMoods = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        List<String> tempSelected = List.from(_getMoodsForDay(day));
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('How did today make you feel?'),
              content: SingleChildScrollView(
                child: Column(
                  children: emotionList.map((emotion) {
                    final isSelected = tempSelected.contains(emotion);
                    return CheckboxListTile(
                      title: Text(emotion),
                      value: isSelected,
                      onChanged: (checked) {
                        // Use dialog-local setState so UI updates immediately inside the dialog
                        setStateDialog(() {
                          if (checked == true) {
                            if (tempSelected.length < 3) {
                              tempSelected.add(emotion);
                            }
                          } else {
                            tempSelected.remove(emotion);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, tempSelected),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedMoods != null) {
      setState(() {
        _moodEntries[DateTime.utc(day.year, day.month, day.day)] = selectedMoods;
        _checkedActivities.clear();

        // Compute recommended activities
        final activities = <String>{};
        for (var mood in selectedMoods) {
          int score = moodActivities[mood] ?? 0;
          if (score > 0) {
            for (int i = 0; i < score; i++) {
              if (activities.length < allActivities.length) {
                activities.add(allActivities[activities.length]);
              }
              if (activities.length >= 4) break;
            }
          }
          if (activities.length >= 4) break;
        }

        for (var act in activities) {
          _checkedActivities[act] = false;
        }
      });
    }
  }
  
  void scheduleDailyReminder() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'daily_reminder_channel',
      title: 'How are you feeling today?',
      body: 'Tap to log your mood and get activity suggestions!',
      notificationLayout: NotificationLayout.Default,
    ),
    schedule: NotificationCalendar(
      hour: 22,
      minute: 51,
      second: 0,
      millisecond: 0,
      repeats: true,
      timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final selectedMoods = _getMoodsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        centerTitle: true,
        backgroundColor:
            themeProvider.isDarkMode ? AppColors.mediumPurple : AppColors.lightPink,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _selectMoodsForDay(selectedDay);
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: themeProvider.isDarkMode ? AppColors.accentPurple : Colors.pink[200],
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: themeProvider.isDarkMode ? AppColors.accentPurple : AppColors.hotPink,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: themeProvider.isDarkMode ? AppColors.lightPurple : AppColors.darkPink,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(
                color: themeProvider.isDarkMode ? AppColors.darkText : Colors.black,
              ),
              weekendTextStyle: TextStyle(
                color: themeProvider.isDarkMode ? AppColors.darkSecondaryText : Colors.black54,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonTextStyle: TextStyle(
                color: themeProvider.isDarkMode ? AppColors.darkText : Colors.black,
              ),
              titleTextStyle: TextStyle(
                color: themeProvider.isDarkMode ? AppColors.darkText : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            eventLoader: (day) => _getMoodsForDay(day),
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recommended Activities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? AppColors.darkText : Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: _checkedActivities.entries.map((entry) {
                return CheckboxListTile(
                  title: Text(
                    entry.key,
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  value: entry.value,
                  onChanged: (bool? val) {
                    setState(() {
                      _checkedActivities[entry.key] = val ?? false;
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
 
