# 🚀 Flight & Hotel Booking Setup Guide

## Quick Start

The flight and hotel booking features are **ready to use** with mock data. No API keys required for testing!

## API Setup (Optional - for Real Data)

### Step 1: Get Amadeus API Keys

1. Visit [Amadeus for Developers](https://developers.amadeus.com/register)
2. Create a free account
3. Create a new app in the dashboard
4. Copy your **API Key** and **API Secret**

**Free Tier:** 2,000 API calls/month (plenty for development)

### Step 2: Update .env File

Open `.env` and replace the placeholders:

```env
AMADEUS_API_KEY=your_actual_api_key_here
AMADEUS_API_SECRET=your_actual_api_secret_here
```

### Step 3: Restart the App

```bash
flutter run
```

That's it! The app will now fetch real-time flight and hotel data.

---

## Testing the Features

### Navigate to Flights

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => FlightsScreen(
      origin: 'DEL',
      destination: 'JFK',
      departureDate: DateTime.now().add(Duration(days: 7)),
      currency: currentCurrency,
    ),
  ),
);
```

### Navigate to Hotels

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => HotelsScreen(
      destination: 'Paris',
      checkInDate: DateTime.now().add(Duration(days: 7)),
      checkOutDate: DateTime.now().add(Duration(days: 10)),
      currency: currentCurrency,
    ),
  ),
);
```

---

## Features

✅ Real-time flight search with Amadeus API  
✅ Real-time hotel search with Amadeus API  
✅ Smart caching (1-2 hours) to reduce API calls  
✅ Automatic fallback to mock data  
✅ Comprehensive filtering (price, stops, time, rating, type)  
✅ External booking via Skyscanner & Booking.com  
✅ Premium UI with glassmorphism design  
✅ Loading, error, and empty states  
✅ Currency conversion support  

---

## Troubleshooting

### "No flights/hotels found"
- Check your internet connection
- Verify API keys are correct in `.env`
- Try adjusting filters
- The app will automatically use mock data if API fails

### "Could not open booking website"
- Ensure `url_launcher` package is installed
- Check device has a default browser
- Try on a different device/emulator

### API Errors
- Verify API keys are active in Amadeus dashboard
- Check you haven't exceeded free tier limits (2000 calls/month)
- The app gracefully falls back to mock data

---

## Mock Data vs Real Data

**Without API Keys:**
- Realistic mock flights and hotels
- Instant results (no network delay)
- Perfect for UI testing and development

**With API Keys:**
- Real-time pricing and availability
- Actual booking links
- Live data from airlines and hotels

---

## Next Steps

See [walkthrough.md](file:///C:/Users/yours/.gemini/antigravity/brain/fa8f4f44-5dea-42ca-bc2b-3b34dabf0fbe/walkthrough.md) for:
- Complete implementation details
- Integration examples
- Architecture diagrams
- Future enhancement ideas
