import 'package:fb/auth.dart';
import 'package:fb/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 1. Create a GlobalKey to identify this specific form
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isloading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loginUser() async {
    if(_formKey.currentState!.validate()){
      setState(() {
        _isloading = true;
      });
      try {
      User user=await Auth().signInWithEmailAndPassword(
        emailController.text, passwordController.text);


      setState(() {
        _isloading = false;
      });
      } catch (e) {
        setState(() {
          _isloading = false;
        });
        if(context.mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2196f3),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // 2. Wrap your Column in a Form widget
            child: Form(
              key: _formKey, // Assign the key here
              child: Column(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    controller: emailController,
                    decoration: const InputDecoration(hintText: "Email", hintStyle: TextStyle(color: Colors.white)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email'; // The error message
                      }
        
                      bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value);
        
                      if (!emailValid) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    controller: passwordController,
                    obscureText: true, 
                    decoration: const InputDecoration(hintText: "Password", hintStyle: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _isloading ? null :
                      loginUser();
                    },
                    child: _isloading ? const CircularProgressIndicator(color: Colors.white) : const Text("Login"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
                    },
                    child: const Text("Don't have an account? Sign Up", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
