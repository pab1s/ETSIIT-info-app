
import 'package:flutter/material.dart';


class TuiQrPage extends StatelessWidget {
  const TuiQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
