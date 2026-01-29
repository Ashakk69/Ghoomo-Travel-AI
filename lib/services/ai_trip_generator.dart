import 'dart:math';
import '../models/destination.dart';
import '../models/itinerary.dart';
import '../models/user_persona.dart';

class AITripGenerator {
  static final Random _random = Random();

  // Generate personalized itinerary based on user preferences
  static List<DayPlan> generateItinerary({
    required Destination destination,
    required int days,
    required double budgetUSD,
    required Set<String> interests,
    required UserPersona persona,
  }) {
    final List<DayPlan> itinerary = [];
    final dailyBudget = budgetUSD / days;

    for (int day = 1; day <= days; day++) {
      final activities = _generateDayActivities(
        day: day,
        destination: destination,
        dailyBudget: dailyBudget,
        interests: interests,
        persona: persona,
      );
      itinerary.add(DayPlan(day, activities));
    }

    return itinerary;
  }

  static List<ItineraryItem> _generateDayActivities({
    required int day,
    required Destination destination,
    required double dailyBudget,
    required Set<String> interests,
    required UserPersona persona,
  }) {
    final List<ItineraryItem> activities = [];
    final weights = persona.preferenceWeights;
    final budgetMultiplier = persona.budgetMultiplier;

    // Morning activity (8-12)
    activities.add(_selectActivity(
      timeSlot: 'morning',
      interests: interests,
      weights: weights,
      budget: dailyBudget * 0.25 * budgetMultiplier,
      destination: destination,
      day: day,
    ));

    // Lunch (12-2)
    activities.add(_selectMeal(
      mealType: 'lunch',
      budget: dailyBudget * 0.20 * budgetMultiplier,
      destination: destination,
      weights: weights,
    ));

    // Afternoon activity (2-6)
    activities.add(_selectActivity(
      timeSlot: 'afternoon',
      interests: interests,
      weights: weights,
      budget: dailyBudget * 0.30 * budgetMultiplier,
      destination: destination,
      day: day,
    ));

    // Dinner (6-8)
    activities.add(_selectMeal(
      mealType: 'dinner',
      budget: dailyBudget * 0.25 * budgetMultiplier,
      destination: destination,
      weights: weights,
    ));

    return activities;
  }

  static ItineraryItem _selectActivity({
    required String timeSlot,
    required Set<String> interests,
    required Map<String, double> weights,
    required double budget,
    required Destination destination,
    required int day,
  }) {
    final activities = _getActivitiesForDestination(destination, timeSlot, day);

    // Filter by interests and apply persona weights
    final scoredActivities = activities.map((activity) {
      final baseScore = interests.contains(activity['type']) ? 1.0 : 0.5;
      final weightedScore = baseScore * (weights[activity['type']] ?? 1.0);
      return {...activity, 'score': weightedScore};
    }).toList();

    // Sort by score and pick top options
    scoredActivities
        .sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    final selected =
        scoredActivities[_random.nextInt(min(3, scoredActivities.length))];

    return ItineraryItem(
      selected['title'] as String,
      selected['time'] as String,
      selected['type'] as String,
      cost: (selected['cost'] as double) * (budget / 50),
      aiGenerated: true,
      personaMatch: (selected['score'] as double) / 2.0,
    );
  }

  static ItineraryItem _selectMeal({
    required String mealType,
    required double budget,
    required Destination destination,
    required Map<String, double> weights,
  }) {
    final meals = _getMealsForDestination(destination, mealType);
    final foodWeight = weights['Food'] ?? 1.0;

    final selected = meals[_random.nextInt(meals.length)];

    return ItineraryItem(
      selected['title'] as String,
      selected['time'] as String,
      'Food',
      cost: (selected['cost'] as double) * budget / 30,
      aiGenerated: true,
      personaMatch: foodWeight / 2.0,
    );
  }

