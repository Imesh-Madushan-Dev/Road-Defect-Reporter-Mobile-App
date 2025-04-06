import 'package:exe_assignment/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;
  User? _user;
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;

  AuthController() {
    _init();
  }

  void _init() {
    _user = _authService.currentUser;
    if (_user != null) {
      _loadUserData();
    }
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData();
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    try {
      _userData = await _authService.getCurrentUserData();
      notifyListeners();
    } catch (e) {
      _error = 'Error loading user data: $e';
      notifyListeners();
    }
  }

  Future<void> refreshUserData() async {
    await _loadUserData();
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.registerWithEmailAndPassword(email, password, name);

      await _loadUserData(); // Load user data after registration
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(email, password);
      await _loadUserData(); // Load user data after login
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _userData = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
