import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../screens/login_screen.dart';
import '../../../utils/ui_helpers.dart';
import '../utils/constant.dart';
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
  List<Map<String, dynamic>> filteredLocations = [];
  TextEditingController _searchController = TextEditingController();
  TextEditingController _addLocationController = TextEditingController();
  late Stream<QuerySnapshot> _locationsStream;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _locationsStream = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('locations')
          .snapshots();
    }
  }

  void _filterLocations(String query) {
    setState(() {
      filteredLocations = locations.where((location) {
        return location['name'].toLowerCase().contains(query.toLowerCase()) ||
            location['zipCode'].toString().contains(query);
      }).toList();
    });
  }

  Future<void> _addLocation() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String input = _addLocationController.text.trim();
    if (input.isEmpty) {
      UIHelpers.showSnackBar(
          context, 'Please enter a location name or zip code',
          isError: true);
      return;
    }

    try {
      bool isZipCode = int.tryParse(input) != null;
      var weatherData = await _weatherService.getWeather(input);

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('locations')
          .add({
        'type': isZipCode ? 'zipCode' : 'city',
        'name': weatherData['name'],
        'zipCode': isZipCode ? input : '',
      });

      _addLocationController.clear();
      UIHelpers.showSnackBar(context, 'Location added successfully');
    } catch (e) {
      print('Error adding location: $e');
      UIHelpers.showSnackBar(context,
          'Error adding location. Please check the name or zip code and try again.',
          isError: true);
    }
  }

  Future<void> _deleteLocation(String docId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('locations')
          .doc(docId)
          .delete();
      UIHelpers.showSnackBar(context, 'Location deleted successfully');
    } catch (e) {
      print('Error deleting location: $e');
      UIHelpers.showSnackBar(
          context, 'Error deleting location. Please try again.',
          isError: true);
    }
  }

  Future _uploadExcel(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

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
        print('Error processing Excel file: $e');
        UIHelpers.showSnackBar(context,
            'Error processing file. Please check the file format and try again.',
            isError: true);
      }
    }
  }

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
      print('Error fetching weather: $e');
      UIHelpers.showSnackBar(
          context, 'Error fetching weather. Please try again later.',
          isError: true);
    }
  }

  Future _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route route) => false,
      );
    } catch (e) {
      print('Error logging out: $e');
      UIHelpers.showSnackBar(context, 'Error logging out. Please try again.',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: AppbarDesignBackgraound(),
        title:
            Text('Spiderweb forecast', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search locations',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: _filterLocations,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _locationsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                locations = snapshot.data!.docs.map((doc) {
                  return {
                    'id': doc.id,
                    'type': doc['type'],
                    'name': doc['name'],
                    'zipCode': doc['zipCode'] ?? '',
                  };
                }).toList();

                filteredLocations = _searchController.text.isEmpty
                    ? locations
                    : locations.where((location) {
                        return location['name'].toLowerCase().contains(
                                _searchController.text.toLowerCase()) ||
                            location['zipCode']
                                .toString()
                                .contains(_searchController.text);
                      }).toList();

                return ListView.builder(
                  itemCount: filteredLocations.length,
                  padding:
                      EdgeInsets.only(bottom: 90), // Add padding to the bottom

                  itemBuilder: (context, index) {
                    final location = filteredLocations[index];
                    return Card(
                      elevation: 4.0,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: Icon(
                          location['type'] == 'city'
                              ? Icons.location_city
                              : Icons.map,
                          color: Color.fromARGB(133, 40, 58, 255),
                        ),
                        title: Text(
                          location['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(location['zipCode'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteLocation(location['id']),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.grey),
                          ],
                        ),
                        onTap: () => _getWeatherForLocation(location['name']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Upload Excel Button
            SizedBox(
              height: 50,
              width: 150,
              child: FloatingActionButton.extended(
                onPressed: () => _uploadExcel(context),
                icon: Icon(Icons.upload_file),
                label: Text('Upload Excel', style: TextStyle(fontSize: 12)),
                backgroundColor: Color.fromARGB(133, 40, 58, 255),
              ),
            ),
            SizedBox(width: 10),

            // Add Location Button
            SizedBox(
              height: 50,
              width: 150,
              child: FloatingActionButton.extended(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Add New Location'),
                        content: TextField(
                          controller: _addLocationController,
                          decoration: InputDecoration(
                            hintText: 'Enter city name or zip code',
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Add'),
                            onPressed: () {
                              _addLocation();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.add),
                label: Text('Add Location', style: TextStyle(fontSize: 12)),
                backgroundColor: Color.fromARGB(133, 40, 58, 255),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
