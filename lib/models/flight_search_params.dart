/// Flight search parameters model
class FlightSearchParams {
  final String origin; // IATA airport code
  final String destination; // IATA airport code
  final DateTime departureDate;
  final DateTime? returnDate; // null for one-way
  final int passengers;
  final String cabinClass; // "ECONOMY", "PREMIUM_ECONOMY", "BUSINESS", "FIRST"

  // Filter criteria
  final double? minPrice;
  final double? maxPrice;
  final List<String>? preferredAirlines;
  final int? maxStops; // null = any, 0 = direct only
  final String?
      departureTimeOfDay; // "morning", "afternoon", "evening", "night"

  const FlightSearchParams({
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    this.passengers = 1,
    this.cabinClass = 'ECONOMY',
    this.minPrice,
    this.maxPrice,
    this.preferredAirlines,
    this.maxStops,
    this.departureTimeOfDay,
  });

  /// Create a copy with updated fields
  FlightSearchParams copyWith({
    String? origin,
    String? destination,
    DateTime? departureDate,
    DateTime? returnDate,
    int? passengers,
    String? cabinClass,
    double? minPrice,
    double? maxPrice,
    List<String>? preferredAirlines,
    int? maxStops,
    String? departureTimeOfDay,
  }) {
    return FlightSearchParams(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      passengers: passengers ?? this.passengers,
      cabinClass: cabinClass ?? this.cabinClass,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      preferredAirlines: preferredAirlines ?? this.preferredAirlines,
      maxStops: maxStops ?? this.maxStops,
      departureTimeOfDay: departureTimeOfDay ?? this.departureTimeOfDay,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'origin': origin,
      'destination': destination,
      'departureDate': departureDate.toIso8601String(),
      if (returnDate != null) 'returnDate': returnDate!.toIso8601String(),
      'passengers': passengers,
      'cabinClass': cabinClass,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (preferredAirlines != null) 'preferredAirlines': preferredAirlines,
      if (maxStops != null) 'maxStops': maxStops,
      if (departureTimeOfDay != null) 'departureTimeOfDay': departureTimeOfDay,
    };
  }

  /// Is this a round trip?
  bool get isRoundTrip => returnDate != null;
}
