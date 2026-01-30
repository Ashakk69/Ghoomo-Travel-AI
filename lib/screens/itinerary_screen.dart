import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/destination.dart';
import '../models/itinerary.dart';
import '../models/currency.dart';
import '../models/saved_trip.dart';
import '../models/user_persona.dart';
import '../models/weather_data.dart';
import '../models/flight_info.dart';
import '../models/hotel_info.dart';
import '../services/trip_storage_service.dart';
import '../services/weather_service.dart';
import '../services/travel_data_service.dart';
import '../services/notification_service.dart';
import '../widgets/cost_display.dart';
import '../widgets/weather_day_widget.dart';
import '../widgets/travel_data_bottom_sheet.dart';
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
  final WeatherService _weatherService = WeatherService();
  final TravelDataService _travelDataService = TravelDataService();
  final NotificationService _notificationService = NotificationService();

  bool _isSaving = false;
  List<WeatherForecast>? _forecasts;
  bool _isLoadingWeather = false;
  List<FlightInfo> _flights = [];
  List<HotelInfo> _hotels = [];
  bool _isLoadingTravelData = false;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() => _isLoadingWeather = true);
    final forecasts = await _weatherService.getForecast(
      widget.destination.name,
      days: widget.days,
    );
    if (mounted) {
      setState(() {
        _forecasts = forecasts;
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _saveTrip() async {
    setState(() => _isSaving = true);

    // Create new SavedTrip with start date
    final trip = SavedTrip(
      id: const Uuid().v4(),
      destination: widget.destination,
      persona: widget.persona,
      currency: widget.currency,
      budget: widget.budget,
      days: widget.days,
      interests: widget.interests,
      createdAt: DateTime.now(),
      startDate:
          DateTime.now().add(const Duration(days: 1)), // Default to tomorrow
      itinerary: null,
    );

    await _storageService.saveTrip(trip);

    // Schedule notifications for itinerary
    await _notificationService.scheduleItineraryNotifications(
      trip,
      widget.itinerary,
    );

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
                title: Row(
                  children: [
                    Text(
                      'Day ${day.dayNumber}',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (_forecasts != null && index < _forecasts!.length)
                      WeatherDayWidget(
                        forecast: _forecasts![index],
                        isLoading: _isLoadingWeather,
                      ),
                  ],
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: _showTravelDataBottomSheet,
            backgroundColor: const Color(0xFF2A2A2A),
            icon: const Icon(Icons.flight, color: Colors.white),
            label: Text(
              'Flights & Hotels',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
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
        ],
      ),
    );
  }

  Future<void> _showTravelDataBottomSheet() async {
    setState(() => _isLoadingTravelData = true);

    // Load travel data
    final flights =
        await _travelDataService.getFlights(widget.destination.name);
    final hotels = await _travelDataService.getHotels(widget.destination.name);

    if (mounted) {
      setState(() {
        _flights = flights;
        _hotels = hotels;
        _isLoadingTravelData = false;
      });

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => TravelDataBottomSheet(
          flights: _flights,
          hotels: _hotels,
          currency: widget.currency,
          isLoading: _isLoadingTravelData,
        ),
      );
    }
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
