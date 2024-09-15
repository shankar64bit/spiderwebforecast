import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _temperatureUnitKey = 'temperature_unit';
  static const String _updateFrequencyKey = 'update_frequency';

  static Future<void> setTemperatureUnit(String unit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_temperatureUnitKey, unit);
  }

  static Future<String> getTemperatureUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_temperatureUnitKey) ??
        'Celsius'; // Default to Celsius
  }

  static Future<void> setUpdateFrequency(int frequency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_updateFrequencyKey, frequency);
  }

  static Future<int> getUpdateFrequency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_updateFrequencyKey) ?? 60; // Default to 60 minutes
  }
}
