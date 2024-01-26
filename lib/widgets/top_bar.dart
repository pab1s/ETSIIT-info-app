import 'package:flutter/material.dart';
import 'dart:async';
import 'package:light/light.dart';

class TopBar extends StatefulWidget {
  final String title;

  const TopBar({super.key, required this.title});

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
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
    return AppBar(
      title: Text(
        widget.title,
        style: TextStyle(
            color: _darkMode ? Colors.white : Colors.white,
            fontWeight: FontWeight.bold),
      ),
      backgroundColor:
          _darkMode ? const Color.fromARGB(255, 53, 53, 53) : Colors.orange,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
