import 'package:cloud_firestore/cloud_firestore.dart';

class Rehearsal {
  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final String location;
  final String notes;
  final String bandId;
  final String createdBy;
  final DateTime? createdAt;

  Rehearsal({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.notes,
    required this.bandId,
    required this.createdBy,
    this.createdAt,
  });

  factory Rehearsal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Rehearsal(
      id: doc.id,
      date: data['date'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      location: data['location'] ?? '',
      notes: data['notes'] ?? '',
      bandId: data['bandId'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'notes': notes,
      'bandId': bandId,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
