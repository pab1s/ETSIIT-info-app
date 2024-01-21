import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class SubjectsPage extends StatelessWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopBar(title: 'Subjects'),
      body: Center(
        child: Text('Subjects Page Content'),
      ),
    );
  }
}
