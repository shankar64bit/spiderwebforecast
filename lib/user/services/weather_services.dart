import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  final String apiKey = '8a3a3f6d7dc2b8d581bd4c488145cb63'; // API key
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // Fetch weather data by city name
  Future<Map<String, dynamic>> getWeather(String city) async {
    final response = await http
        .get(Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      print('Weather data for city: ${json.decode(response.body)}');
      return json.decode(response.body);
    } else {
      print('Failed to load weather data. Status code: ${response.statusCode}');
      throw Exception('Failed to load weather data');
    }
  }

  // Fetch weather data by coordinates (latitude and longitude)
  Future<Map<String, dynamic>> getWeatherByCoordinates(
      double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        '$baseUrl?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Weather data for coordinates ($latitude, $longitude): $data');
      return data;
    } else {
      print('Failed to load weather data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load weather data');
    }
  }
}
