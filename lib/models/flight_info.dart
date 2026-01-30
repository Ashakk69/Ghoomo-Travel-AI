/// Flight information model
class FlightInfo {
  final String airline;
  final String flightNumber;
  final double price; // in USD
  final String duration; // e.g., "2h 30m"
  final String departureTime;
  final String arrivalTime;
  final String departureAirport;
  final String arrivalAirport;

  const FlightInfo({
    required this.airline,
    required this.flightNumber,
    required this.price,
    required this.duration,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureAirport,
    required this.arrivalAirport,
  });

  /// Get airline icon/emoji
  String get airlineIcon {
    // Simple emoji representation
    return '✈️';
  }

  /// Format price display
  String formatPrice(String currencySymbol) {
    return '$currencySymbol${price.toStringAsFixed(0)}';
  }
}
