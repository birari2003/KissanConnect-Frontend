import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // Base URL for the backend API
  final String baseUrl;

  EmailService({this.baseUrl = 'http://192.168.43.43:5000/farmer'});
  // EmailService({this.baseUrl = 'https://kissanconnect-backend-z00d.onrender.com/farmer'});

  /// Returns a Map containing the API response with success status and details
  Future<Map<String, dynamic>> sendEmail({
    required String subject,
    required String message,
    dynamic senderEmail, // Can be String or List<String>
  }) async {
    final url = Uri.parse('$baseUrl/send-email');

    try {
      // Validate required fields
      if (subject.trim().isEmpty) {
        throw Exception('Subject is required');
      }
      if (message.trim().isEmpty) {
        throw Exception('Message is required');
      }
      if (senderEmail == null) {
        throw Exception('Sender email is required');
      }

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'subject': subject,
        'message': message,
        'senderEmail': senderEmail, // Can be single string or array
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);

      // Handle different status codes
      if (response.statusCode == 200) {
        // All emails sent successfully
        print('✅ Email(s) sent successfully: ${data['message']}');
        return data;
      } else if (response.statusCode == 207) {
        // Partial success (some emails sent, some failed)
        print('⚠️ Partial success: ${data['message']}');
        return data;
      } else if (response.statusCode == 400) {
        // Bad request (validation error)
        throw Exception(data['message'] ?? 'Invalid request');
      } else if (response.statusCode == 500) {
        // Server error (all emails failed)
        throw Exception(data['message'] ?? 'Failed to send email(s)');
      } else {
        throw Exception('Unexpected response: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error sending email: $e');
      throw Exception('Error sending email: $e');
    }
  }

  /// Convenience method to send email from a single sender
  static Future<Map<String, dynamic>> sendSingleEmail({
    required String subject,
    required String message,
    required String senderEmail,
  }) async {
    final service = EmailService();
    return await service.sendEmail(
      subject: subject,
      message: message,
      senderEmail: senderEmail,
    );
  }

  /// Convenience method to send email from multiple senders
  static Future<Map<String, dynamic>> sendMultipleEmails({
    required String subject,
    required String message,
    required List<String> senderEmails,
  }) async {
    final service = EmailService();
    return await service.sendEmail(
      subject: subject,
      message: message,
      senderEmail: senderEmails,
    );
  }
}
