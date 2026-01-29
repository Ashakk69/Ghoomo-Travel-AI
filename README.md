# Travel Planner App

A premium, AI-powered travel planner built with Flutter.

## Prerequisites

Before you can run this app, you must have the **Flutter SDK** installed.

### 1. Install Flutter
1.  Download the SDK from [flutter.dev/docs/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows).
2.  Extract the zip file to a location like `C:\src\flutter`.
3.  **Add to Path**:
    *   Search for "Environment Variables" in Windows.
    *   Edit "Path" in your User variables.
    *   Add the full path to `flutter\bin` (e.g., `C:\src\flutter\bin`).
4.  Restart your terminal.

## How to Run

1.  Open a terminal in this directory:
    ```powershell
    cd C:\Users\yours\.gemini\antigravity\scratch\travel_planner
    ```

2.  Get dependencies:
    ```powershell
    flutter pub get
    ```

3.  Generate platform files (Android/iOS/Windows):
    ```powershell
    flutter create .
    ```

4.  Run the app:
    ```powershell
    flutter run
    ```

## Features
*   **Swipeable Home**: Parallax destination cards.
*   **Planning UI**: Interactive budget and interest selectors.
*   **Trip Generation**: Simulated AI loading screen.
*   **Itinerary**: Detailed day-by-day plan.
