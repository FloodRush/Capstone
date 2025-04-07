/*PLEASE READ!
During testing in isolation this file is being tested as main.dart. If any issues come up that is why. This will be changed later.
*/
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
//add function to make new journal entries
 add(input){
print('ADD'); //button testing
print(input.text);
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
//@override
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
  late DateTime chosenDate;
  DateTime startDate = DateTime(2025, 5, 7);
  final myController= TextEditingController();//for input
  final formkey = GlobalKey<FormState>();//for forms
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
          // @override
          body:
          //@override
          Container(
         /*   decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 231, 125, 160),
                const Color.fromARGB(255, 248, 87, 140),
                const Color.fromARGB(255, 247, 199, 215)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
          */
          child: Row( 
            children: <Widget> [ 

           Align( //Menu options
          alignment: Alignment.centerLeft,
          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () { 
                //date=myController.text.trim();
                //add(date);
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
            Center(
                //alignment: Alignment.center,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                      //onTap: (){
                        //date=myController.text.trim();
                        
                     // },
                      ),
                    //),
                    ),
                    SizedBox(
                    height: 30,
                    width: 30,

                    //_DatePickerItem(
                     //child: CupertinoButton(
                       //   onPressed: (){
                          //  showCupertinoModalPopup(
                            //  context: context,
                              //builder: (BuildContext context) => SizedBox(
                           //     width: 100,
                         child: 
                         CupertinoDatePicker(
                          initialDateTime: startDate,
                          onDateTimeChanged: (DateTime chosenDate){ setState(()=> startDate = chosenDate);},
                          use24hFormat: true,
                          mode: CupertinoDatePickerMode.date,
                       //  ),
                         //     ),
                         // );     
                        //add(chosenDate);
                          //}, //child: null,                   
                  ),
                    ),
                    //),
                  Text('Name'),
                    Form(
                      key: formkey,
                    child: Column(
                    children: [
                    TextFormField(
                    validator: (value) {
                        if(value==null){ return null;}
                        //if(value!=null)
                        else
                        {print(value);}
                      },
                      decoration: InputDecoration(border: OutlineInputBorder(),
                      hintText: 'Input',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      
                    ),
                    ),
                    //for testing
                    ElevatedButton(
                        onPressed: (){
                        if(formkey.currentState!.validate())
                        {Text('Stored!');}
                      }, 
                      child: Text("Confirm"),
                      )
                    ],
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
        //    ),
         // ),
          ),
      );
 //To clean up controller
 //date.dispose();
 //super.dispose();     
  }
}
