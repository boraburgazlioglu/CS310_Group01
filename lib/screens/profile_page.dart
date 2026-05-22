import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile_availability_model.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../utils/colors.dart';
import '../utils/padding.dart';
import '../utils/text.dart';
import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
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

  Future<DateTime?> _pickDateTime({
    required BuildContext pickerContext,
    required DateTime initialDateTime,
    required bool allowPastDates,
  }) async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: pickerContext,
      initialDate: initialDateTime.isBefore(now) && !allowPastDates
          ? now
          : initialDateTime,
      firstDate: allowPastDates ? DateTime(2000) : now,
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return null;
    }

    if (!mounted) {
      return null;
    }

    final pickedTime = await showTimePicker(
      context: pickerContext,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    if (pickedTime == null) {
      return null;
    }

    if (!mounted) {
      return null;
    }

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  void _deleteSlot(String id) {
    _profileService.deleteSlot(id);
  }

  void _showAddSlotDialog() {
    DateTime? selectedStartAt;
    DateTime? selectedEndAt;

    final uid = context.read<AuthProvider>().user?.uid;

    if (uid == null) {
      _showError('You must be signed in to add a slot.');
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text('Add availability slot', style: AppTexts.headS),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final pickedStart = await _pickDateTime(
                            pickerContext: ctx,
                            initialDateTime: DateTime.now(),
                            allowPastDates: false,
                          );

                          if (pickedStart == null) {
                            return;
                          }

                          if (!mounted || !ctx.mounted) {
                            return;
                          }

                          setDialogState(() {
                            selectedStartAt = pickedStart;

                            if (selectedEndAt == null ||
                                !selectedEndAt!.isAfter(pickedStart)) {
                              selectedEndAt =
                                  pickedStart.add(const Duration(hours: 2));
                            }
                          });
                        },
                        icon: Icon(
                          Icons.play_arrow,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          'Select Start Date & Time',
                          style: AppTexts.button.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedStartAt == null
                          ? 'No start time selected'
                          : 'Start: ${_formatDateTime(selectedStartAt!)}',
                      style: AppTexts.bodyM,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final initialEnd = selectedEndAt ??
                              selectedStartAt?.add(const Duration(hours: 2)) ??
                              DateTime.now().add(const Duration(hours: 2));

                          final pickedEnd = await _pickDateTime(
                            pickerContext: ctx,
                            initialDateTime: initialEnd,
                            allowPastDates: false,
                          );

                          if (pickedEnd == null) {
                            return;
                          }

                          if (!mounted || !ctx.mounted) {
                            return;
                          }

                          setDialogState(() {
                            selectedEndAt = pickedEnd;
                          });
                        },
                        icon: Icon(
                          Icons.stop,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          'Select End Date & Time',
                          style: AppTexts.button.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedEndAt == null
                          ? 'No end time selected'
                          : 'End: ${_formatDateTime(selectedEndAt!)}',
                      style: AppTexts.bodyM,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: AppTexts.button),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedStartAt == null) {
                      _showError('Please select a start date and time.');
                      return;
                    }

                    if (selectedEndAt == null) {
                      _showError('Please select an end date and time.');
                      return;
                    }

                    if (!selectedEndAt!.isAfter(selectedStartAt!)) {
                      _showError('End time must be after start time.');
                      return;
                    }

                    try {
                      await _profileService.addSlot(
                        userId: uid,
                        startAt: selectedStartAt!,
                        endAt: selectedEndAt!,
                      );

                      if (!mounted || !ctx.mounted) {
                        return;
                      }

                      Navigator.pop(ctx);
                    } catch (e) {
                      if (!mounted) {
                        return;
                      }

                      _showError('Could not add slot: $e');
                    }
                  },
                  child: Text('Add', style: AppTexts.button),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditSlotDialog(ProfileAvailabilitySlot slot) {
    DateTime selectedStartAt = slot.startAt;
    DateTime selectedEndAt = slot.endAt;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text('Edit availability slot', style: AppTexts.headS),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final pickedStart = await _pickDateTime(
                            pickerContext: ctx,
                            initialDateTime: selectedStartAt,
                            allowPastDates: true,
                          );

                          if (pickedStart == null) {
                            return;
                          }

                          if (!mounted || !ctx.mounted) {
                            return;
                          }

                          setDialogState(() {
                            selectedStartAt = pickedStart;

                            if (!selectedEndAt.isAfter(selectedStartAt)) {
                              selectedEndAt =
                                  selectedStartAt.add(const Duration(hours: 2));
                            }
                          });
                        },
                        icon: Icon(
                          Icons.play_arrow,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          'Change Start Date & Time',
                          style: AppTexts.button.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start: ${_formatDateTime(selectedStartAt)}',
                      style: AppTexts.bodyM,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final pickedEnd = await _pickDateTime(
                            pickerContext: ctx,
                            initialDateTime: selectedEndAt,
                            allowPastDates: true,
                          );

                          if (pickedEnd == null) {
                            return;
                          }

                          if (!mounted || !ctx.mounted) {
                            return;
                          }

                          setDialogState(() {
                            selectedEndAt = pickedEnd;
                          });
                        },
                        icon: Icon(
                          Icons.stop,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          'Change End Date & Time',
                          style: AppTexts.button.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'End: ${_formatDateTime(selectedEndAt)}',
                      style: AppTexts.bodyM,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: AppTexts.button),
                ),
                TextButton(
                  onPressed: () async {
                    if (!selectedEndAt.isAfter(selectedStartAt)) {
                      _showError('End time must be after start time.');
                      return;
                    }

                    try {
                      await _profileService.updateSlot(
                        id: slot.id,
                        startAt: selectedStartAt,
                        endAt: selectedEndAt,
                      );

                      if (!mounted || !ctx.mounted) {
                        return;
                      }

                      Navigator.pop(ctx);
                    } catch (e) {
                      if (!mounted) {
                        return;
                      }

                      _showError('Could not update slot: $e');
                    }
                  },
                  child: Text('Save', style: AppTexts.button),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final profileName = auth.profileDisplayName;
    final email = user?.email ?? '—';
    final photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const BandmateHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPadding.allL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: AppTexts.headL,
              ),
              SizedBox(height: AppPadding.L),
              Container(
                width: double.infinity,
                padding: AppPadding.allL,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gray),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.gray,
                            border: Border.all(color: AppColors.black),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: photoUrl != null && photoUrl.isNotEmpty
                              ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _AvatarFallback(label: profileName);
                            },
                          )
                              : _AvatarFallback(label: profileName),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow(label: 'Name', value: profileName),
                              const SizedBox(height: 10),
                              _InfoRow(label: 'Email', value: email),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    if (user?.uid != null)
                      _InfoRow(
                        label: 'User ID',
                        value: user!.uid,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.gray),
                ),
                child: Padding(
                  padding: AppPadding.allL,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arrange Schedule',
                        style: AppTexts.headM,
                      ),
                      SizedBox(height: AppPadding.S),
                      Text(
                        'Add your available time slots. These slots are shared across all bands you are in.',
                        style: AppTexts.bodyM.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppPadding.M),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: _showAddSlotDialog,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppPadding.L,
                              vertical: AppPadding.S,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: AppColors.black),
                            backgroundColor: AppColors.surface,
                          ),
                          icon: Icon(
                            Icons.add,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'Add Slot',
                            style: AppTexts.button,
                          ),
                        ),
                      ),
                      SizedBox(height: AppPadding.M),
                      Text('Available Time Slots', style: AppTexts.headS),
                      SizedBox(height: AppPadding.S),
                      StreamBuilder<List<ProfileAvailabilitySlot>>(
                        stream: _profileService.watchSlotsForSignedInUser(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                              'Could not load slots: ${snapshot.error}',
                              style: AppTexts.bodyM.copyWith(
                                color: AppColors.error,
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting &&
                              !snapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }

                          final slots = snapshot.data ?? [];

                          if (slots.isEmpty) {
                            return Text(
                              'No time slots added yet.',
                              style: AppTexts.bodyM.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            );
                          }

                          return Column(
                            children: slots.map((slot) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: AppPadding.S),
                                child: Card(
                                  color: AppColors.surface,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: AppColors.gray,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.schedule_outlined,
                                      color: AppColors.primary,
                                    ),
                                    title: Text(
                                      '${_formatDate(slot.startAt)}',
                                      style: AppTexts.bodyM.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${_formatTime(slot.startAt)} - ${_formatTime(slot.endAt)}',
                                      style: AppTexts.bodyM.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              _showEditSlotDialog(slot),
                                          icon: const Icon(Icons.edit_outlined),
                                          color: AppColors.primary,
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _deleteSlot(slot.id),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 180,
                child: OutlinedButton(
                  onPressed: () async {
                    await context.read<AuthProvider>().signOut();

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/auth',
                          (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppPadding.L,
                      vertical: AppPadding.S,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: AppColors.black),
                    backgroundColor: AppColors.widgetLight,
                  ),
                  child: const Text(
                    'Log out',
                    style: AppTexts.button,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MyNavBar(currentIndex: 4),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String label;

  const _AvatarFallback({required this.label});

  @override
  Widget build(BuildContext context) {
    final t = label.trim();
    final initial = t.isEmpty ? '?' : t[0].toUpperCase();

    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTexts.headM.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: AppTexts.bodyM.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTexts.bodyM.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}