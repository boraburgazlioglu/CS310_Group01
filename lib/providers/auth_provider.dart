import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _errorMessage;

  late final StreamSubscription<User?> _authSubscription;

  AuthProvider() {
    _user = _authService.currentUser;

    _authSubscription = _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _user != null;

  /// Firestore `createdBy` / demo alanları için: önce ad, yoksa e-posta, yoksa uid.
  String get createdByForFirestore {
    final u = _user;
    if (u == null) return 'guest';
    final n = u.displayName?.trim();
    if (n != null && n.isNotEmpty) return n;
    final e = u.email?.trim();
    if (e != null && e.isNotEmpty) return e;
    return u.uid;
  }

  /// Profil başlığı için kısa görünen ad
  String get displayNameOrEmail {
    final u = _user;
    if (u == null) return 'Misafir';
    final n = u.displayName?.trim();
    if (n != null && n.isNotEmpty) return n;
    return u.email ?? u.uid;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _errorMessage = null;

    try {
      await _authService.signIn(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _errorMessage = null;

    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  //instant log out
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}