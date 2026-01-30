import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/flight_info.dart';
import '../models/hotel_info.dart';
import '../models/currency.dart';
import 'flight_card.dart';
import 'hotel_card.dart';

/// Bottom sheet with tabs for flights and hotels
class TravelDataBottomSheet extends StatefulWidget {
  final List<FlightInfo> flights;
  final List<HotelInfo> hotels;
  final Currency currency;
  final bool isLoading;

  const TravelDataBottomSheet({
    super.key,
    required this.flights,
    required this.hotels,
    required this.currency,
    this.isLoading = false,
  });

  @override
  State<TravelDataBottomSheet> createState() => _TravelDataBottomSheetState();
}

class _TravelDataBottomSheetState extends State<TravelDataBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Flights & Stays',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(text: 'Flights'),
                Tab(text: 'Stays'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFlightsList(),
                _buildHotelsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightsList() {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.flights.isEmpty) {
      return _buildEmptyState('No flights available', Icons.flight_takeoff);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: widget.flights.length,
      itemBuilder: (context, index) {
        return FlightCard(
          flight: widget.flights[index],
          currency: widget.currency,
        );
      },
    );
  }

  Widget _buildHotelsList() {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.hotels.isEmpty) {
      return _buildEmptyState('No hotels available', Icons.hotel);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: widget.hotels.length,
      itemBuilder: (context, index) {
        return HotelCard(
          hotel: widget.hotels[index],
          currency: widget.currency,
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
