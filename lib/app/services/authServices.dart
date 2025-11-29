import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;

  AuthService({this.baseUrl = 'http://192.168.43.43:5000/farmer'});
  // AuthService({this.baseUrl = 'https://kissanconnect-backend-z00d.onrender.com/farmer'});
  

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? role,
    String? preferredLanguage,
  }) async {
    final url = Uri.parse('$baseUrl/add-user');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'role': role,
          'preferred_language': preferredLanguage,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to register user');
      }
    } catch (e) {
      throw Exception('Error registering user: $e');
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to login');
      }
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }
}
