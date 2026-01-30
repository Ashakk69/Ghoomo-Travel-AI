import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/flight_info.dart';
import '../models/flight_search_params.dart';
import '../models/currency.dart';
import '../services/flight_service.dart';
import '../widgets/flight_card.dart';
import '../widgets/loading_widget.dart';

/// Screen for searching and displaying flights
class FlightsScreen extends StatefulWidget {
  final String? origin;
  final String? destination;
  final DateTime? departureDate;
  final Currency currency;

  const FlightsScreen({
    super.key,
    this.origin,
    this.destination,
    this.departureDate,
    required this.currency,
  });

  @override
  State<FlightsScreen> createState() => _FlightsScreenState();
}

class _FlightsScreenState extends State<FlightsScreen> {
  final FlightService _flightService = FlightService();
  List<FlightInfo> _flights = [];
  bool _isLoading = false;
  String? _error;

  // Search parameters
  late FlightSearchParams _searchParams;

  @override
  void initState() {
    super.initState();
    _searchParams = FlightSearchParams(
      origin: widget.origin ?? 'DEL',
      destination: widget.destination ?? 'JFK',
      departureDate:
          widget.departureDate ?? DateTime.now().add(const Duration(days: 7)),
      passengers: 1,
    );
    _searchFlights();
  }

  Future<void> _searchFlights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final flights = await _flightService.searchFlights(_searchParams);
      setState(() {
        _flights = flights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load flights: $e';
        _isLoading = false;
      });
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    double? minPrice = _searchParams.minPrice;
    double? maxPrice = _searchParams.maxPrice;
    int? maxStops = _searchParams.maxStops;
    String? timeOfDay = _searchParams.departureTimeOfDay;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Price Range
              Text(
                'Price Range',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Min Price',
                        labelStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setModalState(() {
                          minPrice = double.tryParse(value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Max Price',
                        labelStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setModalState(() {
                          maxPrice = double.tryParse(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stops
              Text(
                'Stops',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('Any', maxStops == null, () {
                    setModalState(() => maxStops = null);
                  }),
                  _buildFilterChip('Direct', maxStops == 0, () {
                    setModalState(() => maxStops = 0);
                  }),
                  _buildFilterChip('1 Stop', maxStops == 1, () {
                    setModalState(() => maxStops = 1);
                  }),
                  _buildFilterChip('2+ Stops', maxStops == 2, () {
                    setModalState(() => maxStops = 2);
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Time of Day
              Text(
                'Departure Time',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('Any', timeOfDay == null, () {
                    setModalState(() => timeOfDay = null);
                  }),
                  _buildFilterChip('Morning', timeOfDay == 'morning', () {
                    setModalState(() => timeOfDay = 'morning');
                  }),
                  _buildFilterChip('Afternoon', timeOfDay == 'afternoon', () {
                    setModalState(() => timeOfDay = 'afternoon');
                  }),
                  _buildFilterChip('Evening', timeOfDay == 'evening', () {
                    setModalState(() => timeOfDay = 'evening');
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchParams = _searchParams.copyWith(
                        minPrice: minPrice,
                        maxPrice: maxPrice,
                        maxStops: maxStops,
                        departureTimeOfDay: timeOfDay,
                      );
                    });
                    Navigator.pop(context);
                    _searchFlights();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white.withValues(alpha: 0.1),
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: GoogleFonts.outfit(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).primaryColor
            : Colors.white.withValues(alpha: 0.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          'Flights',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilters,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_searchParams.origin} → ${_searchParams.destination}',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_searchParams.passengers} passenger${_searchParams.passengers > 1 ? 's' : ''} • ${_searchParams.cabinClassDisplay}',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingWidget())
                : _error != null
                    ? _buildErrorState()
                    : _flights.isEmpty
                        ? _buildEmptyState()
                        : _buildFlightsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _flights.length,
      itemBuilder: (context, index) {
        return FlightCard(
          flight: _flights[index],
          currency: widget.currency,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No flights found',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
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
              _error ?? 'Unknown error',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _searchFlights,
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

extension on FlightSearchParams {
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
}
