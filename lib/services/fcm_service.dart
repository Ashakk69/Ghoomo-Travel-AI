import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user_persona.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.notification?.title}');
}

/// Service for Firebase Cloud Messaging (promotional notifications)
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  /// Initialize FCM
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('FCM permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        final token = await _messaging.getToken();
        debugPrint('FCM Token: $token');

        // Set up message handlers
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);

        _initialized = true;
        debugPrint('FCM initialized successfully');
      } else {
        debugPrint('FCM permission denied');
      }
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  /// Subscribe to topics based on user persona
  Future<void> subscribeToPersonaTopics(UserPersona persona) async {
    try {
      // Unsubscribe from all topics first
      await _messaging.unsubscribeFromTopic('budget_travel');
      await _messaging.unsubscribeFromTopic('luxury_travel');
      await _messaging.unsubscribeFromTopic('relaxation');

      // Subscribe based on persona
      switch (persona) {
        case UserPersona.budgetTraveler:
          await _messaging.subscribeToTopic('budget_travel');
          debugPrint('Subscribed to: budget_travel');
          break;
        case UserPersona.luxuryTraveler:
          await _messaging.subscribeToTopic('luxury_travel');
          debugPrint('Subscribed to: luxury_travel');
          break;
        case UserPersona.adventurer:
          await _messaging.subscribeToTopic('budget_travel');
          debugPrint('Subscribed to: budget_travel');
          break;
        case UserPersona.cultureEnthusiast:
          await _messaging.subscribeToTopic('luxury_travel');
          debugPrint('Subscribed to: luxury_travel');
          break;
        case UserPersona.relaxationSeeker:
          await _messaging.subscribeToTopic('relaxation');
          debugPrint('Subscribed to: relaxation');
          break;
        case UserPersona.foodie:
          await _messaging.subscribeToTopic('luxury_travel');
          debugPrint('Subscribed to: luxury_travel');
          break;
      }
    } catch (e) {
      debugPrint('Error subscribing to topics: $e');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');

    // Show notification even in foreground
    // The notification will be displayed by the system
  }

  /// Handle notification tap when app is in background
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.notification?.title}');

    // Handle deep linking
    final data = message.data;
    if (data.containsKey('screen')) {
      _navigateToScreen(data['screen']);
    }
  }

  /// Navigate to specific screen based on deep link
  void _navigateToScreen(String screen) {
    debugPrint('Navigate to screen: $screen');
    // TODO: Implement navigation logic
    // This would typically use Navigator or a routing package
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Check if FCM is initialized
  bool get isInitialized => _initialized;
}
