import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_data.dart';

/// Service for fetching weather data from OpenWeatherMap API
class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String? _apiKey = dotenv.env['WEATHER_API_KEY'];

  // Cache to minimize API calls
  final Map<String, WeatherData> _currentWeatherCache = {};
  final Map<String, List<WeatherForecast>> _forecastCache = {};
  static const Duration _cacheDuration = Duration(minutes: 30);

  /// Fetch current weather for a city
  Future<WeatherData?> getCurrentWeather(String cityName) async {
    // Check cache first
    final cached = _currentWeatherCache[cityName];
    if (cached != null &&
        DateTime.now().difference(cached.timestamp) < _cacheDuration) {
      debugPrint('Weather: Using cached data for $cityName');
      return cached;
    }

    if (_apiKey == null ||
        _apiKey!.isEmpty ||
        _apiKey == 'your_openweathermap_api_key_here') {
      debugPrint('Weather API key not configured');
      return null;
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric',
      );

      debugPrint('Fetching weather for: $cityName');
      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weather = WeatherData.fromJson(data);

        // Cache the result
        _currentWeatherCache[cityName] = weather;

        debugPrint(
            'Weather fetched: ${weather.temperatureDisplay} ${weather.emoji}');
        return weather;
      } else {
        debugPrint('Weather API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      return null;
    }
  }

  /// Fetch 7-day weather forecast for a city
  Future<List<WeatherForecast>?> getForecast(String cityName,
      {int days = 7}) async {
    // Check cache first
    final cached = _forecastCache[cityName];
    if (cached != null && cached.isNotEmpty) {
      final cacheAge = DateTime.now().difference(cached.first.date);
      if (cacheAge < _cacheDuration) {
        debugPrint('Weather: Using cached forecast for $cityName');
        return cached.take(days).toList();
      }
    }

    if (_apiKey == null ||
        _apiKey!.isEmpty ||
        _apiKey == 'your_openweathermap_api_key_here') {
      debugPrint('Weather API key not configured');
      return null;
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/forecast/daily?q=$cityName&appid=$_apiKey&units=metric&cnt=$days',
      );

      debugPrint('Fetching forecast for: $cityName');
      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];

        final forecasts =
            forecastList.map((item) => WeatherForecast.fromJson(item)).toList();

        // Cache the result
        _forecastCache[cityName] = forecasts;

        debugPrint('Forecast fetched: ${forecasts.length} days');
        return forecasts;
      } else {
        debugPrint('Weather API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching forecast: $e');
      return null;
    }
  }

  /// Clear all cached weather data
  void clearCache() {
    _currentWeatherCache.clear();
    _forecastCache.clear();
    debugPrint('Weather cache cleared');
  }

  /// Get weather for a specific date from forecast
  WeatherForecast? getWeatherForDate(
    List<WeatherForecast> forecasts,
    DateTime targetDate,
  ) {
    for (final forecast in forecasts) {
      if (forecast.date.year == targetDate.year &&
          forecast.date.month == targetDate.month &&
          forecast.date.day == targetDate.day) {
        return forecast;
      }
    }
    return null;
  }
}
