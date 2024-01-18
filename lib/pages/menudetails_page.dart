// menu_details_page.dart
import 'package:flutter/material.dart';
import 'package:etsiit_info_app/entities/dining_option.dart';


class MenuDetailsPage extends StatelessWidget {
  final DiningOption diningOption;

  const MenuDetailsPage({super.key, required this.diningOption});

  @override
  Widget build(BuildContext context) {
    List<String> menuSections = diningOption.menuDetails.split('\n\n');
    return Scaffold(
      appBar: AppBar(
        title: Text(diningOption.name),
        backgroundColor: Colors.orange, // Añade color anaranjado al AppBar
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: menuSections.length,
        itemBuilder: (context, index) {
          List<String> sectionItems = menuSections[index].split('\n');
          String sectionTitle = sectionItems[0];
          List<String> items = sectionItems.sublist(1);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionTitle,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange, // Añade color anaranjado al título de la sección
                ),
              ),
              const SizedBox(height: 8.0),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(item),
              )),
              const SizedBox(height: 16.0), // Espacio entre secciones
            ],
          );
        },
      ),
    );
  }
}
