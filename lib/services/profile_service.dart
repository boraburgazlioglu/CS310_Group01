import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/profile_availability_model.dart';

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

  /// Giriş yoksa boş liste; varsa sadece o kullanıcının slotları.
  /// `orderBy` kullanılmıyor (gigs/rehearsals ile aynı: bileşik indeks / stream hatası önlenir).
  Stream<List<ProfileAvailabilitySlot>> watchSlotsForSignedInUser() {
    return FirebaseAuth.instance.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream<List<ProfileAvailabilitySlot>>.value(
            <ProfileAvailabilitySlot>[]);
      }
      return _slots
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
        final list = <ProfileAvailabilitySlot>[];
        for (final doc in snapshot.docs) {
          try {
            list.add(ProfileAvailabilitySlot.fromFirestore(doc));
          } catch (_) {}
        }
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
    });
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
