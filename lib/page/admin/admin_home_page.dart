import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pothole_app/page/admin/admin_first_page.dart';
import 'package:pothole_app/page/admin/admin_second_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text("Signed out.")),
      ),
    );
  }

  int currentTab = 1;
  final List<Widget> screens = [
    const AdminFirstPage(),
    const AdminSecondPage(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const AdminFirstPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: screens[currentTab],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.redAccent,
        onTap: (index) {
          setState(() {
            currentTab = index;
          });
        },
        currentIndex: currentTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.share_location,
            ),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.insert_photo,
            ),
            label: 'All Photo',
          ),
        ],
      ),
    );
  }
}
