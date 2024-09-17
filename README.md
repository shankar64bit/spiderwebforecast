# Weather App

## Overview

This application allows users to track weather data for multiple locations. Users can upload weather data via an Excel file, view weather reports, and manage their locations. The application integrates with Firebase for user authentication and data storage and uses external weather APIs to fetch weather information.

## Features

- Upload Excel files containing location names to fetch weather data.
- View detailed weather reports for added locations.
- Search and manage location entries.
- Real-time updates with Firebase Cloud Firestore.

## Getting Started

### Prerequisites

- Flutter SDK (>= 2.0.0)
- Dart SDK
- Firebase project (with Authentication and Firestore enabled)
- API Key for weather service (e.g., OpenWeatherMap)

### Setup

1. **Clone the repository**

   bash
   git clone https://github.com/your-repo/weather-app.git
   cd weather-app

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

### Codebase

- **`lib/main.dart`**: Entry point of the application.
- **`lib/screens/user_dashboard_screen.dart`**: Screen for managing user locations and uploading Excel files.
- **`lib/screens/temporary_data_screen.dart`**: Screen for displaying weather data from Excel uploads.
- **`lib/screens/weather_report_screen.dart`**: Screen for displaying weather reports for individual locations.
- **`lib/services/excel_service.dart`**: Service for parsing Excel files.
- **`lib/services/weather_services.dart`**: Service for fetching weather data.
- **`lib/utils/constant.dart`**: Contains constants used across the application.
- **`lib/utils/ui_helpers.dart`**: Contains utility functions for UI design.
- **`lib/screens/login_screen.dart`**: Screen for user login.

### Configuration Files

- **`pubspec.yaml`**: Manages project dependencies.
- **`android/app/build.gradle`**: Android-specific build configuration.
- **`ios/Runner/Info.plist`**: iOS-specific configuration.

### Contribution

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

### Contact

For any questions or issues, please contact [shankar2space@gmail.com].
