import 'package:flutter/material.dart';
import 'dart:async';

import 'package:light/light.dart'; // Importa el paquete light

class TuiQrPage extends StatefulWidget {
  const TuiQrPage({Key? key}) : super(key: key);

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
    // Define el tema claro y oscuro
    final lightTheme = ThemeData(
      // Define los colores y características del tema claro
      brightness: Brightness.light,
      primaryColor: Colors.white, // Color principal en modo claro
      // Otros ajustes de tema claro
    );

    final darkTheme = ThemeData(
      // Define los colores y características del tema oscuro
      brightness: Brightness.dark,
      primaryColor: Colors.black, // Color principal en modo oscuro
      // Otros ajustes de tema oscuro
    );

    final theme =
        _darkMode ? darkTheme : lightTheme; // Selecciona el tema según el modo

    return MaterialApp(
      theme: theme, // Aplica el tema seleccionado
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TUI y QR'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/tui.jpg'), // Imagen de la TUI
              const SizedBox(height: 20),
              Image.asset('assets/luiscrespo-QR.png'), // Imagen del código QR
              // Los botones de expandir han sido eliminados
            ],
          ),
        ),
      ),
    );
  }
}
