/// Weather data model for current conditions and forecasts
class WeatherData {
  final double temperature; // in Celsius
  final String condition; // e.g., "Clear", "Clouds", "Rain"
  final String iconCode; // OpenWeatherMap icon code
  final String cityName;
  final DateTime timestamp;

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.cityName,
    required this.timestamp,
  });

  /// Parse from OpenWeatherMap API response
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'] as String,
      iconCode: json['weather'][0]['icon'] as String,
      cityName: json['name'] as String,
      timestamp: DateTime.now(),
    );
  }

  /// Get weather icon emoji based on condition
  String get emoji {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
      case 'drizzle':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  /// Format temperature with degree symbol
  String get temperatureDisplay => '${temperature.round()}°C';
}

/// Daily weather forecast model
class WeatherForecast {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final String condition;
  final String iconCode;

  const WeatherForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
    required this.iconCode,
  });

  /// Parse from OpenWeatherMap forecast API response
  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      tempMax: (json['temp']['max'] as num).toDouble(),
      tempMin: (json['temp']['min'] as num).toDouble(),
      condition: json['weather'][0]['main'] as String,
      iconCode: json['weather'][0]['icon'] as String,
    );
  }

  /// Get weather icon emoji based on condition
  String get emoji {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
      case 'drizzle':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  /// Format temperature range
  String get temperatureRange => '${tempMax.round()}° / ${tempMin.round()}°';
}
