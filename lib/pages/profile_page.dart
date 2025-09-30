import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../components/text_box.dart';
import 'startUp_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Method to pick an image from gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();

    // Pick an image from gallery or take a new photo
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final file = File(image.path);
      try {
        // Upload the image to Firebase Storage
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child(currentUser.email! + '.jpg');

        await ref.putFile(file);

        // Get the URL of the uploaded image
        String imageUrl = await ref.getDownloadURL();

        // Update the user's profile picture in Firestore
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.email)
            .update({'profilePicture': imageUrl});

        setState(() {}); // Refresh the UI to show new profile picture
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  // Method to edit user fields like username, birthday, etc.
  Future<void> editField(String field) async {
    String newValue = "";
    TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Edit $field",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.pink[400],
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Colors.grey[600]),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.pink[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection("Users")
                    .doc(currentUser.email)
                    .update({field: newValue});
              }
              Navigator.pop(context); // close dialog
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.pink),
            ),
          ),
        ],
      ),
    );
  }

  // Method to log out the user
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage()), // Navigate directly to LoginPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light background for the page
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.pink[100], // Light pink app bar
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: logout, // Logout when button is pressed
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              children: [
                SizedBox(height: 30),
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.pink[100],
                    backgroundImage: userData['profilePicture'] != null
                        ? NetworkImage(userData[
                            'profilePicture']) // If profile picture exists, show it
                        : null, // No background image if there's no profile picture
                    child: GestureDetector(
                      onTap: _pickImage, // Allow the user to pick a new image
                      child: userData['profilePicture'] == null
                          ? Icon(
                              Icons.person,
                              size: 70,
                              color: Colors.white,
                            ) // Default icon if no profile picture
                          : null, // No icon if profile picture exists
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  currentUser.email!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Details',
                    style: TextStyle(color: Colors.pink[300], fontSize: 18),
                  ),
                ),
                SizedBox(height: 20),
                // Username Field
                MyTextBox(
                  text: userData['username'],
                  sectionName: 'username',
                  onPressed: () => editField('username'),
                ),
                // Birthday Field
                MyTextBox(
                  text: userData['birthday'],
                  sectionName: 'birthday',
                  onPressed: () => editField('birthday'),
                ),
                // Bio Field
                MyTextBox(
                  text: userData['bio'],
                  sectionName: 'bio',
                  onPressed: () => editField('bio'),
                ),
                SizedBox(height: 30),
                // Logout Button at the bottom of the screen
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: ElevatedButton(
                    onPressed: logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[300], // Pink button color
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 50),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
