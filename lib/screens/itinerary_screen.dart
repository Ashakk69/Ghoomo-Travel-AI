import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/destination.dart';
import '../models/itinerary.dart';
import '../models/currency.dart';
import '../widgets/cost_display.dart';

class ItineraryScreen extends StatelessWidget {
  final Destination destination;
  final List<DayPlan> itinerary;
  final Currency currency;

  const ItineraryScreen({
    super.key,
    required this.destination,
    required this.itinerary,
    required this.currency,
  });

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
        itemCount: itinerary.length,
        itemBuilder: (context, index) {
          final day = itinerary[index];
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
                              displayCurrency: currency,
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
        onPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.check, color: Colors.white),
        label: Text('Finish',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: Colors.white)),
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
