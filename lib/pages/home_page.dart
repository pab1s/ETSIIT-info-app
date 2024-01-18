import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/side_bar.dart';
import '../utils/colors.dart';
import 'locations_page.dart';
import 'clubs_page.dart';
import 'time_table_page.dart';
import 'menu_page.dart';
import 'tuiqr_page.dart'; // Asegúrate de tener esta página

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TuiQrPage()), // Asegúrate de tener TuiQrPage
      );
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildGridButton({required IconData icon, required String label, required VoidCallback onTap}) {
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
      appBar: const TopBar(title: 'Home'),
      drawer: const SideBar(),
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
                    MaterialPageRoute(builder: (context) => const LocationsPage()),
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
                        builder: (context) =>  const TimeTableCalendar()),
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
      bottomNavigationBar: BottomBar(
        currentIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}

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

// Asegúrate de tener una página TuiQrPage para manejar la vista de la TUI y el QR.
