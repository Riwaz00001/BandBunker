import 'package:flutter/material.dart';
import 'package:frontend/screens/splash_screen.dart';
import 'pages/register.dart';
import 'pages/role_selection.dart';
import 'pages/room_owner_register.dart';

void main() {
  runApp(const BandBunker());
}

class BandBunker extends StatelessWidget {
  const BandBunker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Band Bunker',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),

      // First screen when application starts
      home: const SplashScreen(),
    );
  }
}