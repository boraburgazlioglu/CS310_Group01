import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/band_provider.dart';
import '../services/gig_service.dart';
import '../utils/colors.dart';
import '../utils/padding.dart';
import '../utils/text.dart';

class AddGigScreen extends StatefulWidget {
  const AddGigScreen({super.key});

  @override
  State<AddGigScreen> createState() => _AddGigScreenState();
}

class _AddGigScreenState extends State<AddGigScreen> {
  final GigService _gigService = GigService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _scheduledAt;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
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
    required DateTime initialDateTime,
    required bool allowPastDates,
  }) async {
    final now = DateTime.now();

    final safeInitialDate =
    initialDateTime.isBefore(now) && !allowPastDates
        ? now
        : initialDateTime;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: allowPastDates ? DateTime(2000) : now,
      lastDate: DateTime(2100),
      barrierDismissible: false,
    );

    if (pickedDate == null || !mounted) {
      return null;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(safeInitialDate),
      barrierDismissible: false,
    );

    if (pickedTime == null || !mounted) {
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

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _selectDateTime() async {
    final pickedDateTime = await _pickDateTime(
      initialDateTime: DateTime.now(),
      allowPastDates: false,
    );

    if (pickedDateTime == null) {
      return;
    }

    setState(() {
      _scheduledAt = pickedDateTime;
    });
  }

  Future<void> _saveGig() async {
    final bandId = context.read<BandProvider>().currentBandId;
    final createdBy = context.read<AuthProvider>().createdByForFirestore;

    if (bandId == null) {
      _showMessage('Please select a band first.');
      return;
    }

    final title = _titleController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty) {
      _showMessage('Please enter a gig title.');
      return;
    }

    if (location.isEmpty) {
      _showMessage('Please enter a location.');
      return;
    }

    if (_scheduledAt == null) {
      _showMessage('Please select a date and time.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _gigService.addGig(
        title: title,
        location: location,
        bandId: bandId,
        createdBy: createdBy,
        scheduledAt: _scheduledAt!,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      _showMessage('Could not add gig: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        title: Text(
          'Add Gig',
          style: AppTexts.headS,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPadding.allL,
          child: Container(
            width: double.infinity,
            padding: AppPadding.allL,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_titleController, 'Gig title'),
                const SizedBox(height: 12),
                _buildTextField(_locationController, 'Location'),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _selectDateTime,
                  icon: Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    'Select Date & Time',
                    style: AppTexts.button.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _scheduledAt == null
                      ? 'No date and time selected'
                      : 'Gig Time: ${_formatDateTime(_scheduledAt!)}',
                  style: AppTexts.bodyM,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveGig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: AppPadding.vertM,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _isSaving ? 'Saving...' : 'Add',
                    style: AppTexts.button.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: AppTexts.bodyL,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTexts.bodyM,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}