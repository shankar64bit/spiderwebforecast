import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'admin/admin_dashboard_screen.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'routes.dart';
import 'screens/login_screen.dart';
import 'user/user_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Spiderwebforecast App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthWrapper(),
        routes: AppRoutes.routes,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (_, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return LoginScreen();
          }
          return FutureBuilder<bool>(
            future: authService.isAdmin(),
            builder: (_, AsyncSnapshot<bool> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == true) {
                  return AdminDashboardScreen();
                } else {
                  return UserDashboardScreen();
                }
              }
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            },
          );
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
