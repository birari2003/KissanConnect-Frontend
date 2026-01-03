import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api.dart';

class AdminService {
  // URL is now managed by ApiConfig
  final String baseUrl = ApiConfig.adminBaseUrl;

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

  // Get government schemes created by admin
  Future<List<dynamic>> getSchemes() async {
    final url = Uri.parse('$baseUrl/get-schemes');
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to fetch schemes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching schemes: $e');
    }
  }

  // Get jobs created by admin
  Future<List<dynamic>> getMyJobs() async {
    final url = Uri.parse('$baseUrl/my-jobs');
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to fetch my jobs: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching my jobs: $e');
    }
  }

  // Update job status
  Future<Map<String, dynamic>> updateJobStatus({
    required int jobId,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/update-job-status/$jobId');
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to update job status');
      }
    } catch (e) {
      throw Exception('Error updating job status: $e');
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

  // Get villages by taluka ID
  Future<List<dynamic>> getVillagesByTaluka(String talukaId) async {
    final url = Uri.parse('$baseUrl/talukas/$talukaId/villages');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to fetch villages: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching villages: $e');
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

  // Create a new government scheme
  Future<Map<String, dynamic>> createScheme({
    required String title,
    required String description,
    String targetAudience = 'all',
    String status = 'draft',
    String? attachmentPath,
  }) async {
    final url = Uri.parse('$baseUrl/create-scheme');
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({'Authorization': 'Bearer $token'});

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['target_audience'] = targetAudience;
      request.fields['status'] = status;

      if (attachmentPath != null && attachmentPath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('attachment', attachmentPath),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to create scheme');
      }
    } catch (e) {
      throw Exception('Error creating scheme: $e');
    }
  }

  // Create a new job profile
  Future<Map<String, dynamic>> createJob({
    required String jobTitle,
    required String companyName,
    required String jobType,
    required String location,
    required String description,
    String? stateId,
    String? districtId,
    String? talukaId,
    String? villageId,
    String? salaryMin,
    String? salaryMax,
    String? salaryPeriod,
    String? requirements,
    String? benefits,
    String? contactEmail,
    String? contactPhone,
    String? expiresAt,
    String status = 'draft',
    String? attachmentPath,
  }) async {
    final url = Uri.parse('$baseUrl/create-job');
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({'Authorization': 'Bearer $token'});

      request.fields['job_title'] = jobTitle;
      request.fields['company_name'] = companyName;
      request.fields['job_type'] = jobType;
      request.fields['location'] = location;
      request.fields['description'] = description;
      request.fields['status'] = status;

      if (stateId != null) request.fields['state_id'] = stateId;
      if (districtId != null) request.fields['district_id'] = districtId;
      if (talukaId != null) request.fields['taluka_id'] = talukaId;
      if (villageId != null) request.fields['village_id'] = villageId;

      if (salaryMin != null) request.fields['salary_min'] = salaryMin;
      if (salaryMax != null) request.fields['salary_max'] = salaryMax;
      if (salaryPeriod != null) request.fields['salary_period'] = salaryPeriod;

      if (requirements != null) request.fields['requirements'] = requirements;
      if (benefits != null) request.fields['benefits'] = benefits;

      if (contactEmail != null) request.fields['contact_email'] = contactEmail;
      if (contactPhone != null) request.fields['contact_phone'] = contactPhone;
      if (expiresAt != null) request.fields['expires_at'] = expiresAt;

      if (attachmentPath != null && attachmentPath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('attachment', attachmentPath),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to create job');
      }
    } catch (e) {
      throw Exception('Error creating job: $e');
    }
  }

  // Update query (status and/or admin response)
  Future<Map<String, dynamic>> updateQuery({
    required int queryId,
    String? status,
    String? adminResponse,
  }) async {
    // Use farmer base URL since endpoint is /farmer/update-query
    final farmerBaseUrl = baseUrl.replaceAll('/admin', '/farmer');
    final url = Uri.parse('$farmerBaseUrl/update-query');

    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{'query_id': queryId};

      if (status != null) {
        body['status'] = status;
      }

      if (adminResponse != null) {
        body['admin_response'] = adminResponse;
      }

      print('updateQuery - Request body: $body');

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('updateQuery - Response status: ${response.statusCode}');
      print('updateQuery - Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('updateQuery - Success!');
        return data;
      } else {
        print('updateQuery - Failed: ${data['message']}');
        throw Exception(data['message'] ?? 'Failed to update query');
      }
    } catch (e) {
      print('updateQuery - Error: $e');
      throw Exception('Error updating query: $e');
    }
  }

  // Get all queries for admin review
  Future<List<dynamic>> getQueries() async {
    final url = Uri.parse('$baseUrl/get-queries');

    try {
      final headers = await _getHeaders();
      print('Fetching queries from: $url');
      final response = await http.get(url, headers: headers);

      print('getQueries response status: ${response.statusCode}');
      print('getQueries response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Queries data: ${data['data']}');
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to fetch queries: ${response.body}');
      }
    } catch (e) {
      print('Error fetching queries: $e');
      throw Exception('Error fetching queries: $e');
    }
  }

  // Add a new nursery
  Future<Map<String, dynamic>> addNursery(
    Map<String, dynamic> nurseryData,
  ) async {
    final url = Uri.parse('$baseUrl/add-nursery');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(nurseryData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to add nursery');
      }
    } catch (e) {
      throw Exception('Error adding nursery: $e');
    }
  }

  // Bulk add nurseries
  Future<Map<String, dynamic>> bulkAddNurseries(
    List<Map<String, dynamic>> nurseries,
  ) async {
    final url = Uri.parse('$baseUrl/bulk-add-nurseries');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'nurseries': nurseries}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to bulk add nurseries');
      }
    } catch (e) {
      throw Exception('Error bulk adding nurseries: $e');
    }
  }
}
