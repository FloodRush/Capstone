import 'package:flutter/material.dart';

class MotivationPage extends StatelessWidget {
  const MotivationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Motivation Quotes')),
      body: Center(child: Text('Welcome to the Motivation Quotes Page')),
    );
  }
}
