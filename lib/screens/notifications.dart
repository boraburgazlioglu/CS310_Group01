import 'package:flutter/material.dart';
import '../utils/text.dart';
import '../utils/colors.dart';
import '../utils/padding.dart';
import '../widgets/bandmate_header.dart';
import '../widgets/bot_nav_bar.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // dummy notification list
  final List<AppNotification> notifications = [
    ExpenseAddedNotification(
      id: 'n1',
      createdAt: DateTime(2026, 4, 13, 11, 45),
      itemName: 'Bass strings',
      amount: '1000 TL',
      addedBy: 'Bora',
    ),
    GigAddedNotification(
      id: 'n2',
      createdAt: DateTime(2026, 4, 13, 10, 15),
      title: 'Campus Fest - Back in Town',
      date: '15 April',
    ),
    RehearsalRequestNotification(
      id: 'n3',
      createdAt: DateTime(2026, 4, 12, 19, 30),
      senderName: 'Taha',
      proposedDate: '25 March',
      proposedTime: '18:00',
    ),
  ];

  // 2 semi-dummy functions for UI adaptation,
  void _acceptRequest(String id) {
    final request = notifications
        .whereType<RehearsalRequestNotification>()
        .firstWhere((item) => item.id == id);

    setState(() {
      notifications.removeWhere((item) => item.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accepted ${request.senderName}\'s rehearsal request'),
        backgroundColor: AppColors.widgetDark,
      ),
    );
  }

  void _declineRequest(String id) {
    final request = notifications
        .whereType<RehearsalRequestNotification>()
        .firstWhere((item) => item.id == id);

    setState(() {
      notifications.removeWhere((item) => item.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Declined ${request.senderName}\'s rehearsal request'),
        backgroundColor: AppColors.widgetDark,
      ),
    );
  }

  void _viewGigDetails() {
    Navigator.pushNamed(context, '/gigs');
  }

  void _viewExpenses() {
    Navigator.pushNamed(context, '/expenses');
  }

  @override
  Widget build(BuildContext context) {
    // newest = top order
    final orderedNotifications = [...notifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
                'Notifications',
                style: AppTexts.headL,
              ),
              SizedBox(height: AppPadding.L),
              if (orderedNotifications.isEmpty)
                Container(
                  width: double.infinity,
                  padding: AppPadding.allL,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray),
                  ),
                  child: Text(
                    'No notifications right now.',
                    style: AppTexts.bodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...orderedNotifications.map(
                      (notification) => Padding(
                    padding: EdgeInsets.only(bottom: AppPadding.M),
                    child: _buildNotification(notification),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MyNavBar(currentIndex: 4),
    );
  }

  // custom widget for different types of notifications
  Widget _buildNotification(AppNotification notification) {
    if (notification is RehearsalRequestNotification) {
      return _RehearsalRequestCard(
        notification: notification,
        onAccept: () => _acceptRequest(notification.id),
        onDecline: () => _declineRequest(notification.id),
      );
    }

    if (notification is GigAddedNotification) {
      return _GigAddedCard(
        notification: notification,
        onViewDetails: _viewGigDetails,
      );
    }

    if (notification is ExpenseAddedNotification) {
      return _ExpenseAddedCard(
        notification: notification,
        onViewExpenses: _viewExpenses,
      );
    }

    return const SizedBox.shrink();
  }
}

abstract class AppNotification {
  final String id;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.createdAt,
  });
}

class RehearsalRequestNotification extends AppNotification {
  final String senderName;
  final String proposedDate;
  final String proposedTime;

  const RehearsalRequestNotification({
    required super.id,
    required super.createdAt,
    required this.senderName,
    required this.proposedDate,
    required this.proposedTime,
  });
}

class GigAddedNotification extends AppNotification {
  final String title;
  final String date;

  const GigAddedNotification({
    required super.id,
    required super.createdAt,
    required this.title,
    required this.date,
  });
}

class ExpenseAddedNotification extends AppNotification {
  final String itemName;
  final String amount;
  final String addedBy;

  const ExpenseAddedNotification({
    required super.id,
    required super.createdAt,
    required this.itemName,
    required this.amount,
    required this.addedBy,
  });
}

class _RehearsalRequestCard extends StatelessWidget {
  final RehearsalRequestNotification notification;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RehearsalRequestCard({
    required this.notification,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Text('Rehearsal Request', style: AppTexts.headM),
            SizedBox(height: AppPadding.S),
            Text(
              '${notification.senderName} suggests rehearsal',
              style: AppTexts.bodyM.copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: AppPadding.S),
            Text(
              '${notification.proposedDate} - ${notification.proposedTime}',
              style: AppTexts.bodyM.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppPadding.M),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onAccept,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.black),
                    ),
                    child: const Text('Accept', style: AppTexts.button),
                  ),
                ),
                SizedBox(width: AppPadding.S),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.widgetLight,
                      side: const BorderSide(color: AppColors.black),
                    ),
                    child: const Text('Decline', style: AppTexts.button),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GigAddedCard extends StatelessWidget {
  final GigAddedNotification notification;
  final VoidCallback onViewDetails;

  const _GigAddedCard({
    required this.notification,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Text('New Gig Added', style: AppTexts.headM),
            SizedBox(height: AppPadding.S),
            Text(
              notification.title,
              style: AppTexts.bodyM.copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: AppPadding.S),
            Text(
              'Date: ${notification.date}',
              style: AppTexts.bodyM.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppPadding.M),
            OutlinedButton(
              onPressed: onViewDetails,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.black),
              ),
              child: const Text('View Details', style: AppTexts.button),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseAddedCard extends StatelessWidget {
  final ExpenseAddedNotification notification;
  final VoidCallback onViewExpenses;

  const _ExpenseAddedCard({
    required this.notification,
    required this.onViewExpenses,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Text('Expense Added', style: AppTexts.headM),
            SizedBox(height: AppPadding.S),
            Text(
              '${notification.itemName} - ${notification.amount}',
              style: AppTexts.bodyM.copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: AppPadding.S),
            Text(
              'Added by ${notification.addedBy}',
              style: AppTexts.bodyM.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppPadding.M),

            OutlinedButton(
              onPressed: onViewExpenses,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.black),
              ),
              child: const Text('View Expenses', style: AppTexts.button),
            ),
          ],
        ),
      ),
    );
  }
}
