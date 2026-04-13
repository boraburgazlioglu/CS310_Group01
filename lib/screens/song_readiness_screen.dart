import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/padding.dart';
import '../utils/text.dart';
import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';

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

  static TextStyle get _sutunBaslikStili {
    return AppTexts.bodyL.copyWith(fontWeight: FontWeight.w700);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: BandmateHeader(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle(),
            Expanded(child: _buildTableArea()),
            _buildLegendArea(),
          ],
        ),
        bottomNavigationBar: MyNavBar(currentIndex: 3),
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
        'Song Readiness — $bandName',
        style: AppTexts.headS,
      ),
    );
  }

  Widget _buildTableArea() {
    return Padding(
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
                child: _buildReadinessTable(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadinessTable() {
    final List<DataColumn> kolonlar = [];

    kolonlar.add(
      DataColumn(
        label: Text('Song', style: _sutunBaslikStili),
      ),
    );

    for (final String uyeAdi in _members) {
      kolonlar.add(
        DataColumn(
          label: Text(uyeAdi, style: _sutunBaslikStili),
        ),
      );
    }

    final List<DataRow> tabloSatirlari = [];

    for (final _SongRow satir in _rows) {
      final List<DataCell> hucreler = [];

      hucreler.add(
        DataCell(
          SizedBox(
            width: 160,
            child: Text(satir.title, style: AppTexts.bodyL),
          ),
        ),
      );

      for (final _Readiness durum in satir.cells) {
        hucreler.add(DataCell(_StatusIcon(status: durum)));
      }

      tabloSatirlari.add(DataRow(cells: hucreler));
    }

    return DataTable(
      headingRowColor: WidgetStatePropertyAll(
        AppColors.surface.withValues(alpha: 0.65),
      ),
      dataRowColor: WidgetStatePropertyAll(AppColors.white),
      border: TableBorder.all(
        color: AppColors.primary.withValues(alpha: 0.25),
        width: 1,
      ),
      columns: kolonlar,
      rows: tabloSatirlari,
    );
  }

  Widget _buildLegendArea() {
    return Padding(
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
              style: AppTexts.bodyL.copyWith(fontWeight: FontWeight.w700),
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
    final double ikonBoyutu = compact ? 22.0 : 26.0;

    switch (status) {
      case _Readiness.ready:
        return Icon(
          Icons.check_circle,
          color: AppColors.widgetDark,
          size: ikonBoyutu,
        );
      case _Readiness.inProgress:
        return Icon(
          Icons.warning_amber_rounded,
          color: AppColors.primary,
          size: ikonBoyutu,
        );
      case _Readiness.notStarted:
        return Icon(
          Icons.horizontal_rule,
          color: AppColors.error,
          size: ikonBoyutu + 4,
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
