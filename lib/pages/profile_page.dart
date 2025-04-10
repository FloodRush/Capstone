import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> editField(String field) async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Welcome to the Profile Page')),
        body: ListView(
          children: [
            SizedBox(height: 50),
            Icon(
              Icons.person,
              size: 72,
            ),
            Text(
              currentUser.email!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Text(
                'My details',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            MyTextBox(
              text: 'Test Subject',
              sectionName: 'username',
              onPressed: () => editField('username'),
            ),
            MyTextBox(
              text: 'Empty Bio',
              sectionName: 'bio',
              onPressed: () => editField('bio'),
            ),
            SizedBox(height: 50),
          ],
        ));
  }
}
