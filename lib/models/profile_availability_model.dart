import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileAvailabilitySlot {
  final String id;
  final String userId;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? createdAt;

  ProfileAvailabilitySlot({
    required this.id,
    required this.userId,
    required this.startAt,
    required this.endAt,
    this.createdAt,
  });

  factory ProfileAvailabilitySlot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProfileAvailabilitySlot(
      id: doc.id,
      userId: data['userId'] ?? '',
      startAt: (data['startAt'] as Timestamp).toDate(),
      endAt: (data['endAt'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  bool covers(DateTime requestedStart, DateTime requestedEnd) {
    return !startAt.isAfter(requestedStart) &&
        !endAt.isBefore(requestedEnd);
  }
}