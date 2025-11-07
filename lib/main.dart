import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Configure aqui a publishable key do Stripe (modo teste)
  Stripe.publishableKey =
      "pk_test_51SPcftFplV8Hq8XnCGDfv6z4l1HaEzv9TkQGxXOdeizqZvFM6JzrRktoLKLlMU8usQx4PudTiUrqaVZGVz4mlupp0042CgVwjf"; // substitua pela sua chave

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
