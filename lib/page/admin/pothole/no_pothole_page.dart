import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoPotholePage extends StatefulWidget {
  const NoPotholePage({super.key});

  @override
  State<NoPotholePage> createState() => _NoPotholePageState();
}

class User {
  final String id;
  final String email;
  final List<Map<String, dynamic>> potholes;

  User({
    required this.id,
    required this.email,
    required this.potholes,
  });
}

class _NoPotholePageState extends State<NoPotholePage> {
  late Future<List<User>> usersWithPotholesFuture;
  @override
  void initState() {
    super.initState();
    usersWithPotholesFuture = fetchUsersWithFalseStatusPotholes();
  }

  Future<List<String>> fetchUserEmails() async {
    final firestore = FirebaseFirestore.instance;
    final usersSnapshot = await firestore.collection('users').get();
    return usersSnapshot.docs
        .map((doc) => doc.data()['email'] as String)
        .toList();
  }

  Future<List<User>> fetchUsersWithFalseStatusPotholes() async {
    final firestore = FirebaseFirestore.instance;
    List<User> usersWithPotholes = [];

    final usersSnapshot = await firestore.collection('users').get();

    for (var userDoc in usersSnapshot.docs) {
      String email = userDoc.data()['email'] as String;
      final String userId = userDoc.id;
      List<Map<String, dynamic>> potholes = [];

      final potholesSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('potholes')
          .where('status', isEqualTo: false)
          .get();

      for (var potholeDoc in potholesSnapshot.docs) {
        potholes.add({
          'id': potholeDoc.id,
          'imageUrl': potholeDoc.data()['imageUrl'] as String,
          'status': potholeDoc.data()['status'] as bool,
          'confidence': potholeDoc.data()['confidence'] as String,
        });
      }

      if (potholes.isNotEmpty) {
        usersWithPotholes
            .add(User(id: userId, email: email, potholes: potholes));
      }
    }

    return usersWithPotholes;
  }

  Future<void> updatePotholeStatus(
      String userId, String potholeId, bool newStatus) async {
    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection('users')
        .doc(userId)
        .collection('potholes')
        .doc(potholeId)
        .update({'status': newStatus}).then((_) {
      setState(() {
        usersWithPotholesFuture = fetchUsersWithFalseStatusPotholes();
      });
    });
  }

  Widget buildUsersList(List<User> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user.email,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: user.potholes.length,
                itemBuilder: (context, index) {
                  final pothole = user.potholes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Column(
                      children: [
                        Image.network(
                          pothole['imageUrl'],
                          width: 200,
                          height: 200,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'confidence score: ${pothole['confidence']}',
                        ),
                        ElevatedButton(
                          onPressed: () {
                            bool newStatus = !pothole['status'];
                            setState(() {
                              pothole['status'] = newStatus;
                            });
                            updatePotholeStatus(
                                user.id, pothole['id'], newStatus);
                          },
                          child: const Text(
                            'ไม่ถูกต้อง',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<User>>(
        future: usersWithPotholesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return buildUsersList(snapshot.data!);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
