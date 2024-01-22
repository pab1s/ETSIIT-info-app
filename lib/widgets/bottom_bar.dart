import 'package:flutter/material.dart';
import 'package:etsiit_info_app/utils/colors.dart';
import 'dart:async';
import 'package:light/light.dart';

class BottomBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const BottomBar({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
  }) : super(key: key);

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
        _darkMode = luxValue < 100; // Ajusta este valor según sea necesario
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
    Color? iconColor = _darkMode ? Colors.white : null;
    Color? textColor = _darkMode ? Colors.white : null;

    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onItemSelected,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: iconColor),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code, color: iconColor),
          label: 'QR',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map, color: iconColor),
          label: 'Mapa',
        ),
        // Nuevo botón de Asistente
        BottomNavigationBarItem(
          icon: Icon(Icons.mic, color: iconColor),
          label: 'Asistente',
        ),
      ],
      selectedItemColor: _darkMode ? Colors.orange : AppColors.primary,
      backgroundColor: _darkMode ? Colors.grey : null,
      unselectedItemColor: textColor,
    );
  }
}
