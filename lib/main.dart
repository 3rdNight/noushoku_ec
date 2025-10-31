import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(NoushokuApp());
}

class NoushokuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noushoku_EC',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const HomeScreen(),
    );
  }
}
