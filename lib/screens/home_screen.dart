import 'package:fb/screens/chatScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff2196f3),
          title: Text('Alter'),
          actions: [
            IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: PageView(
          controller: pageController,
          onPageChanged: (index) {
            setState(() {
              _page = index;
            });
          },
          children: [
            Center(child: ChatScreen()),
            Center(child: Text('Confessions Screen')),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _page,
          backgroundColor: const Color(0xff2196f3),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black38,
          onTap: (int index) {
            pageController.jumpToPage(index);
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.theater_comedy),
              label: 'Confessions',
            ),
          ],
        ),
      ),
    );
  }
}
