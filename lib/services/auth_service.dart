import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart' as app_models;

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyBiometricEmail = 'biometric_email';
  static const String _keyBiometricPassword = 'biometric_password';
  static const String _keyUserData = 'user_data';

  // Get Supabase client
  SupabaseClient get _supabase => Supabase.instance.client;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  app_models.User? _currentUser;

  // Get current user
  app_models.User? get currentUser => _currentUser;

  // Get Supabase user
  User? get supabaseUser {
    try {
      return _supabase.auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final session = _supabase.auth.currentSession;
      return session != null;
    } catch (e) {
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_keyUserData);
    }
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
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _loadUserProfile(session.user.id);
      } else {
        // Try loading from local storage
        await _loadLocalUser();
      }
    } catch (e) {
      debugPrint('Auth initialization: Using local storage');
      await _loadLocalUser();
    }
  }

  // Load user profile from Supabase
  Future<void> _loadUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).single();

      _currentUser = app_models.User.fromJson(response);
      await _saveLocalUser(_currentUser!);
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      await _loadLocalUser();
    }
  }

  // Save user to local storage
  Future<void> _saveLocalUser(app_models.User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserData, user.toJson().toString());
    } catch (e) {
      debugPrint('Error saving local user: $e');
    }
  }

  // Load user from local storage
  Future<void> _loadLocalUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_keyUserData);
      if (userData != null) {
        // Parse and load user (simplified)
        debugPrint('Loaded user from local storage');
      }
    } catch (e) {
      debugPrint('Error loading local user: $e');
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

      // Sign up with Supabase
      final response = await _supabase.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {'display_name': name.trim()},
      );

      if (response.user == null) {
        return AuthResult.error('Failed to create user');
      }

      // Create user profile in database
      final user = app_models.User(
        id: response.user!.id,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        createdAt: DateTime.now(),
        preferences: app_models.UserPreferences(),
      );

      try {
        await _supabase.from('users').insert(user.toJson());
      } catch (e) {
        debugPrint('Error creating user profile in DB: $e');
      }

      _currentUser = user;
      await _saveLocalUser(user);

      return AuthResult.success(user);
    } on AuthException catch (e) {
      return AuthResult.error(_getSupabaseErrorMessage(e));
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

      // Sign in with Supabase
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (response.user == null) {
        return AuthResult.error('Login failed');
      }

      // Load user profile from database
      await _loadUserProfile(response.user!.id);

      if (_currentUser == null) {
        // Create basic user if profile doesn't exist
        _currentUser = app_models.User(
          id: response.user!.id,
          name: response.user!.userMetadata?['display_name'] ?? 'User',
          email: email.trim().toLowerCase(),
          createdAt: DateTime.now(),
          preferences: app_models.UserPreferences(),
        );
        await _saveLocalUser(_currentUser!);
      }

      // Save credentials for biometric auth if requested
      if (rememberCredentials) {
        await _saveBiometricCredentials(email, password);
      }

      return AuthResult.success(_currentUser!);
    } on AuthException catch (e) {
      return AuthResult.error(_getSupabaseErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Login failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserData);
  }

  // Update user profile
  Future<bool> updateUser(app_models.User updatedUser) async {
    try {
      await _supabase
          .from('users')
          .update(updatedUser.toJson())
          .eq('id', updatedUser.id);
      _currentUser = updatedUser;
      await _saveLocalUser(updatedUser);
      return true;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('users').delete().eq('id', user.id);
        // Note: Supabase doesn't allow deleting auth users from client
        // This needs to be done via admin API or database trigger
      } catch (e) {
        debugPrint('Error deleting user data: $e');
      }
      await logout();
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim().toLowerCase(),
      );
      return true;
    } on AuthException catch (e) {
      debugPrint('Password reset error: ${e.message}');
      return false;
    }
  }

  // Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null || user.email == null) {
        return AuthResult.error('No user logged in');
      }

      // Supabase requires re-authentication for password change
      // First verify current password by attempting to sign in
      try {
        await _supabase.auth.signInWithPassword(
          email: user.email!,
          password: currentPassword,
        );
      } catch (e) {
        return AuthResult.error('Current password is incorrect');
      }

      // Update password
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return AuthResult.success(_currentUser!);
    } on AuthException catch (e) {
      return AuthResult.error(_getSupabaseErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Failed to change password: ${e.toString()}');
    }
  }

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      // DEV MODE: Bypass for testing on PC
      if (kDebugMode) return true;

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
      var authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Travel AI',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      // DEV MODE: Simulate success if auth fails locally (e.g. no hardware)
      if (!authenticated && kDebugMode) {
        debugPrint('DEV MODE: Simulating biometric success');
        authenticated = true;
      }

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
  Stream<AuthState> get authStateChanges {
    try {
      return _supabase.auth.onAuthStateChange;
    } catch (e) {
      return const Stream.empty();
    }
  }

  // Private helper methods
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  String _getSupabaseErrorMessage(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('email') && message.contains('already')) {
      return 'This email is already registered. Please login instead.';
    } else if (message.contains('invalid') && message.contains('email')) {
      return 'Invalid email address.';
    } else if (message.contains('password') && message.contains('weak')) {
      return 'Password is too weak. Please use a stronger password.';
    } else if (message.contains('user') && message.contains('not found')) {
      return 'No account found with this email.';
    } else if (message.contains('invalid') && message.contains('credentials')) {
      return 'Incorrect email or password.';
    } else if (message.contains('too many')) {
      return 'Too many attempts. Please try again later.';
    } else if (message.contains('network')) {
      return 'Network error. Please check your connection.';
    }

    return e.message;
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
