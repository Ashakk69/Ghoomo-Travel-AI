import 'package:flutter/material.dart';

enum UserPersona {
  adventurer,
  foodie,
  cultureEnthusiast,
  relaxationSeeker,
  budgetTraveler,
  luxuryTraveler,
}

extension UserPersonaExtension on UserPersona {
  String get displayName {
    switch (this) {
      case UserPersona.adventurer:
        return 'Adventurer';
      case UserPersona.foodie:
        return 'Foodie';
      case UserPersona.cultureEnthusiast:
        return 'Culture Enthusiast';
      case UserPersona.relaxationSeeker:
        return 'Relaxation Seeker';
      case UserPersona.budgetTraveler:
        return 'Budget Traveler';
      case UserPersona.luxuryTraveler:
        return 'Luxury Traveler';
    }
  }

  String get description {
    switch (this) {
      case UserPersona.adventurer:
        return 'Thrill-seeker who loves outdoor activities, hiking, and extreme sports';
      case UserPersona.foodie:
        return 'Culinary explorer passionate about local cuisine and dining experiences';
      case UserPersona.cultureEnthusiast:
        return 'History buff who enjoys museums, art galleries, and cultural landmarks';
      case UserPersona.relaxationSeeker:
        return 'Wellness-focused traveler seeking spas, beaches, and peaceful retreats';
      case UserPersona.budgetTraveler:
        return 'Smart spender who maximizes experiences while minimizing costs';
      case UserPersona.luxuryTraveler:
        return 'Premium experience seeker who values comfort and exclusivity';
    }
  }

  IconData get icon {
    switch (this) {
      case UserPersona.adventurer:
        return Icons.terrain;
      case UserPersona.foodie:
        return Icons.restaurant_menu;
      case UserPersona.cultureEnthusiast:
        return Icons.museum;
      case UserPersona.relaxationSeeker:
        return Icons.spa;
      case UserPersona.budgetTraveler:
        return Icons.savings;
      case UserPersona.luxuryTraveler:
        return Icons.diamond;
    }
  }

  Color get color {
    switch (this) {
      case UserPersona.adventurer:
        return const Color(0xFFFF6B35);
      case UserPersona.foodie:
        return const Color(0xFFFFA500);
      case UserPersona.cultureEnthusiast:
        return const Color(0xFF6C63FF);
      case UserPersona.relaxationSeeker:
        return const Color(0xFF00E5FF);
      case UserPersona.budgetTraveler:
        return const Color(0xFF4CAF50);
      case UserPersona.luxuryTraveler:
        return const Color(0xFFFFD700);
    }
  }

  // Preference weights for AI trip generation
  Map<String, double> get preferenceWeights {
    switch (this) {
      case UserPersona.adventurer:
        return {
          'Nature': 1.5,
          'Activity': 1.5,
          'Food': 0.8,
          'Culture': 0.9,
          'Relax': 0.5
        };
      case UserPersona.foodie:
        return {
          'Food': 2.0,
          'Culture': 1.2,
          'Nature': 0.7,
          'Activity': 0.8,
          'Relax': 0.9
        };
      case UserPersona.cultureEnthusiast:
        return {
          'Culture': 2.0,
          'Food': 1.2,
          'Nature': 0.8,
          'Activity': 0.7,
          'Relax': 0.8
        };
      case UserPersona.relaxationSeeker:
        return {
          'Relax': 2.0,
          'Nature': 1.3,
          'Food': 1.1,
          'Culture': 0.6,
          'Activity': 0.4
        };
      case UserPersona.budgetTraveler:
        return {
          'Food': 1.0,
          'Culture': 1.2,
          'Nature': 1.3,
          'Activity': 1.1,
          'Relax': 0.8
        };
      case UserPersona.luxuryTraveler:
        return {
          'Food': 1.5,
          'Relax': 1.5,
          'Culture': 1.2,
          'Nature': 1.0,
          'Activity': 0.9
        };
    }
  }

  // Budget multiplier for AI trip generation
  double get budgetMultiplier {
    switch (this) {
      case UserPersona.budgetTraveler:
        return 0.7;
      case UserPersona.luxuryTraveler:
        return 1.5;
      default:
        return 1.0;
    }
  }
}
