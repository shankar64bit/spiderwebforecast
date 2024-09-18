import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../utils/ui_helpers.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.signIn(_email, _password);
      } catch (e) {
        String errorMessage = e.toString(); // Customize based on error type
        UIHelpers.showSnackBar(context, 'Login failed: $errorMessage',
            isError: true);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(212, 205, 208, 239),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Login Spiderweb',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      validator: Validators.validateEmail,
                      onChanged: (value) => setState(() => _email = value),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      obscureText: true,
                      validator: Validators.validatePassword,
                      onChanged: (value) => setState(() => _password = value),
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 115, 123, 210),
                              padding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Sign in',
                                style: TextStyle(color: Colors.white)),
                            onPressed: _isLoading
                                ? null
                                : _signIn, // Disable when loading
                          ),
                    SizedBox(height: 12),
                    TextButton(
                      child: Text('Don\'t have an account? Register here'),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
