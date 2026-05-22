import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/band_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/colors.dart';
import '../utils/text.dart';
import '../utils/padding.dart';
import '../models/gig_model.dart';
import '../models/rehearsal_model.dart';
import '../services/gig_service.dart';
import '../services/rehearsal_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    final bandProvider = context.watch<BandProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: BandmateHeader(),
      body: SingleChildScrollView(
        padding: AppPadding.allL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello ${authProvider.profileDisplayName},',
              style: AppTexts.headM,
            ),
            Text(
              'Welcome to ${bandProvider.currentBandName}!',
              style: AppTexts.headM,
            ),
            const SizedBox(height: 32),
            //switch band card
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

            _UpcomingRehearsalCard(
              bandId: bandProvider.currentBandId,
              formatDateTime: _formatDateTime,
            ),

            const SizedBox(height: 16),

            _UpcomingGigCard(
              bandId: bandProvider.currentBandId,
              formatDateTime: _formatDateTime,
            ),
          ],
        ),
      ),

      bottomNavigationBar: MyNavBar(currentIndex: -1),
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

class _UpcomingRehearsalCard extends StatelessWidget {
  _UpcomingRehearsalCard({
    required this.bandId,
    required this.formatDateTime,
  });

  final String? bandId;
  final String Function(DateTime) formatDateTime;

  final RehearsalService _rehearsalService = RehearsalService();

  @override
  Widget build(BuildContext context) {
    if (bandId == null) {
      return _SectionCard(
        child: Text(
          'Select a band to see upcoming rehearsals.',
          style: AppTexts.bodyM,
        ),
      );
    }

    return StreamBuilder<List<Rehearsal>>(
      stream: _rehearsalService.getRehearsals(bandId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _SectionCard(
            child: Text(
              'Upcoming rehearsal could not be loaded.',
              style: AppTexts.bodyM.copyWith(color: AppColors.error),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _SectionCard(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final now = DateTime.now();

        final upcoming = (snapshot.data ?? [])
            .where(
              (rehearsal) =>
          rehearsal.startAt.isAfter(now) ||
              rehearsal.startAt.isAtSameMomentAs(now),
        )
            .toList();

        upcoming.sort((a, b) => a.startAt.compareTo(b.startAt));

        final rehearsal = upcoming.isEmpty ? null : upcoming.first;

        if (rehearsal == null) {
          return _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upcoming Rehearsal', style: AppTexts.headS),
                const SizedBox(height: 8),
                Text('No upcoming rehearsal yet.', style: AppTexts.bodyM),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/add-rehearsal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Add Rehearsal',
                      style: AppTexts.button.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upcoming Rehearsal', style: AppTexts.headS),
              const SizedBox(height: 8),
              Text(
                rehearsal.title,
                style: AppTexts.bodyL.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.play_arrow, color: AppColors.primary, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Start: ${formatDateTime(rehearsal.startAt)}',
                      style: AppTexts.bodyM,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.stop, color: AppColors.primary, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'End: ${formatDateTime(rehearsal.endAt)}',
                      style: AppTexts.bodyM,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rehearsal.location,
                      style: AppTexts.bodyM,
                    ),
                  ),
                ],
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
                  child: Text(
                    'View Details',
                    style: AppTexts.button.copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
class _UpcomingGigCard extends StatelessWidget {
  _UpcomingGigCard({
    required this.bandId,
    required this.formatDateTime,
  });

  final String? bandId;
  final String Function(DateTime) formatDateTime;

  final GigService _gigService = GigService();

  @override
  Widget build(BuildContext context) {
    if (bandId == null) {
      return _SectionCard(
        child: Text(
          'Select a band to see upcoming gigs.',
          style: AppTexts.bodyM,
        ),
      );
    }

    return StreamBuilder<List<Gig>>(
      stream: _gigService.getGigs(bandId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _SectionCard(
            child: Text(
              'Upcoming gig could not be loaded.',
              style: AppTexts.bodyM.copyWith(color: AppColors.error),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _SectionCard(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final now = DateTime.now();

        final upcoming = (snapshot.data ?? [])
            .where(
              (gig) =>
          gig.scheduledAt.isAfter(now) ||
              gig.scheduledAt.isAtSameMomentAs(now),
        )
            .toList();

        upcoming.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

        final gig = upcoming.isEmpty ? null : upcoming.first;

        if (gig == null) {
          return _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upcoming Gig', style: AppTexts.headS),
                const SizedBox(height: 8),
                Text('No upcoming gig yet.', style: AppTexts.bodyM),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/add-gig'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Add Gig',
                      style: AppTexts.button.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upcoming Gig', style: AppTexts.headS),
              const SizedBox(height: 8),
              Text(
                gig.title,
                style: AppTexts.bodyL.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      formatDateTime(gig.scheduledAt),
                      style: AppTexts.bodyM,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      gig.location,
                      style: AppTexts.bodyM,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/gigs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'View Details',
                    style: AppTexts.button.copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}