import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_trip.dart';

class TripStorageService {
  static const String _tripsKey = 'saved_trips';

  // Save a trip
  Future<void> saveTrip(SavedTrip trip) async {
    final prefs = await SharedPreferences.getInstance();
    final trips = await getAllTrips();

    // Add new trip
    trips.add(trip);

    // Save to storage
    final tripsJson = trips.map((t) => t.toJson()).toList();
    await prefs.setString(_tripsKey, json.encode(tripsJson));
  }

  // Get all saved trips
  Future<List<SavedTrip>> getAllTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final tripsData = prefs.getString(_tripsKey);

    if (tripsData == null) return [];

    final List<dynamic> tripsList = json.decode(tripsData);
    return tripsList
        .map((json) => SavedTrip.fromJson(json))
        .whereType<SavedTrip>()
        .toList();
  }

  // Delete a trip
  Future<void> deleteTrip(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    final trips = await getAllTrips();

    trips.removeWhere((trip) => trip.id == tripId);

    final tripsJson = trips.map((t) => t.toJson()).toList();
    await prefs.setString(_tripsKey, json.encode(tripsJson));
  }

  // Get trip by ID
  Future<SavedTrip?> getTripById(String tripId) async {
    final trips = await getAllTrips();
    try {
      return trips.firstWhere((trip) => trip.id == tripId);
    } catch (e) {
      return null;
    }
  }

  // Get trip statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final trips = await getAllTrips();

    final uniqueCountries =
        trips.map((t) => t.destination.country).toSet().length;
    final totalBudget = trips.fold<double>(0, (sum, trip) => sum + trip.budget);
    final totalDays = trips.fold<int>(0, (sum, trip) => sum + trip.days);

    return {
      'totalTrips': trips.length,
      'uniqueCountries': uniqueCountries,
      'totalBudget': totalBudget,
      'totalDays': totalDays,
    };
  }

  // Clear all trips
  Future<void> clearAllTrips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tripsKey);
  }
}
