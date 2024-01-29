import 'package:flutter/material.dart';
import 'dart:async';
import 'package:light/light.dart';
import '../widgets/top_bar.dart';

class TuiQrPage extends StatefulWidget {
  const TuiQrPage({super.key});

  @override
  _TuiQrPageState createState() => _TuiQrPageState();
}

class _TuiQrPageState extends State<TuiQrPage> {
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
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopBar(title: "TUI y QR"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/tui.png',
              key: UniqueKey(),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/luiscrespo-QR.png',
              key: UniqueKey(),
            ),
          ],
        ),
      ),
      backgroundColor: _darkMode ? Colors.black : Colors.white,
    );
  }
}
