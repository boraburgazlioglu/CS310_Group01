import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gig_model.dart';

class GigService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // gigs collection
  CollectionReference get _gigs => _db.collection('gigs');

  // add new gig to firestore
  Future<void> addGig({
    required String title,
    required String date,
    required String time,
    required String location,
    required String bandId,
    required String createdBy,
  }) async {
    await _gigs.add({
      'title': title,
      'date': date,
      'time': time,
      'location': location,
      'bandId': bandId,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // real-time stream of gigs for a band
  Stream<List<Gig>> getGigs(String bandId) {
    return _gigs
        .where('bandId', isEqualTo: bandId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Gig.fromFirestore(doc)).toList());
  }

  // delete a gig
  Future<void> deleteGig(String id) async {
    await _gigs.doc(id).delete();
  }

  // update a gig
  Future<void> updateGig({
    required String id,
    required String title,
    required String date,
    required String time,
    required String location,
  }) async {
    await _gigs.doc(id).update({
      'title': title,
      'date': date,
      'time': time,
      'location': location,
    });
  }
}