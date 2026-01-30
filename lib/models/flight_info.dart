/// Flight information model with booking support
class FlightInfo {
  final String airline;
  final String airlineCode; // e.g., "AA", "DL"
  final String flightNumber;
  final double price; // in USD
  final String duration; // e.g., "2h 30m"
  final String departureTime; // ISO 8601 format
  final String arrivalTime; // ISO 8601 format
  final String departureAirport; // IATA code
  final String arrivalAirport; // IATA code
  final int stops; // 0 for direct, 1+
  final String cabinClass; // "ECONOMY", "PREMIUM_ECONOMY", "BUSINESS", "FIRST"
  final String bookingUrl; // External booking link
  final String? airlineLogoUrl; // Optional airline logo

  const FlightInfo({
    required this.airline,
    required this.airlineCode,
    required this.flightNumber,
    required this.price,
    required this.duration,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureAirport,
    required this.arrivalAirport,
    this.stops = 0,
    this.cabinClass = 'ECONOMY',
    required this.bookingUrl,
    this.airlineLogoUrl,
  });

  /// Create from JSON (API response)
  factory FlightInfo.fromJson(Map<String, dynamic> json) {
    return FlightInfo(
      airline: json['airline'] as String,
      airlineCode: json['airlineCode'] as String,
      flightNumber: json['flightNumber'] as String,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] as String,
      departureTime: json['departureTime'] as String,
      arrivalTime: json['arrivalTime'] as String,
      departureAirport: json['departureAirport'] as String,
      arrivalAirport: json['arrivalAirport'] as String,
      stops: json['stops'] as int? ?? 0,
      cabinClass: json['cabinClass'] as String? ?? 'ECONOMY',
      bookingUrl: json['bookingUrl'] as String,
      airlineLogoUrl: json['airlineLogoUrl'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'airline': airline,
      'airlineCode': airlineCode,
      'flightNumber': flightNumber,
      'price': price,
      'duration': duration,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'stops': stops,
      'cabinClass': cabinClass,
      'bookingUrl': bookingUrl,
      'airlineLogoUrl': airlineLogoUrl,
    };
  }

  /// Get airline icon/emoji
  String get airlineIcon {
    return '✈️';
  }

  /// Format price display
  String formatPrice(String currencySymbol) {
    return '$currencySymbol${price.toStringAsFixed(0)}';
  }

  /// Get stops display text
  String get stopsDisplay {
    if (stops == 0) return 'Direct';
    if (stops == 1) return '1 Stop';
    return '$stops Stops';
  }

  /// Get cabin class display
  String get cabinClassDisplay {
    switch (cabinClass) {
      case 'ECONOMY':
        return 'Economy';
      case 'PREMIUM_ECONOMY':
        return 'Premium Economy';
      case 'BUSINESS':
        return 'Business';
      case 'FIRST':
        return 'First Class';
      default:
        return cabinClass;
    }
  }

  /// Parse departure time for filtering
  DateTime get departureDateTime {
    return DateTime.parse(departureTime);
  }

  /// Get time of day for filtering (morning, afternoon, evening, night)
  String get departureTimeOfDay {
    final hour = departureDateTime.hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }
}
