class ItineraryItem {
  final String title;
  final String time;
  final String type; // e.g., 'Activity', 'Food', 'Relax'
  final double cost; // Cost in USD
  final bool aiGenerated;
  final double personaMatch; // 0.0 to 1.0 score
  final String? placeUrl; // Google Maps URL
  final String? address; // Location address
  final String? description; // Activity description

  const ItineraryItem(
    this.title,
    this.time,
    this.type, {
    this.cost = 0.0,
    this.aiGenerated = false,
    this.personaMatch = 0.0,
    this.placeUrl,
    this.address,
    this.description,
  });
}

class DayPlan {
  final int dayNumber;
  final List<ItineraryItem> items;

  const DayPlan(this.dayNumber, this.items);

  // Calculate total cost for the day
  double get totalCost {
    return items.fold(0.0, (sum, item) => sum + item.cost);
  }
}

class Itinerary {
  // Calculate total cost for entire itinerary
  static double calculateTotalCost(List<DayPlan> days) {
    return days.fold(0.0, (sum, day) => sum + day.totalCost);
  }

  static List<DayPlan> get mockDays => [
        const DayPlan(1, [
          ItineraryItem('Arrival & Check-in', '10:00 AM', 'Travel'),
          ItineraryItem('Local Street Food Tour', '01:00 PM', 'Food'),
          ItineraryItem('Sunset Viewpoint', '06:00 PM', 'Activity'),
        ]),
        const DayPlan(2, [
          ItineraryItem('Morning Temple Visit', '08:00 AM', 'Culture'),
          ItineraryItem('Traditional Lunch', '12:30 PM', 'Food'),
          ItineraryItem('Forest Hike', '03:00 PM', 'Nature'),
        ]),
        const DayPlan(3, [
          ItineraryItem('Art Museum', '10:00 AM', 'Culture'),
          ItineraryItem('Cafe Hopping', '02:00 PM', 'Relax'),
          ItineraryItem('Night Market', '07:00 PM', 'Nightlife'),
        ]),
      ];
}
