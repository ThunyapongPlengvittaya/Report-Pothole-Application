import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PotholePage extends StatefulWidget {
  const PotholePage({super.key});

  @override
  State<PotholePage> createState() => _PotholePageState();
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

class _PotholePageState extends State<PotholePage> {
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

    // Fetch all users
    final usersSnapshot = await firestore.collection('users').get();

    for (var userDoc in usersSnapshot.docs) {
      String email = userDoc.data()['email'] as String;
      final String userId = userDoc.id;
      List<Map<String, dynamic>> potholes = [];

      // Fetch potholes with false status under each user
      final potholesSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('potholes')
          .where('status', isEqualTo: true)
          .get();

      for (var potholeDoc in potholesSnapshot.docs) {
        potholes.add({
          'id': potholeDoc.id,
          'imageUrl': potholeDoc.data()['imageUrl'] as String,
          'status': potholeDoc.data()['status'] as bool,
          'confidence':potholeDoc.data()['confidence'] as String,
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
      // Refresh the list to reflect the change
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
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              height: 300, // Increased height to accommodate the status text
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
                        Text(
                          pothole['status'] ? 'True' : 'False',
                        ),
                        Text(
                          'confidence score: ${pothole['confidence']}',
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // New status is the opposite of the current status
                            bool newStatus = !pothole['status'];
                            setState(() {
                              pothole['status'] = newStatus;
                            });
                            // Call the method to update the status in Firestore
                            updatePotholeStatus(
                                user.id, pothole['id'], newStatus);
                          },
                          child: Text('ตรวจ/แก้ แล้ว'),
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
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
