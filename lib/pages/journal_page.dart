import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../pages/Create_Account.dart';
class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _UIState();
}
//for id authentification
//Future<void> currentUser(var user)
//{

//}
//retrieving ids
//Stream<QuerySnapshot> getUser()
//{
class _UIState extends State<JournalPage> {
  final List<String> entry = [];
  final List<String> name = [];
  final List<String> date = [];
  final formkey = GlobalKey<FormState>();
  final dateController = TextEditingController();
  final nameController = TextEditingController();
  final entryController = TextEditingController();
  final deleteController = TextEditingController();
  DateTime startDate = DateTime(2025, 5, 7);

  final userInstance = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (user == null) {
      print("This user does not exist");
    }
  }

  void add() {
    setState(() {
      date.add(dateController.text.trim());
      name.add(nameController.text.trim());
      entry.add(entryController.text.trim());
    });

    FirebaseFirestore.instance
        .collection("Entries")
        .doc(userInstance.currentUser!.uid)
        .set({
      'date': dateController.text.trim(),
      'name': nameController.text.trim(),
      'entry': entryController.text.trim(),
      'uid': userInstance.currentUser!.uid
    });
  }

  void delete(String deleted) {
    int i = name.indexOf(deleted.trim());

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
                controller: deleteController,
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
        name.removeAt(i);
        date.removeAt(i);
        entry.removeAt(i);
      } else if (entry.isEmpty) {
        print('Entry does not exist');
      }
    });
  }

  void update(String updated) {
    setState(() {
      int i = name.indexOf(updated.trim());
      if (entry.isNotEmpty && i != -1) {
        date[i] = dateController.text.trim();
        name[i] = nameController.text.trim();
        entry[i] = entryController.text.trim();
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
            content: Text('Date: ${date[i]}\n\n${entry[i]}'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Journal"),
        centerTitle: true,
      ),
      backgroundColor: Colors.pink[200],
      body: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: add, child: Text('ADD')),
                ElevatedButton(
                  onPressed: () => delete(nameController.text),
                  child: Text('DELETE'),
                ),
                ElevatedButton(
                  onPressed: () => update(nameController.text),
                  child: Text('UPDATE'),
                ),
                ElevatedButton(
                  onPressed: () => view(nameController.text),
                  child: Text('VIEW'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => SizedBox(
                          height: 200,
                          child: CupertinoDatePicker(
                            initialDateTime: startDate,
                            onDateTimeChanged: (DateTime date) {
                              setState(() {
                                startDate = date;
                                dateController.text =
                                    "${date.year}/${date.month}/${date.day}";
                              });
                            },
                            use24hFormat: true,
                            mode: CupertinoDatePickerMode.date,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text('Date'),
                        SizedBox(
                          height: 30,
                          width: 200,
                          child: TextField(
                            controller: dateController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Input',
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Name'),
                  SizedBox(
                    height: 30,
                    width: 200,
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Name',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Entry'),
                  SizedBox(
                    height: 100,
                    width: 200,
                    child: TextField(
                      controller: entryController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'How are you feeling?',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
