import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text.dart';
import '../utils/padding.dart';

class RehearsalScreen extends StatefulWidget {
  const RehearsalScreen({super.key});

  @override
  State<RehearsalScreen> createState() => _RehearsalScreenState();
}

class _RehearsalScreenState extends State<RehearsalScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, String>> _members = [
    {'name': 'Umit Berke Polat', 'status': 'Available'},
    {'name': 'Bora Burgazlioglu', 'status': 'Busy'},
    {'name': 'Idris Inanoglu', 'status': 'Available'},
    {'name': 'Taha Unal', 'status': 'Available'},
  ];

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
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

  void _createRehearsal() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Success',
            style: AppTexts.headS,
          ),
          content: Text(
            'Rehearsal request created successfully.',
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
                      controller: _timeController,
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
                      controller: _timeController,
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