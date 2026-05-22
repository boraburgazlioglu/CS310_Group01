import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/profile_availability_model.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _slots =>
      _db.collection('profile_availability_slots');

  Future<void> addSlot({
    required String userId,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    await _slots.add({
      'userId': userId,
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ProfileAvailabilitySlot>> watchSlotsForSignedInUser() {
    return FirebaseAuth.instance.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream<List<ProfileAvailabilitySlot>>.value(
          <ProfileAvailabilitySlot>[],
        );
      }

      return _slots
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
        final slots = snapshot.docs
            .map((doc) => ProfileAvailabilitySlot.fromFirestore(doc))
            .toList();

        slots.sort((a, b) => a.startAt.compareTo(b.startAt));

        return slots;
      });
    });
  }

  Future<void> updateSlot({
    required String id,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    await _slots.doc(id).update({
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
    });
  }

  Future<void> deleteSlot(String id) async {
    await _slots.doc(id).delete();
  }

  Future<Map<String, bool>> checkMembersAvailability({
    required List<String> memberIds,
    required DateTime rehearsalStart,
    required DateTime rehearsalEnd,
  }) async {
    final Map<String, bool> result = {
      for (final memberId in memberIds) memberId: false,
    };

    for (final memberId in memberIds) {
      final snapshot = await _slots
          .where('userId', isEqualTo: memberId)
          .get();

      for (final doc in snapshot.docs) {
        final slot = ProfileAvailabilitySlot.fromFirestore(doc);

        if (slot.covers(rehearsalStart, rehearsalEnd)) {
          result[memberId] = true;
          break;
        }
      }
    }

    return result;
  }
}