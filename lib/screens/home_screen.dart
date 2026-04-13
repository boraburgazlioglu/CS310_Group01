import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text.dart';
import '../utils/padding.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // placeholder band data
  static const String _bandName = 'Group 1';
  static const String _userName = 'Idris';
  static const String _nextRehearsalDate = '25 March';
  static const String _nextRehearsalTime = '18:00';
  static const int _availableMembers = 3;
  static const int _totalMembers = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPadding.allL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // welcome message
              Text('Welcome, $_userName', style: AppTexts.headM),
              const SizedBox(height: 16),

              // upcoming rehearsal card
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upcoming Rehearsal', style: AppTexts.headS),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(_nextRehearsalDate, style: AppTexts.bodyL),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(_nextRehearsalTime, style: AppTexts.bodyL),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Members: $_availableMembers/$_totalMembers available',
                      style: AppTexts.bodyM,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('View Details', style: AppTexts.button),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // my bands section
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Bands', style: AppTexts.headS),
                    const SizedBox(height: 8),
                    _BandItem(name: 'Kinder'),
                    _BandItem(name: 'Avareler'),
                    _BandItem(name: 'Jazzesesh'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // quick actions
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Actions', style: AppTexts.headS),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            label: 'Add Availability',
                            icon: Icons.event_available,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickActionButton(
                            label: 'Add Gig',
                            icon: Icons.music_note,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            label: 'Add Expense',
                            icon: Icons.attach_money,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        // network image as band photo placeholder
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300',
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 60,
                                    color: AppColors.surface,
                                    child: Icon(Icons.image, color: AppColors.primary),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // recent activity
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Activity', style: AppTexts.headS),
                    const SizedBox(height: 8),
                    _ActivityItem(text: "New Song Added: 'Scotty Doesn't Know'"),
                    _ActivityItem(text: 'Gig Added: Offtown'),
                    _ActivityItem(text: 'Expense Added: Bass strings, Boss Katana 60W'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// reusable card container
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.allL,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _BandItem extends StatelessWidget {
  const _BandItem({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.vertS,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: AppTexts.bodyL),
          Icon(Icons.chevron_right, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppPadding.allM,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white, size: 16),
            const SizedBox(width: 6),
            Flexible(child: Text(label, style: AppTexts.bodyS.copyWith(color: AppColors.white))),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.vertS,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, color: AppColors.primary, size: 8),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTexts.bodyM)),
        ],
      ),
    );
  }
}