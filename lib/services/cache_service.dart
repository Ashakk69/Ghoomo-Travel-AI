import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CacheService {
  static const String _keyCacheSize = 'cache_size_bytes';
  static const String _keyLastCacheUpdate = 'last_cache_update';

  /// Get estimated cache size in bytes
  Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyCacheSize) ?? 0;
    } catch (e) {
      debugPrint('Error getting cache size: $e');
      return 0;
    }
  }

  /// Format cache size for display
  String formatCacheSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Clear all caches
  Future<bool> clearAllCaches() async {
    try {
      // Clear image cache
      await clearImageCache();

      // Clear shared preferences cache (except user data and important settings)
      await _clearNonEssentialPreferences();

      // Update cache size
      await _updateCacheSize(0);

      debugPrint('✅ All caches cleared successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error clearing caches: $e');
      return false;
    }
  }

  /// Clear image cache
  Future<void> clearImageCache() async {
    try {
      // Clear cached network images
      await CachedNetworkImage.evictFromCache('');

      // Clear Flutter's image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      debugPrint('✅ Image cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing image cache: $e');
    }
  }

  /// Clear non-essential shared preferences
  Future<void> _clearNonEssentialPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      // List of keys to preserve
      const preserveKeys = [
        'has_seen_onboarding',
        'user_data',
        'user_preferences',
        'saved_trips',
        'biometric_email',
        'biometric_password',
      ];

      // Remove non-essential keys
      for (final key in keys) {
        if (!preserveKeys.contains(key) && !key.startsWith('trip_')) {
          await prefs.remove(key);
        }
      }

      debugPrint('✅ Non-essential preferences cleared');
    } catch (e) {
      debugPrint('❌ Error clearing preferences: $e');
    }
  }

  /// Update cache size estimate
  Future<void> _updateCacheSize(int bytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyCacheSize, bytes);
      await prefs.setString(
        _keyLastCacheUpdate,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error updating cache size: $e');
    }
  }

  /// Estimate and update current cache size
  Future<void> estimateCacheSize() async {
    try {
      // This is a rough estimate
      // In a production app, you'd want to actually measure file sizes
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      int totalSize = 0;
      for (final key in keys) {
        final value = prefs.get(key);
        if (value is String) {
          totalSize += value.length;
        } else if (value is List) {
          totalSize += value.length * 100; // Rough estimate
        }
      }

      // Add estimate for image cache (rough approximation)
      final imageCache = PaintingBinding.instance.imageCache;
      totalSize +=
          (imageCache.currentSize.toInt() * 50000); // Rough estimate per image

      await _updateCacheSize(totalSize);
    } catch (e) {
      debugPrint('Error estimating cache size: $e');
    }
  }

  /// Get last cache update time
  Future<DateTime?> getLastCacheUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateString = prefs.getString(_keyLastCacheUpdate);
      if (dateString != null) {
        return DateTime.parse(dateString);
      }
    } catch (e) {
      debugPrint('Error getting last cache update: $e');
    }
    return null;
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final size = await getCacheSize();
    final lastUpdate = await getLastCacheUpdate();

    return {
      'size': size,
      'formattedSize': formatCacheSize(size),
      'lastUpdate': lastUpdate,
      'imageCount': PaintingBinding.instance.imageCache.currentSize,
    };
  }
}
