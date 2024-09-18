
import 'package:flutter/material.dart';
import '../../models/userpreferences.dart';
import '../../utils/constant.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedUnit = 'Celsius';
  int selectedFrequency = 60;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    String unit = await UserPreferences.getTemperatureUnit();
    int frequency = await UserPreferences.getUpdateFrequency();

    setState(() {
      selectedUnit = unit;
      selectedFrequency = frequency;
    });
  }

  Future<void> _savePreferences() async {
    await UserPreferences.setTemperatureUnit(selectedUnit);
    await UserPreferences.setUpdateFrequency(selectedFrequency);
    // Pop and return the updated preferences
    Navigator.pop(context, {
      'unit': selectedUnit,
      'frequency': selectedFrequency,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarDesign('Settings'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSettingCard(
              title: 'Temperature Unit',
              child: DropdownButton<String>(
                value: selectedUnit,
                items: ['Celsius', 'Fahrenheit']
                    .map((unit) => DropdownMenuItem(
                          child: Text(
                            unit,
                            style: TextStyle(
                              color:
                                  Colors.black, // Ensure text color is visible
                            ),
                          ),
                          value: unit,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value!;
                  });
                },
                isExpanded: true,
                style: TextStyle(
                  color: Colors.black, // Ensure text color is visible
                  fontSize: 16.0,
                ),
                underline: Container(),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black, // Ensure icon color is visible
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingCard(
              title: 'Update Frequency (minutes)',
              child: DropdownButton<int>(
                value: selectedFrequency,
                items: [15, 30, 60, 120]
                    .map((frequency) => DropdownMenuItem(
                          child: Text(
                            '$frequency minutes',
                            style: TextStyle(
                              color:
                                  Colors.black, // Ensure text color is visible
                            ),
                          ),
                          value: frequency,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFrequency = value!;
                  });
                },
                isExpanded: true,
                style: TextStyle(
                  color: Colors.black, // Ensure text color is visible
                  fontSize: 16.0,
                ),
                underline: Container(),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black, // Ensure icon color is visible
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.blue, // First color
                    Colors.purple, // Second color
                    Colors.red, // Optional third color
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              child: ElevatedButton(
                onPressed: _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.transparent, // Make button background transparent
                  shadowColor: Colors.transparent, // Remove shadow
                ),
                child: const Text('Save Preferences'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({required String title, required Widget child}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            child,
          ],
        ),
      ),
    );
  }
}
