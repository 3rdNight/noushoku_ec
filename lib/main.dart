import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("🔥 Firebase INICIALIZADO com sucesso!");
  } catch (e) {
    debugPrint("❌ Firebase NÃO inicializou: $e");
    rethrow; // <-- para o app, pra poder ver que deu erro
  }

  // Stripe apenas no mobile
  if (!kIsWeb) {
    Stripe.publishableKey = "stripe key here";
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const NoushokuApp(),
    ),
  );
}

class NoushokuApp extends StatelessWidget {
  const NoushokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noushoku_EC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepOrange,
        ).copyWith(secondary: Colors.deepOrangeAccent),
      ),
      home: const HomeScreen(),
    );
  }
}
