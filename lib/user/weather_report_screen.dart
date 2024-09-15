import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../admin/services/location_service.dart';
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

  Widget _buildWeatherDetails() {
    // Assume we now have daily or hourly forecast data in weatherReports
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.weatherReports.length,
      itemBuilder: (context, index) {
        var report = widget.weatherReports[index];
        var mainWeather = report['weather'][0];
        var main = report['main'];
        var wind = report['wind'];
        var sys = report['sys'];

        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report['name'],
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left),
                const SizedBox(height: 16.0),
                _weatherReportItem(FontAwesomeIcons.temperatureHigh,
                    'Temperature: ${main['temp']} ${_getUnit()}'),
                _weatherReportItem(FontAwesomeIcons.thermometerHalf,
                    'Feels Like: ${main['feels_like']} ${_getUnit()}'),
                _weatherReportItem(FontAwesomeIcons.cloud,
                    'Condition: ${mainWeather['description']}'),
                _weatherReportItem(
                    FontAwesomeIcons.tint, 'Humidity: ${main['humidity']}%'),
                _weatherReportItem(
                    FontAwesomeIcons.wind, 'Wind Speed: ${wind['speed']} m/s'),
                _weatherReportItem(FontAwesomeIcons.compressArrowsAlt,
                    'Pressure: ${main['pressure']} hPa'),
                _weatherReportItem(FontAwesomeIcons.eye,
                    'Visibility: ${report['visibility']} meters'),
                _weatherReportItem(FontAwesomeIcons.mapMarkerAlt,
                    'Coordinates: ${report['coord']['lat']}, ${report['coord']['lon']}'),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          FaIcon(icon, color: Colors.blueGrey[700], size: 18.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey[700],
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
            onPressed: () {
              // Open settings page to change user preferences
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildWeatherDetails(),
    );
  }
}
