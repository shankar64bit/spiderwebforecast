import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _locationsKey = 'cached_locations';

  Future<void> cacheLocations(
      String type, List<Map<String, dynamic>> locations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_locationsKey}_$type', json.encode(locations));
  }

  Future<List<Map<String, dynamic>>> getCachedLocations(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final String? locationsJson = prefs.getString('${_locationsKey}_$type');
    if (locationsJson != null) {
      return List<Map<String, dynamic>>.from(json.decode(locationsJson));
    }
    return [];
  }
}
