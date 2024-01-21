import 'package:flutter/material.dart';
import 'dart:async';
import 'package:light/light.dart';
// Importa tus widgets y páginas personalizadas aquí
import '../widgets/top_bar.dart';
import '../widgets/side_bar.dart';
import '../utils/colors.dart';
import 'locations_page.dart';
import 'subjects_page.dart';
import 'time_table_page.dart';
import 'menu_page.dart';
import 'tuiqr_page.dart';
import 'mapa_page.dart';

// La clase BottomBar debe estar fuera de la clase HomePage
class BottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onItemSelected,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code),
          label: 'QR',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Mapa',
        ),
      ],
      selectedItemColor: AppColors.primary,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
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

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TuiQrPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MapaPage(),
        ),
      );
    }
    setState(() {
      _selectedIndex = index;
    });
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
              shrinkWrap:
                  true, // Necesario para que GridView funcione dentro de SingleChildScrollView
              physics:
                  const NeverScrollableScrollPhysics(), // Deshabilita el desplazamiento dentro de GridView
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
                        builder: (context) => const LocationsPage()),
                  ),
                ),
                _buildGridButton(
                  icon: Icons.group,
                  label: 'Asignaturas',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SubjectsPage()),
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
      bottomNavigationBar: BottomBar(
        currentIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
      backgroundColor: _darkMode ? Colors.black : Colors.white,
    );
  }
}
