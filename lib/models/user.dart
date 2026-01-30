import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final UserPreferences preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
    required this.createdAt,
    required this.preferences,
  });

  // Create a copy with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePictureUrl,
    DateTime? createdAt,
    UserPreferences? preferences,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt.toIso8601String(),
      'preferences': preferences.toJson(),
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      preferences: UserPreferences.fromJson(
        json['preferences'] as Map<String, dynamic>,
      ),
    );
  }

  // Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create from JSON string
  factory User.fromJsonString(String jsonString) {
    return User.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  // Get user initials for avatar
  String getInitials() {
    final nameParts = name.trim().split(' ');
    if (nameParts.isEmpty) return '?';
    if (nameParts.length == 1) {
      return nameParts[0].substring(0, 1).toUpperCase();
    }
    return (nameParts[0].substring(0, 1) + nameParts[1].substring(0, 1))
        .toUpperCase();
  }
}

class UserPreferences {
  final String defaultCurrency;
  final bool notificationsEnabled;
  final bool biometricAuthEnabled;
  final String theme; // 'dark', 'light', 'system'

  UserPreferences({
    this.defaultCurrency = 'USD',
    this.notificationsEnabled = true,
    this.biometricAuthEnabled = false,
    this.theme = 'dark',
  });

  UserPreferences copyWith({
    String? defaultCurrency,
    bool? notificationsEnabled,
    bool? biometricAuthEnabled,
    String? theme,
  }) {
    return UserPreferences(
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
      theme: theme ?? this.theme,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultCurrency': defaultCurrency,
      'notificationsEnabled': notificationsEnabled,
      'biometricAuthEnabled': biometricAuthEnabled,
      'theme': theme,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      defaultCurrency: json['defaultCurrency'] as String? ?? 'USD',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      biometricAuthEnabled: json['biometricAuthEnabled'] as bool? ?? false,
      theme: json['theme'] as String? ?? 'dark',
    );
  }
}
