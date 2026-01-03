import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../../utils/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentgetwayController extends GetxController {
  final _razorpay = Razorpay();

  // Observables
  var isProcessing = false.obs;
  var payerName = ''.obs;
  var payerContact = ''.obs;
  var payerEmail = ''.obs;

  // Subscription related
  var selectedPlanId = 'plan_RgHnFHx9XiAhg8'.obs;
  var planAmount = 499.0.obs;
  var planName = 'Yearly Subscription'.obs;

  // Backend URL - Replace with your actual backend URL
  final String backendUrl = 'https://your-backend-url.com';

  // Current user ID - Get this from your auth service
  final String userId = ''; // TODO: Get from auth service

  @override
  void onInit() {
    super.onInit();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Fetch plan details on init
    fetchPlanDetails();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  // Fetch subscription plan details from backend
  Future<void> fetchPlanDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/api/subscription/plan/${selectedPlanId.value}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          planAmount.value = data['plan']['amount'].toDouble();
          planName.value = data['plan']['plan_name'];
        }
      }
    } catch (e) {
      print('Error fetching plan: $e');
    }
  }

  // Method 1: Start payment with Razorpay SDK (In-app checkout)
  Future<void> startSubscriptionPayment() async {
    if (payerName.value.isEmpty ||
        payerContact.value.isEmpty ||
        payerEmail.value.isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please fill all the required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return;
    }

    isProcessing.value = true;

    try {
      // Create UPI intent and get order ID
      final response = await http.post(
        Uri.parse('$backendUrl/api/subscription/create-upi-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'planId': selectedPlanId.value,
          'userName': payerName.value,
          'userEmail': payerEmail.value,
          'userContact': payerContact.value,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          // Start Razorpay checkout
          var options = {
            'key': data['razorpayKeyId'],
            'amount': (planAmount.value * 100).toInt(),
            'name': 'Somayu Infotech',
            'order_id': data['orderId'],
            'description': planName.value,
            'prefill': {
              'contact': payerContact.value,
              'email': payerEmail.value,
              'name': payerName.value,
            },
            'method': {
              'upi': true,
              'card': true,
              'netbanking': true,
              'wallet': true,
            },
            'notes': {'subscription_id': data['subscriptionId'].toString()},
          };

          _razorpay.open(options);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to create payment order');
      }
    } catch (e) {
      isProcessing.value = false;
      UiUtils.showErrorSnackbar(
        'Payment Error',
        'Failed to initiate payment: $e',
      );
    }
  }

  // Method 2: Open UPI payment link (Direct UPI with pre-filled amount)
  Future<void> openUpiPaymentLink() async {
    if (payerName.value.isEmpty ||
        payerContact.value.isEmpty ||
        payerEmail.value.isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please fill all the required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return;
    }

    try {
      isProcessing.value = true;

      // Create payment link with pre-filled amount
      final response = await http.post(
        Uri.parse('$backendUrl/api/subscription/create-payment-link'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'planId': selectedPlanId.value,
          'userName': payerName.value,
          'userEmail': payerEmail.value,
          'userContact': payerContact.value,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          // Open payment link in browser
          final uri = Uri.parse(data['paymentLink']);

          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);

            Get.snackbar(
              'Payment Link Opened',
              'Complete the payment in the browser. Amount: ₹${planAmount.value}',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 5),
            );
          } else {
            throw Exception('Could not launch payment link');
          }
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to create payment link');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open payment link: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Method 3: Open direct UPI intent with pre-filled amount
  Future<void> openDirectUpiIntent() async {
    try {
      // Create UPI deep link with pre-filled amount
      final upiUrl =
          'upi://pay?pa=somayuinfotech@razorpay&pn=Somayu Infotech&am=${planAmount.value}&cu=INR&tn=${Uri.encodeComponent(planName.value)}';

      final uri = Uri.parse(upiUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web payment link
        openUpiPaymentLink();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No UPI app found. Opening web payment link...',
        snackPosition: SnackPosition.BOTTOM,
      );
      openUpiPaymentLink();
    }
  }

  // Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    isProcessing.value = false;

    // Verify payment on backend
    verifyPayment(
      razorpayPaymentId: response.paymentId!,
      razorpayOrderId: response.orderId!,
      razorpaySignature: response.signature!,
    );
  }

  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    isProcessing.value = false;

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

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    isProcessing.value = false;
    Get.snackbar(
      'External Wallet',
      'Selected wallet: ${response.walletName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Verify payment on backend
  Future<void> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/subscription/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'razorpayPaymentId': razorpayPaymentId,
          'razorpayOrderId': razorpayOrderId,
          'razorpaySignature': razorpaySignature,
          'subscriptionId': '', // Get from notes in payment response
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          UiUtils.showSuccessSnackbar(
            translate('payment_success_title'),
            translate('payment_success_message'),
          );

          // Navigate to success page or refresh subscription status
          Get.offAllNamed('/home');
        } else {
          throw Exception(data['message']);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Verification Error',
        'Payment successful but verification failed. Contact support.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        duration: const Duration(seconds: 5),
      );
    }
  }

  // Check subscription status
  Future<bool> checkSubscriptionStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/api/subscription/status/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['hasActiveSubscription'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking subscription: $e');
      return false;
    }
  }
}
