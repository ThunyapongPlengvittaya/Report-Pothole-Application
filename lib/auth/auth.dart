import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pothole_app/auth/login_or_register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pothole_app/page/admin/admin_home_page.dart';
import 'package:pothole_app/page/user/user_home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasData && userSnapshot.data!.uid.isNotEmpty) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('admins')
                  .doc(userSnapshot.data!.uid)
                  .get(),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.connectionState == ConnectionState.done) {
                  if (adminSnapshot.hasData && adminSnapshot.data!.exists) {
                    return const AdminHomePage();
                  } else {
                    return const UserHomePage();
                  }
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          } else {
            // User is not logged in
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
