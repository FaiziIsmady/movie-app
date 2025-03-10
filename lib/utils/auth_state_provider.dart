import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStateProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  User? _user;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthStateProvider() {
    // Initialize state
    _checkAuthState();
    // Listen to Firebase auth changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      _updateLoginState();
    });
  }

  Future<void> _checkAuthState() async {
    // Check SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    // Check Firebase
    _user = FirebaseAuth.instance.currentUser;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _updateLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    // Sync Firebase and SharedPreferences if needed
    if (_user != null && !_isLoggedIn) {
      _isLoggedIn = true;
      await prefs.setBool('isLoggedIn', true);
    } else if (_user == null && _isLoggedIn) {
      _isLoggedIn = false;
      await prefs.setBool('isLoggedIn', false);
    }
    
    notifyListeners();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }

  Future<void> refreshAuthState() async {
    await _checkAuthState();
  }
}