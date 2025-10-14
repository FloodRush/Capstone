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
    tag = widget.initialTag! ?? [];
    tagController.text = tag.join(', ');
    }
  }


  void add() {
    if (widget.onSave != null) {
      // Editing: only call the callback, do not add a new entry
      widget.onSave!(nameController.text.trim(), dateController.text.trim(), entryController.text.trim(), tagController.text.split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList());
      Navigator.pop(context);
      return;
    }
    // Adding: create a new entry in Firestore
    setState(() {
      date.add(dateController.text.trim());
      name.add(nameController.text.trim());
      entry.add(entryController.text.trim());
      //tag.add(tagController.text.trim());
    });
    FirebaseFirestore.instance
        .collection("Entries")
        .add({
      'date': dateController.text.trim(),
      'name': nameController.text.trim(),
      'entry': entryController.text.trim(),
      'tag': tag,
      'uid': userInstance.currentUser!.uid
    });
    Navigator.pop(context); // Always go back to JournalListPage after saving
  }

  void delete(String deleted) {
    int i = name.indexOf(deleted.trim());
//for the popup
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (entry.isNotEmpty && i != -1) {
          return AlertDialog(
            title: Text('Select Entry'),
            content: SizedBox(
              height: 30,
              width: 200,
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                ),
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );

    setState(() {
      if (entry.isNotEmpty && i != -1) {
        /*name.removeAt(i);
        date.removeAt(i);
        entry.removeAt(i);*/
        //updates the entry for the current user
      database.doc(userInstance.currentUser!.uid).update({
      'date': FieldValue.delete(),
      'name': FieldValue.delete(),
      'entry': FieldValue.delete(),  
      'tag': FieldValue.delete(),  
    });
        print('Entry does not exist');
      }
    });
  }

  void update(String updated) {
    int i = name.indexOf(updated.trim());
    //for the popup
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (entry.isNotEmpty && i != -1) {
          return AlertDialog(
            title: Text('Select Entry'),
            content: SizedBox(
              height: 30,
              width: 200,
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                ),
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );

    setState(() {
      int i = name.indexOf(updated.trim());
      if (entry.isNotEmpty && i != -1) {
      /*  date[i] = dateController.text.trim();
        name[i] = nameController.text.trim();
        entry[i] = entryController.text.trim();*/
              database.doc(userInstance.currentUser!.uid).update({
      'date': dateController.text.trim(),
      'name': nameController.text.trim(),
      'entry': entryController.text.trim(),
      'tag': tag,
    });
      } else if (entry.isEmpty) {
        print('Entry does not exist');
      }
    });
  }
//view function to view journal entries
  void view(String viewed) {
    int i = name.indexOf(viewed.trim());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (entry.isNotEmpty && i != -1) {
          return AlertDialog(
            title: Text('Name: ${name[i]}'),
            content: Text('Date: ${date[i]}\n\n${entry[i]}\n\n${tag}'),
          );
        } else if (entry.isEmpty) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Entry does not exist'),
          );
        } else {
          return AlertDialog(
            title: Text('Invalid'),
            content: Text('Invalid index'),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 1;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE7BDF0),
              Color(0xFFF7C7D7),
              Color(0xFFD6EAF8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 32),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Journal",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48), // For symmetry
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
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          margin: EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date', style: TextStyle(fontWeight: FontWeight.w500)),
                              SizedBox(height: 8),
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
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                  hintText: 'Date',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          margin: EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Title', style: TextStyle(fontWeight: FontWeight.w500)),
                              SizedBox(height: 8),
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                  hintText: 'Title',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 280, // Increased height for the whole Entry box
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          margin: EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Entry', style: TextStyle(fontWeight: FontWeight.w500)),
                              SizedBox(height: 8),
                              Expanded(
                                child: TextField(
                                  controller: entryController,
                                  maxLines: 30, // Input starts from the top
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                    hintText: 'How are you feeling?',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                                  ),
                                ),
                                
                              ),
                               TextField(
                                  controller: tagController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                    hintText: 'Tag',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                  ),
                                onSubmitted: (value) {
                                  setState(() {
                                    tag.add(value.trim());
                                    tagController.clear();
                                  });
                                },
                                ),
                                  SizedBox(height: 8),
                          //to display multiple tags
                          Wrap(
                          spacing: 4,
                          children: tag.map((t) {
                            return Chip(
                              label: Text('#${t.toLowerCase()}'),
                              deleteIcon: Icon(Icons.close),
                              shape: StadiumBorder(side: BorderSide(color: Colors.transparent)),
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
                        SizedBox(height: 18),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.hotPink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 2,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          onPressed: add,
                          child: Text('Save Entry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
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
          color: AppColors.lightPink,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.darkPink,
          unselectedItemColor: const Color.fromARGB(255, 21, 21, 21),
          onTap: (index) {
            if (index == 0) Navigator.pushReplacementNamed(context, '/home');
            if (index == 1) Navigator.pushReplacementNamed(context, '/journal');
            if (index == 2) Navigator.pushReplacementNamed(context, '/goals');
            if (index == 3) Navigator.pushReplacementNamed(context, '/quotes');
            if (index == 4) Navigator.pushReplacementNamed(context, '/meditate');
          },
          items: [
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
