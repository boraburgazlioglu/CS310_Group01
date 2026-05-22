import 'package:cs310_2026/screens/add_gig.dart';
import 'package:cs310_2026/screens/band_select.dart';
import 'package:cs310_2026/screens/expenses_screen.dart';
import 'package:cs310_2026/screens/rehearsal_screen.dart';
import 'package:cs310_2026/widgets/auth_gate.dart';
import 'package:flutter/material.dart';
import '../screens/screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'providers/song_provider.dart';
import 'providers/band_provider.dart';
import '../screens/add_rehearsal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //app wrapped in multiprovider with changeNotifier
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SongProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BandProvider(),
        ),
      ],
      child: const BandmateApp(),
    ),
  );
}

class BandmateApp extends StatelessWidget {
  const BandmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      routes: {
        '/notifications': (context) => const NotificationsPage(),
        '/gigs': (context) => const UpcomingGigsScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage(),
        '/songs': (context) => const SongReadinessScreen(),
        '/rehearsals': (context) => const RehearsalScreen(),
        '/expenses': (context) => const ExpensesScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgotPass': (context) => const ForgotPasswordScreen(),//dummy for now
        '/signup': (context) => const SignupScreen(),
        '/auth': (context) => const AuthGate(),
        '/band': (context) => const BandSelectionScreen(),
        '/add-rehearsal': (context) => const AddRehearsalScreen(),
        '/add-gig': (context) => const AddGigScreen(),
      },
    );
  }
}

