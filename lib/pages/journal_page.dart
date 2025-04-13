import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _UIState();
}

class _UIState extends State<JournalPage> {
  final List<String> entry = [];
  final List<String> name = [];
  final List<String> date = [];
  final formkey = GlobalKey<FormState>();
  final dateController = TextEditingController();
  final nameController = TextEditingController();
  final entryController = TextEditingController();
  DateTime startDate = DateTime(2025, 5, 7);

  void add() {
    setState(() {
      date.add(dateController.text.trim());
      name.add(nameController.text.trim());
      entry.add(entryController.text.trim());
    });
  }

  delete(deleted) {
    int i = name.indexOf(deleted.trim());
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

  update(updated) {
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
  view(viewed) {
    int i = name.indexOf(viewed.trim());
    if (entry.isNotEmpty && i != -1) {
      // SizedBox(
      //  height: 100,
      // width: 30,
      // child: Text(entry),
      //);
      //for testing
      print(date[i]);
      print(name[i]);
      print(entry[i]);
    } else if (entry.isEmpty) {
      print('Entry does not exist');
    }
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
                    child: Text('DELETE')),
                ElevatedButton(
                    onPressed: () => update(nameController.text),
                    child: Text('UPDATE')),
                ElevatedButton(
                    onPressed: () => view(nameController.text),
                    child: Text('VIEW')),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => SizedBox(
                          height: 200,
                          child: CupertinoDatePicker(
                            initialDateTime: startDate,
                            onDateTimeChanged: (DateTime date) {
                              setState(() => startDate = date);
                            },
                            use24hFormat: true,
                            mode: CupertinoDatePickerMode.date,
                          ),
                        ),
                      );
                    },
                    child: Text('Pick Date'),
                  ),
                  Text('Name'),
                  SizedBox(
                    height: 30,
                    width: 200,
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Name',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        print("Stored!");
                      }
                    },
                    child: Text("Confirm"),
                  ),
                  Text('Entry'),
                  SizedBox(
                    height: 100,
                    width: 200,
                    child: TextField(
                      controller: entryController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'How are you feeling?',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        print("Stored!");
                      }
                    },
                    child: Text("Confirm"),
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
