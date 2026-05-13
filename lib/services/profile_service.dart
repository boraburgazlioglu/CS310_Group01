import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _slots =>
      _db.collection('profile_availability_slots');

  Future<void> addSlot({
    required int year,
    required int month,
    required int day,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required String userId,
  }) async {
    await _slots.add({
      'year': year,
      'month': month,
      'day': day,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getSlots(String userId) {
    return _slots
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteSlot(String id) async {
    await _slots.doc(id).delete();
  }

  Future<void> updateSlot({
    required String id,
    required int year,
    required int month,
    required int day,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
  }) async {
    await _slots.doc(id).update({
      'year': year,
      'month': month,
      'day': day,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
    });
  }
}
