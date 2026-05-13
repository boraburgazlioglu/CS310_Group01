import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileAvailabilitySlot {
  final String id;
  final int year;
  final int month;
  final int day;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String userId;
  final DateTime? createdAt;

  ProfileAvailabilitySlot({
    required this.id,
    required this.year,
    required this.month,
    required this.day,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.userId,
    this.createdAt,
  });

  factory ProfileAvailabilitySlot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfileAvailabilitySlot(
      id: doc.id,
      year: (data['year'] as num?)?.toInt() ?? 0,
      month: (data['month'] as num?)?.toInt() ?? 0,
      day: (data['day'] as num?)?.toInt() ?? 0,
      startHour: (data['startHour'] as num?)?.toInt() ?? 0,
      startMinute: (data['startMinute'] as num?)?.toInt() ?? 0,
      endHour: (data['endHour'] as num?)?.toInt() ?? 0,
      endMinute: (data['endMinute'] as num?)?.toInt() ?? 0,
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'day': day,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
