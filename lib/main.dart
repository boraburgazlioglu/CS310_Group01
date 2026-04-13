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
      home: HomeScreen(),
      routes: {
        '/notifications': (context) => const NotificationsPage(),
        '/gigs': (context) => const UpcomingGigsScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage(),
        '/songs': (context) => const SongReadinessScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

