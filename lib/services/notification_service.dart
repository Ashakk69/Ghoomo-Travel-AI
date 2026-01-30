import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/saved_trip.dart';
import '../models/itinerary.dart';

/// Service for managing local notifications (itinerary alerts)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('Android notification permission: $granted');
        return granted ?? false;
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('iOS notification permission: $granted');
        return granted ?? false;
      }
    }

    return false;
  }

  /// Schedule notifications for a trip's itinerary
  Future<void> scheduleItineraryNotifications(
    SavedTrip trip,
    List<DayPlan> itinerary,
  ) async {
    if (trip.startDate == null) {
      debugPrint('Cannot schedule notifications: trip has no start date');
      return;
    }

    // Cancel any existing notifications for this trip
    await cancelTripNotifications(trip.id);

    int notificationId = trip.id.hashCode;

    for (int dayIndex = 0; dayIndex < itinerary.length; dayIndex++) {
      final day = itinerary[dayIndex];
      final dayDate = trip.startDate!.add(Duration(days: dayIndex));

      for (final item in day.items) {
        // Parse time from item.time (e.g., "10:00 AM")
        final scheduledTime = _parseTimeString(item.time, dayDate);

        if (scheduledTime == null) continue;

        // Schedule notification 30 minutes before
        final notificationTime =
            scheduledTime.subtract(const Duration(minutes: 30));

        // Only schedule if in the future
        if (notificationTime.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: notificationId++,
            title: '⏰ Upcoming: ${item.title}',
            body: 'Starting at ${item.time} - Day ${day.dayNumber}',
            scheduledTime: notificationTime,
            payload: 'trip:${trip.id}',
          );

          debugPrint(
            'Scheduled notification for ${item.title} at $notificationTime',
          );
        }
      }
    }

    debugPrint(
        'Scheduled ${notificationId - trip.id.hashCode} notifications for trip');
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'itinerary_alerts',
      'Itinerary Alerts',
      channelDescription: 'Notifications for upcoming activities in your trip',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancel all notifications for a specific trip
  Future<void> cancelTripNotifications(String tripId) async {
    // Since we use trip.id.hashCode as base, we need to cancel all
    // This is a simplified approach - in production, you'd track notification IDs
    final pendingNotifications =
        await _notifications.pendingNotificationRequests();

    for (final notification in pendingNotifications) {
      if (notification.payload?.contains('trip:$tripId') ?? false) {
        await _notifications.cancel(notification.id);
      }
    }

    debugPrint('Cancelled notifications for trip: $tripId');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('Cancelled all notifications');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to trip details screen
  }

  /// Parse time string like "10:00 AM" to DateTime
  DateTime? _parseTimeString(String timeStr, DateTime date) {
    try {
      final parts = timeStr.trim().split(' ');
      if (parts.length != 2) return null;

      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;

      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final isPM = parts[1].toUpperCase() == 'PM';

      // Convert to 24-hour format
      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }

      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      debugPrint('Error parsing time: $timeStr - $e');
      return null;
    }
  }
}
