import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String id;
  final String title;
  final String bandId;
  final Map<String, String> memberReadiness;
  final String createdBy;
  final DateTime? createdAt;

  Song({
    required this.id,
    required this.title,
    required this.bandId,
    required this.memberReadiness,
    required this.createdBy,
    this.createdAt,
  });

  // convert firestore document to Song object
  factory Song.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Song(
      id: doc.id,
      title: data['title'] ?? '',
      bandId: data['bandId'] ?? '',
      memberReadiness: Map<String, String>.from(data['memberReadiness'] ?? {}),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // convert Song object to map for firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'bandId': bandId,
      'memberReadiness': memberReadiness,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}