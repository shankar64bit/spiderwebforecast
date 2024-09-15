import 'package:flutter/material.dart';

class WeatherReportScreen extends StatelessWidget {
  final List<Map<String, dynamic>> weatherReports;

  WeatherReportScreen({required this.weatherReports});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(133, 129, 136, 212),
        title: Text('Weather Reports'),
      ),
      body: PageView(
        children: [
          _buildGridLayout(),
        ],
      ),
    );
  }

  Widget _buildGridLayout() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: weatherReports.length,
      itemBuilder: (context, index) {
        var report = weatherReports[index];
        return Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(report['name'],
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center),
                weatherreporttextreuse(
                    'Temperature: ${report['main']['temp']}°C'),
                weatherreporttextreuse(
                    'Condition: ${report['weather'][0]['description']}'),
                weatherreporttextreuse(
                    'Humidity: ${report['main']['humidity']}%'),
                weatherreporttextreuse(
                    'Wind Speed: ${report['wind']['speed']} m/s'),
              ],
            ),
          ),
        );
      },
    );
  }
}

weatherreporttextreuse(String textdetails) {
  return Column(
    children: [
      SizedBox(height: 4.0),
      Text(
        '$textdetails',
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.blueGrey[500],
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}
