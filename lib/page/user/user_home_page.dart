import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pothole_app/page/user/report/google_maps_location.dart';
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
    UserMain(),
    UserMaps(),
    UserHistory(),
    UserProfile(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = UserMain();

  Future<void> captureImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      //ไปหน้า googlemaps
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GoogleMapsLocation()),
      );

      if (result != null) {
        LatLng selectedLatLng = result as LatLng;
        Location selectedLocation = Location(
          latitude: selectedLatLng.latitude,
          longitude: selectedLatLng.longitude,
          timestamp: DateTime.now(),
        );
        String potholeId = await _saveImageToStorage(image, selectedLocation);
    
        await uploadImage(image, potholeId);
      }
    }
  }
  
  Future<void> uploadImage(XFile image, String potholeId) async {
    final request = http.MultipartRequest(
      "POST", Uri.parse("https://flask-server-42sfapbrda-as.a.run.app/predict"));
    final headers = {"Content-type": "multipart/form-data"};

    request.files.add(http.MultipartFile(
      'image',
      image.readAsBytes().asStream(),
      await image.length(),
      filename: image.path.split("/").last
    ));
    request.headers.addAll(headers);

    //send POST request
    final response = await request.send();
    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final resJson = jsonDecode(res.body);
      await _saveJsonDataToFirestore(resJson, potholeId);
    }
  }

  Future<void> _saveJsonDataToFirestore(Map<String, dynamic> jsonData, String potholeId) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  String userId = currentUser?.uid ?? 'defaultUserId';

  await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('potholes')
    .doc(potholeId) 
    .update(
      jsonData 
    );
  }


  Future<String> _saveImageToStorage(
      XFile image, Location selectedLocation) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String userId = currentUser?.uid ?? 'defaultUserId';
    String imageName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    String filePath = 'user_images/$userId/$imageName';

    FirebaseStorage storage = FirebaseStorage.instance;
    TaskSnapshot snapshot = await storage.ref(filePath).putFile(File(image.path));
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
        // Other data like status, etc.
      'createdAt': FieldValue.serverTimestamp(),
      'confidence': "loading.. please wait",
      'status': true,
      });
    return docRef.id;
  }

  Future<void> _requestLocationPermission(BuildContext context) async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Handle denied permission
    } else if (permission == LocationPermission.deniedForever) {
      // Handle permanently denied permission
    } else {
      // Permission granted, navigate to next page or perform further actions
    }
  }

  @override
  Widget build(BuildContext context) {
    _requestLocationPermission(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Pothole Report Application"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      floatingActionButton: SizedBox(
        height: 80,
        width: 80,
        child: FloatingActionButton(
          onPressed: () async {
            captureImage();
          },
          child: Icon(
            Icons.camera_alt,
            size: 30,
          ),
          elevation: 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
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
                      currentScreen = UserMain();
                      currentTab = 0;
                    });
                  },
                ),
                Transform.translate(
                  offset: const Offset(0, -8),
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
                      currentScreen = UserMaps();
                      currentTab = 1;
                    });
                  },
                ),
                Transform.translate(
                  offset: const Offset(0, -8),
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
                  padding: EdgeInsets.only(top: 40.0),
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
                      currentScreen = UserHistory();
                      currentTab = 3;
                    });
                  },
                ),
                Transform.translate(
                  offset: const Offset(0, -8),
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
                      currentScreen = UserProfile();
                      currentTab = 4;
                    });
                  },
                ),
                Transform.translate(
                  offset: const Offset(0, -8),
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
