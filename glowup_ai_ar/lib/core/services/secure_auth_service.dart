import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureAuthService {
  static const String _usersKeyPrefix = 'user_account_';
  static const String _currentUserKey = 'current_user_session';

  /// Generates a secure SHA-256 hash for the given password
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Register a new user
  static Future<String?> register(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_usersKeyPrefix$email';

    if (prefs.containsKey(key)) {
      return 'Account already exists. Please login.';
    }

    final hashedPassword = _hashPassword(password);
    await prefs.setString(key, hashedPassword);
    return null; // Null means success
  }

  /// Login a user and create a session
  static Future<String?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_usersKeyPrefix$email';

    if (!prefs.containsKey(key)) {
      return 'Invalid credentials. Account not found.';
    }

    final savedHash = prefs.getString(key);
    final inputHash = _hashPassword(password);

    if (savedHash != inputHash) {
      return 'Invalid credentials. Incorrect password.';
    }

    await prefs.setString(_currentUserKey, email);
    return null; // Success
  }

  /// Logout the current user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  /// Check if a user is currently logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentUserKey);
  }

  /// Get current user email
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }
}
