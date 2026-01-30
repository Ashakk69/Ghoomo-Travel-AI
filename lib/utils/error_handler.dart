import 'package:flutter/foundation.dart';

class ErrorHandler {
  // Log error to console (in production, send to error reporting service)
  static void logError(String message,
      {Object? error, StackTrace? stackTrace}) {
    debugPrint('ERROR: $message');
    if (error != null) {
      debugPrint('Error details: $error');
    }
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // Get user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network connection error. Please check your internet connection.';
    }

    // Timeout errors
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    // Permission errors
    if (errorString.contains('permission')) {
      return 'Permission denied. Please check app permissions.';
    }

    // Storage errors
    if (errorString.contains('storage') || errorString.contains('space')) {
      return 'Storage error. Please free up some space.';
    }

    // API errors
    if (errorString.contains('api') || errorString.contains('400')) {
      return 'Invalid request. Please try again.';
    }

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Authentication failed. Please login again.';
    }

    if (errorString.contains('404')) {
      return 'Resource not found.';
    }

    if (errorString.contains('500') || errorString.contains('server')) {
      return 'Server error. Please try again later.';
    }

    // Default message
    return 'Something went wrong. Please try again.';
  }

  // Retry logic with exponential backoff
  static Future<T> retryWithBackoff<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        attempt++;
        if (attempt >= maxAttempts) {
          logError('Max retry attempts reached',
              error: error, stackTrace: stackTrace);
          rethrow;
        }

        logError('Attempt $attempt failed, retrying in ${delay.inSeconds}s',
            error: error);
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }
}
