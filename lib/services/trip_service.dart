import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/saved_SavedTrip.dart';

/// Service for managing SavedTrips in Supabase database
class SavedTripService {
  // Get Supabase client
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Get all SavedTrips for the current user
  Future<List<SavedTrip>> getUserSavedTrips() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('⚠️ No user logged in');
        return [];
      }

      final response = await _supabase
          .from('SavedTrips')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => SavedTrip.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error loading SavedTrips: $e');
      return [];
    }
  }

  /// Save a new SavedTrip
  Future<bool> saveSavedTrip(SavedTrip SavedTrip) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('⚠️ No user logged in');
        return false;
      }

      final SavedTripData = SavedTrip.toJson();
      SavedTripData['user_id'] = userId;

      await _supabase.from('SavedTrips').insert(SavedTripData);

      debugPrint('✅ SavedTrip saved successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving SavedTrip: $e');
      return false;
    }
  }

  /// Update an existing SavedTrip
  Future<bool> updateSavedTrip(SavedTrip SavedTrip) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('⚠️ No user logged in');
        return false;
      }

      final SavedTripData = SavedTrip.toJson();
      SavedTripData['user_id'] = userId;
      SavedTripData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('SavedTrips')
          .update(SavedTripData)
          .eq('id', SavedTrip.id)
          .eq('user_id', userId);

      debugPrint('✅ SavedTrip updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating SavedTrip: $e');
      return false;
    }
  }

  /// Delete a SavedTrip
  Future<bool> deleteSavedTrip(String SavedTripId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('⚠️ No user logged in');
        return false;
      }

      await _supabase
          .from('SavedTrips')
          .delete()
          .eq('id', SavedTripId)
          .eq('user_id', userId);

      debugPrint('✅ SavedTrip deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting SavedTrip: $e');
      return false;
    }
  }

  /// Get a single SavedTrip by ID
  Future<SavedTrip?> getSavedTrip(String SavedTripId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('⚠️ No user logged in');
        return null;
      }

      final response = await _supabase
          .from('SavedTrips')
          .select()
          .eq('id', SavedTripId)
          .eq('user_id', userId)
          .single();

      return SavedTrip.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error loading SavedTrip: $e');
      return null;
    }
  }

  /// Save a flight to a SavedTrip
  Future<bool> saveFlight({
    required String SavedTripId,
    required Map<String, dynamic> flightData,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('⚠️ No user logged in');
        return false;
      }

      await _supabase.from('saved_flights').insert({
        'user_id': userId,
        'SavedTrip_id': SavedTripId,
        'flight_data': flightData,
      });

      debugPrint('✅ Flight saved successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving flight: $e');
      return false;
    }
  }

  /// Save a hotel to a SavedTrip
  Future<bool> saveHotel({
    required String SavedTripId,
    required Map<String, dynamic> hotelData,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('⚠️ No user logged in');
        return false;
      }

      await _supabase.from('saved_hotels').insert({
        'user_id': userId,
        'SavedTrip_id': SavedTripId,
        'hotel_data': hotelData,
      });

      debugPrint('✅ Hotel saved successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving hotel: $e');
      return false;
    }
  }

  /// Get saved flights for a SavedTrip
  Future<List<Map<String, dynamic>>> getSavedTripFlights(String SavedTripId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('saved_flights')
          .select('flight_data')
          .eq('SavedTrip_id', SavedTripId)
          .eq('user_id', userId);

      return (response as List)
          .map((item) => item['flight_data'] as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('❌ Error loading flights: $e');
      return [];
    }
  }

  /// Get saved hotels for a SavedTrip
  Future<List<Map<String, dynamic>>> getSavedTripHotels(String SavedTripId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('saved_hotels')
          .select('hotel_data')
          .eq('SavedTrip_id', SavedTripId)
          .eq('user_id', userId);

      return (response as List)
          .map((item) => item['hotel_data'] as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('❌ Error loading hotels: $e');
      return [];
    }
  }

  /// Listen to real-time SavedTrip updates
  Stream<List<SavedTrip>> watchUserSavedTrips() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('SavedTrips')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => SavedTrip.fromJson(json)).toList());
  }
}
