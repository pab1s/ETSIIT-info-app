import 'package:flutter/material.dart';
import 'package:light/light.dart';
import 'indoor_navigation_page.dart';
import 'navigation_page.dart';
import 'dart:async';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  _LocationsPageState createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  Light? _light;
  StreamSubscription? _lightSubscription;
  bool _darkMode = false;

  final List<String> outdoorLocations = [
    'ETSIIT',
    'PTS',
    'Comedor Fuentenueva',
  ];

  final List<String> indoorLocations = [
    'Laboratiorio 2.6',
    'Cafeteria ETSIIT',
    'Despacho 2.6',
  ];

  @override
  void initState() {
    super.initState();
    _light = Light();
    _lightSubscription = _light?.lightSensorStream.listen((luxValue) {
      setState(() {
        _darkMode = luxValue < 100;
      });
    });
  }

  @override
  void dispose() {
    _lightSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Localizaciones',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Exterior', icon: Icon(Icons.landscape)),
              Tab(text: 'Interior', icon: Icon(Icons.home)),
            ],
            indicatorColor: Colors.white,
            labelColor: _darkMode ? Colors.white : Colors.black,
          ),
        ),
        body: TabBarView(
          children: [
            _buildLocationList(context, outdoorLocations, false),
            _buildLocationList(context, indoorLocations, true),
          ],
        ),
        backgroundColor: _darkMode ? Colors.black : Colors.white,
      ),
    );
  }

  Widget _buildLocationList(
      BuildContext context, List<String> locations, bool isIndoor) {
    return ListView.builder(
      itemCount: locations.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.location_on,
              color: _darkMode ? Colors.white : Colors.orange),
          title: Text(
            locations[index],
            style: TextStyle(color: _darkMode ? Colors.white : Colors.orange),
          ),
          trailing: Icon(Icons.arrow_forward_ios,
              color: _darkMode ? Colors.white : Colors.orange),
          onTap: () => _onLocationTap(context, locations[index], isIndoor),
        );
      },
    );
  }

  void _onLocationTap(BuildContext context, String location, bool isIndoor) {
    if (isIndoor) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const IndoorNavPage(subfolderName: "lab")),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const NavigationPage(
                destLatitude: 37.19815, destLongitude: -3.62960)),
      );
    }
  }
}
