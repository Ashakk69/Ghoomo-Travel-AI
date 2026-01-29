import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/saved_trip.dart';
import '../models/user_persona.dart';
import '../services/trip_storage_service.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TripStorageService _storageService = TripStorageService();
  List<SavedTrip> _trips = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    final trips = await _storageService.getAllTrips();
    final stats = await _storageService.getStatistics();
    setState(() {
      _trips = trips;
      _stats = stats;
      _isLoading = false;
    });
  }

  Future<void> _deleteTrip(String tripId) async {
    await _storageService.deleteTrip(tripId);
    _loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Trips',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trips.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildStatsCard(),
                    Expanded(child: _buildTripsList()),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flight_takeoff, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            'No saved trips yet',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start planning your next adventure!',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.3),
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Trips', _stats['totalTrips']?.toString() ?? '0'),
          _buildStatItem(
              'Countries', _stats['uniqueCountries']?.toString() ?? '0'),
          _buildStatItem('Days', _stats['totalDays']?.toString() ?? '0'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildTripsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _trips.length,
      itemBuilder: (context, index) {
        final trip = _trips[index];
        return Dismissible(
          key: Key(trip.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _deleteTrip(trip.id),
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: _buildTripCard(trip),
        );
      },
    );
  }

  Widget _buildTripCard(SavedTrip trip) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            trip.destination.imageAsset,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          trip.destination.name,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${trip.days} days • ${trip.currency.format(trip.budget)}',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dateFormat.format(trip.createdAt),
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: trip.interests.take(3).map((interest) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    interest,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        trailing: Icon(
          trip.persona.icon,
          color: trip.persona.color,
        ),
      ),
    );
  }
}
