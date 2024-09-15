import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  final String apiKey = '8a3a3f6d7dc2b8d581bd4c488145cb63'; // API key
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getWeather(String city) async {
    final response = await http
        .get(Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      print(json.decode(response.body));
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
