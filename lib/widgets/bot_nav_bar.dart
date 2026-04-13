import 'package:flutter/material.dart';
import '../utils/colors.dart';

class MyNavBar extends StatelessWidget {
  final int currentIndex;

  const MyNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    //placeholder page names!!!
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/rehearsals');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/gigs');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/expenses');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/songs');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.surface,
      currentIndex: currentIndex < 0 ? 0 : currentIndex,
      selectedItemColor: currentIndex < 0
          ? AppColors.textSecondary
          : AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: TextStyle(
        color: currentIndex < 0 ? AppColors.textSecondary : AppColors.primary,
      ),
      type: BottomNavigationBarType.fixed,
      onTap: (index) => _onTap(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule_outlined),
          activeIcon: Icon(Icons.schedule),
          label: 'Rehearsals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.music_note_outlined),
          activeIcon: Icon(Icons.music_note),
          label: 'Gigs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money_outlined),
          activeIcon: Icon(Icons.attach_money),
          label: 'Expenses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music_outlined),
          activeIcon: Icon(Icons.library_music),
          label: 'Songs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}