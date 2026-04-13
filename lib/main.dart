import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/bandmate_shell.dart';
import 'utils/colors.dart';

void main() {
  runApp(const BandmateApp());
}

class BandmateApp extends StatelessWidget {
  const BandmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BandMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: 'Merriweather',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const BandmateShell(),
      },
    );
  }
}