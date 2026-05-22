import 'package:cloud_firestore/cloud_firestore.dart';

class Rehearsal {
  final String id;
  final String title;
  final String location;
  final String bandId;
  final String createdBy;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? createdAt;

  Rehearsal({
    required this.id,
    required this.title,
    required this.location,
    required this.bandId,
    required this.createdBy,
    required this.startAt,
    required this.endAt,
    this.createdAt,
  });

  factory Rehearsal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Rehearsal(
      id: doc.id,
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      bandId: data['bandId'] ?? '',
      createdBy: data['createdBy'] ?? '',
      startAt: (data['startAt'] as Timestamp).toDate(),
      endAt: (data['endAt'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'bandId': bandId,
      'createdBy': createdBy,
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}