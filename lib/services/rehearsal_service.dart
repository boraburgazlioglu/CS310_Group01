import 'package:cloud_firestore/cloud_firestore.dart';

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

  Stream<QuerySnapshot> getRehearsals(String bandId) {
    return _rehearsals
        .where('bandId', isEqualTo: bandId)
        .orderBy('createdAt', descending: true)
        .snapshots();
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
