import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/paymentgetway_controller.dart';

class PaymentgetwayView extends GetView<PaymentgetwayController> {
  const PaymentgetwayView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: controller.payerName.value);
    final contactController = TextEditingController(text: controller.payerContact.value);
    final emailController = TextEditingController(text: controller.payerEmail.value);

    const Color primaryColor = Color(0xFF0E7D31);
    const Color accentColor = Color(0xFF38A169);

    InputDecoration customInputDecoration(String labelText, {Widget? prefixIcon}) {
      return InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Themed Header Section
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Yearly Subscription',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                      '₹${controller.planAmount.value.toStringAsFixed(2)} per year',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )),
                    const SizedBox(height: 4),
                    const Text(
                      'Powered by Razorpay',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Subscription Benefits Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Subscription Benefits',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildBenefitItem('✓ Full access to all premium features'),
                            _buildBenefitItem('✓ Priority customer support'),
                            _buildBenefitItem('✓ No ads or interruptions'),
                            _buildBenefitItem('✓ Regular updates and new features'),
                            _buildBenefitItem('✓ Cancel anytime'),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Enter Your Details',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    
                    // Payer Details Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: customInputDecoration('Name', 
                                prefixIcon: const Icon(Icons.person, color: accentColor)),
                              onChanged: (v) => controller.payerName.value = v,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: contactController,
                              keyboardType: TextInputType.phone,
                              decoration: customInputDecoration('Contact Number', 
                                prefixIcon: const Icon(Icons.phone, color: accentColor)),
                              onChanged: (v) => controller.payerContact.value = v,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: customInputDecoration('Email', 
                                prefixIcon: const Icon(Icons.email, color: accentColor)),
                              onChanged: (v) => controller.payerEmail.value = v,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Amount Display Card
                    Card(
                      elevation: 4,
                      color: primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '₹',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Text(
                                  controller.planAmount.value.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            )),
                            const SizedBox(height: 4),
                            const Text(
                              'Pre-filled for your convenience',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black45,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Primary Payment Button (Integrated Checkout)
                    Obx(() => ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(55),
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 8,
                      ),
                      onPressed: controller.isProcessing.value 
                        ? null 
                        : () => controller.startSubscriptionPayment(),
                      icon: const Icon(Icons.credit_card, size: 24),
                      label: Text(
                        controller.isProcessing.value 
                          ? 'Processing...' 
                          : 'Pay ₹${controller.planAmount.value} - All Payment Methods',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    )),
                    
                    const SizedBox(height: 16),
                    
                    // UPI Direct Button (With pre-filled amount)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(55),
                        foregroundColor: primaryColor,
                        side: const BorderSide(color: primaryColor, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => controller.openUpiPaymentLink(),
                      icon: const Icon(Icons.qr_code_2, size: 24),
                      label: Text(
                        'Pay via UPI (₹${controller.planAmount.value}) - Browser',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Direct UPI Intent Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(55),
                        foregroundColor: accentColor,
                        side: const BorderSide(color: accentColor, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => controller.openDirectUpiIntent(),
                      icon: const Icon(Icons.payment, size: 24),
                      label: Text(
                        'Quick UPI Pay (₹${controller.planAmount.value}) - Direct',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Informational Tip
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '💡 Amount is pre-filled! Choose your preferred UPI app and just enter your PIN to complete the payment.',
                              style: TextStyle(
                                fontSize: 13, 
                                color: Colors.blue.shade800,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Security Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Secure payment powered by Razorpay',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }
}