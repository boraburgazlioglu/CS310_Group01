import 'package:flutter/material.dart';
import '../utils/text.dart';
import '../utils/colors.dart';
import '../utils/padding.dart';
import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  //placeholder data for info rows
  final String userName = 'idris';
  final String email = 'idrisimamoglu@sabanci.uni';
  final String role = 'manager, guitarist';
  final String groups = 'band1, band2';

  /*void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password tapped')),
    );
  }

  void _logout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log out tapped')),
    );
  }*/

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
                    _InfoRow(label: 'Instrument', value: role),
                    const SizedBox(height: 10),
                    _InfoRow(label: 'Groups', value: groups),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gray),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.schedule_outlined),
                      title: const Text('Arrange Schedule'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushNamed(context, '/schedule_page');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 180,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/notifications', arguments: 'Logged out succesfully');
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
