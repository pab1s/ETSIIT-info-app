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
      professor: 'Ramon Lopez',
      aula: '1.2',
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
      professor: 'Nombre del Profesor',
      aula: 'Aula de Prácticas',
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
      professor: 'Nombre del Profesor',
      aula: 'Aula de Prácticas',
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
      professor: 'Nombre del Profesor SO',
      aula: 'Aula SO',
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
      professor: 'Nombre del Profesor SO',
      aula: 'Aula de Prácticas SO',
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
    ),
    Course(
      title: 'VC - Prácticas A2',
      icon: Icons.visibility,
      color: const Color.fromARGB(255, 204, 180, 0),
      dayOfWeek: DateTime.thursday,
      startHour: 11,
      startMinute: 30,
      endHour: 13,
      endMinute: 30,
      professor: 'Nombre del Profesor VC',
      aula: 'Aula de Prácticas VC',
    ),
    Course(
      title: 'ISE - Prácticas A2',
      icon: Icons.business,
      color: const Color.fromARGB(255, 138, 43, 226),
      dayOfWeek: DateTime.friday,
      startHour: 11,
      startMinute: 30,
      endHour: 13,
      endMinute: 30,
      professor: 'Alberto Guillen',
      aula: '1.4',
    ),
    Course(
      title: 'VC - Teoría',
      icon: Icons.visibility,
      color: const Color.fromARGB(255, 204, 180, 0),
      dayOfWeek: DateTime.friday,
      startHour: 9,
      startMinute: 30,
      endHour: 11,
      endMinute: 30,
      professor: 'Nombre del Profesor VC',
      aula: 'Aula VC',
    ),
  ];

  List<Course> getCourses() {
    return courses;
  }
}
