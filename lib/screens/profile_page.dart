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

  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _startHourController = TextEditingController();
  final TextEditingController _startMinuteController = TextEditingController();
  final TextEditingController _endHourController = TextEditingController();
  final TextEditingController _endMinuteController = TextEditingController();

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _startHourController.dispose();
    _startMinuteController.dispose();
    _endHourController.dispose();
    _endMinuteController.dispose();
    super.dispose();
  }

  void _deleteSlot(String id) {
    _profileService.deleteSlot(id);
  }

  void _showEditSlotDialog(ProfileAvailabilitySlot slot) {
    final yearController =
        TextEditingController(text: slot.year.toString());
    final monthController =
        TextEditingController(text: slot.month.toString());
    final dayController = TextEditingController(text: slot.day.toString());
    final startHourController =
        TextEditingController(text: slot.startHour.toString());
    final startMinuteController =
        TextEditingController(text: slot.startMinute.toString());
    final endHourController =
        TextEditingController(text: slot.endHour.toString());
    final endMinuteController =
        TextEditingController(text: slot.endMinute.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Edit time slot', style: AppTexts.headS),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
              TextField(
                controller: monthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Month'),
              ),
              TextField(
                controller: dayController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Day'),
              ),
              TextField(
                controller: startHourController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Start hour'),
              ),
              TextField(
                controller: startMinuteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Start min'),
              ),
              TextField(
                controller: endHourController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'End hour'),
              ),
              TextField(
                controller: endMinuteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'End min'),
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
            onPressed: () {
              final year = int.tryParse(yearController.text.trim());
              final month = int.tryParse(monthController.text.trim());
              final day = int.tryParse(dayController.text.trim());
              final startHour =
                  int.tryParse(startHourController.text.trim());
              final startMinute =
                  int.tryParse(startMinuteController.text.trim());
              final endHour = int.tryParse(endHourController.text.trim());
              final endMinute = int.tryParse(endMinuteController.text.trim());
              if (year == null ||
                  month == null ||
                  day == null ||
                  startHour == null ||
                  startMinute == null ||
                  endHour == null ||
                  endMinute == null) {
                Navigator.pop(ctx);
                return;
              }
              _profileService.updateSlot(
                id: slot.id,
                year: year,
                month: month,
                day: day,
                startHour: startHour,
                startMinute: startMinute,
                endHour: endHour,
                endMinute: endMinute,
              );
              Navigator.pop(ctx);
            },
            child: Text('Save', style: AppTexts.button),
          ),
        ],
      ),
    );
  }

  //shows the incorrect inputs in a snack bar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  /// `23.00` / `12` gibi; sadece tam sayı kısmını alır.
  int? _parseWholeNumber(String raw) {
    var s = raw.trim().replaceAll(',', '.');
    if (s.isEmpty) return null;
    final dot = s.indexOf('.');
    if (dot != -1) {
      s = s.substring(0, dot);
    }
    return int.tryParse(s);
  }

  /// Ay: `1`–`12`, `January` / `Jan`, `Ocak` vb.
  int? _parseMonthInput(String raw) {
    final t = raw.trim().toLowerCase();
    if (t.isEmpty) return null;
    final n = int.tryParse(t);
    if (n != null && n >= 1 && n <= 12) return n;
    const months = <String, int>{
      'january': 1,
      'jan': 1,
      'february': 2,
      'feb': 2,
      'march': 3,
      'mar': 3,
      'april': 4,
      'apr': 4,
      'may': 5,
      'june': 6,
      'jun': 6,
      'july': 7,
      'jul': 7,
      'august': 8,
      'aug': 8,
      'september': 9,
      'sep': 9,
      'sept': 9,
      'october': 10,
      'oct': 10,
      'november': 11,
      'nov': 11,
      'december': 12,
      'dec': 12,
      'ocak': 1,
      'şubat': 2,
      'subat': 2,
      'mart': 3,
      'nisan': 4,
      'mayıs': 5,
      'mayis': 5,
      'haziran': 6,
      'temmuz': 7,
      'ağustos': 8,
      'agustos': 8,
      'eylül': 9,
      'eylul': 9,
      'ekim': 10,
      'kasım': 11,
      'kasim': 11,
      'aralık': 12,
      'aralik': 12,
    };
    return months[t];
  }

  // adds the time slots to the card list, parses the texts to integers for calculations later on
  void _addSlot() {
    final year = _parseWholeNumber(_yearController.text);
    final month = _parseMonthInput(_monthController.text);
    final day = _parseWholeNumber(_dayController.text);
    final startHour = _parseWholeNumber(_startHourController.text);
    final startMinute = _parseWholeNumber(_startMinuteController.text);
    final endHour = _parseWholeNumber(_endHourController.text);
    final endMinute = _parseWholeNumber(_endMinuteController.text);

    if (year == null) {
      _showError('Invalid year. Example: 2026');
      return;
    }
    if (month == null) {
      _showError(
          'Invalid month. Enter 1-12 or a month name (e.g. 5, January).');
      return;
    }
    if (day == null) {
      _showError('Invalid day. Example: 14');
      return;
    }
    if (startHour == null || startMinute == null) {
      _showError('Start hour and minute must be numbers (e.g. 12 and 0).');
      return;
    }
    if (endHour == null || endMinute == null) {
      _showError('End hour and minute must be numbers (e.g. 23 and 0).');
      return;
    }

    //input checks
    if (month < 1 || month > 12) {_showError('Month has to be in range 1-12!'); return;}
    if (day < 1 || day > 31) {_showError('Day has to be in range 1-31!'); return;}
    if (startHour < 0 || startHour > 23) {_showError('Hour has to be in range 0-23!'); return;}
    if (endHour < 0 || endHour > 23) {_showError('Hour has to be in range 0-23!'); return;}
    if (startMinute < 0 || startMinute > 59) {_showError('Minute has to be in range 0-60!'); return;}
    if (endMinute < 0 || endMinute > 59) {_showError('Minute has to be in range 0-60!'); return;}

    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) {
      _showError('You must be signed in to add a slot.');
      return;
    }

    _profileService.addSlot(
      year: year,
      month: month,
      day: day,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      userId: uid,
    );

    _yearController.clear();
    _monthController.clear();
    _dayController.clear();
    _startHourController.clear();
    _startMinuteController.clear();
    _endHourController.clear();
    _endMinuteController.clear();
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
              Text('Profile',
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
                                    return _AvatarFallback(
                                        label: profileName);
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
                    if (user?.uid != null) const SizedBox(height: 10),
                    _InfoRow(
                      label: 'Roles',
                      value: 'Not set yet',
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: 'Groups',
                      value: 'Not set yet',
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
                      SizedBox(height: AppPadding.M),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Year',
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppPadding.S),
                          Expanded(
                            child: TextField(
                              controller: _monthController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'Month (1-12 or January)',
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppPadding.S),
                          Expanded(
                            child: TextField(
                              controller: _dayController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Day',
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppPadding.M),

                      Text(
                        'Time range (24h): start — then end',
                        style: AppTexts.bodyM,
                      ),
                      SizedBox(height: AppPadding.S),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _startHourController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Start hour',
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppPadding.S),
                          Expanded(
                            child: TextField(
                              controller: _startMinuteController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Start min',
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppPadding.S),
                          Expanded(
                            child: TextField(
                              controller: _endHourController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'End hour',
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppPadding.S),
                          Expanded(
                            child: TextField(
                              controller: _endMinuteController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'End min',
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppPadding.M),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          onPressed: _addSlot,
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
                          child: const Text(
                            'Add Slot',
                            style: AppTexts.button,
                          ),
                        ),
                      ),

                      SizedBox(height: AppPadding.M),

                      Text('Available Time Slots', style: AppTexts.headS),

                      StreamBuilder<List<ProfileAvailabilitySlot>>(
                        stream:
                            _profileService.watchSlotsForSignedInUser(),
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
                                padding:
                                    EdgeInsets.only(bottom: AppPadding.S),
                                child: Card(
                                  color: AppColors.surface,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                        color: AppColors.gray),
                                  ),
                                  child: ListTile(
                                    leading:
                                        const Icon(Icons.schedule_outlined),
                                    title: Text(
                                      '${slot.day.toString().padLeft(2, '0')}/${slot.month.toString().padLeft(2, '0')}/${slot.year}',
                                      style: AppTexts.bodyM.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${slot.startHour.toString().padLeft(2, '0')}:${slot.startMinute.toString().padLeft(2, '0')} - ${slot.endHour.toString().padLeft(2, '0')}:${slot.endMinute.toString().padLeft(2, '0')}',
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
                                          icon:
                                              const Icon(Icons.delete_outline),
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
              color: AppColors.textPrimary
            )
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTexts.bodyM.copyWith(
              color: AppColors.textSecondary
            )
          ),
        ),
      ],
    );
  }
}
