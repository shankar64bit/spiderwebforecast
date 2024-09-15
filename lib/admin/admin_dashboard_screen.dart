// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../screens/login_screen.dart';
import 'services/location_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final LocationService _locationService = LocationService();
  String _selectedType = 'country';
  List _locations = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      var locations = await _locationService.getLocations(_selectedType);
      setState(() {
        _locations = locations;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load locations: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addLocation() async {
    String? name = await showDialog<String>(
      context: context,
      builder: (context) => _AddLocationDialog(),
    );
    if (name != null && name.isNotEmpty) {
      await _locationService.addLocation(_selectedType, name, null);
      _loadLocations();
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to log out: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(133, 129, 136, 212),
        title: Text('Newtokpro Admin'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Select Location Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              items:
                  ['country', 'state', 'district', 'city'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedType = newValue;
                    _loadLocations();
                  });
                }
              },
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: _error.isNotEmpty
                      ? Center(
                          child:
                              Text(_error, style: TextStyle(color: Colors.red)),
                        )
                      : ListView.builder(
                          itemCount: _locations.length,
                          itemBuilder: (context, index) {
                            var location = _locations[index];
                            return Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Card(
                                elevation: 5,
                                child: ListTile(
                                  title: Text(location['name']),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      await _locationService.deleteLocation(
                                          _selectedType, location['id']);
                                      _loadLocations();
                                    },
                                  ),
                                  onTap: () async {
                                    String? newName = await showDialog<String>(
                                      context: context,
                                      builder: (context) => _AddLocationDialog(
                                          initialName: location['name']),
                                    );
                                    if (newName != null && newName.isNotEmpty) {
                                      await _locationService.updateLocation(
                                          _selectedType,
                                          location['id'],
                                          newName);
                                      _loadLocations();
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Color.fromARGB(133, 129, 136, 212),
        ),
        onPressed: _addLocation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add),
            SizedBox(width: 8), // Space between icon and text
            Text(
              'Add Location',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddLocationDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final String? initialName;

  _AddLocationDialog({this.initialName}) {
    _controller.text = initialName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(initialName == null ? 'Add Location' : 'Edit Location'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: "Enter location name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () => Navigator.of(context).pop(_controller.text),
        ),
      ],
    );
  }
}
