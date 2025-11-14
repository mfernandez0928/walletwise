import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  User? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthState();
  }

  void _checkAuthState() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // LOGIN - matches what login_screen expects
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message ?? 'Login failed';
      notifyListeners();
      return false;
    }
  }

  // SIGNUP - matches what signup_screen expects
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(displayName);
      _user = userCredential.user;

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message ?? 'Signup failed';
      notifyListeners();
      return false;
    }
  }

  // Also keep these for compatibility
  Future<void> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await loginWithEmail(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Password reset failed';
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (displayName != null) {
        await _user?.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await _user?.updatePhotoURL(photoURL);
      }
      _user = _firebaseAuth.currentUser;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Update profile failed: $e';
      notifyListeners();
    }
  }
}
