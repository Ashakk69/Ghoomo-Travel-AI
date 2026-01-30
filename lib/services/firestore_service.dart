import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/saved_trip.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Profile Operations
  Future<void> createUserProfile(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<User?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<void> deleteUserProfile(String userId) async {
    try {
      // Delete user document
      await _firestore.collection('users').doc(userId).delete();

      // Delete all user's trips
      final tripsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .get();

      for (var doc in tripsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error deleting user profile: $e');
      rethrow;
    }
  }

  // Trip Operations
  Future<void> saveTrip(String userId, SavedTrip trip) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(trip.id)
          .set(trip.toJson());
    } catch (e) {
      debugPrint('Error saving trip: $e');
      rethrow;
    }
  }

  Future<List<SavedTrip>> getUserTrips(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SavedTrip.fromJson(doc.data()))
          .whereType<SavedTrip>()
          .toList();
    } catch (e) {
      debugPrint('Error getting user trips: $e');
      return [];
    }
  }

  Future<void> deleteTrip(String userId, String tripId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(tripId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting trip: $e');
      rethrow;
    }
  }

  Future<SavedTrip?> getTrip(String userId, String tripId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(tripId)
          .get();

      if (doc.exists) {
        return SavedTrip.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting trip: $e');
      return null;
    }
  }

  // Preferences Operations
  Future<void> updatePreferences(
      String userId, UserPreferences preferences) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'preferences': preferences.toJson(),
      });
    } catch (e) {
      debugPrint('Error updating preferences: $e');
      rethrow;
    }
  }

  // Stream for real-time updates
  Stream<List<SavedTrip>> getUserTripsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('trips')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavedTrip.fromJson(doc.data()))
            .whereType<SavedTrip>()
            .toList());
  }

  Stream<User?> getUserProfileStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? User.fromJson(doc.data()!) : null);
  }
}
