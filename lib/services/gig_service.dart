import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gig_model.dart';

class GigService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // gigs collection
  CollectionReference get _gigs => _db.collection('gigs');

  // add new gig to firestore
  Future<void> addGig({
    required String title,
    required DateTime scheduledAt,
    required String location,
    required String bandId,
    required String createdBy,
  }) async {
    await _gigs.add({
      'title': title,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'location': location,
      'bandId': bandId,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Gig>> getGigs(String bandId) {
    return _gigs.where('bandId', isEqualTo: bandId).snapshots().map((snapshot) {
      final gigs = snapshot.docs.map((doc) => Gig.fromFirestore(doc)).toList();

      gigs.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      return gigs;
    });
  }

  // delete a gig
  Future<void> deleteGig(String id) async {
    await _gigs.doc(id).delete();
  }

  // update a gig
  Future<void> updateGig({
    required String id,
    required String title,
    required String location,
    required DateTime scheduledAt,
  }) async {
    await _gigs.doc(id).update({
      'title': title,
      'location': location,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
    });
  }
}