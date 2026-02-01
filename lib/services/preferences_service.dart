import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import 'auth_service.dart';

class PreferencesService {
  static const String _keyDefaultCurrency = 'default_currency';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyTheme = 'theme';
  static const String _keyLikedDestinations = 'liked_destinations';
  static const String _keySavedDestinations = 'saved_destinations';
  static const String _keyTravelStyles = 'travel_styles';
  static const String _keyAISettings = 'ai_settings';
  static const String _keySelectedFilter = 'selected_filter';

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

  // Liked Destinations
  Future<Set<String>> getLikedDestinations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? liked = prefs.getStringList(_keyLikedDestinations);
    return liked?.toSet() ?? {};
  }

  Future<bool> toggleLikedDestination(String destinationId) async {
    final prefs = await SharedPreferences.getInstance();
    final liked = await getLikedDestinations();

    if (liked.contains(destinationId)) {
      liked.remove(destinationId);
    } else {
      liked.add(destinationId);
    }

    return await prefs.setStringList(_keyLikedDestinations, liked.toList());
  }

  Future<bool> isDestinationLiked(String destinationId) async {
    final liked = await getLikedDestinations();
    return liked.contains(destinationId);
  }

  // Saved/Bookmarked Destinations
  Future<Set<String>> getSavedDestinations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList(_keySavedDestinations);
    return saved?.toSet() ?? {};
  }

  Future<bool> toggleSavedDestination(String destinationId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await getSavedDestinations();

    if (saved.contains(destinationId)) {
      saved.remove(destinationId);
    } else {
      saved.add(destinationId);
    }

    return await prefs.setStringList(_keySavedDestinations, saved.toList());
  }

  Future<bool> isDestinationSaved(String destinationId) async {
    final saved = await getSavedDestinations();
    return saved.contains(destinationId);
  }

  // Travel Styles
  Future<Map<String, bool>> getTravelStyles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? stylesJson = prefs.getString(_keyTravelStyles);

    if (stylesJson != null) {
      final Map<String, dynamic> decoded = json.decode(stylesJson);
      return decoded.map((key, value) => MapEntry(key, value as bool));
    }

    // Default travel styles
    return {
      'Backpacker': true,
      'Luxury': false,
      'Nightlife': false,
      'Nature': true,
      'History': false,
      'Relaxation': false,
    };
  }

  Future<bool> saveTravelStyles(Map<String, bool> styles) async {
    final prefs = await SharedPreferences.getInstance();
    final String stylesJson = json.encode(styles);
    return await prefs.setString(_keyTravelStyles, stylesJson);
  }

  // AI Settings
  Future<Map<String, bool>> getAISettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString(_keyAISettings);

    if (settingsJson != null) {
      final Map<String, dynamic> decoded = json.decode(settingsJson);
      return decoded.map((key, value) => MapEntry(key, value as bool));
    }

    // Default AI settings
    return {
      'Smart Budgeting': true,
      'Hidden Gems': true,
      'Eco Routing': false,
    };
  }

  Future<bool> saveAISettings(Map<String, bool> settings) async {
    final prefs = await SharedPreferences.getInstance();
    final String settingsJson = json.encode(settings);
    return await prefs.setString(_keyAISettings, settingsJson);
  }

  // Filter Preferences
  Future<String> getSelectedFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedFilter) ?? 'Trending';
  }

  Future<bool> saveSelectedFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keySelectedFilter, filter);
  }
}
