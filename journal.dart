/*PLEASE READ!
During testing in isolation this file is being tested as main.dart. If any issues come up that is why. This will be changed later.
*/
import 'package:flutter/material.dart';
//add function to make new journal entries
 add(){
print('ADD'); //button testing
//print(date.text);
}
//delete function to delete journal entries
void delete(){
print('DELETE'); //button testing
}
//update funtion to edit journal entries
void update(){
print('UPDATE'); //button testing
}
//view function to view journal entries
void view(){
print('VIEW'); //button testing
}
void main(){
runApp(Main());//used to run flutter
}
//classes are required for widgets
class Main extends StatefulWidget{
  const Main({super.key});

  @override
  State<Main> createState() => _UIState();
}

class _UIState extends State<Main> {
  get children => null;

  //returns widgets
  late String date;
  final myController= TextEditingController();//for input
  @override
  //Widget build(BuildContext context)
  //{return TextField(controller: myController);}
  @override
  Widget build(BuildContext context){
    //var text = Text('Journal');
    
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Journal'),
          ),  
           
          body:
          //@override
          Row( children: <Widget> [ 

           Align( //Menu options
          alignment: Alignment.centerLeft,
          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () { 
                date=myController.text.trim();
                add();
                 },
                //controller: myController,
                child: Text('ADD'),
                //context: context,
                //builder: (context)
                //const SizedBox(height: 5),
                //return AlertDialog (
                //  TextEditingController.content: 
                //  Text(myController.text),);
              ),
              // SizedBox(height: 20),
              ElevatedButton(
                onPressed: delete,
                child: Text('DELETE'),
              ),
              ElevatedButton(
                onPressed: update,
                child: Text('UPDATE'),
              ),
              ElevatedButton(
                onPressed: view,
                child: Text('VIEW'),
              ),
       
            ],
          ),    

            ),
            Align(
                alignment: Alignment.centerRight,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Date'),
                   SizedBox(
                    height: 30,
                    width: 200,
                    child: TextField(
                    controller: myController,
                      decoration: InputDecoration(border: OutlineInputBorder(),
                      hintText: 'Input',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    ),
                  ),
                  Text('Name'),
                   SizedBox(
                    height: 30,
                    width: 200,
                    child: TextField(
                    
                      decoration: InputDecoration(border: OutlineInputBorder(),
                      hintText: 'Input',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    ),
                  ),
                  //entry
                   SizedBox(
                    height: 400,
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(border: OutlineInputBorder(),
                      hintText: 'Input',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    ),
                  ),
                ]
          ),
            ),
          ]//main children
        ),
    
          
      ),
      );
 //To clean up controller
 //date.dispose();
 //super.dispose();     
  }
}
