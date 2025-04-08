// this is the login/ account creation homepage
//import 'package:firstly/pages/log.dart';
//import 'package:firstly/pages/temp_page.dart';
import 'package:flutter/material.dart';
import 'main_navigation.dart';
import 'log_in_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.lock, size: 100),
              const Text(
                'Welcome to FreshStart',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const Spacer(), // pushing the login and create account buttons down
              // Login Button (for now, it does nothing)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyLoginPage(title: 'Log In'),
                    ),
                  );
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),

              // Create Account Button (Navigates to MyHomePage)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MyCreateAccount(title: 'Create Account'),
                    ),
                  );
                },
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainNavigation(),
                    ),
                  );
                },
                child: const Text('Homepage'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class MyCreateAccount extends StatefulWidget {
  //create account widget
  const MyCreateAccount({super.key, required this.title});

  final String title;

  @override
  State<MyCreateAccount> createState() => _MyCreateAccount();
}

class _MyCreateAccount extends State<MyCreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account Created Successfully!'),
        ), // message if all paramaters are met
      );

      // Navigate back to Login Page after success
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[300], // rest of the screen bg color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 12),

              // DOB Field
              TextFormField(
                controller: _birthdayController,
                decoration: const InputDecoration(
                  labelText: 'DOB',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your DOB' : null,
              ),
              const SizedBox(height: 12),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
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
                decoration: const InputDecoration(
                  labelText: 'Password',
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
              // const Spacer(), push the create account button to the bottom, javent decided if i like it or not
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Create Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
