import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/padding.dart';
import '../utils/text.dart';
import '../widgets/bandmate_header.dart';

class _GigItem {
  const _GigItem({
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    this.showMapIcon = false,
  });

  final String title;
  final String date;
  final String time;
  final String location;
  final bool showMapIcon;
}

class UpcomingGigsScreen extends StatefulWidget {
  const UpcomingGigsScreen({super.key});

  static const String bandName = 'Avareler';

  @override
  State<UpcomingGigsScreen> createState() => _UpcomingGigsScreenState();
}

class _UpcomingGigsScreenState extends State<UpcomingGigsScreen> {
  final TextEditingController _searchController = TextEditingController();

  static final List<_GigItem> _allGigs = [
    _GigItem(
      title: 'Offtown Festival',
      date: 'Sat, Jun 14, 2026',
      time: '8:00 PM',
      location: 'Main Stage, Riverside Park',
      showMapIcon: true,
    ),
    _GigItem(
      title: 'Campus Cafe Night',
      date: 'Fri, Jun 27, 2026',
      time: '7:30 PM',
      location: 'Student Union, Building B',
    ),
    _GigItem(
      title: 'Warehouse Sessions',
      date: 'Sat, Jul 5, 2026',
      time: '9:00 PM',
      location: 'District 4 Arts District',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _aramaDegisti() {
    setState(() {});
  }

  List<_GigItem> _filtrelenmisKonserler() {
    final String aranan = _searchController.text.trim().toLowerCase();

    if (aranan.isEmpty) {
      return List<_GigItem>.from(_allGigs);
    }

    final List<_GigItem> cikti = [];

    for (final _GigItem k in _allGigs) {
      final String baslikKucuk = k.title.toLowerCase();

      if (baslikKucuk.contains(aranan)) {
        cikti.add(k);
      }
    }

    return cikti;
  }

  @override
  Widget build(BuildContext context) {
    final List<_GigItem> ekrandaGosterilecek = _filtrelenmisKonserler();

    return Material(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BandmateHeader(),
          _buildSectionTitle(),
          _buildSearchRow(),
          Expanded(child: _buildGigList(ekrandaGosterilecek)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppPadding.L,
        AppPadding.M,
        AppPadding.L,
        AppPadding.S,
      ),
      child: Text(
        'Upcoming Gigs — ${UpcomingGigsScreen.bandName}',
        style: AppTexts.headS,
      ),
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
              onChanged: (_) {
                _aramaDegisti();
              },
              style: AppTexts.bodyL,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: AppTexts.bodyM,
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primary,
                ),
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

  Widget _buildGigList(List<_GigItem> gigs) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        AppPadding.L,
        0,
        AppPadding.L,
        88,
      ),
      itemCount: gigs.length,
      separatorBuilder: (BuildContext context, int i) {
        return SizedBox(height: AppPadding.M);
      },
      itemBuilder: (BuildContext context, int indeks) {
        final _GigItem buKonser = gigs[indeks];

        return _buildGigCard(buKonser);
      },
    );
  }

  Widget _buildGigCard(_GigItem konser) {
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
                      Icons.image_outlined,
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              konser.title,
                              style: AppTexts.bodyL.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (konser.showMapIcon)
                            Icon(
                              Icons.map_outlined,
                              size: 20,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                      SizedBox(height: AppPadding.S),
                      Text(
                        'Date: ${konser.date}',
                        style: AppTexts.bodyM,
                      ),
                      Text(
                        'Time: ${konser.time}',
                        style: AppTexts.bodyM,
                      ),
                      Text(
                        'Location: ${konser.location}',
                        style: AppTexts.bodyS,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppPadding.M),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: AppPadding.M,
                    horizontal: AppPadding.L,
                  ),
                ),
                onPressed: () {},
                child: Text('View Details', style: AppTexts.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
