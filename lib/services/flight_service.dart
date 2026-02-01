import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/flight_info.dart';
import '../models/flight_search_params.dart';

/// Service for fetching real-time flight data
/// Uses Amadeus API with fallback to mock data
class FlightService {
  static const String _baseUrl = 'https://test.api.amadeus.com/v2';
  static const String _tokenUrl =
      'https://test.api.amadeus.com/v1/security/oauth2/token';
  static const String _cachePrefix = 'flight_cache_';
  static const Duration _cacheDuration = Duration(hours: 1);

  String? _accessToken;
  DateTime? _tokenExpiry;

  /// Get API credentials from environment
  String get _apiKey => dotenv.env['AMADEUS_API_KEY'] ?? '';
  String get _apiSecret => dotenv.env['AMADEUS_API_SECRET'] ?? '';

  /// Check if API is configured
  bool get isConfigured => _apiKey.isNotEmpty && _apiSecret.isNotEmpty;

  /// Get OAuth access token
  Future<String?> _getAccessToken() async {
    // Return cached token if still valid
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    if (!isConfigured) {
      debugPrint('⚠️ Amadeus API not configured, using mock data');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'client_credentials',
          'client_id': _apiKey,
          'client_secret': _apiSecret,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final expiresIn = data['expires_in'] as int;
        _tokenExpiry =
            DateTime.now().add(Duration(seconds: expiresIn - 60)); // 60s buffer
        return _accessToken;
      } else {
        debugPrint('❌ Failed to get Amadeus token: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error getting Amadeus token: $e');
      return null;
    }
  }

  /// Search for flights
  Future<List<FlightInfo>> searchFlights(FlightSearchParams params) async {
    // Try cache first
    final cachedFlights = await _getCachedFlights(params);
    if (cachedFlights != null) {
      debugPrint('✅ Returning cached flight results');
      return cachedFlights;
    }

    // Try API
    final token = await _getAccessToken();
    if (token != null) {
      final apiFlights = await _searchFlightsFromAPI(params, token);
      if (apiFlights != null) {
        await _cacheFlights(params, apiFlights);
        return apiFlights;
      }
    }

    // Fallback to mock data
    debugPrint('⚠️ Using mock flight data');
    return _generateMockFlights(params);
  }

  /// Search flights from Amadeus API
  Future<List<FlightInfo>?> _searchFlightsFromAPI(
      FlightSearchParams params, String token) async {
    try {
      final queryParams = {
        'originLocationCode': params.origin,
        'destinationLocationCode': params.destination,
        'departureDate': params.departureDate.toIso8601String().split('T')[0],
        'adults': params.passengers.toString(),
        'travelClass': params.cabinClass,
        'max': '50',
      };

      if (params.returnDate != null) {
        queryParams['returnDate'] =
            params.returnDate!.toIso8601String().split('T')[0];
      }

      final uri = Uri.parse('$_baseUrl/shopping/flight-offers')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final offers = data['data'] as List<dynamic>?;

        if (offers == null || offers.isEmpty) {
          return [];
        }

        final flights =
            offers.map((offer) => _parseAmadeusOffer(offer)).toList();
        return _applyFilters(flights, params);
      } else {
        debugPrint(
            '❌ Amadeus API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching flights from API: $e');
      return null;
    }
  }

  /// Parse Amadeus flight offer to FlightInfo
  FlightInfo _parseAmadeusOffer(Map<String, dynamic> offer) {
    final itinerary = offer['itineraries'][0];
    final segment = itinerary['segments'][0];
    final price = offer['price'];

    final airline = segment['carrierCode'] as String;
    final flightNumber = segment['number'] as String;
    final departure = segment['departure'];
    final arrival = segment['arrival'];

    // Calculate duration
    final duration = itinerary['duration'] as String; // Format: PT2H30M
    final durationFormatted = _formatDuration(duration);

    // Count stops
    final segments = itinerary['segments'] as List;
    final stops = segments.length - 1;

    // Generate booking URL (Skyscanner deep link)
    final bookingUrl =
        'https://www.skyscanner.com/transport/flights/${segment['departure']['iataCode'].toString().toLowerCase()}/${segment['arrival']['iataCode'].toString().toLowerCase()}';

    return FlightInfo(
      airline: _getAirlineName(airline),
      airlineCode: airline,
      flightNumber: '$airline$flightNumber',
      price: double.parse(price['total'].toString()),
      duration: durationFormatted,
      departureTime: departure['at'] as String,
      arrivalTime: arrival['at'] as String,
      departureAirport: departure['iataCode'] as String,
      arrivalAirport: arrival['iataCode'] as String,
      stops: stops,
      cabinClass: segment['cabin'] as String? ?? 'ECONOMY',
      bookingUrl: bookingUrl,
    );
  }

