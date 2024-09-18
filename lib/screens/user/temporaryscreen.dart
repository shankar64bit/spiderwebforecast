import 'package:flutter/material.dart';

import '../../utils/constant.dart';

class TemporaryDataScreen extends StatelessWidget {
  final List<Map<String, dynamic>> weatherReports;

  TemporaryDataScreen({required this.weatherReports});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: AppbarDesignBackgraound(),
        title: Text('Multi Weather Data'),
      ),
      body: weatherReports.isNotEmpty
          ? ListView.builder(
              itemCount: weatherReports.length,
              itemBuilder: (context, index) {
                final report = weatherReports[index];

                // Extracting the values from the report
                final name = report['name'] ?? 'Unknown City';
                final temperature = report['main'] != null &&
                        report['main']['temp'] != null
                    ? (report['main']['temp'])
                        .toStringAsFixed(1) // Convert from Kelvin to Celsius
                    : 'N/A';
                final feelsLike = report['main'] != null &&
                        report['main']['feels_like'] != null
                    ? (report['main']['feels_like'])
                        .toStringAsFixed(1) // Convert from Kelvin to Celsius
                    : 'N/A';
                final weather =
                    (report['weather'] != null && report['weather'].isNotEmpty)
                        ? report['weather'][0]['description'] ?? 'N/A'
                        : 'N/A';
                final humidity =
                    report['main'] != null && report['main']['humidity'] != null
                        ? report['main']['humidity'].toString() + '%'
                        : 'N/A';
                final windSpeed =
                    report['wind'] != null && report['wind']['speed'] != null
                        ? (report['wind']['speed'] * 3.6).toStringAsFixed(1) +
                            ' km/h' // Convert m/s to km/h
                        : 'N/A';
                final precipitation = report['rain'] != null
                    ? (report['rain']['1h'] != null
                        ? report['rain']['1h'].toString() + '%'
                        : '0%')
                    : '0%';

                return Card(
                  elevation: 4.0,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Temperature: $temperature °C\n'
                      'Feels Like: $feelsLike °C\n'
                      'Precipitation: $precipitation\n'
                      'Humidity: $humidity\n'
                      'Wind: $windSpeed',
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: Text(
                      weather,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade400,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text(
                'No data available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
    );
  }
}
