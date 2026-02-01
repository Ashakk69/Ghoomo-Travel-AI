import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/hotel_info.dart';
import '../models/hotel_search_params.dart';

/// Service for fetching real-time hotel data
/// Uses Amadeus API with fallback to mock data
class HotelService {
  static const String _baseUrl = 'https://test.api.amadeus.com/v3';
  static const String _tokenUrl =
      'https://test.api.amadeus.com/v1/security/oauth2/token';
  static const String _cachePrefix = 'hotel_cache_';
  static const Duration _cacheDuration = Duration(hours: 2);

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
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));
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

  /// Search for hotels
  Future<List<HotelInfo>> searchHotels(HotelSearchParams params) async {
    // Try cache first
    final cachedHotels = await _getCachedHotels(params);
    if (cachedHotels != null) {
      debugPrint('✅ Returning cached hotel results');
      return cachedHotels;
    }

    // Try API
    final token = await _getAccessToken();
    if (token != null) {
      final apiHotels = await _searchHotelsFromAPI(params, token);
      if (apiHotels != null) {
        await _cacheHotels(params, apiHotels);
        return apiHotels;
      }
    }

    // Fallback to mock data
    debugPrint('⚠️ Using mock hotel data');
    return _generateMockHotels(params);
  }

  /// Search hotels from Amadeus API
  Future<List<HotelInfo>?> _searchHotelsFromAPI(
      HotelSearchParams params, String token) async {
    try {
      // First, get hotel IDs by city
      final cityCode = await _getCityCode(params.destination, token);
      if (cityCode == null) {
        debugPrint('⚠️ Could not find city code for ${params.destination}');
        return null;
      }

      final queryParams = {
        'cityCode': cityCode,
        'checkInDate': params.checkInDate.toIso8601String().split('T')[0],
        'checkOutDate': params.checkOutDate.toIso8601String().split('T')[0],
        'adults': params.guests.toString(),
        'roomQuantity': params.rooms.toString(),
        'radius': '20',
        'radiusUnit': 'KM',
        'ratings': '3,4,5',
      };

      final uri = Uri.parse('$_baseUrl/shopping/hotel-offers')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hotelData = data['data'] as List<dynamic>?;

        if (hotelData == null || hotelData.isEmpty) {
          return [];
        }

        final hotels = hotelData
            .map((hotel) => _parseAmadeusHotel(hotel, params.destination))
            .toList();
        return _applyFilters(hotels, params);
      } else {
        debugPrint(
            '❌ Amadeus API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching hotels from API: $e');
      return null;
    }
  }

  /// Get city code from destination name
  Future<String?> _getCityCode(String destination, String token) async {
    // Simple mapping for common cities
    const cityCodes = {
      'Paris': 'PAR',
      'London': 'LON',
      'New York': 'NYC',
      'Tokyo': 'TYO',
      'Dubai': 'DXB',
      'Singapore': 'SIN',
      'Bali': 'DPS',
      'Maldives': 'MLE',
      'Santorini': 'JTR',
      'Iceland': 'REK',
      'Barcelona': 'BCN',
      'Rome': 'ROM',
      'Sydney': 'SYD',
      'Bangkok': 'BKK',
      'Istanbul': 'IST',
    };

    return cityCodes[destination];
  }

  /// Parse Amadeus hotel offer to HotelInfo
  HotelInfo _parseAmadeusHotel(
      Map<String, dynamic> hotelData, String destination) {
    final hotel = hotelData['hotel'];
    final offers = hotelData['offers'] as List<dynamic>;
    final firstOffer = offers.isNotEmpty ? offers[0] : null;

    final hotelId = hotel['hotelId'] as String;
    final name = hotel['name'] as String? ?? 'Hotel in $destination';
    final rating = (hotel['rating'] as num?)?.toDouble() ?? 4.0;

    // Get price from first offer
    final price = firstOffer != null
        ? double.parse(firstOffer['price']['total'].toString())
        : 100.0;

    // Parse amenities
    final amenities = <String>[];
    final amenitiesList = hotel['amenities'] as List<dynamic>?;
    if (amenitiesList != null) {
      for (var amenity in amenitiesList.take(5)) {
        amenities.add(_formatAmenity(amenity.toString()));
      }
    }

    // Default amenities if none provided
    if (amenities.isEmpty) {
      amenities.addAll(['Free WiFi', 'Air Conditioning', 'Room Service']);
    }

    // Generate booking URL
    final bookingUrl =
        'https://www.booking.com/hotel/${hotelId.toLowerCase()}.html';

    return HotelInfo(
      id: hotelId,
      name: name,
      rating: rating,
      pricePerNight: price,
      location: hotel['address']?['cityName'] ?? destination,
      amenities: amenities,
      hotelType: _determineHotelType(price),
      distanceFromCenter:
          (hotel['distance']?['value'] as num?)?.toDouble() ?? 2.0,
      bookingUrl: bookingUrl,
      description: hotel['description']?['text'] as String?,
    );
  }

  /// Format amenity name
  String _formatAmenity(String amenity) {
    return amenity
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Determine hotel type based on price
  String _determineHotelType(double price) {
    if (price > 300) return 'LUXURY';
    if (price > 150) return 'MID_RANGE';
    if (price > 80) return 'BUDGET';
    return 'BUDGET';
  }

  /// Apply filters to hotel results
  List<HotelInfo> _applyFilters(
      List<HotelInfo> hotels, HotelSearchParams params) {
    var filtered = hotels;

    // Price filter
    if (params.minPrice != null) {
      filtered =
          filtered.where((h) => h.pricePerNight >= params.minPrice!).toList();
    }
    if (params.maxPrice != null) {
      filtered =
          filtered.where((h) => h.pricePerNight <= params.maxPrice!).toList();
    }

    // Rating filter
    if (params.minRating != null) {
      filtered = filtered.where((h) => h.rating >= params.minRating!).toList();
    }

    // Hotel type filter
    if (params.hotelType != null) {
      filtered =
          filtered.where((h) => h.hotelType == params.hotelType).toList();
    }

    // Distance filter
    if (params.maxDistanceFromCenter != null) {
      filtered = filtered
          .where((h) => h.distanceFromCenter <= params.maxDistanceFromCenter!)
          .toList();
    }

    // Amenities filter
    if (params.requiredAmenities != null &&
        params.requiredAmenities!.isNotEmpty) {
      filtered = filtered.where((h) {
        return params.requiredAmenities!.every((required) => h.amenities.any(
            (amenity) =>
                amenity.toLowerCase().contains(required.toLowerCase())));
      }).toList();
    }

    // Sort by rating (highest first)
    filtered.sort((a, b) => b.rating.compareTo(a.rating));

    return filtered;
  }

  /// Generate mock hotels for testing/fallback
  List<HotelInfo> _generateMockHotels(HotelSearchParams params) {
    final prefixes = [
      'Grand',
      'Royal',
      'Imperial',
      'Luxury',
      'Premium',
      'Boutique'
    ];
    final suffixes = ['Palace', 'Resort', 'Hotel', 'Suites', 'Inn'];
    final amenitiesList = [
      ['Free WiFi', 'Pool', 'Spa', 'Gym'],
      ['Free Breakfast', 'Airport Shuttle', 'Restaurant'],
      ['Beach Access', 'Bar', 'Room Service'],
      ['City View', 'Concierge', 'Parking'],
    ];

    final hotels = <HotelInfo>[];

    for (int i = 0; i < 12; i++) {
      final prefix = prefixes[i % prefixes.length];
      final suffix = suffixes[i % suffixes.length];
      final basePrice = 80 + (i * 40);
      final rating = 3.5 + (i * 0.15);

      hotels.add(HotelInfo(
        id: 'hotel_${i}_${params.destination.toLowerCase().replaceAll(' ', '_')}',
        name: '$prefix ${params.destination} $suffix',
        rating: double.parse(rating.clamp(3.0, 5.0).toStringAsFixed(1)),
        pricePerNight: basePrice.toDouble(),
        location: '${params.destination} City Center',
        amenities: amenitiesList[i % amenitiesList.length],
        hotelType: _determineHotelType(basePrice.toDouble()),
        distanceFromCenter: (i * 0.5) + 0.5,
        bookingUrl:
            'https://www.booking.com/search.html?ss=${Uri.encodeComponent(params.destination)}',
      ));
    }

    return _applyFilters(hotels, params);
  }

  /// Cache hotels
  Future<void> _cacheHotels(
      HotelSearchParams params, List<HotelInfo> hotels) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(params);
      final cacheData = {
        'timestamp': DateTime.now().toIso8601String(),
        'hotels': hotels.map((h) => h.toJson()).toList(),
      };
      await prefs.setString(cacheKey, json.encode(cacheData));
    } catch (e) {
      debugPrint('⚠️ Failed to cache hotels: $e');
    }
  }

  /// Get cached hotels
  Future<List<HotelInfo>?> _getCachedHotels(HotelSearchParams params) async {
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

      final hotelsList = cacheData['hotels'] as List<dynamic>;
      return hotelsList.map((h) => HotelInfo.fromJson(h)).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to read cached hotels: $e');
      return null;
    }
  }

  /// Generate cache key from search params
  String _getCacheKey(HotelSearchParams params) {
    return '$_cachePrefix${params.destination}_${params.checkInDate.toIso8601String().split('T')[0]}';
  }
}
