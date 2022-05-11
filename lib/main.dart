import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late GoogleMapController mapController;

  final Map<String, Marker> _markers = {};
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      addUserMarker('123', LatLng(-15.834971, -47.912889), 'juca', true);
    });
  }

  LatLng currentPostion = LatLng(-15.834971, -47.912889);

  void _getUserCurrentLocation() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();
    currentPostion = LatLng(position.latitude, position.longitude);
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  void addUserMarker(String id, LatLng pos, String username, bool newsType) {
    String text;
    if (newsType) {
      text = "This user found a true news!";
    } else {
      text = "This user found a fake news!";
    }

    final newUserMarker = Marker(
        markerId: MarkerId(id),
        position: pos,
        infoWindow: InfoWindow(
          title: username,
          snippet: text,
        ));

    _markers[id] = newUserMarker;
  }

  void addUserCurrentLocation(String id, String username, bool newsType) async {
    _getUserCurrentLocation();
    debugPrint("hello");
    addUserMarker(id, currentPostion, username, newsType);
  }

  static final CameraPosition _iesbLocation = CameraPosition(
    target: LatLng(-15.834971, -47.912889),
    zoom: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        mapType: MapType.normal,
        initialCameraPosition: _iesbLocation,
        markers: _markers.values.toSet(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            addUserCurrentLocation("1", "snowAttano", true);
          });
        },
        label: Text('Add your location!'),
        icon: Icon(Icons.map_outlined),
      ),
    );
  }
}
