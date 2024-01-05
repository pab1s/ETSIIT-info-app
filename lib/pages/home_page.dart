// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/side_bar.dart';
import '../utils/colors.dart';
import 'locations_page.dart';
import 'clubs_page.dart';
import 'time_table_page.dart';
import 'menu_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: 'Home'),
      drawer: SideBar(),
      body: SingleChildScrollView(
        // Make the page scrollable
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
                    MaterialPageRoute(builder: (context) => LocationsPage()),
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
                        builder: (context) => const TimeTablePage()),
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
      bottomNavigationBar: const BottomBar(),
    );
  }

  Widget _buildGridButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: AppColors.primary, // Button color changed to orange
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon,
                  size: 50, color: Colors.white), // Icon color changed to white
              Text(label,
                  style: const TextStyle(
                      color: Colors.white)), // Text color changed to white
            ],
          ),
        ),
      ),
    );
  }
}
