import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fb/screens/chatRoom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  FirebaseFirestore instance = FirebaseFirestore.instance;
  late Future<QuerySnapshot> future;
  void initState(){
    super.initState();
    future = instance.collection('users').where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alter'),
      backgroundColor: Color(0xff2196f3),
      actions: [
        IconButton(onPressed: (){}, icon: Icon(Icons.search))
      ],
      ),
      body: SafeArea(child: FutureBuilder(future: future, 
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if(snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        var users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index){
            var user = users[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(child: Text(user['name'][0])),
              title: Text(user['name']),
              subtitle: Text(user['email']),
              onTap: () {
                String uid= FirebaseAuth.instance.currentUser!.uid;
                String friendId = user['uid'];

                List<String> participants = [uid, friendId];
                participants.sort(); 
                String chatId = participants.join('_');
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoomScreen(chatId: chatId, friendId: friendId, friendName: user['name'],)));
              },
            );
          },
        );
      })),
    );
  }
}