import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../screens/login_screen.dart';
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
      _showSnackBar('Please enter a location name or zip code', true);
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
        'name': weatherData['name'] ?? 'Unknown City',
        'zipCode': isZipCode ? input : '',
      });

      _addLocationController.clear();
      _showSnackBar('Location added successfully');
    } catch (e) {
      print('Error adding location: $e');
      _showSnackBar(
          'Error adding location. Please check the name or zip code and try again.',
          true);
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
      _showSnackBar('Location deleted successfully');
    } catch (e) {
      print('Error deleting location: $e');
      _showSnackBar('Error deleting location. Please try again.', true);
    }
  }

  Future<void> _showUploadInstructions(BuildContext context) async {
    bool? shouldProceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Upload Instructions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          content: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '1. Ensure the file is in .xlsx format.\n\n',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: '2. The file should contain a column named\n',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: '* Country\n* State\n* District\n* City\n',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  TextSpan(
                    text: 'with the required weather location names.\n\n',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text:
                        '3. The app will process the file and display the weather data.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Got It',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.all(24),
          actionsPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        );
      },
    );

    if (shouldProceed == true) {
      _uploadExcel(context); // Proceed with file upload
    }
  }

  Future<void> _uploadExcel(BuildContext context) async {
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
                TemporaryDataScreen(weatherReports: weatherReports),
          ),
        );
      } catch (e) {
        print('Error processing Excel file: $e');
        _showSnackBar(
            'Error processing file. Please check the file format and try again.',
            true);
      }
    }
  }

  Future<void> _getWeatherForLocation(String locationName) async {
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
      _showSnackBar('Error fetching weather. Please try again later.', true);
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route route) => false,
      );
    } catch (e) {
      print('Error logging out: $e');
      _showSnackBar('Error logging out. Please try again.', true);
    }
  }

  void _showSnackBar(String message, [bool isError = false]) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: AppbarDesignBackgraound(),
        backgroundColor: Color.fromARGB(133, 40, 58, 255),
        title:
            Text('Spiderweb Forecast', style: TextStyle(color: Colors.white)),
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
                    'name': doc['name'] ?? 'Unknown Location',
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
                  padding: EdgeInsets.only(bottom: 90),
                  itemBuilder: (context, index) {
                    final location = filteredLocations[index];
                    return Card(
                      elevation: 4.0,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteLocation(location['id']),
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
            SizedBox(
              height: 50,
              width: 150,
              child: FloatingActionButton.extended(
                onPressed: () {
                  _showUploadInstructions(
                      context); // Show instructions before upload
                },
                icon: Icon(Icons.upload_file),
                label: Text('Upload Excel', style: TextStyle(fontSize: 12)),
                backgroundColor: Color.fromARGB(133, 40, 58, 255),
              ),
            ),
            SizedBox(width: 10),
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
