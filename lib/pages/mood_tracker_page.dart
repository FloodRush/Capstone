import 'package:flutter/material.dart';
import 'package:project/theme.dart';
import 'package:table_calendar/table_calendar.dart';

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
    //List of emotions (Can add more for more variety)
    'Happy', 'Sad', 'Angry', 'Excited', 'Calm', 'Anxious', 'Tired', 'Grateful'
  ];

  List<String> _getMoodsForDay(DateTime day) {
    return _moodEntries[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _selectMoodsForDay(DateTime day) async {
    //Mood Selection Screen
    final selectedMoods = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        List<String> tempSelected = List.from(_getMoodsForDay(day));
        return AlertDialog(
          title: const Text(
              'How did today make you feel?'), //Maybe better phrasing?
          content: SingleChildScrollView(
            child: Column(
              children: emotionList.map((emotion) {
                final isSelected = tempSelected.contains(emotion);
                return CheckboxListTile(
                  title: Text(emotion),
                  value: isSelected,
                  onChanged: (checked) {
                    setState(() {
                      //Not checking properly, but could be emulation issue
                      if (checked == true) {
                        if (tempSelected.length < 3) {
                          //Limits users to 3 emotions a day. Can change
                          tempSelected.add(emotion);
                        }
                      } else {
                        // Clear extras from list
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
    }
  }

  @override
  Widget build(BuildContext context) {
    //Whole Mood Calendar
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        centerTitle: true,
        backgroundColor: AppColors.lightPink,
      ),
      body: Column(
        children: [
          TableCalendar(
            //Actual calendar
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              //Highlights current and selected day. May change how they are able to be used
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _selectMoodsForDay(selectedDay);
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                //Dots for days with submission
                color: Colors.pink[200],
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) => _getMoodsForDay(day),
          ),
          const SizedBox(height: 16),
          Text(
            //Simple display for emotions saved
            'Moods on ${_selectedDay.toLocal().toString().split(' ')[0]}:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _getMoodsForDay(_selectedDay)
                .map((mood) => Chip(label: Text(mood)))
                .toList(),
          )
        ],
      ),
    );
  }
}
