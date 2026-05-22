import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/band_model.dart';

class BandMember {
  final String id;
  final String name;

  BandMember({
    required this.id,
    required this.name,
  });
}

class BandService {
  final CollectionReference<Map<String, dynamic>> _bands =
  FirebaseFirestore.instance.collection('bands');

  final CollectionReference<Map<String, dynamic>> _users =
  FirebaseFirestore.instance.collection('users');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  User _requiredUser() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in first.');
    }

    return user;
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();

    return List.generate(
      6,
          (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  String _getMemberName({
    required User user,
    required String? givenName,
  }) {
    final cleanName = givenName?.trim() ?? '';

    if (cleanName.isNotEmpty) {
      return cleanName;
    }

    return user.email?.split('@').first ?? 'Member';
  }

  Stream<List<BandModel>> getUserBands(String userId) {
    return _bands
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BandModel.fromFirestore(doc))
          .where((band) => !band.isDeleted)
          .toList();
    });
  }

  Stream<List<BandMember>> getBandMembers(String bandId) {
    return _bands.doc(bandId).snapshots().map((doc) {
      final band = BandModel.fromFirestore(doc);

      return band.members.map((memberId) {
        final name = band.memberNames[memberId];

        final fallbackName = memberId.length > 6
            ? '${memberId.substring(0, 6)}...'
            : memberId;

        return BandMember(
          id: memberId,
          name: name != null && name.trim().isNotEmpty
              ? name
              : fallbackName,
        );
      }).toList();
    });
  }

  Future<BandModel> createBand({
    required String name,
    required String description,
    required String? memberName,
  }) async {
    final user = _requiredUser();

    final bandDoc = _bands.doc();
    final joinCode = _generateJoinCode();

    final finalMemberName = _getMemberName(
      user: user,
      givenName: memberName,
    );

    await bandDoc.set({
      'id': bandDoc.id,
      'name': name,
      'description': description,
      'joinCode': joinCode,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'members': [user.uid],
      'memberNames': {
        user.uid: finalMemberName,
      },
      'isDeleted': false,
    });

    await setCurrentBandForUser(bandDoc.id);

    final createdDoc = await bandDoc.get();
    return BandModel.fromFirestore(createdDoc);
  }

  Future<BandModel> joinBand({
    required String joinCode,
    required String? memberName,
  }) async {
    final user = _requiredUser();

    final finalMemberName = _getMemberName(
      user: user,
      givenName: memberName,
    );

    final query = await _bands
        .where('joinCode', isEqualTo: joinCode)
        .where('isDeleted', isEqualTo: false)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('No band found with this code.');
    }

    final bandDoc = query.docs.first;

    await _bands.doc(bandDoc.id).update({
      'members': FieldValue.arrayUnion([user.uid]),
      'memberNames.${user.uid}': finalMemberName,
    });

    await setCurrentBandForUser(bandDoc.id);

    final updatedDoc = await _bands.doc(bandDoc.id).get();
    return BandModel.fromFirestore(updatedDoc);
  }

  Future<void> setCurrentBandForUser(String bandId) async {
    final user = _requiredUser();

    await _users.doc(user.uid).set({
      'currentBandId': bandId,
      'joinedBands': FieldValue.arrayUnion([bandId]),
    }, SetOptions(merge: true));
  }
}