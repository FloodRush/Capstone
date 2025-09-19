import 'package:flutter/material.dart';
import 'package:project/theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

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

  final Map<String, int> emotionValues = {
    'Happy': 2,
    'Excited': 2,
    'Calm': 1,
    'Grateful': 2,
    'Sad': -2,
    'Angry': -3,
    'Anxious': -2,
    'Tired': -1,
  };

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _scheduleMoodReminder();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> _scheduleMoodReminder() async {
    final today = DateTime.now();
    final utcToday = DateTime.utc(today.year, today.month, today.day);
    final hasEntry = _moodEntries.containsKey(utcToday);

    if (hasEntry) {
      // Cancel existing reminder
      await flutterLocalNotificationsPlugin.cancel(0);
    } else {
      // Schedule notification at 8 PM
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledTime =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0);

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Mood Check-In',
        'Don’t forget to record your mood today!',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'mood_channel',
            'Mood Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  List<String> _getMoodsForDay(DateTime day) {
    return _moodEntries[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  int calculateDailyMoodScore(DateTime day) {
    final moods = _getMoodsForDay(day);
    int score = 0;
    for (var mood in moods) {
      score += emotionValues[mood] ?? 0;
    }
    return score;
  }

  List<FlSpot> getMoodDataPoints() {
    final List<DateTime> sortedDates = _moodEntries.keys.toList()..sort();
    List<FlSpot> spots = [];

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final score = calculateDailyMoodScore(date);
      spots.add(FlSpot(i.toDouble(), score.toDouble()));
    }

    return spots;
  }

  void _selectMoodsForDay(DateTime day) async {
    final selectedMoods = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        List<String> tempSelected = List.from(_getMoodsForDay(day));
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
                    setState(() {
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

    if (selectedMoods != null) {
      setState(() {
        _moodEntries[DateTime.utc(day.year, day.month, day.day)] =
            selectedMoods;
      });

      // Reschedule/cancel reminder after mood update
      _scheduleMoodReminder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodSpots = getMoodDataPoints();
    final sortedDates = _moodEntries.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        centerTitle: true,
        backgroundColor: AppColors.lightPink,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _selectMoodsForDay(selectedDay);
              },
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.pink[200],
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: (day) => _getMoodsForDay(day),
            ),
            const SizedBox(height: 16),
            Text(
              'Moods on ${_selectedDay.toLocal().toString().split(' ')[0]}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _getMoodsForDay(_selectedDay)
                  .map((mood) => Chip(label: Text(mood)))
                  .toList(),
            ),
            const SizedBox(height: 24),
            if (moodSpots.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= sortedDates.length) {
                                return const SizedBox.shrink();
                              }
                              final date = sortedDates[index];
                              final label = "${date.month}/${date.day}";
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(label,
                                    style: const TextStyle(fontSize: 10)),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, interval: 1),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      minY: -6,
                      maxY: 6,
                      lineBarsData: [
                        LineChartBarData(
                          spots: moodSpots,
                          isCurved: true,
                          barWidth: 3,
                          colors: Colors.pink,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
