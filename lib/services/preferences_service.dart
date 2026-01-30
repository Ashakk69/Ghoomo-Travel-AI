import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'auth_service.dart';

class PreferencesService {
  static const String _keyDefaultCurrency = 'default_currency';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyTheme = 'theme';

  final AuthService _authService = AuthService();

  // Get user preferences
  Future<UserPreferences> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return UserPreferences(
      defaultCurrency: prefs.getString(_keyDefaultCurrency) ?? 'USD',
      notificationsEnabled: prefs.getBool(_keyNotificationsEnabled) ?? true,
      biometricAuthEnabled: prefs.getBool(_keyBiometricEnabled) ?? false,
      theme: prefs.getString(_keyTheme) ?? 'dark',
    );
  }

  // Save user preferences
  Future<bool> savePreferences(UserPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyDefaultCurrency, preferences.defaultCurrency);
      await prefs.setBool(
          _keyNotificationsEnabled, preferences.notificationsEnabled);
      await prefs.setBool(
          _keyBiometricEnabled, preferences.biometricAuthEnabled);
      await prefs.setString(_keyTheme, preferences.theme);

      // Update current user
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(preferences: preferences);
        await _authService.updateUser(updatedUser);
      }

      return true;
    } catch (e) {
      debugPrint('Error saving preferences: $e');
      return false;
    }
  }

  // Update specific preference
  Future<bool> updateDefaultCurrency(String currency) async {
    final currentPrefs = await getPreferences();
    final updatedPrefs = currentPrefs.copyWith(defaultCurrency: currency);
    return await savePreferences(updatedPrefs);
  }

  Future<bool> updateNotificationsEnabled(bool enabled) async {
    final currentPrefs = await getPreferences();
    final updatedPrefs = currentPrefs.copyWith(notificationsEnabled: enabled);
    return await savePreferences(updatedPrefs);
  }

  Future<bool> updateBiometricEnabled(bool enabled) async {
    final currentPrefs = await getPreferences();
    final updatedPrefs = currentPrefs.copyWith(biometricAuthEnabled: enabled);
    return await savePreferences(updatedPrefs);
  }

  Future<bool> updateTheme(String theme) async {
    final currentPrefs = await getPreferences();
    final updatedPrefs = currentPrefs.copyWith(theme: theme);
    return await savePreferences(updatedPrefs);
  }

  // Clear all preferences
  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDefaultCurrency);
    await prefs.remove(_keyNotificationsEnabled);
    await prefs.remove(_keyBiometricEnabled);
    await prefs.remove(_keyTheme);
  }
}
