import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/padding.dart';
import '../utils/text.dart';

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
  final TextEditingController _search = TextEditingController();

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
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _allGigs
        : _allGigs
            .where((g) => g.title.toLowerCase().contains(query))
            .toList();

    // Shell içinde Material altlığı; TextField + dolgulu butonlar için gerekli.
    // Üst bar ve alt nav [BandmateShell] içinde — burada tekrarlanmaz.
    return Material(
      color: AppColors.background,
      child: Column(
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
              'Upcoming Gigs — ${UpcomingGigsScreen.bandName}',
              style: AppTexts.headS,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppPadding.L,
              vertical: AppPadding.M,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
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
                    backgroundColor:
                        AppColors.widgetLight.withValues(alpha: 0.35),
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filter',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(
                AppPadding.L,
                0,
                AppPadding.L,
                88,
              ),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => SizedBox(height: AppPadding.M),
              itemBuilder: (context, index) {
                final g = filtered[index];
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
                                color: AppColors.widgetLight.withValues(
                                  alpha: 0.25,
                                ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          g.title,
                                          style: AppTexts.bodyL.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      if (g.showMapIcon)
                                        Icon(
                                          Icons.map_outlined,
                                          size: 20,
                                          color: AppColors.primary,
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: AppPadding.S),
                                  Text(
                                    'Date: ${g.date}',
                                    style: AppTexts.bodyM,
                                  ),
                                  Text(
                                    'Time: ${g.time}',
                                    style: AppTexts.bodyM,
                                  ),
                                  Text(
                                    'Location: ${g.location}',
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
