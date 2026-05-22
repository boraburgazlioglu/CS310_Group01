import 'package:cloud_firestore/cloud_firestore.dart';

class Gig {
  final String id;
  final String title;
  final DateTime scheduledAt;
  final String location;
  final String bandId;
  final String createdBy;
  final DateTime? createdAt;

  Gig({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.location,
    required this.bandId,
    required this.createdBy,
    this.createdAt,
  });

  // convert firestore document to Gig object
  factory Gig.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data();
    final data = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    return Gig(
      id: doc.id,
      title: data['title'] ?? '',
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      bandId: data['bandId'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // convert Gig object to map for firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'location': location,
      'bandId': bandId,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}