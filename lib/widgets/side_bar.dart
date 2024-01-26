import 'package:flutter/material.dart';
import 'package:etsiit_info_app/utils/colors.dart';
import 'package:etsiit_info_app/pages/profile_page.dart';
import 'package:etsiit_info_app/pages/login_page.dart';
import 'dart:async';
import 'package:light/light.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
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
    return Drawer(
      backgroundColor: _darkMode ? const Color(0xFF9E9E9E) : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Text(
              'App Institucional',
              style: TextStyle(
                color: _darkMode ? Colors.black : Colors.white, // Inverse color
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app,
                color: _darkMode ? Colors.white : Colors.black),
            title: Text('Cerrar sesión',
                style:
                    TextStyle(color: _darkMode ? Colors.white : Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person,
                color: _darkMode ? Colors.white : Colors.black),
            title: Text('Perfil',
                style:
                    TextStyle(color: _darkMode ? Colors.white : Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
