import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';

import '../widgets/top_bar.dart';
import '../utils/location_service.dart';
import '../utils/pedometer_service.dart';
import 'navigation_page.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> with TickerProviderStateMixin {
  final double _zoomLevel = 16; // default zoom level
  LatLng? currentLocation;
  late Marker originMarker;
  late Marker destinationMarker1;
  late Marker destinationMarker2;
  late Marker destinationMarker3;
  late Marker destinationMarker4;
  late Marker destinationMarker5;
  late Marker destinationMarker6;
  List<LatLng> points = [];
  int stepCount = 0;
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

        double latitude1 = 37.14827;
        double longitude1 = -3.60377;

        destinationMarker1 = Marker(
          point: LatLng(latitude1, longitude1),
          width: 80.0,
          height: 80.0,
          child: GestureDetector(
            onTap: () {
              _showMarkerDialog(context, "Comedor PTS", latitude1, longitude1);
            },
            child: const Column(
              children: [
                Icon(
                  Icons.location_on,
                  size: 40.0,
                  color: Color.fromARGB(255, 168, 42, 42),
                ),
                Text(
                  "Comedor PTS",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );

        double latitude2 = 37.19708;
        double longitude2 = -3.62457;

        destinationMarker2 = Marker(
          point: LatLng(latitude2, longitude2),
          width: 80.0,
          height: 80.0,
          child: GestureDetector(
            onTap: () {
              _showMarkerDialog(context, "ETSIIT", latitude2, longitude2);
            },
            child: const Column(
              children: [
                Icon(
                  Icons.location_on,
                  size: 40.0,
                  color: Colors.blue,
                ),
                Text(
                  "ETSIIT",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );

        double latitude3 = 37.19815;
        double longitude3 = -3.62960;

        destinationMarker3 = Marker(
          point: LatLng(latitude3, longitude3),
          width: 80.0,
          height: 80.0,
          child: GestureDetector(
            onTap: () {
              _showMarkerDialog(
                  context, "ETSIIT Auxiliar", latitude3, longitude3);
            },
            child: const Column(
              children: [
                Icon(
                  Icons.location_on,
                  size: 40.0,
                  color: Color.fromARGB(255, 9, 76, 131),
                ),
                Text(
                  "ETSIIT Auxiliar",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );

        double latitude4 = 37.18290;
        double longitude4 = -3.60594;

        destinationMarker4 = Marker(
          point: LatLng(latitude4, longitude4),
          width: 80.0,
          height: 80.0,
          child: GestureDetector(
            onTap: () {
              _showMarkerDialog(
                  context, "Comedor Ciencias", latitude4, longitude4);
            },
            child: const Column(
              children: [
                Icon(
                  Icons.location_on,
                  size: 40.0,
                  color: Color.fromARGB(255, 33, 138, 156),
                ),
                Text(
                  "Comedor Ciencias",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );

        double latitude5 = 37.18622;
        double longitude5 = -3.60449;

        destinationMarker5 = Marker(
          point: LatLng(latitude5, longitude5),
          width: 80.0,
          height: 80.0,
          child: GestureDetector(
            onTap: () {
              _showMarkerDialog(context, "V Centenario", latitude5, longitude5);
            },
            child: const Column(
              children: [
                Icon(
                  Icons.location_on,
                  size: 40.0,
                  color: Color.fromARGB(255, 99, 9, 9),
                ),
                Text(
                  "V Centenario",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );

        double latitude6 = 37.17973;
        double longitude6 = -3.60912;

        destinationMarker6 = Marker(
          point: LatLng(latitude6, longitude6),
          width: 80.0,
          height: 80.0,
          child: GestureDetector(
            onTap: () {
              _showMarkerDialog(
                  context, "Facultad de Ciencias", latitude6, longitude6);
            },
            child: const Column(
              children: [
                Icon(
                  Icons.location_on,
                  size: 40.0,
                  color: Color.fromARGB(255, 40, 80, 7),
                ),
                Text(
                  "Facultad de ciencias",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );
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

  void _showMarkerDialog(
      BuildContext context, String placeName, double lat, double lon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Deseas ir a $placeName?"),
          actions: <Widget>[
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Sí"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NavigationPage(
                      destLatitude: lat,
                      destLongitude: lon,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBar(title: "Puntos de Interés"),
      ),
      body: FlutterMap(
        mapController: _animatedMapController.mapController,
        options: MapOptions(
          initialCenter: currentLocation!,
          initialZoom: _zoomLevel,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(markers: [
            originMarker,
            destinationMarker1,
            destinationMarker2,
            destinationMarker3,
            destinationMarker4,
            destinationMarker5,
            destinationMarker6
          ]),
        ],
      ),
    );
  }
}
