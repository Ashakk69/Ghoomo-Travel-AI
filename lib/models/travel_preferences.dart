/// Travel preferences model for comprehensive search
class TravelPreferences {
  final String origin;
  final String destination;
  final DateTime departureDate;
  final DateTime? returnDate;
  final String? departureTime; // "morning", "afternoon", "evening", "night"
  final String? returnTime;

  // Accommodation
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int guests;
  final int rooms;

  // Transportation
  final String transportMode; // "flight", "train", "bus", "car_rental", "all"
  final int passengers;
  final String cabinClass; // For flights

  // Budget
  final double? minBudget;
  final double? maxBudget;

  // Filters
  final int? maxStops;
  final double? minHotelRating;
  final String? hotelType;
  final List<String>? preferredAirlines;

  const TravelPreferences({
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    this.departureTime,
    this.returnTime,
    this.checkInDate,
    this.checkOutDate,
    this.guests = 2,
    this.rooms = 1,
    this.transportMode = 'all',
    this.passengers = 1,
    this.cabinClass = 'ECONOMY',
    this.minBudget,
    this.maxBudget,
    this.maxStops,
    this.minHotelRating,
    this.hotelType,
    this.preferredAirlines,
  });

  /// Create a copy with updated fields
  TravelPreferences copyWith({
    String? origin,
    String? destination,
    DateTime? departureDate,
    DateTime? returnDate,
    String? departureTime,
    String? returnTime,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guests,
    int? rooms,
    String? transportMode,
    int? passengers,
    String? cabinClass,
    double? minBudget,
    double? maxBudget,
    int? maxStops,
    double? minHotelRating,
    String? hotelType,
    List<String>? preferredAirlines,
  }) {
    return TravelPreferences(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      departureTime: departureTime ?? this.departureTime,
      returnTime: returnTime ?? this.returnTime,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guests: guests ?? this.guests,
      rooms: rooms ?? this.rooms,
      transportMode: transportMode ?? this.transportMode,
      passengers: passengers ?? this.passengers,
      cabinClass: cabinClass ?? this.cabinClass,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      maxStops: maxStops ?? this.maxStops,
      minHotelRating: minHotelRating ?? this.minHotelRating,
      hotelType: hotelType ?? this.hotelType,
      preferredAirlines: preferredAirlines ?? this.preferredAirlines,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'origin': origin,
      'destination': destination,
      'departureDate': departureDate.toIso8601String(),
      if (returnDate != null) 'returnDate': returnDate!.toIso8601String(),
      if (departureTime != null) 'departureTime': departureTime,
      if (returnTime != null) 'returnTime': returnTime,
      if (checkInDate != null) 'checkInDate': checkInDate!.toIso8601String(),
      if (checkOutDate != null) 'checkOutDate': checkOutDate!.toIso8601String(),
      'guests': guests,
      'rooms': rooms,
      'transportMode': transportMode,
      'passengers': passengers,
      'cabinClass': cabinClass,
      if (minBudget != null) 'minBudget': minBudget,
      if (maxBudget != null) 'maxBudget': maxBudget,
      if (maxStops != null) 'maxStops': maxStops,
      if (minHotelRating != null) 'minHotelRating': minHotelRating,
      if (hotelType != null) 'hotelType': hotelType,
      if (preferredAirlines != null) 'preferredAirlines': preferredAirlines,
    };
  }

  /// Create from JSON
  factory TravelPreferences.fromJson(Map<String, dynamic> json) {
    return TravelPreferences(
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      departureDate: DateTime.parse(json['departureDate'] as String),
      returnDate: json['returnDate'] != null
          ? DateTime.parse(json['returnDate'] as String)
          : null,
      departureTime: json['departureTime'] as String?,
      returnTime: json['returnTime'] as String?,
      checkInDate: json['checkInDate'] != null
          ? DateTime.parse(json['checkInDate'] as String)
          : null,
      checkOutDate: json['checkOutDate'] != null
          ? DateTime.parse(json['checkOutDate'] as String)
          : null,
      guests: json['guests'] as int? ?? 2,
      rooms: json['rooms'] as int? ?? 1,
      transportMode: json['transportMode'] as String? ?? 'all',
      passengers: json['passengers'] as int? ?? 1,
      cabinClass: json['cabinClass'] as String? ?? 'ECONOMY',
      minBudget: json['minBudget'] as double?,
      maxBudget: json['maxBudget'] as double?,
      maxStops: json['maxStops'] as int?,
      minHotelRating: json['minHotelRating'] as double?,
      hotelType: json['hotelType'] as String?,
      preferredAirlines: (json['preferredAirlines'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  /// Is this a round trip?
  bool get isRoundTrip => returnDate != null;

  /// Get number of nights for hotel
  int get numberOfNights {
    if (checkInDate == null || checkOutDate == null) return 0;
    return checkOutDate!.difference(checkInDate!).inDays;
  }

  /// Get trip duration in days
  int get tripDuration {
    if (returnDate == null) return 1;
    return returnDate!.difference(departureDate).inDays;
  }
}
