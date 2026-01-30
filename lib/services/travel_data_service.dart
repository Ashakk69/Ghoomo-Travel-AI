import 'dart:math';
import '../models/flight_info.dart';
import '../models/hotel_info.dart';

/// Mock service for flight and hotel data
/// Uses repository pattern for easy API swapping later
class TravelDataService {
  final Random _random = Random();

  /// Simulate network delay for realistic UX
  Future<void> _simulateDelay() async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
  }

  /// Get mock flight data for a destination
  Future<List<FlightInfo>> getFlights(String destination,
      {int count = 5}) async {
    await _simulateDelay();

    final airlines = [
      'Emirates',
      'Qatar Airways',
      'Singapore Airlines',
      'Lufthansa',
      'British Airways',
      'Air India',
      'IndiGo',
      'Vistara',
    ];

    final flights = <FlightInfo>[];

    for (int i = 0; i < count; i++) {
      final airline = airlines[_random.nextInt(airlines.length)];
      final basePrice = 300 + _random.nextInt(700);
      final hours = 2 + _random.nextInt(10);
      final minutes = _random.nextInt(60);

      final flightNumber =
          '${airline.substring(0, 2).toUpperCase()}${100 + _random.nextInt(900)}';
      final airportCode = _getAirportCode(destination);

      flights.add(FlightInfo(
        airline: airline,
        airlineCode: airline.substring(0, 2).toUpperCase(),
        flightNumber: flightNumber,
        price: basePrice.toDouble(),
        duration: '${hours}h ${minutes}m',
        departureTime: DateTime.now().add(Duration(days: i)).toIso8601String(),
        arrivalTime: DateTime.now()
            .add(Duration(days: i, hours: hours))
            .toIso8601String(),
        departureAirport: 'DEL',
        arrivalAirport: airportCode,
        stops: _random.nextInt(3),
        cabinClass: [
          'ECONOMY',
          'PREMIUM_ECONOMY',
          'BUSINESS'
        ][_random.nextInt(3)],
        bookingUrl:
            'https://www.skyscanner.com/transport/flights/del/$airportCode',
      ));
    }

    // Sort by price
    flights.sort((a, b) => a.price.compareTo(b.price));

    return flights;
  }

  /// Get mock hotel data for a destination
  Future<List<HotelInfo>> getHotels(String destination, {int count = 5}) async {
    await _simulateDelay();

    final hotelPrefixes = [
      'Grand',
      'Royal',
      'Imperial',
      'Luxury',
      'Premium',
      'Boutique',
      'Heritage',
      'Modern',
    ];

    final hotelSuffixes = [
      'Palace',
      'Resort',
      'Hotel',
      'Suites',
      'Inn',
      'Residency',
      'Plaza',
      'Tower',
    ];

    final amenitiesList = [
      ['Free WiFi', 'Pool', 'Spa', 'Gym'],
      ['Free Breakfast', 'Airport Shuttle', 'Restaurant'],
      ['Beach Access', 'Bar', 'Room Service'],
      ['City View', 'Concierge', 'Parking'],
      ['Pet Friendly', 'Business Center', 'Laundry'],
    ];

    final hotels = <HotelInfo>[];

    for (int i = 0; i < count; i++) {
      final prefix = hotelPrefixes[_random.nextInt(hotelPrefixes.length)];
      final suffix = hotelSuffixes[_random.nextInt(hotelSuffixes.length)];
      final basePrice = 50 + _random.nextInt(450);
      final rating = 3.0 + (_random.nextDouble() * 2.0);

      final hotelName = '$prefix $destination $suffix';

      hotels.add(HotelInfo(
        id: 'hotel_${i}_${destination.toLowerCase().replaceAll(' ', '_')}',
        name: hotelName,
        rating: double.parse(rating.toStringAsFixed(1)),
        pricePerNight: basePrice.toDouble(),
        location: '$destination City Center',
        amenities: amenitiesList[_random.nextInt(amenitiesList.length)],
        hotelType: basePrice > 300
            ? 'LUXURY'
            : basePrice > 150
                ? 'MID_RANGE'
                : 'BUDGET',
        distanceFromCenter: _random.nextDouble() * 5,
        bookingUrl:
            'https://www.booking.com/search.html?ss=${Uri.encodeComponent(destination)}',
      ));
    }

    // Sort by rating (highest first)
    hotels.sort((a, b) => b.rating.compareTo(a.rating));

    return hotels;
  }

  /// Get airport code for destination (simplified)
  String _getAirportCode(String destination) {
    final codes = {
      'Paris': 'CDG',
      'Tokyo': 'NRT',
      'New York': 'JFK',
      'London': 'LHR',
      'Dubai': 'DXB',
      'Singapore': 'SIN',
      'Bali': 'DPS',
      'Maldives': 'MLE',
      'Santorini': 'JTR',
      'Iceland': 'KEF',
    };

    return codes[destination] ?? destination.substring(0, 3).toUpperCase();
  }
}
