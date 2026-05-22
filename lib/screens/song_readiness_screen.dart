import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/auth_provider.dart';
import '../services/song_service.dart';
import '../utils/colors.dart';
import '../utils/padding.dart';
import '../utils/text.dart';
import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';
import '../providers/band_provider.dart';
import '../services/band_service.dart';

enum _Readiness { ready, inProgress, notStarted }

class SongReadinessScreen extends StatefulWidget {
  const SongReadinessScreen({super.key});

  @override
  State<SongReadinessScreen> createState() => _SongReadinessScreenState();
}

class _SongReadinessScreenState extends State<SongReadinessScreen> {
  final SongService _songService = SongService();
  final TextEditingController _titleController = TextEditingController();
  final BandService _bandService = BandService();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAddSongDialog(List<BandMember> members) {
    final bandId = context.read<BandProvider>().currentBandId;

    if (bandId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a band first.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Add Song', style: AppTexts.headS),
        content: TextField(
          controller: _titleController,
          style: AppTexts.bodyL,
          decoration: InputDecoration(
            hintText: 'Song title',
            hintStyle: AppTexts.bodyM,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTexts.button),
          ),
          TextButton(
            onPressed: () async {
              final title = _titleController.text.trim();

              if (title.isEmpty) return;

              try {
                await _songService.addSong(
                  title: title,
                  bandId: bandId,
                  createdBy: context.read<AuthProvider>().createdByForFirestore,
                  memberIds: members.map((member) => member.id).toList(),
                );

                _titleController.clear();

                if (!mounted) return;
                Navigator.pop(ctx);
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not add song: $e')),
                );
              }
            },
            child: Text('Add', style: AppTexts.button),
          ),
        ],
      ),
    );
  }

  void _deleteSong(String songId) {
    _songService.deleteSong(songId);
  }

  void _updateReadiness(String songId, String memberId, String status) {
    _songService.updateReadiness(
      songId: songId,
      memberId: memberId,
      status: status,
    );
  }

  _Readiness _parseReadiness(String status) {
    switch (status) {
      case 'ready':
        return _Readiness.ready;
      case 'inProgress':
        return _Readiness.inProgress;
      default:
        return _Readiness.notStarted;
    }
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
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: BandmateHeader(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final members = await _bandService.getBandMembers(bandId).first;

          if (!mounted) return;

          if (members.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No band members found.'),
              ),
            );
            return;
          }

          _showAddSongDialog(members);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Song',
            style: AppTexts.button.copyWith(color: Colors.white)),
      ),
      body: StreamBuilder<List<BandMember>>(
        stream: _bandService.getBandMembers(bandId),
        builder: (context, memberSnapshot) {
          if (memberSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: AppPadding.allL,
                child: Text(
                  'Band members could not be loaded: ${memberSnapshot.error}',
                  style: AppTexts.bodyM.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!memberSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final members = memberSnapshot.data!;

          if (members.isEmpty) {
            return Center(
              child: Text(
                'No band members found.',
                style: AppTexts.bodyM,
              ),
            );
          }

          return StreamBuilder<List<Song>>(
            stream: _songService.getSongs(bandId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: AppPadding.allL,
                    child: Text(
                      'Song listesi yüklenemedi: ${snapshot.error}',
                      style: AppTexts.bodyM.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final songs = snapshot.data!;

              if (songs.isEmpty) {
                return Center(
                  child: Text(
                    'No songs yet. Add one!',
                    style: AppTexts.bodyM,
                  ),
                );
              }

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
                      'Song Readiness — ${bandProvider.displayBandName}',
                      style: AppTexts.headS,
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
                                    for (final member in members)
                                      DataColumn(
                                        label: Text(
                                          member.name,
                                          style: AppTexts.bodyL.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    const DataColumn(label: Text('')),
                                  ],
                                  rows: songs.map((song) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          SizedBox(
                                            width: 160,
                                            child: Text(
                                              song.title,
                                              style: AppTexts.bodyL,
                                            ),
                                          ),
                                        ),
                                        for (final member in members)
                                          DataCell(
                                            GestureDetector(
                                              onTap: () {
                                                final current =
                                                    song.memberReadiness[member.id] ??
                                                        'notStarted';

                                                final next = current == 'notStarted'
                                                    ? 'inProgress'
                                                    : current == 'inProgress'
                                                    ? 'ready'
                                                    : 'notStarted';

                                                _updateReadiness(
                                                  song.id,
                                                  member.id,
                                                  next,
                                                );
                                              },
                                              child: _StatusIcon(
                                                status: _parseReadiness(
                                                  song.memberReadiness[member.id] ??
                                                      'notStarted',
                                                ),
                                              ),
                                            ),
                                          ),
                                        DataCell(
                                          IconButton(
                                            onPressed: () => _deleteSong(song.id),
                                            icon: const Icon(Icons.delete_outline),
                                            color: AppColors.widgetDark,
                                          ),
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
                  _buildLegendArea(),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: MyNavBar(currentIndex: 3),
    );
  }

  Widget _buildLegendArea() {
    return Padding(
      padding:
      EdgeInsets.fromLTRB(AppPadding.L, AppPadding.M, AppPadding.L, 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Legend',
              style: AppTexts.bodyL.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: AppPadding.M),
          _LegendRow(
              icon: _StatusIcon(status: _Readiness.ready, compact: true),
              label: 'Ready'),
          SizedBox(height: AppPadding.S),
          _LegendRow(
              icon: _StatusIcon(status: _Readiness.inProgress, compact: true),
              label: 'Work in Progress'),
          SizedBox(height: AppPadding.S),
          _LegendRow(
              icon: _StatusIcon(status: _Readiness.notStarted, compact: true),
              label: 'Not Started'),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status, this.compact = false});

  final _Readiness status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 22.0 : 26.0;
    switch (status) {
      case _Readiness.ready:
        return Icon(Icons.check_circle, color: AppColors.widgetDark, size: size);
      case _Readiness.inProgress:
        return Icon(Icons.warning_amber_rounded,
            color: AppColors.primary, size: size);
      case _Readiness.notStarted:
        return Icon(Icons.horizontal_rule, color: AppColors.error, size: size + 4);
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