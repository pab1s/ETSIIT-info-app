import 'package:flutter/material.dart';

class Course {
  final String title;
  final IconData icon;
  final Color color;

  Course({required this.title, required this.icon, required this.color});
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
    ),
    Course(
      title: 'PL - Teoría',
      icon: Icons.code,
      color: Colors.blue[800] ?? Colors.blue,
    ),
    Course(
      title: 'SO - Teoría',
      icon: Icons.storage,
      color: Colors.red[800] ?? Colors.red,
    ),
    Course(
      title: 'SO - Prácticas',
      icon: Icons.storage,
      color: Colors.redAccent[700] ?? Colors.redAccent,
    ),
    Course(
      title: 'ISE - Teoría',
      icon: Icons.business,
      color: const Color.fromARGB(255, 138, 43, 226),
    ),
    Course(
      title: 'VC - Prácticas',
      icon: Icons.visibility,
      color: const Color.fromARGB(255, 204, 180, 0),
    ),
    Course(
      title: 'ISE - Prácticas',
      icon: Icons.business,
      color: const Color.fromARGB(255, 138, 43, 226),
    ),
    Course(
      title: 'VC - Teoría',
      icon: Icons.visibility,
      color: const Color.fromARGB(255, 204, 180, 0),
    ),
  ];

  List<Course> getCourses() {
    return courses;
  }
}
