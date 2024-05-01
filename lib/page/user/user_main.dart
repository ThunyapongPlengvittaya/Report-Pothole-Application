import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserMain extends StatefulWidget {
  const UserMain({super.key});

  @override
  State<UserMain> createState() => _UserMainPageState();
}

class Pothole {
  final String id;
  final String imageUrl;
  final bool status;
  final double latitude;
  final double longitude;
  final String confidence;

  Pothole({
    required this.id,
    required this.imageUrl,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.confidence,
  });
}

class _UserMainPageState extends State<UserMain> {
  final List<Pothole> _potholes = [];

  @override
  void initState() {
    super.initState();
    getUserPotholes();
  }

  Future<void> getUserPotholes() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;
    if (user != null) {
      final String uid = user.uid;
      //รูปจาก user ทั้งหมด
      final potholesSnapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('potholes')
          .get();

      // เอาไปใส่ใน _potholes List
      final List<Pothole> newPotholes = potholesSnapshot.docs.map((doc) {
        final data = doc.data();
        final locationData = data['location'] as Map<String, dynamic>;
        return Pothole(
          id: doc.id,
          imageUrl: data['imageUrl'] as String,
          status: data['status'] as bool,
          latitude: locationData['latitude'] as double,
          longitude: locationData['longitude'] as double,
          confidence: data['confidence'] as String,
        );
      }).toList();

      newPotholes.sort((a, b) => a.status ? 1 : -1);

      setState(() {
        _potholes.clear();
        _potholes.addAll(newPotholes);
      });
    }
  }

  Widget buildPotholeSection(List<Pothole> potholes, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: potholes.length,
            itemBuilder: (context, index) {
              final pothole = potholes[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  children: [
                    Image.network(
                      pothole.imageUrl,
                      width: 200,
                      height: 200,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            'Lat: ${pothole.latitude.toStringAsFixed(4)}, Lng: ${pothole.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Confidence Score: ${pothole.confidence}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
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
  }

  @override
  Widget build(BuildContext context) {
    List<Pothole> trueStatusPotholes =
        _potholes.where((p) => p.status).toList();
    List<Pothole> falseStatusPotholes =
        _potholes.where((p) => !p.status).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await getUserPotholes();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (trueStatusPotholes.isNotEmpty)
                buildPotholeSection(trueStatusPotholes, 'Have Potholes'),
              const SizedBox(height: 5),
              if (falseStatusPotholes.isNotEmpty)
                buildPotholeSection(falseStatusPotholes, 'No Potholes'),
            ],
          ),
        ),
      ),
    );
  }
}
