import 'package:flutter/material.dart';
import 'package:etsiit_info_app/entities/dining_option.dart';



class MenuDetailsPage extends StatelessWidget {
  final DiningOption diningOption;

  const MenuDetailsPage({super.key, required this.diningOption});

  @override
  Widget build(BuildContext context) {
    List<String> menuSections = diningOption.menuDetails.split('\n\n');
    String priceSection = menuSections.removeLast(); // Extraer la sección de precio

    return Scaffold(
      appBar: AppBar(
        title: Text(diningOption.name),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        color: const Color.fromARGB(255, 235, 170, 67), // Fondo anaranjado suave
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: menuSections.length,
                itemBuilder: (context, index) {
                  List<String> sectionItems = menuSections[index].split('\n');
                  String sectionTitle = sectionItems[0];
                  List<String> items = sectionItems.sublist(1);

                  return Card(
                    color: Colors.white,
                    elevation: 4.0,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(sectionTitle),
                          const SizedBox(height: 8.0),
                          ...items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(item),
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Text(
              priceSection,
              style: const TextStyle(
                fontSize: 20.0, // Tamaño de letra más grande para el precio
                fontWeight: FontWeight.normal, // Letra en negrita
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Añadir lógica para manejar el pago
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Color naranja para el botón
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text(
                'Pagar',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), // Texto en negrita
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String sectionTitle) {
    return Row(
      children: [
        Icon(
          _getIconForSection(sectionTitle),
          color: Colors.orange,
        ),
        const SizedBox(width: 8.0),
        Text(
          sectionTitle,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  IconData _getIconForSection(String sectionTitle) {
    switch (sectionTitle.toLowerCase()) {
      case 'entrantes:':
        return Icons.fastfood;
      case 'platos principales:':
        return Icons.restaurant;
      case 'postres:':
        return Icons.cake;
      default:
        return Icons.money;
    }
  }
}

