import 'package:flutter/material.dart';
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
  bool _isLoggedIn = false;
  String _username = '';
  String _password = '';
  String _loginMessage = '';

  static const String _mockUsername = 'luis';
  static const String _mockPassword = '1234';

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

  void _attemptLogin() {
    if (_username == _mockUsername && _password == _mockPassword) {
      setState(() {
        _isLoggedIn = true;
        _loginMessage = '';
      });
    } else {
      setState(() {
        _loginMessage = 'Credenciales incorrectas';
      });
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _username = '';
      _password = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return const MainPage();
    }

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
        fillColor: _darkMode ? Colors.black : Colors.white,
        filled: true,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Iniciar sesión"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              onChanged: (value) => _username = value,
              style: textStyle,
              decoration: inputDecoration('Usuario'),
              cursorColor: _darkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) => _password = value,
              obscureText: true,
              style: textStyle,
              decoration: inputDecoration('Contraseña'),
              cursorColor: _darkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _attemptLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Iniciar sesión'),
            ),
            if (_loginMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _loginMessage,
                  style: const TextStyle(color: Colors.red),
                ),
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
