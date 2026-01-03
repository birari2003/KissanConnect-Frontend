import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api.dart';

class FarmerService {
  // URLs are now managed by ApiConfig
  final String baseUrl = ApiConfig.farmerBaseUrl;
  final String paymentUrl = ApiConfig.paymentBaseUrl;

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
    final url = Uri.parse('$baseUrl/add-query');

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
        body: jsonEncode({'description': query}),
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

  // Get all queries with user and responder details
  Future<List<dynamic>> getQueries() async {
    final url = Uri.parse('$baseUrl/get-queries');

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
        throw Exception(data['message'] ?? 'Failed to fetch queries');
      }
    } catch (e) {
      throw Exception('Error fetching queries: $e');
    }
  }

  // Get queries submitted by the logged-in user
  Future<List<dynamic>> getMyQueries() async {
    final url = Uri.parse('$baseUrl/get-my-queries');

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
        throw Exception(data['message'] ?? 'Failed to fetch my queries');
      }
    } catch (e) {
      throw Exception('Error fetching my queries: $e');
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

  // Get payment details
  Future<Map<String, dynamic>> getPaymentDetails() async {
    final url = Uri.parse('$paymentUrl/payment-details');

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
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch payment details');
      }
    } catch (e) {
      throw Exception('Error fetching payment details: $e');
    }
  }

  // Search farmer by contact number
  Future<Map<String, dynamic>?> searchFarmerByContact(String contact) async {
    final url = Uri.parse('$baseUrl/search-farmer-by-contact?contact=$contact');

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

      if (response.statusCode == 200 && data['success'] == true) {
        // Backend returns nested structure: { data: { user: {...}, farmer_profile: {...} } }
        // Extract the user object
        if (data['data'] != null && data['data']['user'] != null) {
          return data['data']['user'];
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Error searching farmer: $e');
      return null;
    }
  }

  // Submit a crop complaint
  Future<Map<String, dynamic>> submitCropComplaint({
    required int againstUserId,
    required String complaintText,
  }) async {
    final url = Uri.parse('$baseUrl/add-complaint');

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
        body: jsonEncode({
          'against_user_id': againstUserId,
          'complaint_text': complaintText,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to submit complaint');
      }
    } catch (e) {
      throw Exception('Error submitting complaint: $e');
    }
  }

  // Add farmer history
  Future<Map<String, dynamic>> addFarmerHistory({
    required int cropSellId,
    required int cropOwnerUserId,
    String? cropName,
    String? cropImagePath,
  }) async {
    final url = Uri.parse('$baseUrl/add-history');

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
        body: jsonEncode({
          'crop_sell_id': cropSellId,
          'crop_owner_user_id': cropOwnerUserId,
          'crop_name': cropName,
          'crop_image_path': cropImagePath,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to add farmer history');
      }
    } catch (e) {
      throw Exception('Error adding farmer history: $e');
    }
  }

  // Get farmer history
  Future<List<dynamic>> getFarmerHistory() async {
    final url = Uri.parse('$baseUrl/get-history');

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
        throw Exception(data['message'] ?? 'Failed to fetch farmer history');
      }
    } catch (e) {
      throw Exception('Error fetching farmer history: $e');
    }
  }

  // Get complaints
  Future<List<dynamic>> getComplaints() async {
    final url = Uri.parse('$baseUrl/get-complaints');

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
        throw Exception(data['message'] ?? 'Failed to fetch complaints');
      }
    } catch (e) {
      throw Exception('Error fetching complaints: $e');
    }
  }

  // Get my complaints
  Future<List<dynamic>> getMyComplaints() async {
    final url = Uri.parse('$baseUrl/get-my-complaints');

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
        throw Exception(data['message'] ?? 'Failed to fetch complaints');
      }
    } catch (e) {
      throw Exception('Error fetching complaints: $e');
    }
  }

  // Update complaint status
  Future<Map<String, dynamic>> updateComplaintStatus({
    required int complaintId,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/update-complaint-status');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'complaint_id': complaintId, 'status': status}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to update complaint status');
      }
    } catch (e) {
      throw Exception('Error updating complaint status: $e');
    }
  }

  // Update crop claim
  Future<Map<String, dynamic>> updateCropClaim({
    required int claimId,
    String? cropName,
    String? claimDetails,
    String? newEvidencePath,
  }) async {
    final url = Uri.parse('$baseUrl/update-claim/$claimId');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll({'Authorization': 'Bearer $token'});

      if (cropName != null) {
        request.fields['crop_name'] = cropName;
      }
      if (claimDetails != null) {
        request.fields['claim_details'] = claimDetails;
      }

      if (newEvidencePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('evidence', newEvidencePath),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to update crop claim');
      }
    } catch (e) {
      throw Exception('Error updating crop claim: $e');
    }
  }

  // Delete crop claim
  Future<Map<String, dynamic>> deleteCropClaim(int claimId) async {
    final url = Uri.parse('$baseUrl/delete-claim/$claimId');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to delete crop claim');
      }
    } catch (e) {
      throw Exception('Error deleting crop claim: $e');
    }
  }

  // Update crop listing
  Future<Map<String, dynamic>> updateCrop({
    required int cropId,
    String? cropName,
    String? quantity,
    String? unit,
    String? pricePerUnit,
    List<String>? newPhotoPaths,
  }) async {
    final url = Uri.parse('$baseUrl/update-crop/$cropId');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll({'Authorization': 'Bearer $token'});

      if (cropName != null) {
        request.fields['crop_name'] = cropName;
      }
      if (quantity != null) {
        request.fields['quantity'] = quantity;
      }
      if (unit != null) {
        request.fields['unit'] = unit;
      }
      if (pricePerUnit != null) {
        request.fields['price_per_unit'] = pricePerUnit;
      }

      if (newPhotoPaths != null && newPhotoPaths.isNotEmpty) {
        for (var path in newPhotoPaths) {
          request.files.add(await http.MultipartFile.fromPath('photos', path));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to update crop');
      }
    } catch (e) {
      throw Exception('Error updating crop: $e');
    }
  }

  // Delete crop listing
  Future<Map<String, dynamic>> deleteCrop(int cropId) async {
    final url = Uri.parse('$baseUrl/delete-crop/$cropId');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to delete crop');
      }
    } catch (e) {
      throw Exception('Error deleting crop: $e');
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/change-password');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Error changing password: $e');
    }
  }

  // Update password (Forgot Password - No authentication required)
  Future<Map<String, dynamic>> updatePassword({
    required String email,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/update-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'new_password': newPassword}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to update password');
      }
    } catch (e) {
      throw Exception('Error updating password: $e');
    }
  }

  // Bulk add users
  Future<Map<String, dynamic>> bulkAddUsers(
    List<Map<String, dynamic>> users,
  ) async {
    final url = Uri.parse('$baseUrl/bulk-add-users');

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
        body: jsonEncode({'users': users}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to bulk add users');
      }
    } catch (e) {
      throw Exception('Error bulk adding users: $e');
    }
  }
}
