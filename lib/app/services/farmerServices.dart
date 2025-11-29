import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FarmerService {
  // Replace with your actual backend URL
  final String baseUrl = 'http://192.168.43.43:5000/farmer';
  // final String baseUrl = 'https://kissanconnect-backend-z00d.onrender.com/farmer';

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

  // Get farmer profile
  Future<Map<String, dynamic>> getFarmerProfile() async {
    final url = Uri.parse('$baseUrl/get-farmer-profile');

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
        return data;
      } else if (response.statusCode == 404) {
        // User not found or profile not found, return empty or specific structure
        return {'success': false, 'message': 'Profile not found'};
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch farmer profile');
      }
    } catch (e) {
      throw Exception('Error fetching farmer profile: $e');
    }
  }

  // Get messages sent to the logged-in farmer/super admin
  // Future<List<dynamic>> getMessages() async {
  //   final url = Uri.parse('$baseUrl/get-messages');

  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token');

  //     if (token == null) {
  //       throw Exception('User not authenticated');
  //     }

  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     final data = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       return data['data'] ?? [];
  //     } else {
  //       throw Exception(data['message'] ?? 'Failed to fetch messages');
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching messages: $e');
  //   }
  // }

  // Submit a query from farmer to admin
  Future<Map<String, dynamic>> submitQuery(String query) async {
    final url = Uri.parse('$baseUrl/submit-query');

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
        body: jsonEncode({'query': query}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to submit query');
      }
    } catch (e) {
      throw Exception('Error submitting query: $e');
    }
  }

  // Submit a crop claim
  Future<Map<String, dynamic>> addCropClaim(
    String cropName,
    String claimDetails,
    String? evidencePath,
  ) async {
    final url = Uri.parse('$baseUrl/add-claim');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({'Authorization': 'Bearer $token'});

      request.fields['crop_name'] = cropName;
      request.fields['claim_details'] = claimDetails;

      if (evidencePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('evidence', evidencePath),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to submit crop claim');
      }
    } catch (e) {
      throw Exception('Error submitting crop claim: $e');
    }
  }

  // Add a crop for sale
  Future<Map<String, dynamic>> addCrop(
    String cropName,
    String quantity,
    String unit,
    String pricePerUnit,
    List<String> photoPaths,
  ) async {
    final url = Uri.parse('$baseUrl/add-crop');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({'Authorization': 'Bearer $token'});

      request.fields['crop_name'] = cropName;
      request.fields['quantity'] = quantity;
      request.fields['unit'] = unit;
      request.fields['price_per_unit'] = pricePerUnit;

      for (var path in photoPaths) {
        request.files.add(await http.MultipartFile.fromPath('photos', path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to add crop');
      }
    } catch (e) {
      throw Exception('Error adding crop: $e');
    }
  }

  // Get crops uploaded by the farmer
  Future<List<dynamic>> getCrops() async {
    final url = Uri.parse('$baseUrl/get-crops');

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
        throw Exception(data['message'] ?? 'Failed to fetch crops');
      }
    } catch (e) {
      throw Exception('Error fetching crops: $e');
    }
  }

  // Get claims submitted by the farmer
  Future<List<dynamic>> getClaims() async {
    final url = Uri.parse('$baseUrl/get-claims');

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
        throw Exception(data['message'] ?? 'Failed to fetch claims');
      }
    } catch (e) {
      throw Exception('Error fetching claims: $e');
    }
  }

  // Get all crops for the marketplace
  Future<List<dynamic>> getAllCrops() async {
    final url = Uri.parse('$baseUrl/get-all-crops');

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
        throw Exception(data['message'] ?? 'Failed to fetch crops');
      }
    } catch (e) {
      throw Exception('Error fetching all crops: $e');
    }
  }

  // Get government schemes
  Future<List<dynamic>> getGovernmentSchemes() async {
    final url = Uri.parse('$baseUrl/get-schemes');

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
        throw Exception(data['message'] ?? 'Failed to fetch schemes');
      }
    } catch (e) {
      throw Exception('Error fetching schemes: $e');
    }
  }

  // Get jobs
  Future<List<dynamic>> getJobs({
    String? jobType,
    String? location,
    String? stateId,
    String? districtId,
  }) async {
    final queryParams = <String, String>{};
    if (jobType != null) queryParams['job_type'] = jobType;
    if (location != null) queryParams['location'] = location;
    if (stateId != null) queryParams['state_id'] = stateId;
    if (districtId != null) queryParams['district_id'] = districtId;

    final url = Uri.parse(
      '$baseUrl/get-jobs',
    ).replace(queryParameters: queryParams);

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
        throw Exception(data['message'] ?? 'Failed to fetch jobs');
      }
    } catch (e) {
      throw Exception('Error fetching jobs: $e');
    }
  }

  // Get messages
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
