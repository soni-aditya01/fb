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
  late Stream<QuerySnapshot> _stream;
  final Map<String, String> names = {};
  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  Widget _buildChatTile(String chatId, String friendId, String friendName, Map<String, dynamic> chatData) {
  return ListTile(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          chatId: chatId,
          friendId: friendId,
          friendName: friendName,
        ),
      ),
    ),
    leading: CircleAvatar(
      backgroundColor: Colors.blueAccent.shade100,
      child: Text(
        friendName[0].toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    title: Text(friendName, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(
      chatData['lastMessage'] ?? "No messages yet",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: Text(
      formatTimeOrDate(chatData['lastTimestamp']),
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    ),
  );
}

  Future<String> getFriendName(String uid) async {
    // Check memory first (0 reads)
    if (names.containsKey(uid)) {
      return names[uid]!;
    }

    // Not in memory? Ask Firebase (1 read)
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      String name = data['name'] ?? 'Unknown User';

      // Save it to memory for next time
      names[uid] = name;
      return name;
    }
    return 'Unknown User';
  }

  String formatTimeOrDate(Timestamp? timestamp) {
    if (timestamp == null) return "";

    // 1. Convert Firebase Timestamp to Dart DateTime
    DateTime messageTime = timestamp.toDate();
    DateTime now = DateTime.now();

    // 2. Check if the message was sent today
    bool isToday =
        now.year == messageTime.year &&
        now.month == messageTime.month &&
        now.day == messageTime.day;

    if (isToday) {
      // 3. IF TODAY: Return Time (e.g., "14:30")
      String hour = messageTime.hour.toString().padLeft(2, '0');
      String minute = messageTime.minute.toString().padLeft(2, '0');
      return "$hour:$minute";
    } else {
      // 4. IF OLDER: Return Date (e.g., "22/02")
      String day = messageTime.day.toString().padLeft(2, '0');
      String month = messageTime.month.toString().padLeft(2, '0');
      return "$day/$month";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewChatScreen()),
        ),
        backgroundColor: const Color(0xff2196f3),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
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
            itemExtent: 72.0,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
  var chatDoc = snapshot.data!.docs[index];
  var chatData = chatDoc.data() as Map<String, dynamic>;

  List participants = chatData['participants'];
  String friendId = participants.firstWhere((id) => id != currentUserId);

  // --- THE MASTER FIX: SHORT-CIRCUIT ---
  // 1. Check the cache MANUALLY first.
  if (names.containsKey(friendId)) {
    // If we have it, return the ListTile DIRECTLY. 
    // No Builder = No Waiting Frame = NO FLICKER.
    return _buildChatTile(chatDoc.id, friendId, names[friendId]!, chatData);
  }

  // 2. Only use FutureBuilder if the name is truly missing from memory.
  return FutureBuilder<String>(
    future: getFriendName(friendId),
    builder: (context, asyncSnapshot) {
      if (!asyncSnapshot.hasData) {
        return const SizedBox(height: 72); 
      }
      return _buildChatTile(chatDoc.id, friendId, asyncSnapshot.data!, chatData);
    },
  );
},
          );
        },
      ),
    );
  }
}
