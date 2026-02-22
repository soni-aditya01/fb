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

              return FutureBuilder<String>(
                future: getFriendName(friendId),
                initialData: names[friendId],
                builder: (context, asyncSnapshot) {
                  // Fixed: Height set to 72 to match ListTile; better state checking
                  if (asyncSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      !asyncSnapshot.hasData) {
                    return const SizedBox(height: 72);
                  }

                  String friendName = asyncSnapshot.data ?? 'Unknown User';

                  return ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(
                          chatId: chatDoc.id,
                          friendId: friendId,
                          friendName: friendName,
                        ),
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.shade100,
                      child: Text(
                        friendName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      friendName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                },
              );
            },
          );
        },
      ),
    );
  }
}
