import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopBar(title: 'Locations'),
      body: Center(
        child: Text('Locations Page Content'),
      ),
    );
  }
}
