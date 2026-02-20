import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fb/screens/chatRoom.dart';
import 'package:fb/screens/newChat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NewChatScreen())),
        backgroundColor: const Color(0xff2196f3),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No chats found',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var chatDoc = snapshot.data!.docs[index];
              var chatData = chatDoc.data() as Map<String, dynamic>;

              // LOGIC: Find the "Other Person's" ID
              // The 'participants' array has 2 IDs. We filter out ours to find the friend's.
              List participants = chatData['participants'];
              String friendId = participants.firstWhere(
                (id) => id != currentUserId,
              );

              // TODO: Ideally, you would fetch the friend's Name/Image using this friendId.
              // For now, we will display the ID or a placeholder.

              return ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ChatRoomScreen(chatId: chatDoc.id, friendId: friendId),
                  ),
                ),
                // Profile Pic
                leading: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),

                // Name (Showing ID for now, until we link Users collection)
                title: Text(
                  "User: ...${friendId.substring(0, 5)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                // Last Message
                subtitle: Text(
                  chatData['lastMessage'] ?? "No messages yet",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Time (Simple placeholder logic)
                trailing: Text(
                  "Now", // We will format the Timestamp object later
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
