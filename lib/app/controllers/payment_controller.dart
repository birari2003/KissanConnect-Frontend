import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../utils/ui_utils.dart';
import '../utils/api.dart';

class PaymentController extends GetxController {
  late Razorpay _razorpay;
  final isLoading = false.obs;

  // Base URL for payment endpoints - now managed by ApiConfig
  final String baseUrl = ApiConfig.paymentBaseUrl;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<void> startPayment() async {
    isLoading.value = true;
    try {
      // 1. Create Order
      final orderData = await _createOrder();

      if (orderData != null) {
        // 2. Open Checkout
        _openCheckout(orderData);
      }
    } catch (e) {
      UiUtils.showErrorSnackbar('Error', 'Failed to initiate payment: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> _createOrder() async {
    final url = Uri.parse('$baseUrl/create-order');

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
          'amount': 499, // Fixed amount as per requirement
          'currency': 'INR',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Error creating order: ${response.statusCode}');
        print('Response body: ${response.body}');
        try {
          final data = jsonDecode(response.body);
          throw Exception(data['message'] ?? 'Failed to create order');
        } catch (e) {
          throw Exception('Failed to create order: ${response.body}');
        }
      }
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  void _openCheckout(Map<String, dynamic> orderData) {
    var options = {
      'key': orderData['key_id'],
      'amount':
          orderData['amount'] * 100, // Amount is already in paise from backend?
      // Backend says: amount: amount * 100 in createOrder options.
      // But the response returns amount: amount.
      // Wait, backend code:
      // const options = { amount: amount * 100, ... } -> Razorpay order created with paise.
      // return res.status(200).json({ ..., amount: amount, ... }); -> Returns original amount (499).
      // Razorpay checkout expects amount in paise.
      // So we should multiply by 100 here if the backend returns the rupee amount.
      // Let's assume backend returns 499.
      'name': 'Smart Shetkari',
      'description': 'Premium Subscription',
      'order_id': orderData['order_id'],
      'prefill': {
        'contact': '', // Can be filled if available
        'email': '', // Can be filled if available
      },
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening checkout: $e');
      UiUtils.showErrorSnackbar('Error', 'Failed to open payment gateway');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await _verifyPayment(
        response.orderId!,
        response.paymentId!,
        response.signature!,
      );
      UiUtils.showSuccessSnackbar(
        translate('payment_success_title'),
        translate('payment_success_message'),
      );
      Get.back(); // Close popup if open
    } catch (e) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        '${translate('payment_verification_failed')}\n$e',
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Get user-friendly error message based on error code
    String errorMessage = _getPaymentErrorMessage(
      response.code,
      response.message,
    );

    UiUtils.showErrorSnackbar(translate('payment_failed_title'), errorMessage);
  }

  // Helper method to get user-friendly error messages
  String _getPaymentErrorMessage(int? code, String? message) {
    // Common Razorpay error codes
    switch (code) {
      case 0: // BAD_REQUEST_ERROR - User cancelled
        return translate('payment_cancelled');
      case 1: // GATEWAY_ERROR - Network issues
        return translate('payment_network_error');
      case 2: // NETWORK_ERROR
        return translate('payment_network_error');
      case 3: // SERVER_ERROR
        return translate('payment_server_error');
      default:
        // Check message for specific error types
        if (message != null) {
          final lowerMessage = message.toLowerCase();
          if (lowerMessage.contains('cancel')) {
            return translate('payment_cancelled');
          } else if (lowerMessage.contains('network') ||
              lowerMessage.contains('internet')) {
            return translate('payment_network_error');
          } else if (lowerMessage.contains('card') ||
              lowerMessage.contains('invalid')) {
            return translate('payment_invalid_card');
          } else if (lowerMessage.contains('insufficient') ||
              lowerMessage.contains('balance')) {
            return translate('payment_insufficient_funds');
          } else if (lowerMessage.contains('decline')) {
            return translate('payment_declined');
          } else if (lowerMessage.contains('timeout') ||
              lowerMessage.contains('time out')) {
            return translate('payment_timeout');
          }
        }
        return translate('payment_generic_error');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    UiUtils.showSuccessSnackbar(
      'External Wallet',
      'Wallet name: ${response.walletName}',
    );
  }

  Future<void> _verifyPayment(
    String orderId,
    String paymentId,
    String signature,
  ) async {
    final url = Uri.parse('$baseUrl/verify-payment');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Payment verification failed');
      }
    } catch (e) {
      print('Error verifying payment: $e');
      rethrow;
    }
  }
}
