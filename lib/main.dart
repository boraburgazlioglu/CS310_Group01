import 'package:cs310_2026/screens/expenses_screen.dart';
import 'package:cs310_2026/screens/rehearsal_screen.dart';
import 'package:flutter/material.dart';
import '../screens/screens.dart';

void main() {
  runApp(const BandmateApp());
}

class BandmateApp extends StatelessWidget {
  const BandmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      routes: {
        '/notifications': (context) => const NotificationsPage(),
        '/gigs': (context) => const UpcomingGigsScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage(),
        '/songs': (context) => const SongReadinessScreen(),
        '/rehearsals': (context) => const RehearsalScreen(),
        '/expenses': (context) => const ExpensesScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgotPass': (context) => const ForgotPasswordScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}

