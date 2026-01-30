import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hotel_info.dart';
import '../models/hotel_search_params.dart';
import '../models/currency.dart';
import '../services/hotel_service.dart';
import '../widgets/hotel_card.dart';
import '../widgets/loading_widget.dart';

/// Screen for searching and displaying hotels
class HotelsScreen extends StatefulWidget {
  final String? destination;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final Currency currency;

  const HotelsScreen({
    super.key,
    this.destination,
    this.checkInDate,
    this.checkOutDate,
    required this.currency,
  });

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  final HotelService _hotelService = HotelService();
  List<HotelInfo> _hotels = [];
  bool _isLoading = false;
  String? _error;

  // Search parameters
  late HotelSearchParams _searchParams;

  @override
  void initState() {
    super.initState();
    final checkIn =
        widget.checkInDate ?? DateTime.now().add(const Duration(days: 7));
    _searchParams = HotelSearchParams(
      destination: widget.destination ?? 'Paris',
      checkInDate: checkIn,
      checkOutDate: widget.checkOutDate ?? checkIn.add(const Duration(days: 3)),
      guests: 2,
      rooms: 1,
    );
    _searchHotels();
  }

  Future<void> _searchHotels() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hotels = await _hotelService.searchHotels(_searchParams);
      setState(() {
        _hotels = hotels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load hotels: $e';
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
    double? minRating = _searchParams.minRating;
    String? hotelType = _searchParams.hotelType;

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
                'Price Range (per night)',
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

              // Minimum Rating
              Text(
                'Minimum Rating',
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
                  _buildFilterChip('Any', minRating == null, () {
                    setModalState(() => minRating = null);
                  }),
                  _buildFilterChip('3+', minRating == 3.0, () {
                    setModalState(() => minRating = 3.0);
                  }),
                  _buildFilterChip('4+', minRating == 4.0, () {
                    setModalState(() => minRating = 4.0);
                  }),
                  _buildFilterChip('4.5+', minRating == 4.5, () {
                    setModalState(() => minRating = 4.5);
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Hotel Type
              Text(
                'Hotel Type',
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
                  _buildFilterChip('Any', hotelType == null, () {
                    setModalState(() => hotelType = null);
                  }),
                  _buildFilterChip('Budget', hotelType == 'BUDGET', () {
                    setModalState(() => hotelType = 'BUDGET');
                  }),
                  _buildFilterChip('Mid-Range', hotelType == 'MID_RANGE', () {
                    setModalState(() => hotelType = 'MID_RANGE');
                  }),
                  _buildFilterChip('Luxury', hotelType == 'LUXURY', () {
                    setModalState(() => hotelType = 'LUXURY');
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
                        minRating: minRating,
                        hotelType: hotelType,
                      );
                    });
                    Navigator.pop(context);
                    _searchHotels();
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
          'Hotels',
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
                        _searchParams.destination,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_searchParams.numberOfNights} night${_searchParams.numberOfNights > 1 ? 's' : ''} • ${_searchParams.guests} guest${_searchParams.guests > 1 ? 's' : ''}',
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
                    : _hotels.isEmpty
                        ? _buildEmptyState()
                        : _buildHotelsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _hotels.length,
      itemBuilder: (context, index) {
        return HotelCard(
          hotel: _hotels[index],
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
            Icons.hotel,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No hotels found',
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
            onPressed: _searchHotels,
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
