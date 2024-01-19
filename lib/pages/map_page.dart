import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../interface/api.dart';
import '../utils/location_service.dart';

class MapPage extends StatefulWidget {
  final double destLatitude;
  final double destLongitude;

  const MapPage(
      {super.key, required this.destLatitude, required this.destLongitude});

  @override
  // ignore: library_private_types_in_public_api
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late LatLng? currentLocation;
  late Marker originMarker;
  late Marker destinationMarker;
  List<LatLng> points = [];

  @override
  void initState() {
    super.initState();
    _determineCurrentLocation();
  }

  Future<LatLng> _getLocation() async {
    try {
      Position position = await LocationService.determinePosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      // You can handle the error more gracefully or return a default location
      print(e);
      return const LatLng(0.0, 0.0);
    }
  }

  void _determineCurrentLocation() async {
    currentLocation = await _getLocation();
    setState(() {
      // Set up the origin marker
      originMarker = Marker(
        point: currentLocation!,
        width: 80.0,
        height: 80.0,
        child: const Icon(
          Icons.my_location,
          size: 40.0,
          color: Colors.blue,
        ),
      );

      // Set up the destination marker
      destinationMarker = Marker(
        point: LatLng(widget.destLatitude, widget.destLongitude),
        width: 80.0,
        height: 80.0,
        child: const Icon(
          Icons.location_on,
          size: 40.0,
          color: Colors.red,
        ),
      );

      // Call the API to get the route
      getCoordinates();
    });
  }

  // Method to consume the OpenRouteService API
  getCoordinates() async {
    var response = await http.get(getRouteUrl(
        "${currentLocation!.latitude},${currentLocation!.longitude}",
        "${widget.destLatitude},${widget.destLongitude}"));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var listOfPoints = data['features'][0]['geometry']['coordinates'];
      setState(() {
        points = listOfPoints
            .map((p) => LatLng(p[1].toDouble(), p[0].toDouble()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: currentLocation!,
              initialZoom: 16.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(markers: [originMarker, destinationMarker]),
              // Other layers like PolylineLayer for the route can be added here
            ],
          ),
        ],
      ),
    );
  }
}
