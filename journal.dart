import 'package:flutter/material.dart';
//add function to make new journal entries
void add(){
print('ADD'); //button testing
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
  @override
  Widget build(BuildContext context){
    //var text = Text('Journal');
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Journal'),
          ),  
          body: 
          //children: [ 
          const Align( //Menu options
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: add,
                child: Text('ADD'),
              ),
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
  //Journal entry
        //TextField(
          //decoration: const InputDecoration(
        //  border: UnderlineInputBorder(),
      //    labelText: 'Share whatever you like',
    //        ),
          //],
        ),
      ),     
    );    
  }
}