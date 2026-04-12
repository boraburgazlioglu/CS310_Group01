import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _allGigs
        : _allGigs
            .where((g) => g.title.toLowerCase().contains(query))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Upcoming Gigs — ${UpcomingGigsScreen.bandName}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final g = filtered[index];
              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
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
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.image_outlined,
                                size: 36,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        g.title,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (g.showMapIcon)
                                      Icon(
                                        Icons.map_outlined,
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Date: ${g.date}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  'Time: ${g.time}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  'Location: ${g.location}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonal(
                          onPressed: () {},
                          child: const Text('View Details'),
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
    );
  }
}
