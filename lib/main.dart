import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'utils/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BandMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: 'Limelight',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        // other routes will be added as we build each screen
      },
    );
  }
}