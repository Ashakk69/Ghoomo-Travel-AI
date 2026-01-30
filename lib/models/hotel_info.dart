/// Hotel information model
class HotelInfo {
  final String name;
  final double rating; // 0.0 to 5.0
  final double pricePerNight; // in USD
  final String location;
  final List<String> amenities;
  final String imageUrl; // Placeholder for now

  const HotelInfo({
    required this.name,
    required this.rating,
    required this.pricePerNight,
    required this.location,
    required this.amenities,
    this.imageUrl = '',
  });

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
}
