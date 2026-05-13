import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song_model.dart';

class SongService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // songs collection
  CollectionReference get _songs => _db.collection('songs');

  // add new song to firestore
  Future<void> addSong({
    required String title,
    required String bandId,
    required String createdBy,
    required List<String> memberIds,
  }) async {
    // initialize all members as notStarted
    final Map<String, String> readiness = {
      for (final id in memberIds) id: 'notStarted',
    };

    await _songs.add({
      'title': title,
      'bandId': bandId,
      'createdBy': createdBy,
      'memberReadiness': readiness,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // real-time stream of songs for a band
  Stream<List<Song>> getSongs(String bandId) {
    return _songs
        .where('bandId', isEqualTo: bandId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Song.fromFirestore(doc)).toList());
  }

  // update a member's readiness for a song
  Future<void> updateReadiness({
    required String songId,
    required String memberId,
    required String status,
  }) async {
    await _songs.doc(songId).update({
      'memberReadiness.$memberId': status,
    });
  }

  // delete a song
  Future<void> deleteSong(String songId) async {
    await _songs.doc(songId).delete();
  }
}