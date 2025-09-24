 import 'package:flutter/material.dart';
import '../theme.dart';
import 'main_navigation.dart';
import 'Create_Account.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(platformBrightness: Brightness.light),
      child: Theme(
        data: ThemeData.light().copyWith(
          useMaterial3: false,
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.black,
            selectionColor: Colors.black26,
            selectionHandleColor: Colors.black,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.black54),
            floatingLabelStyle: TextStyle(color: Colors.black87),
            hintStyle: TextStyle(color: Colors.black45),
            prefixIconColor: Colors.black54,
            suffixIconColor: Colors.black54,
          ),
          textTheme: ThemeData.light().textTheme.apply(
                bodyColor: Colors.black,
                displayColor: Colors.black,
              ),
        ),
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: appGradientBackground(),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  // prevent overflow on small screens
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock, size: 100, color: Colors.white),
                          const SizedBox(height: 20),
                          const Text(
                            'Welcome back to FreshStart!',
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
                            keyboardAppearance: Brightness.light,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              // filled/border provided by theme
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
                            style: const TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            keyboardAppearance: Brightness.light,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              // filled/border provided by theme
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

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await AuthService().signin(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    context: context,
                                  );
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
                              child: const Text('Log In'),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Create Account Button
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyCreateAccount(
                                      title: 'Create Account'),
                                ),
                              );
                            },
                            child: const Text(
                              'Don’t have an account? Create one!',
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
          ),
        ),
      ),
    );
  }
}
