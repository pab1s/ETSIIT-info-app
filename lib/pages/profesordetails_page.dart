import 'package:etsiit_info_app/entities/courses.dart';
import 'package:flutter/material.dart';

class ProfessorDetailsPage extends StatelessWidget {
  final Course professorCourse;

  const ProfessorDetailsPage({Key? key, required this.professorCourse})
      : super(key: key);

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
            margin: EdgeInsets.all(16.0),
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
                  SizedBox(height: 16),
                  Text(
                    professorCourse.professor,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Despacho: ${professorCourse.professorOffice}',
                        style: TextStyle(fontSize: 16),
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
