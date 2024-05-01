import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pothole_app/page/user/user_main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'user_history.dart';
import 'user_maps.dart';
import 'user_profile.dart';

import 'package:image_picker/image_picker.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  // logout
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  int currentTab = 0;
  final List<Widget> screens = [
    const UserMain(),
    const UserMaps(),
    const UserHistory(),
    const UserProfile(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const UserMain();

  Future<void> captureImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      Position position = await Geolocator.getCurrentPosition();
      Location selectedLocation = Location(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );
      String potholeId = await saveImageToStorage(image, selectedLocation);

      await uploadImage(image, potholeId);
    }
  }

  Future<void> uploadImage(XFile image, String potholeId) async {
    final stopwatch = Stopwatch()..start();
    final request = http.MultipartRequest("POST",
        Uri.parse("https://flask-server-42sfapbrda-as.a.run.app/predict"));
    final headers = {"Content-type": "multipart/form-data"};

    request.files.add(http.MultipartFile(
        'image', image.readAsBytes().asStream(), await image.length(),
        filename: image.path.split("/").last));
    request.headers.addAll(headers);

    final response = await request.send();
    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final resJson = jsonDecode(res.body);
      await saveJsonToFirestore(resJson, potholeId);
    }
    stopwatch.stop(); // Stop the stopwatch when the response is received
    print(
        'HTTP request completed in ${stopwatch.elapsedMilliseconds} milliseconds');
  }

  Future<void> saveJsonToFirestore(
      Map<String, dynamic> jsonData, String potholeId) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('potholes')
        .doc(potholeId)
        .update(jsonData);
  }

  Future<String> saveImageToStorage(
      XFile image, Location selectedLocation) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    String imageName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    String filePath = 'user_images/$userId/$imageName';

    FirebaseStorage storage = FirebaseStorage.instance;
    TaskSnapshot snapshot =
        await storage.ref(filePath).putFile(File(image.path));
    String imageUrl = await snapshot.ref.getDownloadURL();

    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('potholes')
        .add({
      'imageUrl': imageUrl,
      'location': {
        'latitude': selectedLocation.latitude,
        'longitude': selectedLocation.longitude
      },
      'createdAt': FieldValue.serverTimestamp(),
      'confidence': "loading..",
      'status': true,
    });
    return docRef.id;
  }

  Future<void> _requestLocationPermission(BuildContext context) async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {}
  }

  @override
  Widget build(BuildContext context) {
    _requestLocationPermission(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pothole Report Application",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            color: Colors.white,
          ),
        ],
      ),
      body: PageStorage(
        bucket: bucket,
        child: currentScreen,
      ),
      floatingActionButton: SizedBox(
        height: 80,
        width: 80,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: const Color.fromARGB(255, 54, 134, 220),
          onPressed: () async {
            captureImage();
          },
          elevation: 0,
          child: const Icon(
            Icons.camera_alt,
            color: Color.fromARGB(255, 255, 255, 255),
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: kBottomNavigationBarHeight + 40,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.home,
                      color: currentTab == 0 ? Colors.blue : Colors.grey),
                  onPressed: () {
                    setState(() {
                      currentScreen = const UserMain();
                      currentTab = 0;
                    });
                  },
                ),
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: Text('Home',
                      style: TextStyle(
                          color: currentTab == 0 ? Colors.blue : Colors.grey)),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.location_pin,
                      color: currentTab == 1 ? Colors.blue : Colors.grey),
                  onPressed: () {
                    setState(() {
                      currentScreen = const UserMaps();
                      currentTab = 1;
                    });
                  },
                ),
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: Text(
                    'Maps',
                    style: TextStyle(
                        color: currentTab == 1 ? Colors.blue : Colors.grey),
                  ),
                ),
              ],
            ),
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 28.0),
                  child: Text('Report Pothole',
                      style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.history,
                      color: currentTab == 3 ? Colors.blue : Colors.grey),
                  onPressed: () {
                    setState(() {
                      currentScreen = const UserHistory();
                      currentTab = 3;
                    });
                  },
                ),
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: Text('History',
                      style: TextStyle(
                          color: currentTab == 3 ? Colors.blue : Colors.grey)),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.person,
                      color: currentTab == 4 ? Colors.blue : Colors.grey),
                  onPressed: () {
                    setState(() {
                      currentScreen = const UserProfile();
                      currentTab = 4;
                    });
                  },
                ),
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: Text('Profile',
                      style: TextStyle(
                          color: currentTab == 4 ? Colors.blue : Colors.grey)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
