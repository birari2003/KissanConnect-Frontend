import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api.dart';

class AuthService {
  final String baseUrl;

  AuthService({String? baseUrl}) : baseUrl = baseUrl ?? ApiConfig.farmerBaseUrl;

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
    String? languagePreference,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final body = {'phone': phone, 'password': password};

      // Add language_preference if provided
      if (languagePreference != null && languagePreference.isNotEmpty) {
        body['language_preference'] = languagePreference;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      print(response.body);

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
