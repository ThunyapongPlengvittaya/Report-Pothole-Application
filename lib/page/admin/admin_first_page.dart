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
    _loadIconsAndFetchPotholes();
  }

  Future<void> _loadIcons() async {
    potholeIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/pothole_icon.png',
    );
    noPothole = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/location.png',
    );
  }

  Future<void> _loadIconsAndFetchPotholes() async {
    await _loadIcons();
    await _fetchAllPotholeLocationsAndDisplay();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _fetchAllPotholeLocationsAndDisplay() async {
    FirebaseFirestore.instance
        .collectionGroup('potholes')
        .get()
        .then((querySnapshot) {
      Set<Marker> newMarkers = {};
      for (var potholeDoc in querySnapshot.docs) {
        Map<String, dynamic> potholeData =
            potholeDoc.data() as Map<String, dynamic>;
        LatLng potholeLocation = LatLng(
          potholeData['location']['latitude'],
          potholeData['location']['longitude'],
        );
        BitmapDescriptor icon =
            potholeData['status'] == true ? noPothole! : potholeIcon!;

        Marker marker = Marker(
          markerId: MarkerId(potholeDoc.id),
          position: potholeLocation,
          icon: icon,
          // infoWindow: InfoWindow(
          //   title: potholeData['status'] == true ? 'No Pothole' : 'Pothole',
          //   snippet: 'Reported on: ${potholeData['createdAt']}',
          // ),
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
        initialCameraPosition: CameraPosition(
          target: const LatLng(14.0731, 100.6098), // Central position
          zoom: 11.0,
        ),
      ),
    );
  }
}
