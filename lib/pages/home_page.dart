import 'package:flutter/material.dart';
import 'dart:async';
import 'package:light/light.dart';

import '../widgets/top_bar.dart';
import '../widgets/side_bar.dart';
import 'indoor_navigation_page.dart';
import 'subjects_page.dart';
import 'time_table_page.dart';
import 'menu_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  Widget _buildGridButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: const Color(0xFFFF9100),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 50, color: Colors.white),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: 'Inicio'),
      drawer: const SideBar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Bienvenido, Jonathan!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _darkMode ? Colors.white : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/avatar.jpeg'),
                    radius: 30,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 4,
                  child: Image.asset(
                    'assets/banner.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              children: <Widget>[
                _buildGridButton(
                  icon: Icons.location_on,
                  label: 'Localizaciones',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const IndoorNavPage(subfolderName: "lab")),
                  ),
                ),
                _buildGridButton(
                  icon: Icons.group,
                  label: 'Asignaturas',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SubjectsPage()),
                  ),
                ),
                _buildGridButton(
                  icon: Icons.schedule,
                  label: 'Horario',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TimeTableCalendar()),
                  ),
                ),
                _buildGridButton(
                  icon: Icons.restaurant_menu,
                  label: 'Comedores',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MenuPage()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: _darkMode ? Colors.black : Colors.white,
    );
  }
}
