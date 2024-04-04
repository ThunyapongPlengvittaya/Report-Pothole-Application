import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsLocation extends StatefulWidget {
  const GoogleMapsLocation({Key? key}) : super(key: key);

  @override
  State<GoogleMapsLocation> createState() => _GoogleMapsLocationState();
}

class _GoogleMapsLocationState extends State<GoogleMapsLocation> {
  late GoogleMapController googleMapController;
  LatLng? selectedLocation;

  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(14.0731, 100.6098),
    zoom: 15,
  );

  Set<Marker> markers = {};

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

  void _onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      selectedLocation = location;
      markers.clear();
      markers.add(Marker(
        markerId: const MarkerId('selectedLocation'),
        position: location,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Pothole Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        onMapCreated: _onMapCreated,
        onTap: _onMapTapped,
        markers: markers,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        zoomControlsEnabled: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Position position = await _determinePosition();
          LatLng currentLatLng = LatLng(position.latitude, position.longitude);
          _onMapTapped(currentLatLng);
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: currentLatLng,
                zoom: 19,
              ),
            ),
          );
        },
        label: const Text('Current Location'),
        icon: const Icon(Icons.gps_fixed),
      ),
      bottomNavigationBar: SizedBox(
        height: 60.0,
        child: ElevatedButton(
          onPressed: () {
            if (selectedLocation != null) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Location Selected'),
                    content: const Text(
                        'The location selected.'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          // Close the dialog and pop the screen
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.pop(context,
                              selectedLocation); // Pop the screen with the selected location
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              // Handle the case where no location is selected
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('select a location')),
              );
            }
          },
          style:
              ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
          child: const Text('OK'),
        ),
      ),
    );
  }
}
