import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../screens/login_screen.dart';
import '../../../utils/ui_helpers.dart';
import 'services/excel_service.dart';
import 'services/weather_services.dart';
import 'weather_report_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final ExcelService _excelService = ExcelService();
  final WeatherService _weatherService = WeatherService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> locations = [];

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  // Fetch locations added by the admin from Firestore
  Future<void> _fetchLocations() async {
    try {
      List<Map<String, dynamic>> allLocations = [];

      // Fetch countries
      QuerySnapshot countriesSnapshot =
          await _firestore.collection('country').get();
      allLocations.addAll(countriesSnapshot.docs
          .map((doc) => {'type': 'country', 'name': doc['name']}));

      // Fetch states
      QuerySnapshot statesSnapshot = await _firestore.collection('state').get();
      allLocations.addAll(statesSnapshot.docs
          .map((doc) => {'type': 'state', 'name': doc['name']}));

      // Fetch districts
      QuerySnapshot districtsSnapshot =
          await _firestore.collection('district').get();
      allLocations.addAll(districtsSnapshot.docs
          .map((doc) => {'type': 'district', 'name': doc['name']}));

      // Fetch cities
      QuerySnapshot citiesSnapshot = await _firestore.collection('city').get();
      allLocations.addAll(citiesSnapshot.docs
          .map((doc) => {'type': 'city', 'name': doc['name']}));

      setState(() {
        locations = allLocations;
      });
    } catch (e) {
      UIHelpers.showSnackBar(
          context, 'Error fetching locations: ${e.toString()}',
          isError: true);
    }
  }

  // Upload an Excel file and process it
  Future _uploadExcel(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      try {
        List<Map<String, dynamic>> data =
            await _excelService.parseExcelFile(file);
        List<Map<String, dynamic>> weatherReports = [];

        for (var location in data) {
          String city = location['city'] ?? '';
          if (city.isNotEmpty) {
            var weatherData = await _weatherService.getWeather(city);
            weatherReports.add(weatherData);
          }
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WeatherReportScreen(weatherReports: weatherReports),
          ),
        );
      } catch (e) {
        UIHelpers.showSnackBar(
            context, 'Error processing file: ${e.toString()}',
            isError: true);
      }
    }
  }

  // Fetch weather for the selected location
  Future _getWeatherForLocation(String locationName) async {
    try {
      var weatherData = await _weatherService.getWeather(locationName);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WeatherReportScreen(weatherReports: [weatherData]),
        ),
      );
    } catch (e) {
      UIHelpers.showSnackBar(context, 'Error fetching weather: ${e.toString()}',
          isError: true);
    }
  }

  // Log out the user
  Future _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route route) => false,
      );
    } catch (e) {
      UIHelpers.showSnackBar(context, 'Error logging out: ${e.toString()}',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(133, 129, 136, 212),
        title: Text('Newtokpro User'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4.0, // Adds elevation to the ListTile
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(
                      locations[index]['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(locations[index]['type']),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () =>
                        _getWeatherForLocation(locations[index]['name']),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: const Color.fromARGB(133, 129, 136, 212),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(
                Icons.upload_file,
                color: Colors.black,
              ),
              label: Text(
                'Upload Excel',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () => _uploadExcel(context),
            ),
          ),
        ],
      ),
    );
  }
}
