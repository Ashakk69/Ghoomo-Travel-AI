/// Hotel information model with booking support
class HotelInfo {
  final String id; // Unique hotel ID from API
  final String name;
  final double rating; // 0.0 to 5.0
  final double pricePerNight; // in USD
  final String location;
  final List<String> amenities;
  final List<String> imageUrls; // Multiple images
  final String hotelType; // "BUDGET", "MID_RANGE", "LUXURY", "BOUTIQUE"
  final double distanceFromCenter; // in km
  final String bookingUrl; // External booking link
  final String? description; // Optional hotel description
  final int? reviewCount; // Number of reviews

  const HotelInfo({
    required this.id,
    required this.name,
    required this.rating,
    required this.pricePerNight,
    required this.location,
    required this.amenities,
    this.imageUrls = const [],
    this.hotelType = 'MID_RANGE',
    this.distanceFromCenter = 0.0,
    required this.bookingUrl,
    this.description,
    this.reviewCount,
  });

  /// Create from JSON (API response)
  factory HotelInfo.fromJson(Map<String, dynamic> json) {
    return HotelInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      location: json['location'] as String,
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      hotelType: json['hotelType'] as String? ?? 'MID_RANGE',
      distanceFromCenter:
          (json['distanceFromCenter'] as num?)?.toDouble() ?? 0.0,
      bookingUrl: json['bookingUrl'] as String,
      description: json['description'] as String?,
      reviewCount: json['reviewCount'] as int?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'pricePerNight': pricePerNight,
      'location': location,
      'amenities': amenities,
      'imageUrls': imageUrls,
      'hotelType': hotelType,
      'distanceFromCenter': distanceFromCenter,
      'bookingUrl': bookingUrl,
      'description': description,
      'reviewCount': reviewCount,
    };
  }

  /// Format rating display
  String get ratingDisplay {
    return '⭐ ${rating.toStringAsFixed(1)}';
  }

  /// Format price display
  String formatPrice(String currencySymbol) {
    return '$currencySymbol${pricePerNight.toStringAsFixed(0)}/night';
  }

  /// Get star icons
  String get starIcons {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;

    String stars = '⭐' * fullStars;
    if (hasHalfStar && fullStars < 5) {
      stars += '⭐';
    }

    return stars;
  }

  /// Get hotel type display
  String get hotelTypeDisplay {
    switch (hotelType) {
      case 'BUDGET':
        return 'Budget';
      case 'MID_RANGE':
        return 'Mid-Range';
      case 'LUXURY':
        return 'Luxury';
      case 'BOUTIQUE':
        return 'Boutique';
      default:
        return hotelType;
    }
  }

  /// Format distance display
  String get distanceDisplay {
    if (distanceFromCenter < 1) {
      return '${(distanceFromCenter * 1000).toStringAsFixed(0)}m from center';
    }
    return '${distanceFromCenter.toStringAsFixed(1)}km from center';
  }

  /// Get primary image URL
  String get primaryImageUrl {
    return imageUrls.isNotEmpty ? imageUrls.first : '';
  }
}
