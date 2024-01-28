import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:etsiit_info_app/entities/dining_option.dart';
import '../services/biometrics_service.dart';

class MenuDetailsPage extends StatelessWidget {
  final DiningOption diningOption;
  final BiometricService _biometricService = BiometricService();

  MenuDetailsPage({super.key, required this.diningOption});

  @override
  Widget build(BuildContext context) {
    List<String> menuSections = diningOption.menuDetails.split('\n\n');
    String priceSection = menuSections.removeLast();

    return Scaffold(
      appBar: AppBar(
        title: Text(diningOption.name),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        color: const Color.fromARGB(255, 235, 170, 67),
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
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ))),
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
                fontSize: 20.0,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handlePayment(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text(
                'Pagar',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePayment(BuildContext context) async {
    try {
      // Verifica si el dispositivo tiene biometría disponible
      bool canCheckBiometrics = await _biometricService.hasBiometrics();

      if (!canCheckBiometrics) {
        _showErrorDialog(
            context, 'Biometría no disponible en este dispositivo');
        return;
      }

      // Obtiene los tipos de biometría disponibles
      List<BiometricType> availableBiometrics =
          await _biometricService.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        _showErrorDialog(context, 'No hay métodos biométricos disponibles');
        return;
      }

      // Intenta la autenticación biométrica
      bool authenticated = await _biometricService.authenticateWithBiometrics(
        localizedReason: 'Use su huella dactilar para autorizar el pago',
      );

      if (authenticated) {
        _showSuccessDialog(context);
      } else {
        _showErrorDialog(context, 'Autenticación fallida');
      }
    } on PlatformException catch (e) {
      _showErrorDialog(context, 'Error en la autenticación: ${e.message}');
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pago Exitoso'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('El pago se ha realizado con éxito.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
