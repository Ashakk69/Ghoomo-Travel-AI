import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthService {
  static const String _keyCurrentUser = 'current_user';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyUserCredentials = 'user_credentials';

  final LocalAuthentication _localAuth = LocalAuthentication();
  User? _currentUser;

  // Get current user
  User? get currentUser => _currentUser;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Check if user has seen onboarding
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  // Mark onboarding as seen
  Future<void> markOnboardingAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, true);
  }

  // Initialize auth service - load current user if exists
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

    if (isLoggedIn) {
      final userJson = prefs.getString(_keyCurrentUser);
      if (userJson != null) {
        try {
          _currentUser = User.fromJsonString(userJson);
        } catch (e) {
          debugPrint('Error loading user: $e');
          await logout();
        }
      }
    }
  }

  // Sign up new user
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (name.trim().isEmpty) {
        return AuthResult.error('Name cannot be empty');
      }
      if (!_isValidEmail(email)) {
        return AuthResult.error('Invalid email format');
      }
      if (password.length < 6) {
        return AuthResult.error('Password must be at least 6 characters');
      }

      // Check if user already exists
      final prefs = await SharedPreferences.getInstance();
      final existingCredentials = prefs.getString(_keyUserCredentials);
      if (existingCredentials != null) {
        final credentials = existingCredentials.split(':');
        if (credentials[0] == email) {
          return AuthResult.error('User already exists. Please login.');
        }
      }

      // Create new user
      final user = User(
        id: const Uuid().v4(),
        name: name.trim(),
        email: email.trim().toLowerCase(),
        createdAt: DateTime.now(),
        preferences: UserPreferences(),
      );

      // Save credentials (in production, use proper encryption!)
      await prefs.setString(_keyUserCredentials, '$email:$password');

      // Save user and login
      await _saveUser(user);
      _currentUser = user;

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Sign up failed: ${e.toString()}');
    }
  }

  // Login user
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (!_isValidEmail(email)) {
        return AuthResult.error('Invalid email format');
      }
      if (password.isEmpty) {
        return AuthResult.error('Password cannot be empty');
      }

      // Check credentials
      final prefs = await SharedPreferences.getInstance();
      final storedCredentials = prefs.getString(_keyUserCredentials);

      if (storedCredentials == null) {
        return AuthResult.error('No account found. Please sign up.');
      }

      final credentials = storedCredentials.split(':');
      if (credentials[0] != email.trim().toLowerCase() ||
          credentials[1] != password) {
        return AuthResult.error('Invalid email or password');
      }

      // Load user
      final userJson = prefs.getString(_keyCurrentUser);
      if (userJson == null) {
        return AuthResult.error('User data not found');
      }

      final user = User.fromJsonString(userJson);
      _currentUser = user;
      await prefs.setBool(_keyIsLoggedIn, true);

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Login failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    _currentUser = null;
  }

  // Update user profile
  Future<bool> updateUser(User updatedUser) async {
    try {
      await _saveUser(updatedUser);
      _currentUser = updatedUser;
      return true;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUser);
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserCredentials);
    _currentUser = null;
  }

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Travel AI',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  // Private helper methods
  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentUser, user.toJsonString());
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }
}

// Auth result class
class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult._({
    required this.success,
    this.user,
    this.error,
  });

  factory AuthResult.success(User user) {
    return AuthResult._(success: true, user: user);
  }

  factory AuthResult.error(String message) {
    return AuthResult._(success: false, error: message);
  }
}
