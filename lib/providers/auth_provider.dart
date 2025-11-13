import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentEmail;

  late Box<Map> _usersBox;
  bool _boxInitialized = false;

  // Store users in memory for quick lookup
  static final Map<String, String> _mockUsers = {};

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentEmail => _currentEmail;

  AuthProvider() {
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      _usersBox = await Hive.openBox<Map>('users');
      _boxInitialized = true;

      // ✅ LOAD USERS FROM HIVE WHEN APP STARTS
      _loadUsersFromHive();

      notifyListeners();
    } catch (e) {
      print('Error initializing Hive: $e');
    }
  }

  // ✅ THIS METHOD WAS MISSING!
  void _loadUsersFromHive() {
    try {
      _mockUsers.clear(); // Clear first

      for (var key in _usersBox.keys) {
        final userData = _usersBox.get(key);
        if (userData != null) {
          final email = userData['email'] as String;
          final password = userData['password'] as String;
          _mockUsers[email] = password;
        }
      }

      print(
          '✅ Loaded ${_mockUsers.length} users from Hive: ${_mockUsers.keys.toList()}');
    } catch (e) {
      print('❌ Error loading users from Hive: $e');
    }
  }

  Future<bool> signUpWithEmail(
      String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Wait for Hive to initialize
      if (!_boxInitialized) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      await Future.delayed(const Duration(seconds: 1));

      // Check if email already exists
      if (_usersBox.containsKey(email)) {
        throw Exception('Email already in use');
      }

      // Save user to Hive
      _usersBox.put(email, {
        'email': email,
        'password': password,
        'name': name,
        'createdAt': DateTime.now().toString(),
      });

      // Also save to memory
      _mockUsers[email] = password;

      _isLoggedIn = true;
      _currentEmail = email;
      _isLoading = false;
      notifyListeners();

      print('✅ SignUp successful: $email');
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      print('❌ SignUp Error: $_errorMessage');
      return false;
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Wait for Hive to initialize
      if (!_boxInitialized) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      await Future.delayed(const Duration(seconds: 1));

      print('🔍 Attempting login with: $email');
      print('📦 Available users in memory: ${_mockUsers.keys.toList()}');

      // Check if email exists (uses memory cache)
      if (!_mockUsers.containsKey(email)) {
        throw Exception('Email not found');
      }

      // Check password
      if (_mockUsers[email] != password) {
        throw Exception('Wrong password');
      }

      // ✅ SET LOGIN STATE
      _isLoggedIn = true;
      _currentEmail = email;
      _isLoading = false;
      notifyListeners();

      print('✅ Login successful: $email');
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      print('❌ Login Error: $_errorMessage');
      return false;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _currentEmail = null;
    notifyListeners();
    print('✅ Logged out');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
