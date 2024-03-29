import '../pages/profesordetails_page.dart';
import 'package:flutter/material.dart';
// import '../widgets/top_bar.dart';
import '../entities/courses.dart';

class SubjectsPage extends StatelessWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title:
              const Text('Asignaturas', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Mis Asignaturas'),
              Tab(text: 'Mis Profesores'),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            _buildSubjectsList(),
            _buildProfessorsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsList() {
    List<Course> courses = CoursesProvider().getCourses();

    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(courses[index].icon, color: courses[index].color),
          title: Text(
            courses[index].title,
            style: TextStyle(color: courses[index].color),
          ),
          subtitle: Text(
            'Profesor: ${courses[index].professor}\nAula: ${courses[index].aula}',
            style: TextStyle(color: courses[index].color.withOpacity(0.7)),
          ),
          trailing: const Icon(Icons.arrow_forward_ios,
              color: Colors.orange), // Ícono anaranjado
        );
      },
    );
  }

  Widget _buildProfessorsList(BuildContext context) {
    List<Course> courses = CoursesProvider().getCourses();
    Map<String, Course> professors = {
      for (var course in courses) course.professor: course
    };

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: professors.keys
          .map((professor) => Card(
                elevation: 4.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                color: Colors.orange, // Color de fondo de la tarjeta
                child: ListTile(
                  title: Text(
                    professor,
                    style:
                        const TextStyle(color: Colors.black), // Texto en negro
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProfessorDetailsPage(
                          professorCourse: professors[professor]!),
                    ));
                  },
                ),
              ))
          .toList(),
    );
  }
}
