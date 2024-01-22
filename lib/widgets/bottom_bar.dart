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
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      color: _darkMode ? const Color.fromARGB(255, 53, 53, 53) : Colors.orange,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildBottomBarItem(Icons.home, 'Inicio', 0),
          _buildBottomBarItem(Icons.qr_code, 'QR', 1),
          const Spacer(), // This creates a space between the items
          _buildBottomBarItem(Icons.map, 'Mapa', 2),
          _buildBottomBarItem(Icons.mic, 'Asistente', 3),
        ],
      ),
    );
  }

  Widget _buildBottomBarItem(IconData icon, String label, int index) {
    return IconButton(
      icon: widget.currentIndex == index
          ? Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.deepOrange, // Darker orange circle for selected item
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(icon, color: Colors.white),
              ),
            )
          : Icon(icon, color: getIconColor(index)),
      onPressed: () => widget.onItemSelected(index),
    );
  }

  Color getIconColor(int index) {
    if (widget.currentIndex == index) {
      return Colors
          .transparent; // Make it transparent to hide the icon when selected
    }
    return _darkMode ? Colors.white : Colors.black;
  }
}
