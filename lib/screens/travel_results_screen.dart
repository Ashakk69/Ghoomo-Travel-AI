import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/travel_preferences.dart';
import '../models/currency.dart';
import '../models/flight_info.dart';
import '../models/hotel_info.dart';
import '../models/flight_search_params.dart';
import '../models/hotel_search_params.dart';
import '../services/flight_service.dart';
import '../services/hotel_service.dart';
import '../widgets/flight_card.dart';
import '../widgets/hotel_card.dart';
import '../widgets/loading_widget.dart';

/// Unified results screen showing flights, hotels, and transportation
class TravelResultsScreen extends StatefulWidget {
  final TravelPreferences preferences;
  final Currency currency;

  const TravelResultsScreen({
    super.key,
    required this.preferences,
    required this.currency,
  });

  @override
  State<TravelResultsScreen> createState() => _TravelResultsScreenState();
}

class _TravelResultsScreenState extends State<TravelResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FlightService _flightService = FlightService();
  final HotelService _hotelService = HotelService();

  List<FlightInfo> _flights = [];
  List<HotelInfo> _hotels = [];

  bool _isLoadingFlights = false;
  bool _isLoadingHotels = false;

  String? _flightError;
  String? _hotelError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadResults();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    // Load flights if transport mode includes flights
    if (widget.preferences.transportMode == 'flight' ||
        widget.preferences.transportMode == 'all') {
      _loadFlights();
    }

    // Always load hotels
    _loadHotels();
  }

  Future<void> _loadFlights() async {
    setState(() {
      _isLoadingFlights = true;
      _flightError = null;
    });

    try {
      final flightParams = FlightSearchParams(
        origin: widget.preferences.origin,
        destination: widget.preferences.destination,
        departureDate: widget.preferences.departureDate,
        returnDate: widget.preferences.returnDate,
        passengers: widget.preferences.passengers,
        cabinClass: widget.preferences.cabinClass,
        minPrice: widget.preferences.minBudget,
        maxPrice: widget.preferences.maxBudget,
        maxStops: widget.preferences.maxStops,
        departureTimeOfDay: widget.preferences.departureTime,
        preferredAirlines: widget.preferences.preferredAirlines,
      );

      final flights = await _flightService.searchFlights(flightParams);
      setState(() {
        _flights = flights;
        _isLoadingFlights = false;
      });
    } catch (e) {
      setState(() {
        _flightError = 'Failed to load flights: $e';
        _isLoadingFlights = false;
      });
    }
  }

  Future<void> _loadHotels() async {
    setState(() {
      _isLoadingHotels = true;
      _hotelError = null;
    });

    try {
      final hotelParams = HotelSearchParams(
        destination: widget.preferences.destination,
        checkInDate:
            widget.preferences.checkInDate ?? widget.preferences.departureDate,
        checkOutDate: widget.preferences.checkOutDate ??
            (widget.preferences.returnDate ??
                widget.preferences.departureDate.add(const Duration(days: 3))),
        guests: widget.preferences.guests,
        rooms: widget.preferences.rooms,
        minPrice: widget.preferences.minBudget,
        maxPrice: widget.preferences.maxBudget,
        minRating: widget.preferences.minHotelRating,
        hotelType: widget.preferences.hotelType,
      );

      final hotels = await _hotelService.searchHotels(hotelParams);
      setState(() {
        _hotels = hotels;
        _isLoadingHotels = false;
      });
    } catch (e) {
      setState(() {
        _hotelError = 'Failed to load hotels: $e';
        _isLoadingHotels = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final showFlights = widget.preferences.transportMode == 'flight' ||
        widget.preferences.transportMode == 'all';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.preferences.origin} → ${widget.preferences.destination}',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _buildDateRangeText(),
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          tabs: [
            if (showFlights)
              Tab(
                icon: const Icon(Icons.flight),
                text: 'Flights (${_flights.length})',
              ),
            Tab(
              icon: const Icon(Icons.hotel),
              text: 'Hotels (${_hotels.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          if (showFlights) _buildFlightsTab(),
          _buildHotelsTab(),
        ],
      ),
    );
  }

  String _buildDateRangeText() {
    if (widget.preferences.returnDate != null) {
      return '${widget.preferences.tripDuration} days • ${widget.preferences.passengers} passenger${widget.preferences.passengers > 1 ? 's' : ''}';
    }
    return 'One-way • ${widget.preferences.passengers} passenger${widget.preferences.passengers > 1 ? 's' : ''}';
  }

  Widget _buildFlightsTab() {
    if (_isLoadingFlights) {
      return const Center(child: LoadingWidget());
    }

    if (_flightError != null) {
      return _buildErrorState(_flightError!, _loadFlights);
    }

    if (_flights.isEmpty) {
      return _buildEmptyState(
        icon: Icons.flight_takeoff,
        title: 'No flights found',
        subtitle: 'Try adjusting your search criteria',
      );
    }

    return Column(
      children: [
        // Summary Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.2),
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Found ${_flights.length} flight${_flights.length > 1 ? 's' : ''} matching your preferences',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Flights List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _flights.length,
            itemBuilder: (context, index) {
              return FlightCard(
                flight: _flights[index],
                currency: widget.currency,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHotelsTab() {
    if (_isLoadingHotels) {
      return const Center(child: LoadingWidget());
    }

    if (_hotelError != null) {
      return _buildErrorState(_hotelError!, _loadHotels);
    }

    if (_hotels.isEmpty) {
      return _buildEmptyState(
        icon: Icons.hotel,
        title: 'No hotels found',
        subtitle: 'Try adjusting your search criteria',
      );
    }

    return Column(
      children: [
        // Summary Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.2),
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Found ${_hotels.length} hotel${_hotels.length > 1 ? 's' : ''} for ${widget.preferences.numberOfNights} night${widget.preferences.numberOfNights > 1 ? 's' : ''}',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Hotels List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _hotels.length,
            itemBuilder: (context, index) {
              return HotelCard(
                hotel: _hotels[index],
                currency: widget.currency,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
