import 'package:flutter/material.dart';
import 'dart:async';
import 'package:light/light.dart';

class BottomBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  Light? _light;
  StreamSubscription? _lightSubscription;
  bool _darkMode = false;

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
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor:
          _darkMode ? const Color.fromARGB(255, 53, 53, 53) : Colors.orange,
      selectedItemColor: Colors.white,
      unselectedItemColor: _darkMode ? Colors.white : Colors.black,
      currentIndex: widget.currentIndex,
      onTap: widget.onItemSelected,
      items: [
        _buildBottomNavigationBarItem(Icons.home, 'Inicio', 0),
        _buildBottomNavigationBarItem(Icons.qr_code, 'QR', 1),
        _buildBottomNavigationBarItem(Icons.map, 'Mapa', 2),
        _buildBottomNavigationBarItem(Icons.mic, 'Asistente', 3),
      ],
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 25.0),
      label: widget.currentIndex == index ? label : '',
    );
  }
}
