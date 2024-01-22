import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';

import '../interface/api.dart';
import '../utils/location_service.dart';
import '../utils/pedometer_service.dart';

class NavigationPage extends StatefulWidget {
  final double destLatitude;
  final double destLongitude;

  const NavigationPage(
      {super.key, required this.destLatitude, required this.destLongitude});

  @override
  // ignore: library_private_types_in_public_api
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage>
    with TickerProviderStateMixin {
  final double _zoomLevel = 16; // default zoom level
  LatLng? currentLocation;
  late Marker originMarker;
  late Marker destinationMarker;
  List<LatLng> points = [];
  int stepCount = 0;
  double _compassHeading = 0;
  StreamSubscription<StepCount>? _stepCountSubscription;
  final PedometerService _pedometerService = PedometerService();
  late AnimationController animationController;
  late Animation<double> sizeAnimation;
  late final _animatedMapController = AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    _initializeFeaturesAfterPermission();
    _listenToCompass();

    // Initialize animation controller and animation
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    sizeAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
    animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    _animatedMapController.dispose();
    animationController.dispose();
    super.dispose();
  }

  void _listenToCompass() {
    FlutterCompass.events?.listen((compassEvent) {
      setState(() {
        _compassHeading = compassEvent.heading ?? 0;
        _animatedMapController.mapController.rotate(-_compassHeading);
      });
    });
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
      /*LatLng destination = LatLng(widget.destLatitude, widget.destLongitude);
      double distance = _calculateDistance(location, destination);
      double zoomLevel = _calculateZoomLevel(distance);*/

      setState(() {
        currentLocation = location;
        //_animatedMapController.mapController.move(location, zoomLevel);

        originMarker = Marker(
          point: currentLocation!,
          width: 80.0,
          height: 80.0,
          child: AnimatedBuilder(
            animation: sizeAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: sizeAnimation.value,
                child: child,
              );
            },
            child: const Icon(
              Icons.my_location,
              size: 40.0,
              color: Colors.blue,
            ),
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

  /*LatLng _calculateMidpoint(LatLng loc1, LatLng loc2) {
    return LatLng(
      (loc1.latitude + loc2.latitude) / 2,
      (loc1.longitude + loc2.longitude) / 2,
    );
  }*/

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

  /*double _calculateDistance(LatLng loc1, LatLng loc2) {
    var distance = Geolocator.distanceBetween(
      loc1.latitude,
      loc1.longitude,
      loc2.latitude,
      loc2.longitude,
    );
    return distance / 1000; // Convert to kilometers
  }

  double _calculateZoomLevel(double distance) {
    if (distance < 1) {
      // Less than 1 km
      return 15;
    } else if (distance < 5) {
      // Less than 5 km
      return 13;
    } else if (distance < 10) {
      // Less than 10 km
      return 12;
    } else if (distance < 20) {
      // Less than 20 km
      return 11;
    } else if (distance < 40) {
      // Less than 40 km
      return 10;
    } else if (distance < 80) {
      // Less than 80 km
      return 9;
    } else {
      return 8;
    }
  }*/

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    /*LatLng centerPoint = currentLocation != null
        ? _calculateMidpoint(
            currentLocation!, LatLng(widget.destLatitude, widget.destLongitude))
        : const LatLng(0.0, 0.0);
    */

    return Scaffold(
      body: FlutterMap(
        mapController: _animatedMapController.mapController,
        options: MapOptions(
          initialCenter: currentLocation!,
          initialZoom: _zoomLevel,
          initialRotation: _compassHeading,
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
