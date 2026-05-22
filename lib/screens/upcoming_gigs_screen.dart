import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/gig_model.dart';
import '../providers/band_provider.dart';
import '../services/gig_service.dart';
import '../utils/colors.dart';
import '../utils/padding.dart';
import '../utils/text.dart';
import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';

class UpcomingGigsScreen extends StatefulWidget {
  const UpcomingGigsScreen({super.key});

  @override
  State<UpcomingGigsScreen> createState() => _UpcomingGigsScreenState();
}

class _UpcomingGigsScreenState extends State<UpcomingGigsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GigService _gigService = GigService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  void _deleteGig(String id) {
    _gigService.deleteGig(id);
  }

  @override
  Widget build(BuildContext context) {
    final bandProvider = context.watch<BandProvider>();
    final bandId = bandProvider.currentBandId;

    if (bandId == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: BandmateHeader(),
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
        bottomNavigationBar: MyNavBar(currentIndex: 1),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: BandmateHeader(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-gig');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Gig',
          style: AppTexts.button.copyWith(color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<Gig>>(
        stream: _gigService.getGigs(bandId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: AppPadding.allL,
                child: Text(
                  'Gigs could not be loaded: ${snapshot.error}',
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

          final allGigs = snapshot.data ?? [];
          final query = _searchController.text.trim().toLowerCase();

          final gigs = query.isEmpty
              ? allGigs
              : allGigs
              .where((gig) => gig.title.toLowerCase().contains(query))
              .toList();

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
                  'Upcoming Gigs — ${bandProvider.displayBandName}',
                  style: AppTexts.headS,
                ),
              ),
              _buildSearchRow(),
              Expanded(
                child: _buildGigList(gigs),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: MyNavBar(currentIndex: 1),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.L,
        vertical: AppPadding.M,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: AppTexts.bodyL,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: AppTexts.bodyM,
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                isDense: true,
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppPadding.L,
                  vertical: AppPadding.M,
                ),
              ),
            ),
          ),
          SizedBox(width: AppPadding.M),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.widgetLight.withValues(alpha: 0.35),
              foregroundColor: AppColors.primary,
            ),
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
        ],
      ),
    );
  }

  Widget _buildGigList(List<Gig> gigs) {
    if (gigs.isEmpty) {
      return Center(
        child: Text(
          'No gigs yet. Add one!',
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
      itemCount: gigs.length,
      separatorBuilder: (_, __) => SizedBox(height: AppPadding.M),
      itemBuilder: (context, index) {
        return _buildGigCard(gigs[index]);
      },
    );
  }

  Widget _buildGigCard(Gig gig) {
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 88,
                    height: 72,
                    color: AppColors.widgetLight.withValues(alpha: 0.25),
                    child: Icon(
                      Icons.music_note,
                      size: 36,
                      color: AppColors.widgetDark,
                    ),
                  ),
                ),
                SizedBox(width: AppPadding.M),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gig.title,
                        style: AppTexts.bodyL.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: AppPadding.S),
                      Text(
                        'Date: ${_formatDate(gig.scheduledAt)}',
                        style: AppTexts.bodyM,
                      ),
                      Text(
                        'Time: ${_formatTime(gig.scheduledAt)}',
                        style: AppTexts.bodyM,
                      ),
                      Text(
                        'Location: ${gig.location}',
                        style: AppTexts.bodyS,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppPadding.M),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: () {},
                    child: Text(
                      'View Details',
                      style: AppTexts.button,
                    ),
                  ),
                ),
                SizedBox(width: AppPadding.S),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Edit gig screen will be added separately.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  color: AppColors.primary,
                ),
                IconButton(
                  onPressed: () => _deleteGig(gig.id),
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