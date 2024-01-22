import 'package:flutter/material.dart';
import 'package:etsiit_info_app/utils/colors.dart';
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

  Color getIconColor(int index) {
    if (widget.currentIndex == index) {
      return Colors.orange;
    }
    return _darkMode ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onItemSelected,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: getIconColor(0)),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code, color: getIconColor(1)),
          label: 'QR',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map, color: getIconColor(2)),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.mic, color: getIconColor(3)),
          label: 'Asistente',
        ),
      ],
      selectedItemColor: Colors.orange,
      backgroundColor: _darkMode ? const Color.fromARGB(255, 53, 53, 53) : null,
      unselectedItemColor: _darkMode ? Colors.white : Colors.black,
    );
  }
}
