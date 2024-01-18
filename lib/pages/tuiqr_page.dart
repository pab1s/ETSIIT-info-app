
import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/side_bar.dart';
import '../utils/colors.dart';


class TuiQrPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TUI y QR'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/tui.jpg'), // Imagen de la TUI
            SizedBox(height: 20),
            Image.asset('assets/luiscrespo-QR.png'), // Imagen del código QR
            // Los botones de expandir han sido eliminados
          ],
        ),
      ),
    );
  }
}
