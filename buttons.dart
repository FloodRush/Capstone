import 'package:flutter/material.dart';

class UI extends StatelessWidget{
  const UI ({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Journal',  
        home: ElevatedButton(
        child: Text('ADD'),
        onPressed: () {print('Test');},
        ));
    
  }
  }
  