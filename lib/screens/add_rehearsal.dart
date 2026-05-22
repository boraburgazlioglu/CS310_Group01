import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/band_provider.dart';
import '../services/band_service.dart';
import '../services/profile_service.dart';
import '../services/rehearsal_service.dart';
import '../utils/colors.dart';
import '../utils/padding.dart';
import '../utils/text.dart';

class AddRehearsalScreen extends StatefulWidget {
  const AddRehearsalScreen({super.key});

  @override
  State<AddRehearsalScreen> createState() => _AddRehearsalScreenState();
}

class _AddRehearsalScreenState extends State<AddRehearsalScreen> {
  final RehearsalService _rehearsalService = RehearsalService();
  final BandService _bandService = BandService();
  final ProfileService _profileService = ProfileService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _startAt;
  DateTime? _endAt;

  bool _isCheckingAvailability = false;
  bool _isSaving = false;

  List<_AvailabilityResult> _availabilityResults = [];

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
    initialDateTime.isBefore(now) && !allowPastDates ? now : initialDateTime;

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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validateTimes() {
    if (_startAt == null) {
      _showMessage('Please select a start date and time.');
      return false;
    }

    if (_endAt == null) {
      _showMessage('Please select an end date and time.');
      return false;
    }

    if (!_endAt!.isAfter(_startAt!)) {
      _showMessage('End time must be after start time.');
      return false;
    }

    return true;
  }

  Future<void> _selectStart() async {
    final pickedStart = await _pickDateTime(
      initialDateTime: DateTime.now(),
      allowPastDates: false,
    );

    if (pickedStart == null) return;

    setState(() {
      _startAt = pickedStart;

      if (_endAt == null || !_endAt!.isAfter(pickedStart)) {
        _endAt = pickedStart.add(const Duration(hours: 2));
      }

      _availabilityResults = [];
    });
  }

  Future<void> _selectEnd() async {
    final initialEnd = _endAt ??
        _startAt?.add(const Duration(hours: 2)) ??
        DateTime.now().add(const Duration(hours: 2));

    final pickedEnd = await _pickDateTime(
      initialDateTime: initialEnd,
      allowPastDates: false,
    );

    if (pickedEnd == null) return;

    setState(() {
      _endAt = pickedEnd;
      _availabilityResults = [];
    });
  }

  Future<void> _checkAvailability() async {
    final bandId = context.read<BandProvider>().currentBandId;

    if (bandId == null) {
      _showMessage('Please select a band first.');
      return;
    }

    if (!_validateTimes()) {
      return;
    }

    setState(() {
      _isCheckingAvailability = true;
      _availabilityResults = [];
    });

    try {
      final members = await _bandService.getBandMembers(bandId).first;

      final availabilityMap = await _profileService.checkMembersAvailability(
        memberIds: members.map((member) => member.id).toList(),
        rehearsalStart: _startAt!,
        rehearsalEnd: _endAt!,
      );

      if (!mounted) return;

      setState(() {
        _availabilityResults = members.map((member) {
          return _AvailabilityResult(
            memberName: member.name,
            isAvailable: availabilityMap[member.id] ?? false,
          );
        }).toList();

        _isCheckingAvailability = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCheckingAvailability = false;
      });

      _showMessage('Could not check availability: $e');
    }
  }

  Future<void> _saveRehearsal() async {
    final bandId = context.read<BandProvider>().currentBandId;
    final createdBy = context.read<AuthProvider>().createdByForFirestore;

    if (bandId == null) {
      _showMessage('Please select a band first.');
      return;
    }

    final title = _titleController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty) {
      _showMessage('Please enter a rehearsal title.');
      return;
    }

    if (location.isEmpty) {
      _showMessage('Please enter a location.');
      return;
    }

    if (!_validateTimes()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _rehearsalService.addRehearsal(
        title: title,
        location: location,
        bandId: bandId,
        createdBy: createdBy,
        startAt: _startAt!,
        endAt: _endAt!,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage('Could not add rehearsal: $e');
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
        title: Text('Add Rehearsal', style: AppTexts.headS),
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
                _buildTextField(_titleController, 'Rehearsal title'),
                const SizedBox(height: 12),
                _buildTextField(_locationController, 'Location'),
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: _selectStart,
                  icon: Icon(Icons.play_arrow, color: AppColors.primary),
                  label: Text(
                    'Select Start Date & Time',
                    style: AppTexts.button.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _startAt == null
                      ? 'No start time selected'
                      : 'Start: ${_formatDateTime(_startAt!)}',
                  style: AppTexts.bodyM,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: _selectEnd,
                  icon: Icon(Icons.stop, color: AppColors.primary),
                  label: Text(
                    'Select End Date & Time',
                    style: AppTexts.button.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _endAt == null
                      ? 'No end time selected'
                      : 'End: ${_formatDateTime(_endAt!)}',
                  style: AppTexts.bodyM,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed:
                  _isCheckingAvailability ? null : _checkAvailability,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: _isCheckingAvailability
                      ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                      : Icon(Icons.fact_check, color: AppColors.white),
                  label: Text(
                    _isCheckingAvailability
                        ? 'Checking...'
                        : 'Check Availability',
                    style: AppTexts.button.copyWith(color: AppColors.white),
                  ),
                ),

                if (_availabilityResults.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Availability',
                    style: AppTexts.bodyL.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final result in _availabilityResults)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            result.isAvailable
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: result.isAvailable
                                ? AppColors.widgetDark
                                : AppColors.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${result.memberName} — ${result.isAvailable ? 'Available' : 'Busy'}',
                              style: AppTexts.bodyM,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isSaving ? null : _saveRehearsal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: AppPadding.vertM,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _isSaving ? 'Saving...' : 'Add',
                    style: AppTexts.button.copyWith(color: AppColors.white),
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

class _AvailabilityResult {
  final String memberName;
  final bool isAvailable;

  _AvailabilityResult({
    required this.memberName,
    required this.isAvailable,
  });
}