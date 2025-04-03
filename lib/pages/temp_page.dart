// this is the homepage
import 'package:firstly/pages/journal.dart';
import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text(
          'Welcome to FreshStart',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ), //appbar color
      backgroundColor: Colors.grey[300], // rest of the screen bg color
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Main()),
                  );
                },
                child: const Text('Journal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
