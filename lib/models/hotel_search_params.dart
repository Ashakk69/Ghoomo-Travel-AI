/// Hotel search parameters model
class HotelSearchParams {
  final String destination; // City name or coordinates
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final int rooms;

  // Filter criteria
  final double? minPrice;
  final double? maxPrice;
  final double? minRating; // 0.0 to 5.0
  final List<String>? requiredAmenities;
  final String? hotelType; // "BUDGET", "MID_RANGE", "LUXURY", "BOUTIQUE"
  final double? maxDistanceFromCenter; // in km

  const HotelSearchParams({
    required this.destination,
    required this.checkInDate,
    required this.checkOutDate,
    this.guests = 2,
    this.rooms = 1,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.requiredAmenities,
    this.hotelType,
    this.maxDistanceFromCenter,
  });

  /// Create a copy with updated fields
  HotelSearchParams copyWith({
    String? destination,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guests,
    int? rooms,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    List<String>? requiredAmenities,
    String? hotelType,
    double? maxDistanceFromCenter,
  }) {
    return HotelSearchParams(
      destination: destination ?? this.destination,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guests: guests ?? this.guests,
      rooms: rooms ?? this.rooms,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      requiredAmenities: requiredAmenities ?? this.requiredAmenities,
      hotelType: hotelType ?? this.hotelType,
      maxDistanceFromCenter:
          maxDistanceFromCenter ?? this.maxDistanceFromCenter,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'guests': guests,
      'rooms': rooms,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (minRating != null) 'minRating': minRating,
      if (requiredAmenities != null) 'requiredAmenities': requiredAmenities,
      if (hotelType != null) 'hotelType': hotelType,
      if (maxDistanceFromCenter != null)
        'maxDistanceFromCenter': maxDistanceFromCenter,
    };
  }

  /// Get number of nights
  int get numberOfNights => checkOutDate.difference(checkInDate).inDays;
}
