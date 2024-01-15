import 'dart:async';
import 'package:etsiit_info_app/entities/dining_option.dart';
import 'package:etsiit_info_app/pages/compass_page.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'menudetails_page.dart'; // Asegúrate de que esta página esté creada

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});
  
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late CarouselController _carouselController;
  StreamSubscription<AccelerometerEvent>? _streamSubscription;

  final List<DiningOption> diningOptions = [
    DiningOption(name: "Comedor PTS", menuDetails: menutext , latitude : lat , longitude: longi),
    DiningOption(name: "Comedor 2", menuDetails: menutext , latitude : lat , longitude: longi),
    DiningOption(name: "Comedor 3", menuDetails: menutext , latitude : lat , longitude: longi),
    // Añade más opciones según sea necesario
  ];

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselController();
    _streamSubscription = accelerometerEvents.listen(
      (AccelerometerEvent event) {
        if (event.x > 4) {
          _carouselController.nextPage();
        } else if (event.x < -4) {
          _carouselController.previousPage();
        }
      },onError: (error) {
          print('Error: $error');
      },
      cancelOnError: true,
      );
  }

  @override
  void dispose() {
  _streamSubscription?.cancel();
  super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Places to Eat'),
    ),
    body: Column(
      children: [
        SizedBox(height: 150), // Ajusta este valor para controlar el espacio superior
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            autoPlay: false,
            enlargeCenterPage: true,
            height: 300,
            viewportFraction: 0.9,
            aspectRatio: 2.0,
          ),
          items: diningOptions.map((diningOption) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(diningOption.name),
                          content: Text("Selecciona una opción"),
                          actions: <Widget>[
                            TextButton(
                              child: Text("Ver Menú"),
                              onPressed: () {
                                Navigator.pop(context); // Cierra el diálogo
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => MenuDetailsPage(diningOption: diningOption),
                                ));
                              },
                            ),/*
                            TextButton(
                              child: Text("Ver Direccion"),
                              onPressed: () {
                                Navigator.pop(context); // Cierra el diálogo
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => CompassPage(
                                    destinationAngle: 240
                                  ),
                                ));
                              },
                            ),*/
                          ],
                        );
                      },
                    );
                  },

                  child: Container(
                    width: 300, // Ancho de la tarjeta
                    height: 400, // Altura de la tarjeta
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Card(
                      color: Colors.orange,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.restaurant_menu, size: 100, color: Colors.white),
                            Text(
                              diningOption.name,
                              style: const TextStyle(fontSize: 24.0, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    ),
  );
}

}

// La clase MenuDetailsPage se define en otro archivo.

void main() {
  runApp(MaterialApp(
    title: 'Dining Options App',
    home: MenuPage(),
  ));
}


const String menutext =  '''
Entrantes:
- Ensalada César
- Sopa de tomate
- Bruschetta

Platos Principales:
- Lasaña de carne
- Pollo asado con verduras
- Filete de salmón a la parrilla

Postres:
- Tarta de queso
- Helado de vainilla
- Mousse de chocolate

''';

const double lat = 37.1481383;
const double longi = -3.6038452;
