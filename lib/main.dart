import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // AUDITORIA: Configurar Firestore com logs detalhados
    if (kIsWeb) {
      final firestore = FirebaseFirestore.instance;

      // Desabilitar persistência em Web para evitar cache que ocultaria writes
      firestore.settings = const Settings(persistenceEnabled: false);

      // TESTE MÍNIMO: Criar documento DEBUG_TEST para validar conectividade
      try {
        final testRef = firestore
            .collection('DEBUG_TEST')
            .doc('connectivity_check');

        await testRef
            .set({
              'timestamp': DateTime.now().toUtc().toIso8601String(),
              'message': 'Teste de conectividade Firestore Web',
              'flutter': true,
            })
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                throw Exception('Firestore write timeout after 5s');
              },
            );
      } on Exception catch (_) {
        // Silent catch for connectivity test
      }
    }
  } catch (_) {
    rethrow; // preserve original behavior: propagate unexpected initialization errors
  }

  // Stripe apenas no mobile
  if (!kIsWeb) {
    Stripe.publishableKey = "stripe key here";
  }

  runApp(const ProviderScope(child: NoushokuApp()));
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
