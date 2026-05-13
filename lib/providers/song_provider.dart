import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/song_service.dart';

class SongProvider extends ChangeNotifier {
  final SongService _songService = SongService();

  List<Song> _songs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Song> get songs => _songs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // listen to real-time song updates for a band
  void listenToSongs(String bandId) {
    _isLoading = true;
    notifyListeners();

    _songService.getSongs(bandId).listen((songList) {
      _songs = songList;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  // add a new song
  Future<void> addSong({
    required String title,
    required String bandId,
    required String createdBy,
    required List<String> memberIds,
  }) async {
    try {
      await _songService.addSong(
        title: title,
        bandId: bandId,
        createdBy: createdBy,
        memberIds: memberIds,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // delete a song
  Future<void> deleteSong(String songId) async {
    try {
      await _songService.deleteSong(songId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // update member readiness for a song
  Future<void> updateReadiness({
    required String songId,
    required String memberId,
    required String status,
  }) async {
    try {
      await _songService.updateReadiness(
        songId: songId,
        memberId: memberId,
        status: status,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}