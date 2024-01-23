import 'package:flutter/material.dart';
import '../widgets/bottom_bar.dart';
import 'home_page.dart';
import 'tuiqr_page.dart';
import 'mapa_page.dart';
import 'dialogflow.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: const <Widget>[
          HomePage(),
          TuiQrPage(),
          MapaPage(),
          ChatPage(),
        ],
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: _currentIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
