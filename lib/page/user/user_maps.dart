import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserMaps extends StatefulWidget {
  const UserMaps({super.key});

  @override
  State<UserMaps> createState() => _UserMapsState();
}

class _UserMapsState extends State<UserMaps> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  BitmapDescriptor? potholeIcon;
  BitmapDescriptor? noPothole;

  @override
  void initState() {
    super.initState();
    loadPotholeIcon();
    displayPothole();
  }

  Future<void> loadPotholeIcon() async {
    potholeIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.2),
      'assets/pothole_icon.png',
    );
    noPothole = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.2),
      'assets/location.png',
    );
  }

  Future<void> displayPothole() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('potholes')
        .get()
        .then((querySnapshot) {
      Set<Marker> newMarkers = {};
      for (var pothole in querySnapshot.docs) {
        Map<String, dynamic> data = pothole.data();
        LatLng potholeLocation = LatLng(
          data['location']['latitude'],
          data['location']['longitude'],
        );
        BitmapDescriptor icon =
            data['status'] == true ? potholeIcon! : noPothole!;

        Marker marker = Marker(
          markerId: MarkerId(pothole.id),
          position: potholeLocation,
          icon: icon,
        );
        newMarkers.add(marker);
      }
      setState(() {
        _markers = newMarkers;
      });
    });
  }

  final LatLng _center = const LatLng(14.0731, 100.6098);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(255, 11, 67, 171),
      ),
      home: Scaffold(
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
        ),
      ),
    );
  }
}
