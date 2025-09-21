import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../pages/Create_Account.dart';
import 'package:project/theme.dart';

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
  //final deleteController = TextEditingController();
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
  }

  void add() {
    setState(() {
      date.add(dateController.text.trim());
      name.add(nameController.text.trim());
      entry.add(entryController.text.trim());
    });

    FirebaseFirestore.instance
        .collection("Entries")
        .where('uid', isEqualTo: userInstance.currentUser!.uid)
        .get();
        //.doc(userInstance.currentUser!.uid)
   FirebaseFirestore.instance
        .collection("Entries")
        .add({
      //database.doc(userInstance.currentUser!.uid).update({
      'date': dateController.text.trim(),
      'name': nameController.text.trim(),
      'entry': entryController.text.trim(),
      'uid': userInstance.currentUser!.uid
    });
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
  body: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 231, 125, 160),
              AppColors.hotPink,
              Color.fromARGB(255, 247, 199, 215),
            ],
          ),
        ),
      child: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //IconButton(
                GestureDetector(onTap: add,
                child: Image.asset('assets/icons/add_icon.png', width: 60, height: 60),
                  //),
                ),
                IconButton(
                onPressed: () => delete(nameController.text),
                icon: Image.asset('assets/icons/delete_icon.png', width: 60, height: 60),
                ),
                IconButton(
                onPressed: () => update(nameController.text),
                icon: Image.asset('assets/icons/edit_icon.png', width: 60, height: 60),
                ),
                IconButton(
                  onPressed: () => view(nameController.text),
                  icon: Image.asset('assets/icons/view_icon.png', width: 60, height: 60),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                    Column(
                      children: [
                        Text('Date'),
                        SizedBox(
                          height: 30,
                          width: 300,
                          child: TextField(
                          controller: dateController,
                          readOnly: true,
                          onTap: () {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (context) => SizedBox(
                              height: 300,
                              child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                height: 400,
                              child: Opacity(
                                opacity: 0.5,
                              child: CupertinoDatePicker(
                              initialDateTime: startDate,
                              backgroundColor: Colors.white,                              
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
                              ),
                        ),
                      ),
                    );
                  },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Date',
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  //),
                  SizedBox(height: 20),
                  Text('Name'),
                  SizedBox(
                    height: 30,
                    width: 300,
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
                    height: 30,
                    width: 300,
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
      ),
    );
  }
}
