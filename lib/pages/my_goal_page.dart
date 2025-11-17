import 'dart:convert';
import 'package:flutter/material.dart';
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
  // NEW: Your custom color theme
  final Color appThemeColor = const Color(0xFFFEC5E5); // soft pink
  final Color appThemeColorAccent = const Color(0xFFFF6F91); // medium rose / coral
  final Color appThemeWhite = const Color(0xFFFFFFFF); // lavender purple
  final Color backgroundPink = const Color(0xFFFFD6E0); // peachy pink background

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late DateTime _startOfWeek;

  Map<String, List<Map<String, dynamic>>> goalsByDate = {};
  Map<String, List<Map<String, dynamic>>> doneByDate = {};

  final GlobalKey<AnimatedListState> _goalsListKey =
  GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _doneListKey =
  GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _selectedDay =
        DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    // This calculation makes Monday the start of the week.
    _startOfWeek =
        _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));

    // If you want Sunday to be the start of the week, use this instead:
    // _startOfWeek = _focusedDay.subtract(Duration(days: _focusedDay.weekday % 7));
    _loadGoals();
  }

  String getDateKey(DateTime date) => "${date.year}-${date.month}-${date.day}";

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // FIX: Added jsonDecode
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
      // FIX: Added jsonDecode
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
    // FIX: Added jsonEncode
    await prefs.setString("goalsByDate", jsonEncode(goalsByDate));
    // FIX: Added jsonEncode
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
                _selectedDay = DateTime(
                    selectedDay.year, selectedDay.month, selectedDay.day);
                _focusedDay = focusedDay;
                // Match the logic from initState
                _startOfWeek = focusedDay
                    .subtract(Duration(days: focusedDay.weekday - 1));
                // If you want Sunday start:
                // _startOfWeek = focusedDay.subtract(Duration(days: focusedDay.weekday % 7));
              });
              Navigator.pop(ctx);
            },
            // FIX: Hides the "2 week" button
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              // THEME: Updated calendar colors
              todayDecoration:
              BoxDecoration(color: appThemeColor, shape: BoxShape.circle),
              selectedDecoration:
              BoxDecoration(color: appThemeColorAccent, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }

  void _addGoalDialog() {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark; // Define isDark here

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Helps with keyboard
      // THEME FIX: Set the background of the sheet itself
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          // Add padding for the home bar
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        // Removed the extra Container wrapper
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add New Goal",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black, // Title text color
                )),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true, // Immediately open keyboard
              decoration: InputDecoration(
                hintText: "Enter your goal...",
                hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]), // Hint text color
                // THEME: Default border color
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: isDark ? Colors.white : Colors.grey[400]!),
                ),
                // THEME: Focused border color (white in dark mode, accent in light)
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: isDark ? Colors.white : appThemeColorAccent, width: 2.0),
                ),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black), // Input text color
              cursorColor: isDark ? Colors.white : appThemeColorAccent, // Cursor color
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                // THEME: Updated button color
                backgroundColor: appThemeColorAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  final key = getDateKey(_selectedDay!);
                  goalsByDate.putIfAbsent(key, () => []);
                  // Using the simple goal structure from your original code
                  goalsByDate[key]!
                      .add({"label": controller.text, "done": false});
                  _saveGoals();
                  _goalsListKey.currentState
                      ?.insertItem(goalsByDate[key]!.length - 1);
                }
                setState(() {});
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Add Goal",
                  style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  void _markDone(int index) {
    final key = getDateKey(_selectedDay!);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Safety check for fast taps
    if (goalsByDate[key] == null || index >= goalsByDate[key]!.length) return;

    final item = goalsByDate[key]!.removeAt(index);

    // Animate removal from Goals
    _goalsListKey.currentState?.removeItem(
      index,
          (context, animation) => SizeTransition(
        sizeFactor: animation,
        // Use the buildGoalItem widget for the animation
        child: _buildGoalItem(item, index, isDark),
      ),
      duration: const Duration(milliseconds: 300),
    );

    // Insert into Done with animation
    Future.delayed(const Duration(milliseconds: 300), () {
      item["done"] = true;
      doneByDate.putIfAbsent(key, () => []);
      doneByDate[key]!.insert(0, item);

      _doneListKey.currentState
          ?.insertItem(0, duration: const Duration(milliseconds: 300));

      _saveGoals();
      setState(() {});
    });
  }

  void _deleteDone(int index) {
    final key = getDateKey(_selectedDay!);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Safety check for fast taps
    if (doneByDate[key] == null || index >= doneByDate[key]!.length) return;

    final item = doneByDate[key]!.removeAt(index);

    _doneListKey.currentState?.removeItem(
      index,
          (context, animation) => SizeTransition(
        sizeFactor: animation,
        // Use the buildDoneItem widget for the animation
        child: _buildDoneItem(item, index, isDark),
      ),
      duration: const Duration(milliseconds: 300),
    );

    _saveGoals();
    setState(() {});
  }

  // This logic builds the 7 days
  List<DateTime> _getCurrentWeekDates() =>
      List.generate(7, (i) => _startOfWeek.add(Duration(days: i)));

  @override
  Widget build(BuildContext context) {
    // This variable is now used to fix all dark mode issues
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekDates = _getCurrentWeekDates(); // This now generates all 7 days
    final key = getDateKey(_selectedDay!);
    final goals = goalsByDate[key] ?? [];
    final dones = doneByDate[key] ?? [];

    final total = goals.length + dones.length;
    final completed = dones.length;

    return Scaffold(
      // THEME: Background color is theme-aware
      backgroundColor: isDark ? Colors.black : backgroundPink,
      appBar: AppBar(
        // THEME: AppBar is theme-aware
        backgroundColor: isDark ? Colors.black : backgroundPink,
        elevation: 0,
        centerTitle: true,
        // Add a leading back/home button so users can always go back to the previous
        // screen or call the provided onBackToHome callback when no back stack exists.
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            }
          },
        ),
        title: Text(
          DateFormat('MMMM dd, yyyy').format(_selectedDay!),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            // FIX: Text is theme-aware
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          // THEME: Icon is theme-aware
          IconButton(
            icon: Icon(Icons.calendar_today,
                color: isDark ? Colors.white : appThemeWhite),
            onPressed: _openCalendarPicker,
          ),
          if (widget.onBackToHome != null)
            IconButton(
              // THEME: Icon is theme-aware
              icon: Icon(Icons.home,
                  color: isDark ? Colors.white : appThemeWhite),
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
              // THEME: Card is theme-aware, set to white for contrast
              color: isDark ? Colors.grey[850] : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
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
                            // FIX: Text is theme-aware
                            color: isDark ? Colors.white : Colors.black)),
                    Text("$completed / $total done",
                        style: TextStyle(
                            fontSize: 16,
                            color: completed == total && total > 0
                                ? Colors.green
                            // THEME: Updated color
                                : appThemeColorAccent)),
                  ],
                ),
              ),
            ),
          ),

          // Calendar week scroller
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  // THEME: Updated color
                    icon: Icon(Icons.arrow_back_ios, color: appThemeColorAccent),
                    onPressed: _goToPreviousWeek),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: ListView.builder(
                      // We don't need scrolling if all 7 fit
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: weekDates.length, // This is 7
                      itemBuilder: (context, i) {
                        final date = weekDates[i];
                        final isSelected = isSameDay(date, _selectedDay);

                        return GestureDetector(
                          onTap: () => setState(() => _selectedDay =
                              DateTime(date.year, date.month, date.day)),
                          child: Container(
                            // FIX: Adjusted width, margin, and font
                            // to fit all 7 days evenly.
                            width: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              // THEME: Background is theme-aware
                              color: isSelected
                                  ? appThemeColorAccent // THEME: Updated color
                                  : (isDark
                                  ? Colors.grey[850]
                                  : Colors.white), // THEME: Set to white for contrast
                              borderRadius: BorderRadius.circular(16),
                              // FIX: Border is theme-aware (hidden in dark mode)
                              border: isSelected || isDark
                                  ? null
                                  : Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    DateFormat.E()
                                        .format(date)
                                        .substring(0, 3), // e.g., "Mon"
                                    style: TextStyle(
                                        fontSize: 10, // Smaller font
                                        // FIX: Text is theme-aware
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey),
                                        fontWeight: FontWeight.bold)),
                                Text("${date.day}",
                                    style: TextStyle(
                                        fontSize: 12, // Smaller font
                                        // FIX: Text is theme-aware
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                            ? Colors.white
                                            : Colors.black),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                IconButton(
                    icon:
                    // THEME: Updated color
                    Icon(Icons.arrow_forward_ios, color: appThemeColorAccent),
                    onPressed: _goToNextWeek),
              ],
            ),
          ),

          Divider(color: Colors.grey[200]),
          // Goals + Done Sections
          Expanded(
            child: goals.isEmpty && dones.isEmpty
                ? Center(
              child: Text(
                "🎉 No goals yet for this day.\nTap '+' to add one!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (goals.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        // THEME: Updated icon color
                        Icon(Icons.flag, color: appThemeWhite),
                        const SizedBox(width: 8),
                        Text("Goals",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                // FIX: Text is theme-aware
                                color: isDark
                                    ? Colors.white
                                    : Colors.black)),
                      ],
                    ),
                  ),
                AnimatedList(
                  key: _goalsListKey,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  initialItemCount: goals.length,
                  itemBuilder: (context, index, animation) {
                    // Safety check for fast taps
                    if (index >= goals.length) return const SizedBox.shrink();
                    final goal = goals[index];
                    // FIX: Pass isDark to the builder
                    return SizeTransition(
                      sizeFactor: animation,
                      child: _buildGoalItem(goal, index, isDark),
                    );
                  },
                ),
                if (dones.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green),
                        const SizedBox(width: 8),
                        Text("Done",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                // FIX: Text is theme-aware
                                color: isDark
                                    ? Colors.white
                                    : Colors.black)),
                      ],
                    ),
                  ),
                AnimatedList(
                  key: _doneListKey,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  initialItemCount: dones.length,
                  itemBuilder: (context, index, animation) {
                    // Safety check for fast taps
                    if (index >= dones.length) return const SizedBox.shrink();
                    final doneGoal = dones[index];
                    // FIX: Pass isDark to the builder
                    return SizeTransition(
                      sizeFactor: animation,
                      child: _buildDoneItem(doneGoal, index, isDark),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            // THEME: Updated button color
            backgroundColor: appThemeColorAccent,
            minimumSize: const Size(double.infinity, 50),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: _addGoalDialog,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add Goal",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }

  // UPDATED: Now accepts isDark for theme-awareness
  Widget _buildGoalItem(Map<String, dynamic> goal, int index, bool isDark) {
    return Card(
      // THEME: Card is theme-aware, set to white for contrast
      color: isDark ? Colors.grey[850] : Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(
          goal["label"],
          // FIX: Text is theme-aware
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        trailing: IconButton(
          // THEME: Updated icon color
          icon: Icon(Icons.radio_button_unchecked, color: appThemeColorAccent),
          onPressed: () => _markDone(index),
        ),
      ),
    );
  }

  // UPDATED: Now accepts isDark for theme-awareness
  Widget _buildDoneItem(Map<String, dynamic> doneGoal, int index, bool isDark) {
    return Card(
      elevation: 0,
      // FIX: Card is theme-aware
      color: isDark ? Colors.grey[900] : Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(
          doneGoal["label"],
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red[300]),
          onPressed: () => _deleteDone(index),
        ),
      ),
    );
  }
}
