import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'services/excel_service.dart';
import 'services/weather_services.dart';
import 'weather_report_screen.dart';

class UploadExcelScreen extends StatefulWidget {
  @override
  _UploadExcelScreenState createState() => _UploadExcelScreenState();
}

class _UploadExcelScreenState extends State<UploadExcelScreen> {
  final ExcelService _excelService = ExcelService();
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = false;

  Future<void> _uploadExcel() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        List<Map<String, String>> data =
            await _excelService.parseExcelFile(file);
        List<Map<String, dynamic>> weatherReports = [];

        for (var location in data) {
          String city = location['city'] ?? '';
          if (city.isNotEmpty) {
            var weatherData = await _weatherService.getWeather(city);
            weatherReports.add(weatherData);
          }
        }

        // Navigate to the weather report screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WeatherReportScreen(weatherReports: weatherReports),
          ),
        );
      } else {
        // Handle the case where no file was selected
        _showErrorDialog('No file selected. Please try again.');
      }
    } catch (error) {
      // Handle any errors that occur during file upload or weather fetching
      _showErrorDialog('An error occurred: $error');
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Excel')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // Show loading indicator
            : ElevatedButton(
                child: Text('Upload Excel File'),
                onPressed: _uploadExcel,
              ),
      ),
    );
  }
}
