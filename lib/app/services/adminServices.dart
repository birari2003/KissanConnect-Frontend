import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  // Replace with your actual backend URL
  final String baseUrl = 'http://192.168.43.43:5000/admin';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all locations (nested)
  Future<List<dynamic>> getAllLocations() async {
    final url = Uri.parse('$baseUrl/locations');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to fetch locations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching locations: $e');
    }
  }

  // Get all states
  Future<List<dynamic>> getStates() async {
    final url = Uri.parse('$baseUrl/states');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to fetch states: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching states: $e');
    }
  }

  // Get districts by state ID
  Future<List<dynamic>> getDistrictsByState(String stateId) async {
    final url = Uri.parse('$baseUrl/states/$stateId/districts');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to fetch districts: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching districts: $e');
    }
  }

  // Get talukas by district ID
  Future<List<dynamic>> getTalukasByDistrict(String districtId) async {
    final url = Uri.parse('$baseUrl/districts/$districtId/talukas');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to fetch talukas: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching talukas: $e');
    }
  }

  // Get farmers list with optional location filters
  Future<List<dynamic>> getFarmersList({
    String? stateId,
    String? districtId,
    String? talukaId,
    String? villageId,
  }) async {
    // Build query parameters
    final queryParams = <String, String>{};
    if (stateId != null) queryParams['state_id'] = stateId;
    if (districtId != null) queryParams['district_id'] = districtId;
    if (talukaId != null) queryParams['taluka_id'] = talukaId;
    if (villageId != null) queryParams['village_id'] = villageId;

    final url = Uri.parse(
      '$baseUrl/farmers-list',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to fetch farmers list: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching farmers list: $e');
    }
  }

  // Update farmer status (approve/reject)
  Future<Map<String, dynamic>> updateFarmerStatus({
    required int userId,
    required String status,
    String? rejectionReason,
  }) async {
    final url = Uri.parse('$baseUrl/update-status');

    try {
      final headers = await _getHeaders();
      final body = {
        'user_id': userId,
        'status': status,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      };

      print('updateFarmerStatus - Request body: $body');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to update farmer status');
      }
    } catch (e) {
      throw Exception('Error updating farmer status: $e');
    }
  }

  // Assign super admin role to a user
  Future<Map<String, dynamic>> assignSuperAdmin({
    required int userId,
    required String level,
    String? stateId,
    String? districtId,
    String? talukaId,
    String? villageId,
  }) async {
    final url = Uri.parse('$baseUrl/assign-super-admin');

    try {
      final headers = await _getHeaders();
      final body = {
        'user_id': userId,
        'level': level,
        if (stateId != null) 'state_id': stateId,
        if (districtId != null) 'district_id': districtId,
        if (talukaId != null) 'taluka_id': talukaId,
        if (villageId != null) 'village_id': villageId,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to assign super admin');
      }
    } catch (e) {
      throw Exception('Error assigning super admin: $e');
    }
  }

  // Get all super admins
  Future<List<dynamic>> getSuperAdmins() async {
    final url = Uri.parse('$baseUrl/super-admins');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to fetch super admins: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching super admins: $e');
    }
  }

  // Add a message to super admins
  Future<Map<String, dynamic>> addMessage({
    required String message,
    required List<int> recipientIds,
  }) async {
    final url = Uri.parse('$baseUrl/add-message');

    try {
      final headers = await _getHeaders();
      final body = {'message': message, 'recipient_ids': recipientIds};

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // Get all users with their name, role, and super admin level
  Future<List<dynamic>> getAllUsers() async {
    final url = Uri.parse('$baseUrl/get-all-users');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to fetch users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }
}
