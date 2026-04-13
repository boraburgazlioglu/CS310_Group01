import 'package:flutter/material.dart';

import '../widgets/bandmate_header.dart';
import 'home_screen.dart';
import 'song_readiness_screen.dart';
import 'upcoming_gigs_screen.dart';

class BandmateShell extends StatefulWidget {
  const BandmateShell({super.key});

  @override
  State<BandmateShell> createState() => _BandmateShellState();
}

class _BandmateShellState extends State<BandmateShell> {
  int _index = 0;

  static const List<_NavItem> _items = [
    _NavItem(label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home),
    _NavItem(
      label: 'Schedule',
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
    ),
    _NavItem(
      label: 'Gigs',
      icon: Icons.music_note_outlined,
      selectedIcon: Icons.music_note,
    ),
    _NavItem(
      label: 'Expenses',
      icon: Icons.attach_money,
      selectedIcon: Icons.attach_money,
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BandmateHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final item in _items)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
        ],
      ),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody() {
    switch (_index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const _PlaceholderScreen(
          title: 'Schedule',
          message: 'Rehearsals and calendar will appear here.',
        );
      case 2:
        return const UpcomingGigsScreen();
      case 3:
        return const _PlaceholderScreen(
          title: 'Expenses',
          message: 'Track shared band costs here.',
        );
      case 4:
        return const _PlaceholderScreen(
          title: 'Profile',
          message: 'Your band profile and settings.',
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget? _buildFab(BuildContext context) {
    switch (_index) {
      case 0:
        return FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add Song'),
        );
      case 2:
        return FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add Gig'),
        );
      default:
        return null;
    }
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}