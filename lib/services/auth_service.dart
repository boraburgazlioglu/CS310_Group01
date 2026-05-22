import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static const String emailNotFoundMessage =
      'Email not found. Please check your email or sign up.';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  CollectionReference<Map<String, dynamic>> get _emailIndex =>
      _firestore.collection('email_index');

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  Future<void> _indexEmail(String email) async {
    final key = _normalizeEmail(email);
    if (key.isEmpty) return;
    try {
      await _emailIndex.doc(key).set({
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Index is optional until Firestore rules are deployed.
    }
  }

  Future<bool> _isEmailIndexed(String email) async {
    final key = _normalizeEmail(email);
    if (key.isEmpty) return false;
    try {
      final doc = await _emailIndex.doc(key).get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _isEmailRegistered(String email) async {
    // firebase_auth 6.4+ removed fetchSignInMethodsForEmail; use email_index only.
    return _isEmailIndexed(email);
  }

  bool _messageIndicatesUnknownEmail(FirebaseAuthException e) {
    final msg = '${e.message ?? ''} ${e.toString()}'.toUpperCase();
    return msg.contains('EMAIL_NOT_FOUND') ||
        msg.contains('USER_NOT_FOUND') ||
        msg.contains('USER NOT FOUND');
  }

  bool _isSignInCredentialError(FirebaseAuthException e) {
    return e.code == 'wrong-password' ||
        e.code == 'invalid-credential' ||
        e.code == 'invalid-login-credentials';
  }

  Future<String> _resolveSignInError(
    FirebaseAuthException e,
    String email,
  ) async {
    if (e.code == 'user-not-found' || _messageIndicatesUnknownEmail(e)) {
      return emailNotFoundMessage;
    }

    if (e.code == 'wrong-password') {
      return 'Incorrect password.';
    }

    if (_isSignInCredentialError(e)) {
      final registered = await _isEmailRegistered(email);
      if (!registered) {
        return emailNotFoundMessage;
      }
      return 'Incorrect password.';
    }

    return _handleAuthError(e);
  }

  // Sign Up service
  Future<UserCredential> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final name = displayName?.trim();
      if (name != null && name.isNotEmpty) {
        await cred.user?.updateDisplayName(name);
        await cred.user?.reload();
      }
      await _indexEmail(email);
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Login service
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      await _indexEmail(trimmedEmail);
      return cred;
    } on FirebaseAuthException catch (e) {
      throw await _resolveSignInError(e, trimmedEmail);
    }
  }

  // Logout service
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Error handling
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
        return emailNotFoundMessage;
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return emailNotFoundMessage;
      case 'network-request-failed':
        return 'Network error. Please try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
