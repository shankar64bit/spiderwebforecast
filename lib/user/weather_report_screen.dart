import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';
import '../models/userpreferences.dart';
import '../utils/constant.dart';
import 'setting.dart';

class WeatherReportScreen extends StatefulWidget {
  final List<Map<String, dynamic>> weatherReports;

  WeatherReportScreen({required this.weatherReports});

  @override
  _WeatherReportScreenState createState() => _WeatherReportScreenState();
}

class _WeatherReportScreenState extends State<WeatherReportScreen> {
  String temperatureUnit = 'Celsius';
  int updateFrequency = 60; // default to 60 minutes
  Position? currentLocation;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _detectLocation();
  }

  Future<void> _loadUserPreferences() async {
    String unit = await UserPreferences.getTemperatureUnit();
    int frequency = await UserPreferences.getUpdateFrequency();

    setState(() {
      temperatureUnit = unit;
      updateFrequency = frequency;
    });
  }

  Future<void> _detectLocation() async {
    LocationService locationService = LocationService();
    try {
      Position position = await locationService.getCurrentLocation();
      setState(() {
        currentLocation = position;
      });
      // Fetch weather data based on location here
    } catch (e) {
      print(e);
    }
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
    if (result != null) {
      setState(() {
        temperatureUnit = result['unit'];
        updateFrequency = result['frequency'];
      });
      // Optionally, you can re-fetch weather data based on new preferences
    }
  }

  double _convertTemperature(double tempInCelsius) {
    if (temperatureUnit == 'Celsius') {
      return tempInCelsius;
    } else {
      return tempInCelsius * 9 / 5 + 32;
    }
  }

  String _getWeatherIcon(String weatherCondition) {
    switch (weatherCondition) {
      case 'Clear':
        return 'sunny.png';
      case 'Rain':
        return 'rainy.png';
      case 'Snow':
      case 'Clouds':
        return 'cloudy.png';
      case 'Wind':
        return 'windy.png';
      default:
        return 'default.png';
    }
  }

  Widget _weatherIcon(String weatherCondition) {
    String imagePath = 'assets/images/${_getWeatherIcon(weatherCondition)}';
    print('Attempting to load image from: $imagePath'); // Debugging line
    return Positioned(
      top: 8.0,
      right: 8.0,
      child: Image.asset(
        imagePath,
        width: 80.0,
        height: 80.0,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return Icon(Icons.error, size: 80.0, color: Colors.red);
        },
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.weatherReports.length,
      itemBuilder: (context, index) {
        var report = widget.weatherReports[index];
        var mainWeather = report['weather'][0];
        var main = report['main'];
        var wind = report['wind'];
        var weatherCondition = mainWeather['main'];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['name'],
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 16.0),
                      _weatherReportItem(
                        FontAwesomeIcons.temperatureHigh,
                        'Temperature: ${_convertTemperature(main['temp'])} ${_getUnit()}',
                      ),
                      _weatherReportItem(
                        FontAwesomeIcons.thermometerHalf,
                        'Feels Like: ${_convertTemperature(main['feels_like'])} ${_getUnit()}',
                      ),
                      _weatherReportItem(
                        FontAwesomeIcons.cloud,
                        'Condition: ${mainWeather['description']}',
                      ),
                      _weatherReportItem(
                        FontAwesomeIcons.tint,
                        'Humidity: ${main['humidity']}%',
                      ),
                      _weatherReportItem(
                        FontAwesomeIcons.wind,
                        'Wind Speed: ${wind['speed']} m/s',
                      ),
                      _weatherReportItem(
                        FontAwesomeIcons.compressArrowsAlt,
                        'Pressure: ${main['pressure']} hPa',
                      ),
                      _weatherReportItem(
                        FontAwesomeIcons.eye,
                        'Visibility: ${report['visibility']} meters',
                      ),
                      _weatherReportItem(
                        FontAwesomeIcons.mapMarkerAlt,
                        'Coordinates: ${report['coord']['lat']}, ${report['coord']['lon']}',
                      ),
                    ],
                  ),
                ),
              ),
              _weatherIcon(weatherCondition),
            ],
          ),
        );
      },
    );
  }

  String _getUnit() {
    return temperatureUnit == 'Celsius' ? '°C' : '°F';
  }

  Widget _weatherReportItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          FaIcon(icon, color: Colors.white, size: 20.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: AppbarDesignBackgraound(),
        title: const Text('Weather Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: _buildWeatherDetails(),
    );
  }
}
