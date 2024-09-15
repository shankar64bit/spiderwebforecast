import 'package:flutter/material.dart';

import '../models/userpreferences.dart';
import '../utils/constant.dart';

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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarDesign('Settings'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temperature Unit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedUnit,
              items: ['Celsius', 'Fahrenheit']
                  .map((unit) => DropdownMenuItem(
                        child: Text(unit),
                        value: unit,
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedUnit = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Update Frequency (minutes)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<int>(
              value: selectedFrequency,
              items: [15, 30, 60, 120]
                  .map((frequency) => DropdownMenuItem(
                        child: Text('$frequency minutes'),
                        value: frequency,
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedFrequency = value!;
                });
              },
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
                borderRadius:
                    BorderRadius.circular(8), // Optional: for rounded corners
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
}
