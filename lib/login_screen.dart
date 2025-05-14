import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gen_z/dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// User model for login response
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}

// Token model for login response
class Tokens {
  final String refresh;
  final String access;

  Tokens({
    required this.refresh,
    required this.access,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      refresh: json['refresh']?.toString() ?? '',
      access: json['access']?.toString() ?? '',
    );
  }
}

// Login response model
class LoginResponse {
  final bool success;
  final String message;
  final User user;
  final Tokens tokens;

  LoginResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.tokens,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      user: User.fromJson(json['user'] ?? {}),
      tokens: Tokens.fromJson(json['tokens'] ?? {}),
    );
  }
}

// ApiService with login API
class ApiService {
  static const String baseUrl = 'http://178.128.150.238';

  // Login API
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/api/login/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        log('Login response: $responseData');
        final loginResponse = LoginResponse.fromJson(responseData);

        if (loginResponse.success) {
          // Store user data and tokens in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', loginResponse.user.id);
          await prefs.setString('user_email', loginResponse.user.email);
          await prefs.setString('user_first_name', loginResponse.user.firstName);
          await prefs.setString('user_last_name', loginResponse.user.lastName);
          await prefs.setString('user_role', loginResponse.user.role);
          await prefs.setString('access_token', loginResponse.tokens.access);
          await prefs.setString('refresh_token', loginResponse.tokens.refresh);
        }

        return loginResponse;
      } else {
        log('Failed to login: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      log('Error during login: $e');
      throw Exception('Error during login: $e');
    }
  }

  // Get stored user ID (used in reservation APIs)
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Get stored access token
  Future<String?> getBearerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.success) {
        // Navigate to DashboardScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  DashboardScreen()),
        );
      } else {
        setState(() {
          _errorMessage = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.06),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login to GenZ40',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: size.height * 0.02),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: size.height * 0.03),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: size.width * 0.04,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  SizedBox(height: size.height * 0.02),
                  SizedBox(
                    width: double.infinity,
                    height: size.height * 0.07,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  TextButton(
                    onPressed: () {
                      // Implement forgot password or signup navigation
                    },
                    child: Text(
                      'Forgot Password? / Sign Up',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: size.width * 0.04,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}