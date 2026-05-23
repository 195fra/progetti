// ═══════════════════════════════════════════════════════
//  main.dart
//
//  In Android avevi:
//    @HiltAndroidApp class MyApp : Application()
//    @AndroidEntryPoint class MainActivity
//
//  In Flutter:
//    ProviderScope = @HiltAndroidApp (radice di Riverpod)
//    Non serve @AndroidEntryPoint — ogni widget legge
//    i provider tramite ConsumerWidget e ref.watch()
// ═══════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/screens/home_screen.dart';

void main() {
  runApp(
    // ProviderScope = equivalente al tuo @HiltAndroidApp
    // Deve avvolgere tutta l'app — come ProviderScope in Flutter
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5AFE)),
      ),
      home: const HomeScreen(),
    );
  }
}
