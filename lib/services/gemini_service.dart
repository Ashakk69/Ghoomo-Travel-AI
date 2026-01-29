import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/destination.dart';
import '../models/user_persona.dart';
import '../models/itinerary.dart';

class GeminiService {
  static GenerativeModel? _model;

  // Initialize the Gemini model
  static Future<void> initialize() async {
    await dotenv.load();
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
      throw Exception(
          'GEMINI_API_KEY not found. Please add your API key to the .env file.\n'
          'Get a free key from: https://aistudio.google.com/app/apikey');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  // Generate a personalized trip itinerary using Gemini AI
  static Future<List<DayPlan>> generateTrip({
    required Destination destination,
    required UserPersona persona,
    required int days,
    required double budgetUSD,
    required Set<String> interests,
  }) async {
    if (_model == null) {
      await initialize();
    }

    final prompt = _buildPrompt(
      destination: destination,
      persona: persona,
      days: days,
      budgetUSD: budgetUSD,
      interests: interests,
    );

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Gemini AI');
      }

      // Parse the JSON response
      return _parseItinerary(text);
    } catch (e) {
      print('Error generating trip: $e');
      // Return fallback itinerary on error
      return _generateFallbackItinerary(destination, days, budgetUSD);
    }
  }

  static String _buildPrompt({
    required Destination destination,
    required UserPersona persona,
    required int days,
    required double budgetUSD,
    required Set<String> interests,
  }) {
    final interestsList =
        interests.isEmpty ? 'general sightseeing' : interests.join(', ');
    final dailyBudget = (budgetUSD / days).toStringAsFixed(0);

    return '''
You are a professional travel planner. Create a detailed $days-day itinerary for ${destination.name}, ${destination.country}.

User Profile:
- Travel Style: ${persona.displayName} (${persona.description})
- Interests: $interestsList
- Total Budget: \$${budgetUSD.toStringAsFixed(0)} USD (~\$$dailyBudget per day)

Requirements:
1. Create exactly $days days of activities
2. Each day should have 4-5 activities (morning activity, lunch, afternoon activity, dinner, optional evening)
3. Include realistic costs in USD for each activity
4. Provide actual place names and addresses in ${destination.name}
5. Match activities to the user's interests and travel style
6. Stay within the daily budget of \$$dailyBudget

Return ONLY a valid JSON object in this exact format (no markdown, no code blocks):
{
  "days": [
    {
      "dayNumber": 1,
      "activities": [
        {
          "time": "9:00 AM",
          "title": "Place Name",
          "type": "Culture",
          "description": "Brief description of the activity",
          "address": "Full address",
          "cost": 25.00
        }
      ]
    }
  ]
}

Activity types must be one of: Food, Nature, Nightlife, Culture, Relax

Make it authentic and exciting for a ${persona.displayName}!
''';
  }

  static List<DayPlan> _parseItinerary(String jsonText) {
    try {
      // Remove markdown code blocks if present
      String cleanJson = jsonText.trim();
      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.replaceAll(RegExp(r'```json\s*'), '');
        cleanJson = cleanJson.replaceAll(RegExp(r'```\s*'), '');
        cleanJson = cleanJson.trim();
      }

      final data = jsonDecode(cleanJson) as Map<String, dynamic>;
      final daysData = data['days'] as List<dynamic>;

      return daysData.map((dayData) {
        final dayNumber = dayData['dayNumber'] as int;
        final activitiesData = dayData['activities'] as List<dynamic>;

        final activities = activitiesData.map((actData) {
          final title = actData['title'] as String;
          final address = actData['address'] as String?;

          // Generate Google Maps URL
          String? placeUrl;
          if (address != null && address.isNotEmpty) {
            final query = Uri.encodeComponent('$title, $address');
            placeUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
          }

          return ItineraryItem(
            title,
            actData['time'] as String,
            actData['type'] as String,
            cost: (actData['cost'] as num?)?.toDouble() ?? 0.0,
            aiGenerated: true,
            personaMatch: 1.0,
            placeUrl: placeUrl,
            address: address,
            description: actData['description'] as String?,
          );
        }).toList();

        return DayPlan(dayNumber, activities);
      }).toList();
    } catch (e) {
      print('Error parsing itinerary JSON: $e');
      print('JSON text: $jsonText');
      throw Exception('Failed to parse AI response');
    }
  }

  static List<DayPlan> _generateFallbackItinerary(
    Destination destination,
    int days,
    double budgetUSD,
  ) {
    // Simple fallback itinerary if AI fails
    final dailyBudget = budgetUSD / days;

    return List.generate(days, (index) {
      final dayNumber = index + 1;
      return DayPlan(dayNumber, [
        ItineraryItem(
          'Morning Exploration',
          '9:00 AM',
          'Culture',
          cost: dailyBudget * 0.2,
          description: 'Explore local attractions',
        ),
        ItineraryItem(
          'Local Lunch',
          '12:30 PM',
          'Food',
          cost: dailyBudget * 0.25,
          description: 'Try local cuisine',
        ),
        ItineraryItem(
          'Afternoon Activity',
          '3:00 PM',
          'Nature',
          cost: dailyBudget * 0.3,
          description: 'Outdoor adventure',
        ),
        ItineraryItem(
          'Dinner',
          '7:00 PM',
          'Food',
          cost: dailyBudget * 0.25,
          description: 'Evening meal',
        ),
      ]);
    });
  }
}
