import 'package:flutter/material.dart';
import 'screens/stellar_home_screen_simple.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe - Simple',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const StellarHomeScreenSimple(),
      debugShowCheckedModeBanner: false,
    );
  }
}
