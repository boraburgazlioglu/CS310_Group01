import 'package:flutter/material.dart';

import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';
import 'song_readiness_screen.dart';
import 'upcoming_gigs_screen.dart';

class BandmateShell extends StatefulWidget {
  const BandmateShell({super.key});

  @override
  State<BandmateShell> createState() => _BandmateShellState();
}

class _BandmateShellState extends State<BandmateShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BotNavBar(
        selectedIndex: _index,
        onDestinationSelected: (int i) => setState(() => _index = i),
      ),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody() {
    switch (_index) {
      case 0:
        return const SongReadinessScreen();
      case 1:
        return _PlaceholderScreen(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BandmateHeader(),
        Expanded(
          child: Center(
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
          ),
        ),
      ],
    );
  }
}
