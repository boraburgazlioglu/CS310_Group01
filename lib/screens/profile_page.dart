import 'package:flutter/material.dart';
import '../utils/text.dart';
import '../utils/colors.dart';
import '../utils/padding.dart';
import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';

// class for schedule time slots
class AvailableSlot {
  final int year;
  final int month;
  final int day;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  AvailableSlot({
    required this.year,
    required this.month,
    required this.day,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });
}

// user input controllers
final TextEditingController _yearController = TextEditingController();
final TextEditingController _monthController = TextEditingController();
final TextEditingController _dayController = TextEditingController();
final TextEditingController _startHourController = TextEditingController();
final TextEditingController _startMinuteController = TextEditingController();
final TextEditingController _endHourController = TextEditingController();
final TextEditingController _endMinuteController = TextEditingController();

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  //placeholder data for info rows
  final String userName = 'idris';
  final String email = 'idrisimamoglu@sabanci.uni';
  final List<String> roles = ['manager', 'guitarist'];
  final List<String> groups = ['band1', 'band2'];

  final List<AvailableSlot> availableSlots = [
    AvailableSlot(
      year: 2026,
      month: 04,
      day: 14,
      startHour: 18,
      startMinute: 00,
      endHour: 20,
      endMinute: 48
    ),
    AvailableSlot(
        year: 2026,
        month: 04,
        day: 15,
        startHour: 12,
        startMinute: 00,
        endHour: 23,
        endMinute: 59,
    ),
    AvailableSlot(
        year: 2026,
        month: 04,
        day: 16,
        startHour: 15,
        startMinute: 05,
        endHour: 20,
        endMinute: 05
    ),
  ];

  void _removeSlot(int index) {
    setState(() {
      availableSlots.removeAt(index);
    });
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

    setState(() {
      availableSlots.add(
        AvailableSlot(
          year: year,
          month: month,
          day: day,
          startHour: startHour,
          startMinute: startMinute,
          endHour: endHour,
          endMinute: endMinute,
        ),
      );

      _yearController.clear();
      _monthController.clear();
      _dayController.clear();
      _startHourController.clear();
      _startMinuteController.clear();
      _endHourController.clear();
      _endMinuteController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          child: const Icon(
                            Icons.person_outline,
                            size: 48,
                            color: AppColors.black,
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

                      if (availableSlots.isEmpty)
                        Text(
                          'No time slots added yet.',
                          style: AppTexts.bodyM.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )
                      else
                        ...List.generate(
                          availableSlots.length,
                              (index) {
                            final slot = availableSlots[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: AppPadding.S),
                              child: Card(
                                color: AppColors.surface,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: AppColors.gray),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.schedule_outlined),
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
                                  trailing: IconButton(
                                    onPressed: () => _removeSlot(index),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ),
                              ),
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
                  onPressed: () {
                    Navigator.pushNamed(context, '/login', arguments: 'Logged out successfully');
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
