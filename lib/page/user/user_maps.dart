import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
    _loadPotholeIcon();
    _fetchPotholeLocationsAndDisplay();
  }

  Future<void> _loadPotholeIcon() async {
    potholeIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.2),
      'assets/pothole_icon.png',
    );
    noPothole = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.2),
      'assets/location.png',
    );
  }

  Future<void> _fetchPotholeLocationsAndDisplay() async {
    String userId =
        FirebaseAuth.instance.currentUser!.uid; // Get current user ID

    // Fetch pothole locations for the current user
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('potholes')
        .get()
        .then((querySnapshot) {
      Set<Marker> newMarkers = {};
      for (var pothole in querySnapshot.docs) {
        Map<String, dynamic> data = pothole.data() as Map<String, dynamic>;
        LatLng potholeLocation = LatLng(
          data['location']['latitude'],
          data['location']['longitude'],
        );
        BitmapDescriptor icon =
            data['status'] == true ? noPothole! : potholeIcon!;

        Marker marker = Marker(
          markerId: MarkerId(pothole.id),
          position: potholeLocation,
          icon: icon,
          // infoWindow: InfoWindow(
          //   title: 'Pothole Reported',
          //   snippet: 'Reported on: ${data['createdAt']}',
          // ),
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
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
