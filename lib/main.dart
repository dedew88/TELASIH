import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const TelasihApp());
}

class TelasihApp extends StatelessWidget {
  const TelasihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TELASIH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          primary: const Color(0xFF1A73E8),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A73E8),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}