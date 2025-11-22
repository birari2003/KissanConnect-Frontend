import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FarmerService {
  // Replace with your actual backend URL
  final String baseUrl = 'http://192.168.43.43:5000/farmer';

  Future<Map<String, dynamic>> registerFarmerProfile(
    Map<String, dynamic> farmerData,
  ) async {
    final url = Uri.parse('$baseUrl/register-farmer');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(farmerData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to register farmer profile');
      }
    } catch (e) {
      throw Exception('Error registering farmer profile: $e');
    }
  }

  // Get messages sent to the logged-in farmer/super admin
  Future<List<dynamic>> getMessages() async {
    final url = Uri.parse('$baseUrl/get-messages');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch messages');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }
}
