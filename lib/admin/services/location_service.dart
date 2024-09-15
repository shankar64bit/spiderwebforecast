import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/cache_service.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CacheService _cacheService = CacheService();

  /// Adds a location to the specified collection with an optional parentId
  Future<void> addLocation(String type, String name, String? parentId) async {
    Map<String, dynamic> locationData = {
      'name': name,
    };

    // If parentId is provided, add it to the location data
    if (parentId != null) {
      locationData['parentId'] = parentId;
    }

    await _firestore.collection(type).add(locationData);
  }

  Future<List<Map<String, dynamic>>> getLocations(String type) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(type).get();
      List<Map<String, dynamic>> locations = snapshot.docs.map((doc) {
        // Extract the document ID and data
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the map
        return data;
      }).toList();
      await _cacheService.cacheLocations(type, locations);
      return locations;
    } catch (e) {
      print('Error fetching locations: $e');
      return await _cacheService.getCachedLocations(type);
    }
  }

  /// Updates the name of a location in the specified collection
  Future<void> updateLocation(String type, String id, String name) async {
    await _firestore.collection(type).doc(id).update({'name': name});
  }

  /// Deletes a location from the specified collection by document ID
  Future<void> deleteLocation(String type, String id) async {
    await _firestore.collection(type).doc(id).delete();
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
