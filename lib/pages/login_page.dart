import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../utils/colors.dart';
import 'main_page.dart';
import 'dart:async';
import 'package:light/light.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    // Estilos para modo oscuro
    TextStyle textStyle = TextStyle(
      color: _darkMode ? Colors.white : Colors.black,
    );

    InputDecoration inputDecoration(String labelText) {
      return InputDecoration(
        labelText: labelText,
        labelStyle: textStyle,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _darkMode ? Colors.white : Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        // Color del texto dentro del TextField
        fillColor: _darkMode ? Colors.black : Colors.white,
        filled: true,
      );
    }

    return Scaffold(
      appBar: const TopBar(title: "Iniciar sesión"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20),
            TextField(
              style: textStyle,
              decoration: inputDecoration('Usuario'),
              cursorColor: _darkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              style: textStyle,
              decoration: inputDecoration('Contraseña'),
              cursorColor: _darkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implementar lógica de inicio de sesión
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Iniciar sesión'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
              child: const Text('Acceder como invitado'),
            ),
          ],
        ),
      ),
      backgroundColor: _darkMode ? Colors.black : Colors.white,
    );
  }
}
