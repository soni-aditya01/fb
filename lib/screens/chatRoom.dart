import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String friendId;
  const ChatRoomScreen({super.key, required this.chatId, required this.friendId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController _messageController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void sendMessage() async {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2196f3),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
        title: Text(widget.friendId),    // Placeholder, ideally should show friend's name
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true) // Newest at bottom
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                // 1. Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
            
                // 2. Empty State
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Say Hi! 👋"));
                }
                return ListView.builder(
                  reverse: true, // IMPORTANT: Sticks list to bottom
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var msgData = snapshot.data!.docs[index];
                    bool isMe = msgData['senderId'] == currentUserId;
            
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          msgData['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }
                );
              }
            )
            ),
            Padding(padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: TextField(
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  )),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xff2196f3),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (_messageController.text.isNotEmpty) {
                          sendMessage();
                          _messageController.clear();
                        }
                      },
                  ))
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}