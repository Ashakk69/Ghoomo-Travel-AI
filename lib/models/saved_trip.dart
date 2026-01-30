import 'package:flutter/foundation.dart';
import '../models/destination.dart';
import '../models/user_persona.dart';
import '../models/currency.dart';

class SavedTrip {
  final String id;
  final Destination destination;
  final UserPersona persona;
  final Currency currency;
  final double budget;
  final int days;
  final Set<String> interests;
  final DateTime createdAt;
  final DateTime?
      startDate; // Trip start date for weather forecasts and notifications
  final String? itinerary;

  SavedTrip({
    required this.id,
    required this.destination,
    required this.persona,
    required this.currency,
    required this.budget,
    required this.days,
    required this.interests,
    required this.createdAt,
    this.startDate,
    this.itinerary,
  });

  /// Calculate trip end date
  DateTime? get endDate {
    if (startDate == null) return null;
    return startDate!.add(Duration(days: days));
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destinationId': destination.id,
      'personaName': persona.name,
      'currencyCode': currency.code,
      'budget': budget,
      'days': days,
      'interests': interests.toList(),
      'createdAt': createdAt.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'itinerary': itinerary,
    };
  }

  // Create from JSON
  static SavedTrip? fromJson(Map<String, dynamic> json) {
    try {
      final destination = Destination.mockDestinations.firstWhere(
        (d) => d.id == json['destinationId'],
      );
      final persona = UserPersona.values.firstWhere(
        (p) => p.name == json['personaName'],
      );
      final currency = Currency.allCurrencies.firstWhere(
        (c) => c.code == json['currencyCode'],
      );

      return SavedTrip(
        id: json['id'],
        destination: destination,
        persona: persona,
        currency: currency,
        budget: (json['budget'] as num).toDouble(),
        days: json['days'] as int,
        interests: (json['interests'] as List).map((e) => e.toString()).toSet(),
        createdAt: DateTime.parse(json['createdAt']),
        startDate: json['startDate'] != null
            ? DateTime.parse(json['startDate'])
            : null,
        itinerary: json['itinerary'],
      );
    } catch (e) {
      debugPrint('Error parsing saved trip: $e');
      return null;
    }
  }
}
