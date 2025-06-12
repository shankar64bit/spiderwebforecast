import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../screens/login_screen.dart';
import '../../utils/constant.dart';
import 'services/excel_service.dart';
import 'services/weather_services.dart';
import 'temporaryscreen.dart';
import 'weather_report_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final ExcelService _excelService = ExcelService();
  final WeatherService _weatherService = WeatherService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _addLocationController = TextEditingController();
  final TextEditingController _editLocationController = TextEditingController();
  final TextEditingController _editZipCodeController = TextEditingController();

  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> filteredLocations = [];
  late Stream<QuerySnapshot> _locationsStream;

  String _currentLocation = 'Unknown';
  String _currentTemperature = 'N/A';
  Map<String, String> locationTemperatures = {};

  @override
  void initState() {
    super.initState();
    _initializeStream();
    _getCurrentLocationAndWeather();
  }

  void _initializeStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _locationsStream = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('locations')
          .snapshots();
    }
  }

  Future<void> _getCurrentLocationAndWeather() async {
    PermissionStatus permission = await Permission.location.request();
    if (permission.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        double latitude = position.latitude;
        double longitude = position.longitude;

        var weatherData =
            await _weatherService.getWeatherByCoordinates(latitude, longitude);
        setState(() {
          _currentLocation = weatherData['name'] ?? 'Unknown Location';
          _currentTemperature =
              weatherData['main']['temp']?.toStringAsFixed(1) ?? 'N/A';
        });
      } catch (e) {
        print('Error fetching location: $e');
        _showSnackBar('Error fetching location. Please try again later.', true);
      }
    } else {
      _showSnackBar('Location permission denied.', true);
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

  Future<void> _editLocation(
      String docId, String currentName, String currentZipCode) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String newName = _editLocationController.text.trim();
    String newZipCode = _editZipCodeController.text.trim();

    if (newName.isEmpty) {
      _showSnackBar('Location name cannot be empty', true);
      return;
    }

    try {
      var weatherData = await _weatherService.getWeather(newName);
      String verifiedName = weatherData['name'] ?? newName;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('locations')
          .doc(docId)
          .update({
        'name': verifiedName,
        'zipCode': newZipCode,
        'type': newZipCode.isEmpty ? 'city' : 'zipCode',
      });

      _editLocationController.clear();
      _editZipCodeController.clear();

      locationTemperatures.remove(currentName);
      await _fetchWeatherForLocation(verifiedName);

      _showSnackBar('Location updated successfully');
    } catch (e) {
      print('Error updating location: $e');
      _showSnackBar(
          'Error updating location. Please check the name or zip code and try again.',
          true);
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> location) async {
    _editLocationController.text = location['name'];
    _editZipCodeController.text = location['zipCode'] ?? '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editLocationController,
                decoration: InputDecoration(
                  labelText: 'Location Name',
                  hintText: 'Enter new location name',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _editZipCodeController,
                decoration: InputDecoration(
                  labelText: 'Zip Code (optional)',
                  hintText: 'Enter zip code',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _editLocation(
                  location['id'],
                  location['name'],
                  location['zipCode'] ?? '',
                );
              },
            ),
          ],
        );
      },
    );
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
        );
      },
    );

    if (shouldProceed == true) {
      _uploadExcel(context);
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

  Future<void> _fetchWeatherForLocations() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    for (var location in locations) {
      String locationName = location['name'];
      if (!locationTemperatures.containsKey(locationName)) {
        try {
          var weatherData = await _weatherService.getWeather(locationName);
          setState(() {
            locationTemperatures[locationName] =
                (weatherData['main']['temp']).toStringAsFixed(1);
          });
        } catch (e) {
          print('Error fetching weather for $locationName: $e');
        }
      }
    }
  }

  Future<void> _fetchWeatherForLocation(String locationName) async {
    try {
      var weatherData = await _weatherService.getWeather(locationName);
      setState(() {
        locationTemperatures[locationName] =
            (weatherData['main']['temp']).toStringAsFixed(1);
      });
    } catch (e) {
      print('Error fetching weather for $locationName: $e');
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spiderweb Forecast', style: TextStyle(color: Colors.white)),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.red),
                SizedBox(width: 4),
                Text(
                  '$_currentLocation | $_currentTemperature°C',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 15, 10, 15),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => _logout(context),
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search locations',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.blueGrey),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                ),
                onChanged: _filterLocations,
              ),
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

                _fetchWeatherForLocations();

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
                    final temperature =
                        locationTemperatures[location['name']] ?? 'N/A';
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
                          '${location['name']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              '${temperature}°C',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 104, 65, 244)),
                            ),
                            SizedBox(width: 10),
                            Text(location['zipCode'] ?? ''),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(location),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteLocation(location['id']),
                            ),
                          ],
                        ),
                        onTap: () => _getWeatherForLocation(location['name']),
                      ),
                    );
                  },
                );
              },
            ),
          )
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
                heroTag: 'uniqueHeroTag1',
                onPressed: () {
                  _showUploadInstructions(context);
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
                heroTag: 'uniqueHeroTag2',
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
