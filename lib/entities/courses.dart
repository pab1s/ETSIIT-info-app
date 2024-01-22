import 'package:flutter/material.dart';
 
class Course {
  final String title;
  final IconData icon;
  final int dayOfWeek;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String professor;
  final String aula;
  final Color color;
  final String professorOffice; 
  final String professorImage;

  Course({
    required this.title, 
    required this.icon, 
    required this.color,
    required this.dayOfWeek,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.professor,
    required this.aula,
    required this.professorOffice,
    required this.professorImage,
    });
}

class CoursesProvider {
  static final CoursesProvider _instance = CoursesProvider._internal();

  factory CoursesProvider() {
    return _instance;
  }

  CoursesProvider._internal();

  final List<Course> courses = [
    Course(
      title: 'PDOO - Teoría',
      icon: Icons.computer,
      color: Colors.green[800] ?? Colors.green,
      dayOfWeek: DateTime.monday,
      startHour: 9,
      startMinute: 30,
      endHour: 11,
      endMinute: 30,
      professor: 'Cortijo Bon',
      aula: '1.6',
      professorOffice: 'D29 Etsiit',
      professorImage: 'assets/cortijo.png', //
    ),
    Course(
      title: 'PL - Teoría',
      icon: Icons.code,
      color: Colors.blue[800] ?? Colors.blue,
      dayOfWeek: DateTime.monday,
      startHour: 11,
      startMinute: 30,
      endHour: 13,
      endMinute: 30,
      professor: 'Ramón López-Cózar Delgado',
      aula: '1.2',
      professorOffice: 'Etsiit Desp. 26 3ª Planta', 
      professorImage: 'assets/ramon.png', 
    ),
    Course(
      title: 'PDOO - Prácticas A1',
      icon: Icons.computer,
      color: Colors.lightGreen,
      dayOfWeek: DateTime.tuesday,
      startHour: 11,
      startMinute: 30,
      endHour: 13,
      endMinute: 30,
      professor: 'Juan Ruiz De Miras',
      aula: '3.6',
      professorOffice: 'Etsiit D 30 3ª Planta', 
      professorImage: 'assets/juan.png', 
    ),
    Course(
      title: 'PL - Prácticas A2',
      icon: Icons.code,
      color: Colors.lightBlue,
      dayOfWeek: DateTime.tuesday,
      startHour: 9,
      startMinute: 30,
      endHour: 11,
      endMinute: 30,
      professor: 'Ramón López-Cózar Delgado',
      aula: '3.1',
      professorOffice: 'Etsiit Desp. 26 3ª Planta', 
      professorImage: 'assets/ramon.png', 
    ),
    Course(
      title: 'SO - Teoría',
      icon: Icons.storage,
      color: Colors.red[800] ?? Colors.red,
      dayOfWeek: DateTime.wednesday,
      startHour: 9,
      startMinute: 30,
      endHour: 11,
      endMinute: 30,
      professor: 'Alejandro Jose Leon Salas',
      aula: '0.2',
      professorOffice: '', 
      professorImage: '', 
    ),
    Course(
      title: 'SO - Prácticas D3',
      icon: Icons.storage,
      color: Colors.redAccent[700] ?? Colors.redAccent,
      dayOfWeek: DateTime.wednesday,
      startHour: 11,
      startMinute: 30,
      endHour: 13,
      endMinute: 30,
      professor: 'Alejandro Jose Leon Salas',
      aula: '2.5',
      professorOffice: '', 
      professorImage: '', 
    ),
    Course(
      title: 'ISE - Teoría',
      icon: Icons.business,
      color: const Color.fromARGB(255, 138, 43, 226),
      dayOfWeek: DateTime.thursday,
      startHour: 9,
      startMinute: 30,
      endHour: 11,
      endMinute: 30,
      professor: 'Hector Pomares',
      aula: '0.1',
      professorOffice: '', 
      professorImage: '', 
    ),
    Course(
      title: 'VC - Prácticas A2',
      icon: Icons.visibility,
      color: Color.fromARGB(255, 219, 197, 36),
      dayOfWeek: DateTime.thursday,
      startHour: 11,
      startMinute: 30,
      endHour: 13,
      endMinute: 30,
      professor: 'Pablo Mesejo',
      aula: '1.7',
      professorOffice: '', 
      professorImage: '', 
    ),
    Course(
      title: 'ISE - Prácticas A2',
      icon: Icons.business,
      color: Color.fromARGB(255, 124, 52, 193),
      dayOfWeek: DateTime.friday,
      startHour: 11,
      startMinute: 30,
      endHour: 13,
      endMinute: 30,
      professor: 'Alberto Guillen',
      aula: '1.4',
      professorOffice: '', 
      professorImage: '', 
    ),
    Course(
      title: 'VC - Teoría',
      icon: Icons.visibility,
      color: Color.fromARGB(255, 255, 226, 3),
      dayOfWeek: DateTime.friday,
      startHour: 9,
      startMinute: 30,
      endHour: 11,
      endMinute: 30,
      professor: 'Pablo Mesejo',
      aula: '0.3',
      professorOffice: '', 
      professorImage: '', 
    ),
  ];

  List<Course> getCourses() {
    return courses;
  }
}
