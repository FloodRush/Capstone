/*PLEASE READ!
During testing in isolation this file is being tested as main.dart. If any issues come up that is why. This will be changed later.
*/
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MaterialApp(home: Main()));//used to run flutter
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _UIState();
}

class _UIState extends State<Main> {
  //variables
  final List<String> entry = [];
  final formkey = GlobalKey<FormState>();
  final myController = TextEditingController();
  DateTime startDate = DateTime(2025, 5, 7);
//add function to make new journal entries
  void add() {
    setState(() {entry.add(myController.text.trim());
    });
  }
//delete function to delete journal entries
  void delete() {
    setState(() {
      if (entry.isNotEmpty) {
        entry.removeLast();
      }
    });
  }
//update funtion to edit journal entries
  void update() {
    setState(() {
      if (entry.isNotEmpty) {
        entry.insert(0, myController.text.trim());
      }
    });
  }
//view function to view journal entries
  void view() {
    print(entry); //for testing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Journal")),
      body: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [ 
                //buttons
                ElevatedButton(onPressed: add, child: Text('ADD')),
                ElevatedButton(onPressed: delete, child: Text('DELETE')),
                ElevatedButton(onPressed: update, child: Text('UPDATE')),
                ElevatedButton(onPressed: view, child: Text('VIEW')),
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
                      controller: myController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Input',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                    ),
                  ),
                    //to aid the date entry  
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
                  Form(
                    key: formkey,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {//checks for data
                              return 'Enter something';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Name',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
