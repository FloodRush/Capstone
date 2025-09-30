import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class MyGoalPage extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const MyGoalPage({Key? key, this.onBackToHome}) : super(key: key);

  @override
  State<MyGoalPage> createState() => _MyGoalPageState();
}

class _MyGoalPageState extends State<MyGoalPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late DateTime _startOfWeek;

  Map<String, List<Map<String, dynamic>>> goalsByDate = {};
  Map<String, List<Map<String, dynamic>>> doneByDate = {};

  final GlobalKey<AnimatedListState> _goalsListKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _doneListKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    _startOfWeek = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
    _loadGoals();
  }

  String getDateKey(DateTime date) => "${date.year}-${date.month}-${date.day}";

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      goalsByDate = prefs.getString("goalsByDate") != null
          ? Map<String, List<Map<String, dynamic>>>.from(
        (jsonDecode(prefs.getString("goalsByDate")!) as Map).map(
              (k, v) => MapEntry(
            k,
            List<Map<String, dynamic>>.from(v as List<dynamic>),
          ),
        ),
      )
          : {};
      doneByDate = prefs.getString("doneByDate") != null
          ? Map<String, List<Map<String, dynamic>>>.from(
        (jsonDecode(prefs.getString("doneByDate")!) as Map).map(
              (k, v) => MapEntry(
            k,
            List<Map<String, dynamic>>.from(v as List<dynamic>),
          ),
        ),
      )
          : {};
    });
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("goalsByDate", jsonEncode(goalsByDate));
    await prefs.setString("doneByDate", jsonEncode(doneByDate));
  }

  void _goToPreviousWeek() {
    setState(() {
      _startOfWeek = _startOfWeek.subtract(const Duration(days: 7));
      _focusedDay = _startOfWeek;
    });
  }

  void _goToNextWeek() {
    setState(() {
      _startOfWeek = _startOfWeek.add(const Duration(days: 7));
      _focusedDay = _startOfWeek;
    });
  }

  void _openCalendarPicker() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          height: 400,
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                _focusedDay = focusedDay;
                _startOfWeek = focusedDay.subtract(Duration(days: focusedDay.weekday - 1));
              });
              Navigator.pop(ctx);
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.pink[200], shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.pink[400], shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }

  void _addGoalDialog() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add New Goal",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Enter your goal...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  final key = getDateKey(_selectedDay!);
                  goalsByDate.putIfAbsent(key, () => []);
                  goalsByDate[key]!.add({"label": controller.text, "done": false});
                  _saveGoals();
                  _goalsListKey.currentState?.insertItem(goalsByDate[key]!.length - 1);
                }
                setState(() {});
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Goal"),
            )
          ],
        ),
      ),
    );
  }

  void _markDone(int index) {
    final key = getDateKey(_selectedDay!);
    final item = goalsByDate[key]!.removeAt(index);

    // Animate removal from Goals
    _goalsListKey.currentState?.removeItem(
      index,
          (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: Card(
          child: ListTile(
            title: Text(item["label"]),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );

    // Insert into Done with animation
    Future.delayed(const Duration(milliseconds: 300), () {
      item["done"] = true;
      doneByDate.putIfAbsent(key, () => []);
      doneByDate[key]!.insert(0, item);

      _doneListKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));

      _saveGoals();
      setState(() {});
    });
  }

  void _deleteDone(int index) {
    final key = getDateKey(_selectedDay!);
    final item = doneByDate[key]!.removeAt(index);

    _doneListKey.currentState?.removeItem(
      index,
          (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: Card(
          child: ListTile(
            title: Text(item["label"]),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );

    _saveGoals();
    setState(() {});
  }

  List<DateTime> _getCurrentWeekDates() =>
      List.generate(7, (i) => _startOfWeek.add(Duration(days: i)));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekDates = _getCurrentWeekDates();
    final key = getDateKey(_selectedDay!);
    final goals = goalsByDate[key] ?? [];
    final dones = doneByDate[key] ?? [];

    final total = goals.length + dones.length;
    final completed = dones.length;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        title: Text(
          DateFormat('MMMM dd, yyyy').format(_selectedDay!),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          if (widget.onBackToHome != null)
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: widget.onBackToHome,
            ),
        ],
      ),
      body: Column(
        children: [
          // Dashboard summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: isDark ? Colors.grey[850] : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today’s Goals",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black)),
                    Text("$completed / $total done",
                        style: TextStyle(
                            fontSize: 16,
                            color: completed == total && total > 0
                                ? Colors.green
                                : Colors.pink)),
                  ],
                ),
              ),
            ),
          ),
          // Week navigation row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.pink),
                    onPressed: _goToPreviousWeek),
                Expanded(
                  child: SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: weekDates.length,
                      itemBuilder: (context, i) {
                        final date = weekDates[i];
                        final isSelected = isSameDay(date, _selectedDay);

                        final total = (goalsByDate[getDateKey(date)]?.length ?? 0) +
                            (doneByDate[getDateKey(date)]?.length ?? 0);
                        final completed =
                        (doneByDate[getDateKey(date)]?.length ?? 0);

                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedDay = DateTime(
                                  date.year, date.month, date.day)),
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.pink[300] : (isDark ? Colors.grey[850] : Colors.white),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4)
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(DateFormat.E().format(date),
                                    style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark ? Colors.white : Colors.black),
                                        fontWeight: FontWeight.bold)),
                                Text("${date.day}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark ? Colors.white : Colors.black),
                                        fontWeight: FontWeight.bold)),
                                if (total > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: completed == total
                                            ? Colors.green
                                            : Colors.pink[300],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.pink),
                    onPressed: _goToNextWeek),
              ],
            ),
          ),
          const Divider(),
          // Goals + Done Sections
          Expanded(
            child: goals.isEmpty && dones.isEmpty
                ? Center(
              child: Text(
                "🎉 No goals yet for this day.\nTap + to add one!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
                : ListView(
              children: [
                if (goals.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: const [
                        Icon(Icons.flag, color: Colors.pink),
                        SizedBox(width: 8),
                        Text("Goals",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                AnimatedList(
                  key: _goalsListKey,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  initialItemCount: goals.length,
                  itemBuilder: (context, index, animation) {
                    final goal = goals[index];
                    return SizeTransition(
                      sizeFactor: animation,
                      child: Slidable(
                        key: ValueKey(index),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _markDone(index),
                              backgroundColor: Colors.green,
                              icon: Icons.check,
                              label: "Done",
                            ),
                          ],
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: const Icon(Icons.radio_button_unchecked,
                                color: Colors.pink),
                            title: Text(goal["label"]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (dones.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: const [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 8),
                        Text("Done",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                AnimatedList(
                  key: _doneListKey,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  initialItemCount: dones.length,
                  itemBuilder: (context, index, animation) {
                    final doneGoal = dones[index];
                    return SizeTransition(
                      sizeFactor: animation,
                      child: Slidable(
                        key: ValueKey("done_$index"),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _deleteDone(index),
                              backgroundColor: Colors.red,
                              icon: Icons.delete,
                              label: "Delete",
                            ),
                          ],
                        ),
                        child: Card(
                          color: isDark ? Colors.grey[850] : Colors.grey[100],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: const Icon(Icons.check_circle,
                                color: Colors.green),
                            title: Text(
                              doneGoal["label"],
                              style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink[300],
        onPressed: _openCalendarPicker,
        child: const Icon(Icons.calendar_today, color: Colors.white),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: _addGoalDialog,
          icon: const Icon(Icons.add),
          label: const Text("Add Goal"),
        ),
      ),
    );
  }
}
