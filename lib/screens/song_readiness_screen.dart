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

enum _Readiness { ready, inProgress, notStarted }

class SongReadinessScreen extends StatefulWidget {
  const SongReadinessScreen({super.key});

  @override
  State<SongReadinessScreen> createState() => _SongReadinessScreenState();
}

class _SongReadinessScreenState extends State<SongReadinessScreen> {
  final SongService _songService = SongService();
  final TextEditingController _titleController = TextEditingController();

  // placeholder until auth is integrated
  final String _bandId = 'group1';
  final List<String> _members = ['Idris', 'Bora', 'Taha', 'Berke'];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAddSongDialog() {
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
            onPressed: () {
              if (_titleController.text.trim().isNotEmpty) {
                // save to firestore
                _songService.addSong(
                  title: _titleController.text.trim(),
                  bandId: _bandId,
                  createdBy:
                      ctx.read<AuthProvider>().createdByForFirestore,
                  memberIds: _members,
                );
                _titleController.clear();
                Navigator.pop(ctx);
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
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: BandmateHeader(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSongDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Song',
            style: AppTexts.button.copyWith(color: Colors.white)),
      ),
      body: StreamBuilder<List<Song>>(
        stream: _songService.getSongs(_bandId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No songs yet. Add one!', style: AppTexts.bodyM),
            );
          }

          final songs = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    AppPadding.L, AppPadding.M, AppPadding.L, AppPadding.S),
                child: Text('Song Readiness — Group 1', style: AppTexts.headS),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppPadding.M, vertical: AppPadding.S),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35)),
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
                                  AppColors.surface.withValues(alpha: 0.65)),
                              border: TableBorder.all(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                width: 1,
                              ),
                              columns: [
                                DataColumn(
                                    label: Text('Song',
                                        style: AppTexts.bodyL.copyWith(
                                            fontWeight: FontWeight.w700))),
                                for (final m in _members)
                                  DataColumn(
                                      label: Text(m,
                                          style: AppTexts.bodyL.copyWith(
                                              fontWeight: FontWeight.w700))),
                                DataColumn(label: const Text('')),
                              ],
                              rows: songs.map((song) {
                                return DataRow(cells: [
                                  DataCell(SizedBox(
                                    width: 160,
                                    child: Text(song.title,
                                        style: AppTexts.bodyL),
                                  )),
                                  for (final m in _members)
                                    DataCell(
                                      GestureDetector(
                                        onTap: () {
                                          // cycle through readiness statuses on tap
                                          final current =
                                              song.memberReadiness[m] ??
                                                  'notStarted';
                                          final next = current == 'notStarted'
                                              ? 'inProgress'
                                              : current == 'inProgress'
                                              ? 'ready'
                                              : 'notStarted';
                                          _updateReadiness(song.id, m, next);
                                        },
                                        child: _StatusIcon(
                                          status: _parseReadiness(
                                              song.memberReadiness[m] ??
                                                  'notStarted'),
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
                                ]);
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