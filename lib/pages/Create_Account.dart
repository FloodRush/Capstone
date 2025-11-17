import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; //Added by me
import '../theme.dart';
import '../services/auth_service.dart';
import 'main_navigation.dart';

class MyCreateAccount extends StatefulWidget {
  // Create account widget
  const MyCreateAccount({super.key, required this.title});

  final String title;

  @override
  State<MyCreateAccount> createState() => _MyCreateAccount();
}

class _MyCreateAccount extends State<MyCreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  //Added by me
  String generateID() {
    var id = Uuid();
    return id.v4();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: appGradientBackground(), // same as LoginPage
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_add,
                        size: 100, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text(
                      'Create Your FreshStart Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter your email';
                        if (!RegExp(
                          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                        ).hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Username Field
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a display name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Birthday Field
                    TextFormField(
                      controller: _birthdayController,
                      readOnly: true,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        labelText: 'Birthday',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                              initialDate: DateTime(2007),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                         if (pickedDate != null) {
                          _birthdayController.text =
                              pickedDate.toLocal().toString().split(' ')[0];
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your birthday';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter a password';
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Create Account Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .createUserWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                              var myId = generateID();
                              await FirebaseFirestore.instance
                                  .collection("Users")
                                  .doc(userCredential.user!.email)
                                  .set({
                                'email': userCredential.user!.email,
                                'username': _usernameController.text,
                                'bio': "empty bio...",
                                'id': myId,
                                'birthday': _birthdayController.text,
                              });
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainNavigation(),
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              print("Error during sign up: ${e.message}");
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Create Account'),
                      ),
                    ),

                    const SizedBox(height: 10),
                    // Login Redirect Button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Already have an account? Log in.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
