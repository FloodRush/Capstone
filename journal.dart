/*PLEASE READ!
During testing in isolation this file is being tested as main.dart. If any issues come up that is why. This will be changed later.
*/
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MaterialApp(home: Main()));
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _UIState();
}

class _UIState extends State<Main> {
  final List<String> entry = [];
  final List<String> name = [];
  final formkey = GlobalKey<FormState>();
  final myController = TextEditingController();
  DateTime startDate = DateTime(2025, 5, 7);

  void add() {
    setState(() {
entry.add(myController.text.trim());
    });
  }

  delete(name) {
    setState(() {
      if (entry.isNotEmpty) {
        entry.remove(name);
      }
    });}

   update(name) {
    setState(() {
      if (entry.isNotEmpty) {
        ///date.insert(0, myController.text.trim());
        name.insert(0, myController.text.trim());
        entry.insert(0, myController.text.trim());
      }
    });
  }
//view function to view journal entries
   view(name) {
   if (entry.isNotEmpty) {
   // SizedBox(
    //  height: 100,
     // width: 30,
     // child: Text(entry),
    //);
    print(entry);
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
      body: 
      Row( 
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: add, child: Text('ADD')),
                ElevatedButton(onPressed: () => delete(name), child: Text('DELETE')),
                ElevatedButton(onPressed: () => update(name), child: Text('UPDATE')),
                ElevatedButton(onPressed: () => view(name), child: Text('VIEW')),
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
                      controller: myController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Input',
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
                      controller: myController,
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
