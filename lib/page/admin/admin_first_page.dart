import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminFirstPage extends StatefulWidget {
  const AdminFirstPage({super.key});

  @override
  State<AdminFirstPage> createState() => _AdminFirstPageState();
}

class _AdminFirstPageState extends State<AdminFirstPage> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  BitmapDescriptor? potholeIcon;
  BitmapDescriptor? noPothole;

  @override
  void initState() {
    super.initState();
    loadIconsAndFetchPotholes();
  }

  Future<void> loadIcons() async {
    potholeIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/pothole_icon.png',
    );
    noPothole = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/location.png',
    );
  }

  Future<void> loadIconsAndFetchPotholes() async {
    await loadIcons();
    await displayPothole();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> displayPothole() async {
    FirebaseFirestore.instance
        .collectionGroup('potholes')
        .get()
        .then((querySnapshot) {
      Set<Marker> newMarkers = {};
      for (var potholeDoc in querySnapshot.docs) {
        Map<String, dynamic> potholeData = potholeDoc.data();
        LatLng potholeLocation = LatLng(
          potholeData['location']['latitude'],
          potholeData['location']['longitude'],
        );
        BitmapDescriptor? icon =
            potholeData['status'] == true ? potholeIcon : noPothole;

        Marker marker = Marker(
          markerId: MarkerId(potholeDoc.id),
          position: potholeLocation,
          icon: icon!,
        );

        newMarkers.add(marker);
      }

      setState(() {
        _markers = newMarkers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        initialCameraPosition: const CameraPosition(
          target: LatLng(14.0731, 100.6098),
          zoom: 11.0,
        ),
      ),
    );
  }
}
