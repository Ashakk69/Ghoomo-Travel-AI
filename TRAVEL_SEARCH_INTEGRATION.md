# 🎯 Travel Search Integration Guide

## Quick Integration

Add the travel search feature to your app in 3 easy steps!

### Step 1: Add to Home Screen

In your `home_screen.dart` or `dashboard_screen.dart`, add a button to launch the travel search:

```dart
import 'package:travel_planner/screens/travel_search_screen.dart';
import 'package:travel_planner/services/currency_service.dart';

// In your build method or FAB:
FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TravelSearchScreen(
          currency: CurrencyService().currentCurrency,
        ),
      ),
    );
  },
  child: Icon(Icons.search),
  tooltip: 'Search Travel',
)
```

### Step 2: Add to Destination Card

When user selects a destination, pre-fill the search:

```dart
// In destination_card.dart or similar:
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TravelSearchScreen(
          initialDestination: destination.name,
          currency: currentCurrency,
        ),
      ),
    );
  },
  child: Text('Plan Trip'),
)
```

### Step 3: Test It!

Run your app and:
1. Click the search/plan button
2. Fill in travel details (dates, times, mode, etc.)
3. Click "Search Travel Options"
4. View filtered flights and hotels
5. Click "Book Now" to redirect to booking sites

---

## Features

✅ **Comprehensive Input Collection**
- Origin & destination
- Departure & return dates
- Preferred departure/return times
- Transportation mode (flight, train, bus, car, all)
- Number of passengers/guests
- Cabin class for flights
- Hotel preferences (type, rating)
- Budget range

✅ **Smart Results Display**
- Tabbed interface (Flights | Hotels)
- Filtered results based on ALL user preferences
- Real-time data from Amadeus API
- Fallback to mock data
- Direct booking links

✅ **Premium UX**
- Dark theme with glassmorphism
- Date pickers for easy selection
- Counter widgets for passengers/guests
- Filter chips for quick selection
- Loading, error, and empty states

---

## User Flow

```
Home/Dashboard
    ↓
[Search Travel Button]
    ↓
Travel Search Screen
    ↓ (User fills preferences)
[Search Travel Options]
    ↓
Travel Results Screen
    ├─ Flights Tab (if applicable)
    │   └─ [Book Now] → Skyscanner
    └─ Hotels Tab
        └─ [Book Now] → Booking.com
```

---

## Example: Full Integration in Dashboard

```dart
// In dashboard_screen.dart

import 'package:travel_planner/screens/travel_search_screen.dart';

// Add a prominent search card:
Widget _buildSearchCard() {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TravelSearchScreen(
            currency: widget.currency,
          ),
        ),
      );
    },
    child: Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 32, color: Colors.white),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Your Next Trip',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Search flights, hotels & more',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white),
        ],
      ),
    ),
  );
}
```

---

## Customization

### Change Default Values

Edit `travel_search_screen.dart`:

```dart
// Default passengers
int _passengers = 2; // Change from 1 to 2

// Default cabin class
String _cabinClass = 'BUSINESS'; // Change from ECONOMY

// Default transport mode
String _transportMode = 'flight'; // Change from 'all'
```

### Add More Transportation Modes

In `travel_preferences.dart`, add new modes:

```dart
// Add to transportMode options
'ferry', 'bike_rental', 'taxi'
```

Then update the UI in `travel_search_screen.dart`:

```dart
_buildModeChip('Ferry', 'ferry', Icons.directions_boat),
```

---

## Troubleshooting

### "No results found"
- Check API keys are configured in `.env`
- Verify internet connection
- Try different search criteria
- App will automatically use mock data as fallback

### Build errors
- Run `flutter pub get`
- Ensure all imports are correct
- Check that `intl` package is in `pubspec.yaml`

### Navigation issues
- Ensure `currency` is passed to the screen
- Check that `MaterialPageRoute` is used
- Verify context is valid

---

## Next Steps

1. **Add to Navigation Drawer** - Include in side menu
2. **Recent Searches** - Save and display recent searches
3. **Favorites** - Let users save preferred routes
4. **Price Alerts** - Notify when prices drop
5. **Multi-City** - Support complex itineraries

---

**Ready to use! 🚀**

Your users can now search for flights and hotels with comprehensive filtering and instant booking!
