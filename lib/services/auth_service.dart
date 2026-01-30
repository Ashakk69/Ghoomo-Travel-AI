import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart' as app_models;
import 'firestore_service.dart';

class AuthService {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyBiometricEmail = 'biometric_email';
  static const String _keyBiometricPassword = 'biometric_password';

  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  app_models.User? _currentUser;

  // Get current user
  app_models.User? get currentUser => _currentUser;

  // Get Firebase user
  firebase_auth.User? get firebaseUser => _firebaseAuth.currentUser;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _firebaseAuth.currentUser != null;
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
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      await _loadUserProfile(firebaseUser.uid);
    }
  }

  // Load user profile from Firestore
  Future<void> _loadUserProfile(String userId) async {
    try {
      final user = await _firestoreService.getUserProfile(userId);
      _currentUser = user;
    } catch (e) {
      debugPrint('Error loading user profile: $e');
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

      // Create Firebase user
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (credential.user == null) {
        return AuthResult.error('Failed to create user');
      }

      // Update display name
      await credential.user!.updateDisplayName(name.trim());

      // Create user profile in Firestore
      final user = app_models.User(
        id: credential.user!.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        createdAt: DateTime.now(),
        preferences: app_models.UserPreferences(),
      );

      await _firestoreService.createUserProfile(user);
      _currentUser = user;

      // Send email verification (optional)
      try {
        await credential.user!.sendEmailVerification();
      } catch (e) {
        debugPrint('Email verification not sent: $e');
      }

      return AuthResult.success(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.error(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Sign up failed: ${e.toString()}');
    }
  }

  // Login user
  Future<AuthResult> login({
    required String email,
    required String password,
    bool rememberCredentials = false,
  }) async {
    try {
      // Validate inputs
      if (!_isValidEmail(email)) {
        return AuthResult.error('Invalid email format');
      }
      if (password.isEmpty) {
        return AuthResult.error('Password cannot be empty');
      }

      // Sign in with Firebase
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (credential.user == null) {
        return AuthResult.error('Login failed');
      }

      // Load user profile from Firestore
      await _loadUserProfile(credential.user!.uid);

      if (_currentUser == null) {
        return AuthResult.error('User profile not found');
      }

      // Save credentials for biometric auth if requested
      if (rememberCredentials) {
        await _saveBiometricCredentials(email, password);
      }

      return AuthResult.success(_currentUser!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.error(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Login failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
  }

  // Update user profile
  Future<bool> updateUser(app_models.User updatedUser) async {
    try {
      await _firestoreService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
      return true;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestoreService.deleteUserProfile(user.uid);
      await user.delete();
      _currentUser = null;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.code}');
      return false;
    }
  }

  // Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return AuthResult.error('No user logged in');
      }

      // Re-authenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return AuthResult.success(_currentUser!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.error(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Failed to change password: ${e.toString()}');
    }
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

  // Authenticate with biometrics and auto-login
  Future<AuthResult?> authenticateWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Travel AI',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!authenticated) {
        return null;
      }

      // Get saved credentials
      final email = await _secureStorage.read(key: _keyBiometricEmail);
      final password = await _secureStorage.read(key: _keyBiometricPassword);

      if (email == null || password == null) {
        return AuthResult.error('No saved credentials found');
      }

      // Login with saved credentials
      return await login(email: email, password: password);
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return AuthResult.error('Biometric authentication failed');
    }
  }

  // Save credentials for biometric auth
  Future<void> _saveBiometricCredentials(String email, String password) async {
    try {
      await _secureStorage.write(key: _keyBiometricEmail, value: email);
      await _secureStorage.write(key: _keyBiometricPassword, value: password);
    } catch (e) {
      debugPrint('Error saving biometric credentials: $e');
    }
  }

  // Clear saved biometric credentials
  Future<void> clearBiometricCredentials() async {
    try {
      await _secureStorage.delete(key: _keyBiometricEmail);
      await _secureStorage.delete(key: _keyBiometricPassword);
    } catch (e) {
      debugPrint('Error clearing biometric credentials: $e');
    }
  }

  // Check if biometric credentials are saved
  Future<bool> hasBiometricCredentials() async {
    try {
      final email = await _secureStorage.read(key: _keyBiometricEmail);
      return email != null;
    } catch (e) {
      return false;
    }
  }

  // Listen to auth state changes
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  // Private helper methods
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  String _getFirebaseErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please login again to perform this action.';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}

// Auth result class
class AuthResult {
  final bool success;
  final app_models.User? user;
  final String? error;

  AuthResult._({
    required this.success,
    this.user,
    this.error,
  });

  factory AuthResult.success(app_models.User user) {
    return AuthResult._(success: true, user: user);
  }

  factory AuthResult.error(String message) {
    return AuthResult._(success: false, error: message);
  }
}
