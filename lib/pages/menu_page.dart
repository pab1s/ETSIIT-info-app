import 'dart:async';
import '../entities/dining_option.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'menudetails_page.dart';
import 'navigation_page.dart';
import 'package:light/light.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late CarouselController _carouselController;
  StreamSubscription<AccelerometerEvent>? _streamSubscription;
  int? expandedDiningOptionIndex;
  int _currentCarouselIndex = 0;
  Light? _light;
  StreamSubscription? _lightSubscription;
  bool _darkMode = false;

  final List<DiningOption> diningOptions = [
    DiningOption(
        name: "Comedor ETSIIT",
        menuDetails: menutext,
        latitude: 37.19707,
        longitude: -3.62460),
    DiningOption(
        name: "Comedor PTS",
        menuDetails: menutext,
        latitude: 37.14666,
        longitude: -3.60571),
    DiningOption(
        name: "Comedor Fuentenueva",
        menuDetails: menutext,
        latitude: 37.18274,
        longitude: -3.60564),
  ];

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselController();
    _light = Light();
    _lightSubscription = _light?.lightSensorStream.listen((luxValue) {
      setState(() {
        _darkMode = luxValue < 100;
      });
    });
    _streamSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        if (event.x > 4) {
          _carouselController.nextPage();
        } else if (event.x < -4) {
          _carouselController.previousPage();
        }
      },
      onError: (error) {
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
        title: const Text('Comedores'),
        backgroundColor: const Color.fromRGBO(255, 152, 0, 1),
      ),
      body: Column(
        children: [
          const SizedBox(height: 150),
          CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              autoPlay: false,
              enlargeCenterPage: true,
              height: 300,
              viewportFraction: 0.9,
              aspectRatio: 2.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentCarouselIndex = index;
                  if (expandedDiningOptionIndex != null) {
                    expandedDiningOptionIndex = index;
                  }
                });
              },
            ),
            items: List.generate(diningOptions.length, (index) {
              DiningOption diningOption = diningOptions[index];
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (expandedDiningOptionIndex == index) {
                          expandedDiningOptionIndex = null;
                        } else {
                          expandedDiningOptionIndex = index;
                        }
                      });
                    },
                    child: Container(
                      width: 300,
                      height: 400,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        color: Colors.orange,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(Icons.restaurant_menu,
                                  size: 100, color: Colors.white),
                              Text(
                                diningOption.name,
                                style: const TextStyle(
                                    fontSize: 24.0, color: Colors.white),
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
          if (expandedDiningOptionIndex != null)
            _buildActionButtons(
                context, diningOptions[expandedDiningOptionIndex!]),
        ],
      ),
      backgroundColor: _darkMode ? Colors.black : Colors.white,
    );
  }

  Widget _buildActionButtons(BuildContext context, DiningOption diningOption) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MenuDetailsPage(diningOption: diningOption),
            ));
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text(
            "Ver Menú",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => NavigationPage(
                destLatitude: diningOption.latitude,
                destLongitude: diningOption.longitude,
              ),
            ));
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text(
            "Ver Dirección",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// La clase MenuDetailsPage se define en otro archivo.

void main() {
  runApp(const MaterialApp(
    title: 'Opciones del menú',
    home: MenuPage(),
  ));
}

const String menutext = '''
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

Precio........................................3.5€
''';
