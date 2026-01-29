import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/destination.dart';
import '../models/itinerary.dart';
import '../models/currency.dart';
import '../models/saved_trip.dart';
import '../models/user_persona.dart';
import '../services/trip_storage_service.dart';
import '../widgets/cost_display.dart';
import 'dashboard_screen.dart';

class ItineraryScreen extends StatefulWidget {
  final Destination destination;
  final List<DayPlan> itinerary;
  final Currency currency;
  final double budget;
  final int days;
  final Set<String> interests;
  final UserPersona persona;

  const ItineraryScreen({
    super.key,
    required this.destination,
    required this.itinerary,
    required this.currency,
    required this.budget,
    required this.days,
    required this.interests,
    required this.persona,
  });

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final TripStorageService _storageService = TripStorageService();
  bool _isSaving = false;

  Future<void> _saveTrip() async {
    setState(() => _isSaving = true);

    // Create new SavedTrip
    final trip = SavedTrip(
      id: const Uuid().v4(),
      destination: widget.destination,
      persona: widget.persona,
      currency: widget.currency,
      budget: widget.budget,
      days: widget.days,
      interests: widget.interests,
      createdAt: DateTime.now(),
      // In a real app we'd serialize the itinerary too,
      // but for now we're just saving the metadata
      itinerary: null,
    );

    await _storageService.saveTrip(trip);

    if (mounted) {
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Trip saved to Dashboard!',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'VIEW',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Itinerary',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.itinerary.length,
        itemBuilder: (context, index) {
          final day = widget.itinerary[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: const Color(0xFF1E1E1E),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: index == 0,
                title: Text(
                  'Day ${day.dayNumber}',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                children: day.items.map((item) {
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.time,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: item.cost > 0
                        ? Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: CostDisplay(
                              costInUSD: item.cost,
                              displayCurrency: widget.currency,
                              showConversion: false,
                              fontSize: 13,
                            ),
                          )
                        : null,
                    trailing: _getIconForType(item.type),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveTrip,
        backgroundColor: Theme.of(context).primaryColor,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.bookmark, color: Colors.white),
        label: Text(
          _isSaving ? 'Saving...' : 'Save Trip',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _getIconForType(String type) {
    IconData icon;
    Color color;
    switch (type) {
      case 'Food':
        icon = Icons.restaurant;
        color = Colors.orange;
        break;
      case 'Nature':
        icon = Icons.landscape;
        color = Colors.green;
        break;
      case 'Nightlife':
        icon = Icons.local_bar;
        color = Colors.purple;
        break;
      case 'Culture':
        icon = Icons.museum;
        color = Colors.blue;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }
    return Icon(icon, color: color.withValues(alpha: 0.8), size: 20);
  }
}
