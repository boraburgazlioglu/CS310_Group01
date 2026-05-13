import 'package:cloud_firestore/cloud_firestore.dart';

class Gig {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;
  final String bandId;
  final String createdBy;
  final DateTime? createdAt;

  Gig({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.bandId,
    required this.createdBy,
    this.createdAt,
  });

  // convert firestore document to Gig object
  factory Gig.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Gig(
      id: doc.id,
      title: data['title'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
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
      'date': date,
      'time': time,
      'location': location,
      'bandId': bandId,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}