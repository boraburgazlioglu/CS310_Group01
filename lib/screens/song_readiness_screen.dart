import 'package:flutter/material.dart';

enum _Readiness { ready, inProgress, notStarted }

class SongReadinessScreen extends StatelessWidget {
  const SongReadinessScreen({super.key});

  static const String bandName = 'Avareler';

  static final List<String> _members = ['Alex', 'Sam', 'Jordan', 'Chris'];

  static final List<_SongRow> _rows = [
    _SongRow(
      title: 'Scally Doesn\'t Know',
      cells: [
        _Readiness.ready,
        _Readiness.inProgress,
        _Readiness.notStarted,
        _Readiness.ready,
      ],
    ),
    _SongRow(
      title: 'Smells Like Teen Spirit',
      cells: [
        _Readiness.inProgress,
        _Readiness.ready,
        _Readiness.ready,
        _Readiness.inProgress,
      ],
    ),
    _SongRow(
      title: 'Come Together',
      cells: [
        _Readiness.notStarted,
        _Readiness.notStarted,
        _Readiness.inProgress,
        _Readiness.ready,
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 16, 4),
          child: Row(
            children: [
              BackButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              Expanded(
                child: Text(
                  'Song Readiness — $bandName',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(
                    theme.colorScheme.surfaceContainerHighest,
                  ),
                  border: TableBorder.all(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Song',
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    ..._members.map(
                      (m) => DataColumn(
                        label: Text(m, style: theme.textTheme.labelLarge),
                      ),
                    ),
                  ],
                  rows: _rows.map((row) {
                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 160,
                            child: Text(
                              row.title,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        ...row.cells.map(
                          (s) => DataCell(_StatusIcon(status: s)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Legend',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _LegendRow(
                  icon: _StatusIcon(status: _Readiness.ready, compact: true),
                  label: 'Ready',
                ),
                const SizedBox(height: 6),
                _LegendRow(
                  icon: _StatusIcon(
                    status: _Readiness.inProgress,
                    compact: true,
                  ),
                  label: 'Work in Progress',
                ),
                const SizedBox(height: 6),
                _LegendRow(
                  icon: _StatusIcon(
                    status: _Readiness.notStarted,
                    compact: true,
                  ),
                  label: 'Not Started',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SongRow {
  const _SongRow({required this.title, required this.cells});

  final String title;
  final List<_Readiness> cells;
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status, this.compact = false});

  final _Readiness status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 22.0 : 26.0;
    switch (status) {
      case _Readiness.ready:
        return Icon(Icons.check_circle, color: Colors.green.shade700, size: size);
      case _Readiness.inProgress:
        return Icon(
          Icons.warning_amber_rounded,
          color: Colors.amber.shade800,
          size: size,
        );
      case _Readiness.notStarted:
        return Icon(
          Icons.horizontal_rule,
          color: Colors.red.shade700,
          size: size + 4,
        );
    }
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 28, child: icon),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
