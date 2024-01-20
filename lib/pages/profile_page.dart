import 'package:flutter/material.dart';
import 'package:etsiit_info_app/entities/courses.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Perfil',
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = CoursesProvider().getCourses();

    return Scaffold(
      backgroundColor: Colors.orange,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/avatar.jpeg'),
              ),
              const Text(
                'Jonathan Smith',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Hogwarts',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  color: Colors.white70,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20,
                width: 150,
                child: Divider(
                  color: Colors.orange.shade700,
                ),
              ),
              Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 25.0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.person,
                      color: Colors.orange,
                    ),
                    title: Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit ut aliquam',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15.0,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              const Text(
                'CLUBS',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 150, // Set a specific height for the GridView
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 1,
                  ),
                  itemCount: 3, // Number of clubs
                  itemBuilder: (BuildContext context, int index) {
                    switch (index) {
                      case 0:
                        return const ClubCard(
                            title: 'Club de progamadores',
                            icon: Icons.computer,
                            color: Colors.black);
                      case 1:
                        return const ClubCard(
                            title: 'Club PSM',
                            icon: Icons.book,
                            color: Colors.black);
                      case 2:
                        return const ClubCard(
                            title: 'Club Cultural',
                            icon: Icons.palette,
                            color: Colors.black);
                      default:
                        return Container();
                    }
                  },
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'COURSES',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 1,
                ),
                itemCount: courses.length,
                itemBuilder: (BuildContext context, int index) {
                  return ClubCard(
                    title: courses[index].title,
                    icon: courses[index].icon,
                    color: courses[index].color,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ClubCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const ClubCard(
      {super.key,
      required this.title,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      color: Colors.white, // White background
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}
