import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCU1se1aX7GWvadVmWYJ0k6GaY-t-WgEKA",
      authDomain: "telasih.firebaseapp.com",
      projectId: "telasih",
      storageBucket: "telasih.firebasestorage.app",
      messagingSenderId: "582587443674",
      appId: "1:582587443674:web:177c0066427f35e5cf38e3",
    ),
  );
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