import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense_model.dart';
import '../models/gig_model.dart';
import '../models/rehearsal_model.dart';
import '../models/song_model.dart';
import '../providers/auth_provider.dart';
import '../providers/band_provider.dart';
import '../services/expense_service.dart';
import '../services/gig_service.dart';
import '../services/rehearsal_service.dart';
import '../services/song_service.dart';
import '../utils/colors.dart';
import '../utils/padding.dart';
import '../utils/text.dart';
import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: BandmateHeader(),
      body: SingleChildScrollView(
        padding: AppPadding.allL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello ${context.watch<AuthProvider>().profileDisplayName},',
              style: AppTexts.headM,
            ),
            Text(
              'Welcome to ${context.watch<BandProvider>().currentBandName}!',
              style: AppTexts.headM,
            ),
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Band', style: AppTexts.headS),
                  const SizedBox(height: 8),
                  Text(
                    context.watch<BandProvider>().displayBandName,
                    style: AppTexts.bodyL,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Invite Code: ${context.watch<BandProvider>().displayBandJoinCode}',
                    style: AppTexts.bodyM,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/band');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: AppPadding.vertM,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(Icons.swap_horiz, color: AppColors.white),
                      label: Text(
                        'Switch Band',
                        style: AppTexts.button.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _UpcomingRehearsalSection(
              bandId: context.watch<BandProvider>().currentBandId,
            ),
            const SizedBox(height: 16),
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
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _QuickActionButton(
                          label: 'Add Gig',
                          icon: Icons.music_note,
                          onTap: () => Navigator.pushNamed(context, '/gigs'),
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
                          onTap: () => Navigator.pushNamed(context, '/expenses'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _QuickActionButton(
                          label: 'Songs',
                          icon: Icons.library_music,
                          onTap: () => Navigator.pushNamed(context, '/songs'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _RecentActivitySection(
              bandId: context.watch<BandProvider>().currentBandId,
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyNavBar(currentIndex: -1),
    );
  }
}

class _UpcomingRehearsalSection extends StatelessWidget {
  const _UpcomingRehearsalSection({required this.bandId});

  final String? bandId;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming Rehearsal', style: AppTexts.headS),
          const SizedBox(height: 8),
          if (bandId == null)
            Text(
              'Select a band to see rehearsals.',
              style: AppTexts.bodyM.copyWith(color: AppColors.textSecondary),
            )
          else
            StreamBuilder<List<Rehearsal>>(
              stream: RehearsalService().getRehearsals(bandId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final rehearsals = snapshot.data ?? [];
                if (rehearsals.isEmpty) {
                  return Text(
                    'No rehearsals scheduled yet.',
                    style: AppTexts.bodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                }

                final next = rehearsals.first;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(next.date, style: AppTexts.bodyL),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${next.startTime} – ${next.endTime}',
                          style: AppTexts.bodyL,
                        ),
                      ],
                    ),
                    if (next.location.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        next.location,
                        style: AppTexts.bodyM,
                      ),
                    ],
                  ],
                );
              },
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/rehearsals'),
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
    );
  }
}

class _ActivityEntry {
  _ActivityEntry({required this.label, required this.createdAt});

  final String label;
  final DateTime? createdAt;
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({required this.bandId});

  final String? bandId;

  List<_ActivityEntry> _mergeActivities({
    required List<Gig> gigs,
    required List<Song> songs,
    required List<Expense> expenses,
  }) {
    final entries = <_ActivityEntry>[
      ...gigs.map(
        (g) => _ActivityEntry(
          label: 'Gig added: ${g.title}',
          createdAt: g.createdAt,
        ),
      ),
      ...songs.map(
        (s) => _ActivityEntry(
          label: 'Song added: ${s.title}',
          createdAt: s.createdAt,
        ),
      ),
      ...expenses.map(
        (e) => _ActivityEntry(
          label: 'Expense added: ${e.item}',
          createdAt: e.createdAt,
        ),
      ),
    ];

    entries.sort((a, b) {
      final at = a.createdAt;
      final bt = b.createdAt;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });

    return entries.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: AppTexts.headS),
          const SizedBox(height: 8),
          if (bandId == null)
            Text(
              'Select a band to see activity.',
              style: AppTexts.bodyM.copyWith(color: AppColors.textSecondary),
            )
          else
            StreamBuilder<List<Gig>>(
              stream: GigService().getGigs(bandId!),
              builder: (context, gigSnapshot) {
                return StreamBuilder<List<Song>>(
                  stream: SongService().getSongs(bandId!),
                  builder: (context, songSnapshot) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: ExpenseService().getExpenses(bandId!),
                      builder: (context, expenseSnapshot) {
                        if (gigSnapshot.connectionState ==
                                ConnectionState.waiting ||
                            songSnapshot.connectionState ==
                                ConnectionState.waiting ||
                            expenseSnapshot.connectionState ==
                                ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(8),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final expenses = (expenseSnapshot.data?.docs ?? [])
                            .map((doc) => Expense.fromFirestore(doc))
                            .toList();

                        final activities = _mergeActivities(
                          gigs: gigSnapshot.data ?? [],
                          songs: songSnapshot.data ?? [],
                          expenses: expenses,
                        );

                        if (activities.isEmpty) {
                          return Text(
                            'No recent activity yet.',
                            style: AppTexts.bodyM.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          );
                        }

                        return Column(
                          children: activities
                              .map((a) => _ActivityItem(text: a.label))
                              .toList(),
                        );
                      },
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.allL,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
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
            Flexible(
              child: Text(
                label,
                style: AppTexts.bodyS.copyWith(color: AppColors.white),
              ),
            ),
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
