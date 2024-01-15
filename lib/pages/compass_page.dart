/*

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassPage extends StatefulWidget {
  final double destinationAngle;

  CompassPage({Key? key, required this.destinationAngle}) : super(key: key);

  @override
  _CompassPageState createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  double? _currentHeading;

  @override
  void initState() {
    super.initState();
    FlutterCompass.events!.listen((CompassEvent event) {
      setState(() {
        _currentHeading = event.heading;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Brujula'),
      ),
      body: Center(
        child: _buildCompass(),
      ),
    );
  }

  Widget _buildCompass() {
    if (_currentHeading == null) {
      return Text('Brujula no disponible');
    }

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Transform.rotate(
          angle: ((_currentHeading ?? 0) * (3.1416 / 180) * -1),
          child: Image.asset('assets/compass.png'), // Imagen de brújula
        ),
        Transform.rotate(
          angle:(widget.destinationAngle - _currentHeading!) * (3.1416 / 180),
          child: Icon( Icons.location_on, // Símbolo para indicar el destino
          size: 48.0,
          color: Colors.red,
          ),
        ),
      ],
    );
  }
}

*/