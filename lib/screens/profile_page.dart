import 'package:cloud_firestore/cloud_firestore.dart';
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

  // placeholder data for info rows
  final String userName = 'idris';
  final String email = 'idrisimamoglu@sabanci.uni';
  final List<String> roles = ['manager', 'guitarist'];
  final List<String> groups = ['band1', 'band2'];

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
  // adds the time slots to the card list, parses the texts to integers for calculations later on
  void _addSlot() {
    final year = int.tryParse(_yearController.text.trim());
    final month = int.tryParse(_monthController.text.trim());
    final day = int.tryParse(_dayController.text.trim());
    final startHour = int.tryParse(_startHourController.text.trim());
    final startMinute = int.tryParse(_startMinuteController.text.trim());
    final endHour = int.tryParse(_endHourController.text.trim());
    final endMinute = int.tryParse(_endMinuteController.text.trim());

    if (year == null ||
        month == null ||
        day == null ||
        startHour == null ||
        startMinute == null ||
        endHour == null ||
        endMinute == null) {
      _showError('Every input field must be filled.');
      return;
    }

    //input checks
    if (month < 1 || month > 12) {_showError('Month has to be in range 1-12!'); return;}
    if (day < 1 || day > 31) {_showError('Day has to be in range 1-31!'); return;}
    if (startHour < 0 || startHour > 23) {_showError('Hour has to be in range 0-23!'); return;}
    if (endHour < 0 || endHour > 23) {_showError('Hour has to be in range 0-23!'); return;}
    if (startMinute < 0 || startMinute > 59) {_showError('Minute has to be in range 0-60!'); return;}
    if (endMinute < 0 || endMinute > 59) {_showError('Minute has to be in range 0-60!'); return;}

    final userId = context.read<AuthProvider>().user?.uid ?? 'guest';

    _profileService.addSlot(
      year: year,
      month: month,
      day: day,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      userId: userId,
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
    final userId = context.watch<AuthProvider>().user?.uid ?? 'guest';

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
                          child: Image.asset(
                            'assets/images/ahmetkaya.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 48,
                                color: AppColors.widgetDark,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow(label: 'Name', value: userName),
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
                    _InfoRow(label: 'Roles', value: roles.join(', ')),
                    const SizedBox(height: 10),
                    _InfoRow(label: 'Groups', value: groups.join(', ')),
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
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Month',
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

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _startHourController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Hour',
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
                                hintText: 'Min',
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
                                hintText: 'Hour',
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
                                hintText: 'Min',
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

                      StreamBuilder<QuerySnapshot>(
                        stream: _profileService.getSlots(userId),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                              'Could not load slots.',
                              style: AppTexts.bodyM.copyWith(
                                color: AppColors.error,
                              ),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Text(
                              'No time slots added yet.',
                              style: AppTexts.bodyM.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            );
                          }

                          final slots = snapshot.data!.docs
                              .map((doc) =>
                                  ProfileAvailabilitySlot.fromFirestore(doc))
                              .toList();

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
