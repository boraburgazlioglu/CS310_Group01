import 'package:flutter/material.dart';

/// Bottom navigation for BandMate shell tabs.
class BotNavBar extends StatelessWidget {
  const BotNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

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
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (final item in _items)
          NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
          ),
      ],
    );
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