  static List<Map<String, dynamic>> _getActivitiesForDestination(
    Destination destination,
    String timeSlot,
    int day,
  ) {
    // Activity database by destination
    final activityTemplates = {
      'Kyoto': [
        {
          'title': 'Fushimi Inari Shrine Visit',
          'type': 'Culture',
          'cost': 15.0
        },
        {'title': 'Bamboo Forest Walk', 'type': 'Nature', 'cost': 10.0},
        {'title': 'Tea Ceremony Experience', 'type': 'Culture', 'cost': 45.0},
        {'title': 'Zen Garden Meditation', 'type': 'Relax', 'cost': 20.0},
        {'title': 'Geisha District Tour', 'type': 'Culture', 'cost': 35.0},
        {'title': 'Mountain Hiking', 'type': 'Nature', 'cost': 25.0},
      ],
      'Santorini': [
        {'title': 'Caldera Sunset Cruise', 'type': 'Relax', 'cost': 60.0},
        {'title': 'Ancient Akrotiri Ruins', 'type': 'Culture', 'cost': 25.0},
        {'title': 'Wine Tasting Tour', 'type': 'Food', 'cost': 50.0},
        {'title': 'Beach Relaxation', 'type': 'Relax', 'cost': 15.0},
        {'title': 'Volcano Hiking', 'type': 'Nature', 'cost': 40.0},
        {'title': 'Photography Walk', 'type': 'Culture', 'cost': 20.0},
      ],
      'Reykjavik': [
        {'title': 'Northern Lights Tour', 'type': 'Nature', 'cost': 80.0},
        {'title': 'Blue Lagoon Spa', 'type': 'Relax', 'cost': 70.0},
        {'title': 'Golden Circle Tour', 'type': 'Nature', 'cost': 90.0},
        {'title': 'Glacier Hiking', 'type': 'Nature', 'cost': 120.0},
        {'title': 'Viking Museum', 'type': 'Culture', 'cost': 20.0},
        {'title': 'Geothermal Pool', 'type': 'Relax', 'cost': 30.0},
      ],
      'Bali': [
        {'title': 'Temple Sunrise Visit', 'type': 'Culture', 'cost': 25.0},
        {'title': 'Rice Terrace Trek', 'type': 'Nature', 'cost': 30.0},
        {'title': 'Balinese Massage', 'type': 'Relax', 'cost': 35.0},
        {'title': 'Surf Lesson', 'type': 'Nature', 'cost': 40.0},
        {'title': 'Cooking Class', 'type': 'Food', 'cost': 45.0},
        {'title': 'Waterfall Adventure', 'type': 'Nature', 'cost': 35.0},
      ],
      'New York': [
        {'title': 'Central Park Walk', 'type': 'Nature', 'cost': 0.0},
        {'title': 'Metropolitan Museum', 'type': 'Culture', 'cost': 30.0},
        {'title': 'Broadway Show', 'type': 'Nightlife', 'cost': 150.0},
        {'title': 'Statue of Liberty', 'type': 'Culture', 'cost': 25.0},
        {'title': 'High Line Stroll', 'type': 'Relax', 'cost': 0.0},
        {'title': 'Brooklyn Bridge Walk', 'type': 'Nature', 'cost': 0.0},
      ],
    };

    final activities =
        activityTemplates[destination.name] ?? activityTemplates['Kyoto']!;

    return activities.map((activity) {
      final time = timeSlot == 'morning'
          ? '${8 + _random.nextInt(3)}:00 AM'
          : '${2 + _random.nextInt(3)}:00 PM';
      return {...activity, 'time': time};
    }).toList();
  }

  static List<Map<String, dynamic>> _getMealsForDestination(
    Destination destination,
    String mealType,
  ) {
    final mealTemplates = {
      'Kyoto': [
        {'title': 'Traditional Kaiseki Dining', 'cost': 60.0},
        {'title': 'Ramen House Experience', 'cost': 15.0},
        {'title': 'Sushi Master Class', 'cost': 80.0},
        {'title': 'Street Food Market', 'cost': 20.0},
      ],
      'Santorini': [
        {'title': 'Cliffside Mediterranean Feast', 'cost': 70.0},
        {'title': 'Fresh Seafood Taverna', 'cost': 45.0},
        {'title': 'Greek Meze Platter', 'cost': 30.0},
        {'title': 'Local Wine & Cheese', 'cost': 35.0},
      ],
      'Reykjavik': [
        {'title': 'Nordic Cuisine Experience', 'cost': 65.0},
        {'title': 'Fresh Fish Restaurant', 'cost': 50.0},
        {'title': 'Traditional Lamb Dinner', 'cost': 55.0},
        {'title': 'Cozy Cafe Meal', 'cost': 25.0},
      ],
      'Bali': [
        {'title': 'Beachfront Seafood BBQ', 'cost': 40.0},
        {'title': 'Organic Farm-to-Table', 'cost': 35.0},
        {'title': 'Traditional Warung', 'cost': 15.0},
        {'title': 'Jungle View Restaurant', 'cost': 45.0},
      ],
      'New York': [
        {'title': 'Fine Dining Experience', 'cost': 120.0},
        {'title': 'Iconic NYC Pizza', 'cost': 20.0},
        {'title': 'Trendy Rooftop Bar', 'cost': 60.0},
        {'title': 'Food Hall Exploration', 'cost': 30.0},
      ],
    };

    final meals = mealTemplates[destination.name] ?? mealTemplates['Kyoto']!;
    final time = mealType == 'lunch' ? '12:30 PM' : '7:00 PM';

    return meals.map((meal) => {...meal, 'time': time}).toList();
  }
}
