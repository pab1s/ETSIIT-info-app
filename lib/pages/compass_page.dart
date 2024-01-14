import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CompassPage extends StatefulWidget {
  final double targetLatitude;
  final double targetLongitude;

  const CompassPage({
    Key? key,
    required this.targetLatitude,
    required this.targetLongitude,
  }) : super(key: key);

  @override
  _CompassPageState createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  late StreamSubscription<MagnetometerEvent> _streamSubscription;
  double _currentDirection = 0;

  @override
  void initState() {
    super.initState();
    _initLocationAndCompass();
  }

  void _initLocationAndCompass() async {
    _streamSubscription = magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        double currentLatitude = 37.15417; // Ejemplo de latitud actual
        double currentLongitude = -3.58972; // Ejemplo de longitud actual
        double bearingToTarget = _calculateBearing(
          currentLatitude,
          currentLongitude,
          widget.targetLatitude,
          widget.targetLongitude,
        );

        _currentDirection = (atan2(event.y, event.x) * (180 / pi) + 360) % 360;
        _currentDirection = (_currentDirection - bearingToTarget + 360) % 360;

      });
    });
  }
  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  double _calculateBearing(double startLat, double startLng, double endLat, double endLng) {
    startLat = _toRadians(startLat);
    startLng = _toRadians(startLng);
    endLat = _toRadians(endLat);
    endLng = _toRadians(endLng);

    double y = sin(endLng - startLng) * cos(endLat);
    double x = cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(endLng - startLng);
    double bearing = atan2(y, x);
    return (_toDegrees(bearing) + 360) % 360;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  double _toDegrees(double radian) {
    return radian * (180 / pi);
  }

  @override
  Widget build(BuildContext context) {
    // El ángulo en radianes para la rotación de la brújula
    double compassAngle = -_toRadians(_currentDirection);

    // Radio de la brújula (la mitad del tamaño de la imagen)
    double radius = 256; // Como la imagen es de 512x512 píxeles

    // Calcular la posición de la chincheta en la periferia de la brújula
    double pinAngle = _toRadians(_currentDirection);
    double pinX = radius * cos(pinAngle);
    double pinY = radius * sin(pinAngle);

    return Scaffold(
      appBar: AppBar(title: Text('Brújula')),
      backgroundColor: Colors.black, // Fondo de la pantalla en negro
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Imagen de la brújula que gira según la dirección del dispositivo
            Transform.rotate(
              angle: compassAngle,
              child: Image.asset('assets/compass.png'), // Imagen de la brújula
            ),
            // Chincheta que indica la dirección al objetivo
            // Se posiciona sin rotación para que siempre apunte hacia el objetivo
            Transform(
              transform: Matrix4.translationValues(pinX, -pinY, 0.0),
              child: Icon(Icons.location_on, size: 50, color: Colors.red), // Puedes ajustar el tamaño y color de la chincheta
            ),
          ],
        ),
      ),
    );
    }
  }
