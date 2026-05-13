import 'package:flutter/material.dart';

import '../models/rehearsal_model.dart';
import '../services/rehearsal_service.dart';
import '../utils/colors.dart';
import '../utils/padding.dart';
import '../utils/text.dart';
import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';

class RehearsalScreen extends StatefulWidget {
  const RehearsalScreen({super.key});

  @override
  State<RehearsalScreen> createState() => _RehearsalScreenState();
}

class _RehearsalScreenState extends State<RehearsalScreen> {
  final _formKey = GlobalKey<FormState>();
  final RehearsalService _rehearsalService = RehearsalService();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final String _bandId = 'group1';
  final String _createdBy = 'Idris';

  final List<Map<String, String>> _members = [
    {'name': 'Umit Berke Polat', 'status': 'Available'},
    {'name': 'Bora Burgazlioglu', 'status': 'Busy'},
    {'name': 'Idris Inanoglu', 'status': 'Available'},
    {'name': 'Taha Unal', 'status': 'Available'},
  ];

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _isValidDate(String value) {
    final RegExp dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(value)) {
      return false;
    }

    List<String> parts = value.split('/');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);

    if (month < 1 || month > 12) {
      return false;
    }

    if (day < 1) {
      return false;
    }

    int maxDay = 31;

    if (month == 4 || month == 6 || month == 9 || month == 11) {
      maxDay = 30;
    } else if (month == 2) {
      bool isLeapYear =
          (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
      maxDay = isLeapYear ? 29 : 28;
    }

    if (day > maxDay) {
      return false;
    }

    return true;
  }

  bool _isValidTime(String value) {
    final RegExp timeRegex = RegExp(r'^\d{2}:\d{2}$');
    if (!timeRegex.hasMatch(value)) {
      return false;
    }

    List<String> parts = value.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    if (hour < 0 || hour > 23) {
      return false;
    }

    if (minute < 0 || minute > 59) {
      return false;
    }

    return true;
  }

  void _deleteRehearsal(String id) {
    _rehearsalService.deleteRehearsal(id);
  }

  void _showEditRehearsalDialog(Rehearsal rehearsal) {
    final dateController = TextEditingController(text: rehearsal.date);
    final startController =
        TextEditingController(text: rehearsal.startTime);
    final endController = TextEditingController(text: rehearsal.endTime);
    final locationController =
        TextEditingController(text: rehearsal.location);
    final notesController = TextEditingController(text: rehearsal.notes);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Edit rehearsal', style: AppTexts.headS),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                style: AppTexts.bodyL,
                decoration: InputDecoration(
                  hintText: 'dd/mm/yyyy',
                  hintStyle: AppTexts.bodyM,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: startController,
                style: AppTexts.bodyL,
                decoration: InputDecoration(
                  hintText: 'Start xx:xx',
                  hintStyle: AppTexts.bodyM,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: endController,
                style: AppTexts.bodyL,
                decoration: InputDecoration(
                  hintText: 'End xx:xx',
                  hintStyle: AppTexts.bodyM,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                style: AppTexts.bodyL,
                decoration: InputDecoration(
                  hintText: 'Location',
                  hintStyle: AppTexts.bodyM,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                style: AppTexts.bodyL,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Notes',
                  hintStyle: AppTexts.bodyM,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
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
              final date = dateController.text.trim();
              final start = startController.text.trim();
              final end = endController.text.trim();
              if (!_isValidDate(date) ||
                  !_isValidTime(start) ||
                  !_isValidTime(end)) {
                Navigator.pop(ctx);
                return;
              }
              _rehearsalService.updateRehearsal(
                id: rehearsal.id,
                date: date,
                startTime: start,
                endTime: end,
                location: locationController.text.trim(),
                notes: notesController.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: Text('Save', style: AppTexts.button),
          ),
        ],
      ),
    );
  }

  Future<void> _createRehearsal() async {
    if (_formKey.currentState!.validate()) {
      await _rehearsalService.addRehearsal(
        date: _dateController.text.trim(),
        startTime: _startTimeController.text.trim(),
        endTime: _endTimeController.text.trim(),
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
        bandId: _bandId,
        createdBy: _createdBy,
      );

      _dateController.clear();
      _startTimeController.clear();
      _endTimeController.clear();
      _locationController.clear();
      _notesController.clear();

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Success',
            style: AppTexts.headS,
          ),
          content: Text(
            'Rehearsal saved to Firestore.',
            style: AppTexts.bodyL,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: Text(
                'OK',
                style: AppTexts.button,
              ),
            ),
          ],
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'Available') {
      return AppColors.secondary;
    }
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: BandmateHeader(),
      body: SingleChildScrollView(
        padding: AppPadding.allXL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan a New Rehearsal',
              style: AppTexts.headL,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: AppPadding.allL,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rehearsal Details',
                      style: AppTexts.headS,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dateController,
                      style: AppTexts.bodyL,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        hintText: 'dd/mm/yyyy',
                        hintStyle: AppTexts.bodyM,
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a date';
                        }
                        if (!_isValidDate(value.trim())) {
                          return 'Use dd/mm/yyyy format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _startTimeController,
                      style: AppTexts.bodyL,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        hintText: 'Start Time (hr:mn)',
                        hintStyle: AppTexts.bodyM,
                        prefixIcon: Icon(
                          Icons.access_time,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a time';
                        }
                        if (!_isValidTime(value.trim())) {
                          return 'Use 24-hour xx:xx format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _endTimeController,
                      style: AppTexts.bodyL,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        hintText: 'End Time (hr:mn)',
                        hintStyle: AppTexts.bodyM,
                        prefixIcon: Icon(
                          Icons.access_time,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a time';
                        }
                        if (!_isValidTime(value.trim())) {
                          return 'Use 24-hour xx:xx format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      style: AppTexts.bodyL,
                      decoration: InputDecoration(
                        hintText: 'Enter location',
                        hintStyle: AppTexts.bodyM,
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      style: AppTexts.bodyL,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add notes for the rehearsal',
                        hintStyle: AppTexts.bodyM,
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a note';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Saved rehearsals',
              style: AppTexts.headS,
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<Rehearsal>>(
              stream: _rehearsalService.getRehearsals(_bandId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    'Provalar yüklenemedi: ${snapshot.error}',
                    style: AppTexts.bodyM.copyWith(color: AppColors.error),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return Text(
                    'No rehearsals yet.',
                    style: AppTexts.bodyM,
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final r = items[index];
                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        title: Text(
                          '${r.date} · ${r.startTime}–${r.endTime}',
                          style: AppTexts.bodyL,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.location, style: AppTexts.bodyM),
                            if (r.notes.isNotEmpty)
                              Text(
                                r.notes,
                                style: AppTexts.bodyM.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _showEditRehearsalDialog(r),
                              icon: const Icon(Icons.edit_outlined),
                              color: AppColors.primary,
                            ),
                            IconButton(
                              onPressed: () => _deleteRehearsal(r.id),
                              icon: const Icon(Icons.delete_outline),
                              color: AppColors.widgetDark,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Member Availability',
              style: AppTexts.headS,
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];

                return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.widgetLight,
                      child: Text(
                        member['name']![0],
                        style: AppTexts.bodyM,
                      ),
                    ),
                    title: Text(
                      member['name']!,
                      style: AppTexts.bodyL,
                    ),
                    subtitle: Text(
                      member['status']!,
                      style: AppTexts.bodyM.copyWith(
                        color: _getStatusColor(member['status']!),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: AppPadding.allL,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reminder',
                    style: AppTexts.headS,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Check everyone’s availability before confirming the rehearsal time.',
                    style: AppTexts.bodyM,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createRehearsal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: AppPadding.vertM,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Create Rehearsal',
                  style: AppTexts.button,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyNavBar(currentIndex: 0),
    );
  }
}