import 'package:fb/auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  bool _isloading = false;
  final _formKey = GlobalKey<FormState>();

  void signUp() async{
    if(_formKey.currentState!.validate()){
      setState(() {
        _isloading = true;});
        try{
          await Auth().signUpWithEmailPassword(
            emailController.text, passwordController.text, nameController.text);
            Navigator.pop(context);
        } catch(e){
          if(context.mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        } finally {
          setState(() {
            _isloading = false;
          });
        }
      };
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2196f3),
      body:SafeArea(child:Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  validator: (value)=> value == null || value.isEmpty ? 'Please enter your name' : null
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
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
                  controller: passwordController,
                  obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a password' : null
                ),
                TextFormField(
                  controller: confirmpasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  validator: (value) => value != passwordController.text?'Passwords do not match':null
                ),
                SizedBox(height: 24.0),
                ElevatedButton( 
                  onPressed: signUp,
                  child: _isloading? CircularProgressIndicator(): Text('Sign Up')
                )
              ],
            ),
          ),
        ),
      ))
    );
  }
}
