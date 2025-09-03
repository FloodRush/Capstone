import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Override theme for create account page to always use light theme
      data: ThemeData.light().copyWith(
        primaryColor: AppColors.hotPink,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.hotPink,
          title: Text(
            widget.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        backgroundColor: Colors.grey[300], // Rest of the screen bg color
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Field
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.black), // Ensure text is visible
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black54),
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

              // Password Field
              TextFormField(
                controller: _passwordController,
                style: TextStyle(color: Colors.black), // Ensure text is visible
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a password';
                  if (value.length < 6)
                    return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // Sign up the user using Firebase Authentication
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );

                        // Store the email in Firestore
                        await FirebaseFirestore.instance
                            .collection("Users")
                            .doc(userCredential.user!.email)
                            .set({
                          'email': userCredential.user!.email,
                          'username': _emailController.text
                              .split('@')[0], // Use part of email as username
                          'bio': "empty bio...", // Default bio
                        });

                        // Navigate to the homepage after successful signup
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MainNavigation()),
                        );
                      } on FirebaseAuthException catch (e) {
                        // Handle errors
                        print("Error during sign up: ${e.message}");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hotPink, // Set the button color here
                    foregroundColor: Colors.white, // Force white text
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Create Account'),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
