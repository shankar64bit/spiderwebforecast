import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'user/upload_excel_screen.dart';
import 'user/user_dashboard_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String adminDashboard = '/admin';
  static const String userDashboard = '/user';
  static const String uploadExcel = '/excel';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginScreen(),
    register: (context) => RegistrationScreen(),
    userDashboard: (context) => UserDashboardScreen(),
    uploadExcel: (context) => UploadExcelScreen(),
  };
}
