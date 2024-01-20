//import '../widgets/top_bar.dart';
//import '../widgets/side_bar.dart';
import '../utils/colors.dart';
import 'locations_page.dart';
import 'clubs_page.dart';
import 'time_table_page.dart';
import 'menu_page.dart';
import 'tuiqr_page.dart'; // Asegúrate de tener esta página

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:light/light.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool isDarkMode = false;
  Light? _light;
  StreamSubscription? _subscription;

  void onData(int luxValue) async {
    setState(() {
      isDarkMode = luxValue < 50; // Ajusta este umbral según tus necesidades
    });
  }

  void startListening() {
    _light = Light();
    try {
      _subscription = _light?.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      print(exception);
    }
  }

  @override
  void initState() {
    super.initState();
    startListening();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const TuiQrPage()), // Asegúrate de tener TuiQrPage
      );
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  // Método para construir botones en la cuadrícula
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
      backgroundColor: isDarkMode
          ? Colors.black
          : Colors.white, // Cambio de color de fondo según el modo
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: isDarkMode
            ? Colors.black
            : Colors.blue, // Cambio de color de AppBar
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Welcome, User!',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  CircleAvatar(
                    backgroundImage: AssetImage(
                        'assets/avatar.jpeg'), // Use avatar image from assets
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
                  true, // Needed to make GridView work inside SingleChildScrollView
              physics:
                  const NeverScrollableScrollPhysics(), // Disable scrolling inside GridView
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              children: <Widget>[
                _buildGridButton(
                  icon: Icons.location_on,
                  label: 'Locations',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LocationsPage()),
                  ),
                ),
                _buildGridButton(
                  icon: Icons.group,
                  label: 'Clubs',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ClubsPage()),
                  ),
                ),
                _buildGridButton(
                  icon: Icons.schedule,
                  label: 'Time Table',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TimeTableCalendar()),
                  ),
                ),
                _buildGridButton(
                  icon: Icons.restaurant_menu,
                  label: 'Places to Eat',
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        selectedItemColor: Colors
            .blue, // Asegúrate de definir este color en tus colores de app
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const BottomBar({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onItemSelected,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code),
          label: 'QR',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
      ],
      selectedItemColor: AppColors.primary,
    );
  }
}
