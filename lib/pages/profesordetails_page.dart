import 'package:etsiit_info_app/entities/courses.dart';
import 'package:flutter/material.dart';

class ProfessorDetailsPage extends StatelessWidget {
  final Course professorCourse;

  const ProfessorDetailsPage({super.key, required this.professorCourse});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(professorCourse.professor),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.orange[100]!, Colors.white],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(professorCourse.professorImage),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    professorCourse.professor,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.work, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Despacho: ${professorCourse.professorOffice}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  // Aquí puedes añadir más información si es necesario
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
