import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';

import '../interface/api.dart';
import '../utils/location_service.dart';
import '../utils/pedometer_service.dart';

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
  LatLng? currentLocation;
  late Marker originMarker;
  late Marker destinationMarker;
  List<LatLng> points = [];
  int stepCount = 0;
  StreamSubscription<StepCount>? _stepCountSubscription;
  final PedometerService _pedometerService = PedometerService();

  @override
  void initState() {
    super.initState();
    _initializeFeaturesAfterPermission();
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    super.dispose();
  }

  void _initializeFeaturesAfterPermission() async {
    try {
      bool locationPermissionGranted =
          await LocationService.requestLocationPermission();
      bool activityPermissionGranted =
          await PedometerService.requestActivityRecognitionPermission();

      if (locationPermissionGranted && activityPermissionGranted) {
        await _updateCurrentLocation();
        await _pedometerService.initializePedometer();
        _stepCountSubscription =
            _pedometerService.stepCountStream?.listen(_onStepCount);
      } else {
        throw Exception('Necessary permissions not granted');
      }
    } catch (e) {
      debugPrint("Error during initialization: $e");
    }
  }

  void _onStepCount(StepCount event) {
    int steps = event.steps;
    if ((steps - stepCount) >= 5) {
      stepCount = steps;
      _updateCurrentLocation();
    }
  }

  Future<void> _updateCurrentLocation() async {
    try {
      LatLng location = await _getLocation();
      setState(() {
        currentLocation = location;
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

        getCoordinates();
      });
    } catch (e) {
      debugPrint("Location update failed: $e");
    }
  }

  Future<LatLng> _getLocation() async {
    try {
      Position position = await LocationService.determinePosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint(e.toString());
      return const LatLng(0.0, 0.0);
    }
  }

  // Method to consume the OpenRouteService API
  void getCoordinates() async {
    debugPrint("Starting to fetch coordinates");

    try {
      var response = await http.get(
          getRouteUrl(
              "${currentLocation!.longitude},${currentLocation!.latitude}",
              "${widget.destLongitude},${widget.destLatitude}"),
          headers: {
            "Accept":
                "application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8"
          });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var coordinates =
            data['features'][0]['geometry']['coordinates'] as List;
        List<LatLng> newPoints = coordinates
            .map((coordinate) =>
                LatLng(coordinate[1].toDouble(), coordinate[0].toDouble()))
            .toList();

        setState(() {
          points = newPoints;
        });
      } else {
        debugPrint("Failed to fetch data: ${response.statusCode}");
        debugPrint("Error response body: ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception caught: $e");
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
      body: FlutterMap(
        options: MapOptions(
          initialCenter: currentLocation!,
          initialZoom: 14,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(markers: [originMarker, destinationMarker]),
          PolylineLayer(
            polylineCulling: false,
            polylines: [
              Polyline(points: points, color: Colors.black, strokeWidth: 5),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: getCoordinates,
        child: const Icon(Icons.route, color: Colors.white),
      ),
    );
  }
}
