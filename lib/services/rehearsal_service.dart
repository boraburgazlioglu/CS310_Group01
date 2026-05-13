import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rehearsal_model.dart';

class RehearsalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _rehearsals => _db.collection('rehearsals');

  Future<void> addRehearsal({
    required String date,
    required String startTime,
    required String endTime,
    required String location,
    required String notes,
    required String bandId,
    required String createdBy,
  }) async {
    await _rehearsals.add({
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'notes': notes,
      'bandId': bandId,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Avoid where + orderBy on Firestore without a composite index (same issue as gigs).
  Stream<List<Rehearsal>> getRehearsals(String bandId) {
    return _rehearsals
        .where('bandId', isEqualTo: bandId)
        .snapshots()
        .map((snapshot) {
      final list =
          snapshot.docs.map((doc) => Rehearsal.fromFirestore(doc)).toList();
      list.sort((a, b) {
        final at = a.createdAt;
        final bt = b.createdAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
      return list;
    });
  }

  Future<void> deleteRehearsal(String id) async {
    await _rehearsals.doc(id).delete();
  }

  Future<void> updateRehearsal({
    required String id,
    required String date,
    required String startTime,
    required String endTime,
    required String location,
    required String notes,
  }) async {
    await _rehearsals.doc(id).update({
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'notes': notes,
    });
  }
}
