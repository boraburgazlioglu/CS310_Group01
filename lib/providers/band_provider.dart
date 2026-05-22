import 'package:flutter/material.dart';

class BandProvider extends ChangeNotifier {
  String? _currentBandId;
  String? _currentBandName;
  String? _currentBandJoinCode;

  String? get currentBandId => _currentBandId;
  String? get currentBandName => _currentBandName;
  String? get currentBandJoinCode => _currentBandJoinCode;

  String get displayBandName {
    if (_currentBandName == null || _currentBandName!.trim().isEmpty) {
      return 'No Band Selected';
    }

    return _currentBandName!;
  }

  String get displayBandJoinCode {
    if (_currentBandJoinCode == null || _currentBandJoinCode!.trim().isEmpty) {
      return 'No Code';
    }

    return _currentBandJoinCode!;
  }

  bool get hasSelectedBand => _currentBandId != null;

  void setCurrentBand({
    required String bandId,
    required String bandName,
    required String joinCode,
  }) {
    _currentBandId = bandId;
    _currentBandName = bandName;
    _currentBandJoinCode = joinCode;
    notifyListeners();
  }

  void clearBand() {
    _currentBandId = null;
    _currentBandName = null;
    _currentBandJoinCode = null;
    notifyListeners();
  }
}