import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/rehearsal_model.dart';
import '../providers/band_provider.dart';
import '../services/rehearsal_service.dart';
import '../utils/colors.dart';
import '../utils/padding.dart';
import '../utils/text.dart';
import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';

class RehearsalScreen extends StatefulWidget {
  const RehearsalScreen({super.key});

  @override
  State<RehearsalScreen> createState() => _RehearsalScreenState();
}

class _RehearsalScreenState extends State<RehearsalScreen> {
  final RehearsalService _rehearsalService = RehearsalService();

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

  void _deleteRehearsal(String id) {
    _rehearsalService.deleteRehearsal(id);
  }

  @override
  Widget build(BuildContext context) {
    final bandProvider = context.watch<BandProvider>();
    final bandId = bandProvider.currentBandId;

    if (bandId == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: const BandmateHeader(),
        body: Center(
          child: Padding(
            padding: AppPadding.allL,
            child: Text(
              'Please select a band first.',
              style: AppTexts.bodyL,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        bottomNavigationBar: const MyNavBar(currentIndex: 0),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const BandmateHeader(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-rehearsal');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Rehearsal',
          style: AppTexts.button.copyWith(color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<Rehearsal>>(
        stream: _rehearsalService.getRehearsals(bandId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: AppPadding.allL,
                child: Text(
                  'Rehearsals could not be loaded: ${snapshot.error}',
                  style: AppTexts.bodyM.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rehearsals = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppPadding.L,
                  AppPadding.M,
                  AppPadding.L,
                  AppPadding.S,
                ),
                child: Text(
                  'Rehearsals — ${bandProvider.displayBandName}',
                  style: AppTexts.headS,
                ),
              ),
              Expanded(
                child: _buildRehearsalList(rehearsals),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const MyNavBar(currentIndex: 0),
    );
  }

  Widget _buildRehearsalList(List<Rehearsal> rehearsals) {
    if (rehearsals.isEmpty) {
      return Center(
        child: Text(
          'No rehearsals yet. Add one!',
          style: AppTexts.bodyM,
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        AppPadding.L,
        0,
        AppPadding.L,
        88,
      ),
      itemCount: rehearsals.length,
      separatorBuilder: (_, __) => SizedBox(height: AppPadding.M),
      itemBuilder: (context, index) {
        return _buildRehearsalCard(rehearsals[index]);
      },
    );
  }

  Widget _buildRehearsalCard(Rehearsal rehearsal) {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: AppPadding.allM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              rehearsal.title,
              style: AppTexts.bodyL.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppPadding.S),

            Row(
              children: [
                Icon(
                  Icons.play_arrow,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Start: ${_formatDateTime(rehearsal.startAt)}',
                    style: AppTexts.bodyM,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppPadding.S),

            Row(
              children: [
                Icon(
                  Icons.stop,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'End: ${_formatDateTime(rehearsal.endAt)}',
                    style: AppTexts.bodyM,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppPadding.S),

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

            SizedBox(height: AppPadding.M),

            Row(
              children: [
                IconButton(
                  onPressed: () => _deleteRehearsal(rehearsal.id),
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.widgetDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}