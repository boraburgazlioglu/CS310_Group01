import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/rehearsal_model.dart';

class RehearsalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _rehearsals => _db.collection('rehearsals');

  Future<void> addRehearsal({
    required String title,
    required String location,
    required String bandId,
    required String createdBy,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    await _rehearsals.add({
      'title': title,
      'location': location,
      'bandId': bandId,
      'createdBy': createdBy,
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Rehearsal>> getRehearsals(String bandId) {
    return _rehearsals
        .where('bandId', isEqualTo: bandId)
        .snapshots()
        .map((snapshot) {
      final rehearsals = snapshot.docs
          .map((doc) => Rehearsal.fromFirestore(doc))
          .toList();

      rehearsals.sort((a, b) => a.startAt.compareTo(b.startAt));

      return rehearsals;
    });
  }

  Future<void> deleteRehearsal(String id) async {
    await _rehearsals.doc(id).delete();
  }

  Future<void> updateRehearsal({
    required String id,
    required String title,
    required String location,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    await _rehearsals.doc(id).update({
      'title': title,
      'location': location,
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
    });
  }
}
