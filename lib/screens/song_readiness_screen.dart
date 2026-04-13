import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/padding.dart';
import '../utils/text.dart';

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
    return Material(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppPadding.S,
              0,
              AppPadding.L,
              AppPadding.S,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.primary,
                  tooltip: 'Back',
                ),
                Expanded(
                  child: Text(
                    'Song Readiness — $bandName',
                    style: AppTexts.headS,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.M,
                vertical: AppPadding.S,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: AppPadding.allM,
                        child: DataTable(
                          headingRowColor: WidgetStatePropertyAll(
                            AppColors.surface.withValues(alpha: 0.65),
                          ),
                          dataRowColor: WidgetStatePropertyAll(
                            AppColors.white,
                          ),
                          border: TableBorder.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            width: 1,
                          ),
                          columns: [
                            DataColumn(
                              label: Text(
                                'Song',
                                style: AppTexts.bodyL.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            ..._members.map(
                              (m) => DataColumn(
                                label: Text(
                                  m,
                                  style: AppTexts.bodyL.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
                                      style: AppTexts.bodyL,
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
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppPadding.L,
              AppPadding.M,
              AppPadding.L,
              88,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Legend',
                    style: AppTexts.bodyL.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppPadding.M),
                  _LegendRow(
                    icon: _StatusIcon(status: _Readiness.ready, compact: true),
                    label: 'Ready',
                  ),
                  SizedBox(height: AppPadding.S),
                  _LegendRow(
                    icon: _StatusIcon(
                      status: _Readiness.inProgress,
                      compact: true,
                    ),
                    label: 'Work in Progress',
                  ),
                  SizedBox(height: AppPadding.S),
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
      ),
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
        return Icon(
          Icons.check_circle,
          color: AppColors.widgetDark,
          size: size,
        );
      case _Readiness.inProgress:
        return Icon(
          Icons.warning_amber_rounded,
          color: AppColors.primary,
          size: size,
        );
      case _Readiness.notStarted:
        return Icon(
          Icons.horizontal_rule,
          color: AppColors.error,
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
        SizedBox(width: AppPadding.M),
        Text(label, style: AppTexts.bodyM),
      ],
    );
  }
}
