import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  FirebaseFirestore instance = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alter'),
      backgroundColor: Color(0xff2196f3),
      actions: [
        IconButton(onPressed: (){}, icon: Icon(Icons.search))
      ],
      ),
      body: SafeArea(child: FutureBuilder(future: future, builder: builder)),
    );
  }
}