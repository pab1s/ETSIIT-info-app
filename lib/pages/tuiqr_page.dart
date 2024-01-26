import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class TuiQrPage extends StatelessWidget {
  const TuiQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBar(title: "TUI y QR"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/tui.jpg'),
            const SizedBox(height: 20),
            Image.asset('assets/luiscrespo-QR.png'),
          ],
        ),
      ),
    );
  }
}
