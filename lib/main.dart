import 'package:flutter/material.dart';

import 'screens/bandmate_shell.dart';

void main() {
  runApp(const BandmateApp());
}

class BandmateApp extends StatelessWidget {
  const BandmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5C5C5C),
        brightness: Brightness.light,
        surface: const Color(0xFFF5F5F5),
      ),
    );

    return MaterialApp(
      title: 'BandMate',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: base.colorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: base.colorScheme.surface,
          foregroundColor: base.colorScheme.onSurface,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: base.colorScheme.surfaceContainerHighest,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? base.colorScheme.onSurface
                  : base.colorScheme.onSurfaceVariant,
            );
          }),
        ),
      ),
      home: const BandmateShell(),
    );
  }
}
