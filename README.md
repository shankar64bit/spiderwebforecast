# Spiderweb Forecast: A Comprehensive Weather Application

## Overview

Spiderweb Forecast is a Flutter-based mobile application that allows users to track weather data for multiple locations. Users can manually add locations, upload weather data via an Excel file, view detailed weather reports, and manage their saved locations. The application integrates with Firebase for user authentication and data storage and uses external weather APIs to fetch real-time weather information.

## Features

- User authentication (login and registration)
- Manual addition of locations by city name or zip code
- Upload Excel files containing location names to fetch weather data
- View detailed weather reports for added locations
- Search and manage location entries
- Real-time updates with Firebase Cloud Firestore
- Customizable user preferences (temperature unit, update frequency)
- Current location detection and weather display

## Getting Started

### Prerequisites

- Flutter SDK (>= 2.0.0)
- Dart SDK
- Firebase project (with Authentication and Firestore enabled)
- API Key for weather service (e.g., OpenWeatherMap)

### Setup

1. **Clone the repository**

   bash
   git clone https://github.com/shankar64bit/spiderwebforecast.git
   cd spiderwebforecast

2. **Install dependencies**

   Ensure you have Flutter installed, then run:

   bash
   flutter pub get

3. **Configure Firebase**

   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
   - Add Firebase to your Flutter project by following the instructions at [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup).
   - Download the `google-services.json` file for Android and place it in the `android/app/` directory.
   - Download the `GoogleService-Info.plist` file for iOS and place it in the `ios/Runner/` directory.
   - Update Firebase settings in your project as per the Firebase documentation.

4. **Configure Weather API**

   - Obtain an API key from your weather service provider (e.g., [OpenWeatherMap](https://openweathermap.org/)).
   - Add your API key to the `lib/services/weather_services.dart` file.

### Building and Running

1. **Run the app**

   To build and run the app on an emulator or physical device, use:

   bash
   flutter run

2. **Build for release**

   To build the app for release, use:

   bash
   flutter build apk # For Android
   flutter build ios # For iOS

### Testing

1. **Unit Tests**

   Add your unit tests in the `test/` directory. To run tests, use:

   bash
   flutter test

2. **Integration Tests**

   Add integration tests in the `integration_test/` directory. To run integration tests, use:

   bash
   flutter test integration_test

## Codebase Structure

- **`lib/main.dart`**: Entry point of the application.
- **`lib/routes.dart`**: App route definitions.
- **`lib/screens/`**: Contains all screen widgets.
  - `login_screen.dart`: User login screen.
  - `registration_screen.dart`: User registration screen.
  - `user_dashboard_screen.dart`: Main dashboard for managing locations.
  - `weather_report_screen.dart`: Detailed weather report display.
  - `temporary_screen.dart`: Displays weather data from Excel uploads.
  - `settingscreen.dart`: User preferences and settings.
- **`lib/services/`**: Contains service classes.
  - `auth_service.dart`: Handles user authentication.
  - `weather_services.dart`: Fetches weather data from API.
  - `excel_service.dart`: Parses Excel files.
  - `location_service.dart`: Manages user locations.
  - `cache_service.dart`: Handles local data caching.
- **`lib/models/`**: Data models.
  - `userpreferences.dart`: User preference model.
- **`lib/utils/`**: Utility functions and constants.
  - `constant.dart`: App-wide constants.
  - `ui_helpers.dart`: UI utility functions.
  - `validators.dart`: Form input validators.

## Configuration Files

- **`pubspec.yaml`**: Manages project dependencies.
- **`android/app/build.gradle`**: Android-specific build configuration.
- **`ios/Runner/Info.plist`**: iOS-specific configuration.
- **`firebase_options.dart`**: Firebase configuration options.

## Contribution

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## Contact

For any questions or issues, please contact [shankar2space@gmail.com].
