import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gig_model.dart';
import '../providers/auth_provider.dart';
import '../services/gig_service.dart';
import '../utils/colors.dart';
import '../utils/padding.dart';
import '../utils/text.dart';
import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';
import '../providers/band_provider.dart';

class UpcomingGigsScreen extends StatefulWidget {
  const UpcomingGigsScreen({super.key});

  static const String bandName = 'Avareler';

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

  void _showAddGigDialog() {
    final titleController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final locationController = TextEditingController();
    final bandId = context.read<BandProvider>().currentBandId;
    if (bandId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a band first.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Add Gig', style: AppTexts.headS),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(titleController, 'Gig title'),
              const SizedBox(height: 10),
              _buildDialogField(dateController, 'Date (e.g. Sat, Jun 14, 2026)'),
              const SizedBox(height: 10),
              _buildDialogField(timeController, 'Time (e.g. 8:00 PM)'),
              const SizedBox(height: 10),
              _buildDialogField(locationController, 'Location'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTexts.button),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                // save to firestore
                _gigService.addGig(
                  title: titleController.text.trim(),
                  date: dateController.text.trim(),
                  time: timeController.text.trim(),
                  location: locationController.text.trim(),
                  bandId: bandId,
                  createdBy:
                      ctx.read<AuthProvider>().createdByForFirestore,
                );
                Navigator.pop(ctx);
              }
            },
            child: Text('Add', style: AppTexts.button),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Gig gig) {
    final titleController = TextEditingController(text: gig.title);
    final dateController = TextEditingController(text: gig.date);
    final timeController = TextEditingController(text: gig.time);
    final locationController = TextEditingController(text: gig.location);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Edit Gig', style: AppTexts.headS),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(titleController, 'Gig title'),
              const SizedBox(height: 10),
              _buildDialogField(dateController, 'Date'),
              const SizedBox(height: 10),
              _buildDialogField(timeController, 'Time'),
              const SizedBox(height: 10),
              _buildDialogField(locationController, 'Location'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTexts.button),
          ),
          TextButton(
            onPressed: () {
              // update in firestore
              _gigService.updateGig(
                id: gig.id,
                title: titleController.text.trim(),
                date: dateController.text.trim(),
                time: timeController.text.trim(),
                location: locationController.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: Text('Save', style: AppTexts.button),
          ),
        ],
      ),
    );
  }

  void _deleteGig(String id) {
    _gigService.deleteGig(id);
  }

  Widget _buildDialogField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: AppTexts.bodyL,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTexts.bodyM,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bandId = context.read<BandProvider>().currentBandId;

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
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: BandmateHeader(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGigDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Gig',
            style: AppTexts.button.copyWith(color: Colors.white)),
      ),
      body: StreamBuilder<List<Gig>>(
        stream: _gigService.getGigs(bandId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: AppPadding.allL,
                child: Text(
                  'Gig listesi yüklenemedi: ${snapshot.error}',
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

          // filter by search
          final allGigs = snapshot.data ?? [];
          final query = _searchController.text.trim().toLowerCase();
          final gigs = query.isEmpty
              ? allGigs
              : allGigs
                  .where((g) => g.title.toLowerCase().contains(query))
                  .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle(),
              _buildSearchRow(),
              Expanded(child: _buildGigList(gigs)),
            ],
          );
        },
      ),
      bottomNavigationBar: MyNavBar(currentIndex: 1),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppPadding.L, AppPadding.M, AppPadding.L, AppPadding.S),
      child: Text(
        'Upcoming Gigs — ${UpcomingGigsScreen.bandName}',
        style: AppTexts.headS,
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppPadding.L, vertical: AppPadding.M),
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
                      color: AppColors.primary.withValues(alpha: 0.35)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                  BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: AppPadding.L, vertical: AppPadding.M),
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
        child: Text('No gigs yet. Add one!', style: AppTexts.bodyM),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(AppPadding.L, 0, AppPadding.L, 88),
      itemCount: gigs.length,
      separatorBuilder: (_, __) => SizedBox(height: AppPadding.M),
      itemBuilder: (_, index) => _buildGigCard(gigs[index]),
    );
  }

  Widget _buildGigCard(Gig gig) {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
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
                    child: Icon(Icons.music_note,
                        size: 36, color: AppColors.widgetDark),
                  ),
                ),
                SizedBox(width: AppPadding.M),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gig.title,
                          style: AppTexts.bodyL
                              .copyWith(fontWeight: FontWeight.w700)),
                      SizedBox(height: AppPadding.S),
                      Text('Date: ${gig.date}', style: AppTexts.bodyM),
                      Text('Time: ${gig.time}', style: AppTexts.bodyM),
                      Text('Location: ${gig.location}',
                          style: AppTexts.bodyS),
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
                    child: Text('View Details', style: AppTexts.button),
                  ),
                ),
                SizedBox(width: AppPadding.S),
                // edit button
                IconButton(
                  onPressed: () => _showEditDialog(gig),
                  icon: const Icon(Icons.edit_outlined),
                  color: AppColors.primary,
                ),
                // delete button
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