  /// Format ISO 8601 duration to readable format
  String _formatDuration(String isoDuration) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?');
    final match = regex.firstMatch(isoDuration);

    if (match == null) return isoDuration;

    final hours = match.group(1) ?? '0';
    final minutes = match.group(2) ?? '0';

    return '${hours}h ${minutes}m';
  }

  /// Get airline name from code
  String _getAirlineName(String code) {
    const airlines = {
      'AA': 'American Airlines',
      'DL': 'Delta',
      'UA': 'United',
      'BA': 'British Airways',
      'LH': 'Lufthansa',
      'AF': 'Air France',
      'EK': 'Emirates',
      'QR': 'Qatar Airways',
      'SQ': 'Singapore Airlines',
      '6E': 'IndiGo',
      'AI': 'Air India',
      'UK': 'Vistara',
    };
    return airlines[code] ?? code;
  }

  /// Apply filters to flight results
  List<FlightInfo> _applyFilters(
      List<FlightInfo> flights, FlightSearchParams params) {
    var filtered = flights;

    // Price filter
    if (params.minPrice != null) {
      filtered = filtered.where((f) => f.price >= params.minPrice!).toList();
    }
    if (params.maxPrice != null) {
      filtered = filtered.where((f) => f.price <= params.maxPrice!).toList();
    }

    // Stops filter
    if (params.maxStops != null) {
      filtered = filtered.where((f) => f.stops <= params.maxStops!).toList();
    }

    // Airline filter
    if (params.preferredAirlines != null &&
        params.preferredAirlines!.isNotEmpty) {
      filtered = filtered
          .where((f) => params.preferredAirlines!.contains(f.airlineCode))
          .toList();
    }

    // Time of day filter
    if (params.departureTimeOfDay != null) {
      filtered = filtered
          .where((f) => f.departureTimeOfDay == params.departureTimeOfDay)
          .toList();
    }

    // Sort by price
    filtered.sort((a, b) => a.price.compareTo(b.price));

    return filtered;
  }

  /// Generate mock flights for testing/fallback
  List<FlightInfo> _generateMockFlights(FlightSearchParams params) {
    final airlines = [
      'Emirates',
      'Qatar Airways',
      'Singapore Airlines',
      'Lufthansa',
      'British Airways'
    ];
    final flights = <FlightInfo>[];

    for (int i = 0; i < 10; i++) {
      final airline = airlines[i % airlines.length];
      final airlineCode = airline.substring(0, 2).toUpperCase();
      final basePrice = 300 + (i * 50);
      final stops = i % 3;

      flights.add(FlightInfo(
        airline: airline,
        airlineCode: airlineCode,
        flightNumber: '$airlineCode${100 + i}',
        price: basePrice.toDouble(),
        duration: '${2 + i}h ${30 + (i * 5)}m',
        departureTime:
            params.departureDate.add(Duration(hours: 6 + i)).toIso8601String(),
        arrivalTime: params.departureDate
            .add(Duration(hours: 8 + i * 2))
            .toIso8601String(),
        departureAirport: params.origin,
        arrivalAirport: params.destination,
        stops: stops,
        cabinClass: params.cabinClass,
        bookingUrl:
            'https://www.skyscanner.com/transport/flights/${params.origin.toLowerCase()}/${params.destination.toLowerCase()}',
      ));
    }

    return _applyFilters(flights, params);
  }

  /// Cache flights
  Future<void> _cacheFlights(
      FlightSearchParams params, List<FlightInfo> flights) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(params);
      final cacheData = {
        'timestamp': DateTime.now().toIso8601String(),
        'flights': flights.map((f) => f.toJson()).toList(),
      };
      await prefs.setString(cacheKey, json.encode(cacheData));
    } catch (e) {
      debugPrint('⚠️ Failed to cache flights: $e');
    }
  }

  /// Get cached flights
  Future<List<FlightInfo>?> _getCachedFlights(FlightSearchParams params) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(params);
      final cacheString = prefs.getString(cacheKey);

      if (cacheString == null) return null;

      final cacheData = json.decode(cacheString);
      final timestamp = DateTime.parse(cacheData['timestamp']);

      // Check if cache is still valid
      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        return null;
      }

      final flightsList = cacheData['flights'] as List<dynamic>;
      return flightsList.map((f) => FlightInfo.fromJson(f)).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to read cached flights: $e');
      return null;
    }
  }

  /// Generate cache key from search params
  String _getCacheKey(FlightSearchParams params) {
    return '$_cachePrefix${params.origin}_${params.destination}_${params.departureDate.toIso8601String().split('T')[0]}';
  }
}
