import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../pages/Create_Account.dart';
import 'package:project/theme.dart';

class JournalPage extends StatefulWidget {
  final String? initialTitle;
  final String? initialDate;
  final String? initialEntry;
  final List<String>? initialTag;
  final void Function(String title, String date, String entry, List<String> tag)? onSave;

  const JournalPage({
    super.key,
    this.initialTitle,
    this.initialDate,
    this.initialEntry,
    this.initialTag,
    this.onSave,
  });

  @override
  State<JournalPage> createState() => _UIState();
}

class _UIState extends State<JournalPage> {
  final List<String> entry = [];
  final List<String> name = [];
  final List<String> date = [];
  List<String> tag = [];
  final formkey = GlobalKey<FormState>();
  final dateController = TextEditingController();
  final nameController = TextEditingController();
  final entryController = TextEditingController();
  final tagController = TextEditingController();
  DateTime startDate = DateTime(2025, 5, 7);

  final userInstance = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  late CollectionReference database;

  @override
  void initState() {
    super.initState();
    database = db.collection("Entries");
    if (user == null) {
      print("This user does not exist");
    }
    // Pre-fill fields if editing
    if (widget.initialTitle != null) nameController.text = widget.initialTitle!;
    if (widget.initialDate != null) dateController.text = widget.initialDate!;
    if (widget.initialEntry != null) entryController.text = widget.initialEntry!;
    if (widget.initialTag != null) {
      tag = widget.initialTag!;
      tagController.text = tag.join(', ');
    }
  }

  void add() {
    if (widget.onSave != null) {
      // Editing only call the callback, do not add a new entry
      final List<String> cleanTags = [
        ...tag,
        ...tagController.text
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty),
      ].toSet().toList(); // removes duplicates

      widget.onSave!(
        nameController.text.trim(),
        dateController.text.trim(),
        entryController.text.trim(),
        cleanTags.map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
      );
      Navigator.pop(context);
      return;
    }
    // Adding create a new entry in Firestore
    setState(() {
      date.add(dateController.text.trim());
      name.add(nameController.text.trim());
      entry.add(entryController.text.trim());
    });
    FirebaseFirestore.instance.collection("Entries").add({
      'date': dateController.text.trim(),
      'name': nameController.text.trim(),
      'entry': entryController.text.trim(),
      'tag': [
        ...tag,
        ...tagController.text
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
      ].toSet().toList(),
      'uid': userInstance.currentUser!.uid
    });
    Navigator.pop(context); // Always go back to JournalListPage after saving
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        // Use the centralized app gradient which returns a purple gradient in dark mode
        // and the pink gradient in light mode so the Journal page matches other pages.
        decoration: BoxDecoration(
          gradient: appGradientBackground(isDark: isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Journal",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // For symmetry
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 2))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Date', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: dateController,
                                readOnly: true,
                                keyboardType: TextInputType.datetime,
                                onTap: () async {
                                  final DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: startDate,
                                    firstDate: DateTime(2025),
                                    lastDate: DateTime(2100),
                                  );

                                  if (pickedDate != null) {
                                    setState(() {
                                      startDate = pickedDate;
                                      dateController.text =
                                          "${pickedDate.year}/${pickedDate.month}/${pickedDate.day}";
                                    });
                                  }
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                                  hintText: 'Date',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                ),
                                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 2))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Title', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                                  hintText: 'Title',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                ),
                                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 280, // Increased height for the whole Entry box
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 2))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Entry', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Expanded(
                                child: TextField(
                                  controller: entryController,
                                  maxLines: 30, // Input starts from the top
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                                    hintText: 'How are you feeling?',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                                  ),
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: tagController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                                  hintText: 'Tag',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                ),
                                onSubmitted: (value) {
                                  setState(() {
                                    tag.add(value.trim());
                                    tagController.clear();
                                  });
                                },
                                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              ),
                              const SizedBox(height: 8),
                              // to display multiple tags
                              Wrap(
                                spacing: 4,
                                children: tag.map((t) {
                                  return Chip(
                                    label: Text('#${t.toLowerCase()}', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                                    deleteIcon: const Icon(Icons.close),
                                    shape: const StadiumBorder(side: BorderSide(color: Colors.transparent)),
                                    onDeleted: () {
                                      setState(() {
                                        tag.remove(t);
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // Use the dark theme purple to match other pages in dark mode
                            backgroundColor: isDark ? AppColors.mediumPurple : AppColors.hotPink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          onPressed: add,
                          child: const Text('Save Entry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // Use the mediumPurple in dark mode to match other pages
          color: isDark ? AppColors.mediumPurple : AppColors.lightPink,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.darkPink,
          unselectedItemColor: isDark ? Colors.white70 : const Color.fromARGB(255, 21, 21, 21),
          onTap: (index) {
            if (index == 0) Navigator.pushReplacementNamed(context, '/home');
            if (index == 1) Navigator.pushReplacementNamed(context, '/journal');
            if (index == 2) Navigator.pushReplacementNamed(context, '/goals');
            if (index == 3) Navigator.pushReplacementNamed(context, '/quotes');
            if (index == 4) Navigator.pushReplacementNamed(context, '/meditate');
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: "Journal",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag),
              label: "Goals",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.format_quote),
              label: "Quotes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement),
              label: "Meditate",
            ),
          ],
        ),
      ),
    );
  }
}
