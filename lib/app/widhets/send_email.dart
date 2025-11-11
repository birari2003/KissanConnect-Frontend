import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendEmailController extends GetxController {
  // Toggle between Send Email and Generate Email with AI
  final selectedTab = 0.obs; // 0 = Send Email, 1 = Generate with AI

  // Location filters
  final selectedState = Rxn<String>();
  final selectedDistrict = Rxn<String>();
  final selectedCity = Rxn<String>();
  final selectedVillage = Rxn<String>();

  // Email fields
  final fromEmail = 'gov@gmail.com';
  final messageController = TextEditingController();

  // AI Chat
  final chatMessages = <ChatMessage>[].obs;
  final aiMessageController = TextEditingController();
  final isGenerating = false.obs;

  // Mock location data
  final states = <String>[
    'Maharashtra',
    'Gujarat',
    'Karnataka',
    'Tamil Nadu',
    'Uttar Pradesh',
  ].obs;

  final districts = <String, List<String>>{
    'Maharashtra': ['Pune', 'Mumbai', 'Nagpur', 'Nashik', 'Aurangabad'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot'],
    'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Mangalore'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Agra', 'Varanasi'],
  };

  final cities = <String, List<String>>{
    'Pune': ['Kothrud', 'Shivajinagar', 'Hadapsar', 'Wakad', 'Hinjewadi'],
    'Mumbai': ['Andheri', 'Bandra', 'Borivali', 'Dadar', 'Thane'],
    'Nagpur': ['Sitabuldi', 'Dharampeth', 'Sadar', 'Kamptee'],
    'Ahmedabad': ['Satellite', 'Navrangpura', 'Maninagar', 'Vastrapur'],
    'Bangalore': ['Koramangala', 'Indiranagar', 'Whitefield', 'Jayanagar'],
  };

  final villages = <String, List<String>>{
    'Kothrud': ['Karve Nagar', 'Paud Road', 'Mayur Colony', 'Dahanukar Colony'],
    'Shivajinagar': ['Deccan', 'JM Road', 'Nal Stop', 'Shivaji Market'],
    'Hadapsar': ['Magarpatta', 'Mundhwa', 'Wanowrie', 'Fatimanagar'],
    'Andheri': ['Versova', 'Lokhandwala', 'Oshiwara', 'Chakala'],
    'Koramangala': ['5th Block', '6th Block', '7th Block', '8th Block'],
  };

  // Mock farmer counts by location
  final farmerCounts = {
    'total': 20,
    'Maharashtra': 15,
    'Pune': 10,
    'Kothrud': 5,
    'Karve Nagar': 2,
  };

  @override
  void onClose() {
    messageController.dispose();
    aiMessageController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  List<String> getDistricts() {
    if (selectedState.value == null) return [];
    return districts[selectedState.value] ?? [];
  }

  List<String> getCities() {
    if (selectedDistrict.value == null) return [];
    return cities[selectedDistrict.value] ?? [];
  }

  List<String> getVillages() {
    if (selectedCity.value == null) return [];
    return villages[selectedCity.value] ?? [];
  }

  int getFilteredFarmerCount() {
    if (selectedVillage.value != null) {
      return farmerCounts[selectedVillage.value] ?? 1;
    }
    if (selectedCity.value != null) {
      return farmerCounts[selectedCity.value] ?? 3;
    }
    if (selectedDistrict.value != null) {
      return farmerCounts[selectedDistrict.value] ?? 8;
    }
    if (selectedState.value != null) {
      return farmerCounts[selectedState.value] ?? 12;
    }
    return farmerCounts['total'] ?? 20;
  }

  String getLocationPath() {
    List<String> path = [];
    if (selectedState.value != null) path.add(selectedState.value!);
    if (selectedDistrict.value != null) path.add(selectedDistrict.value!);
    if (selectedCity.value != null) path.add(selectedCity.value!);
    if (selectedVillage.value != null) path.add(selectedVillage.value!);
    return path.isEmpty ? 'All Locations' : path.join(' > ');
  }

  void resetLocationFilters() {
    selectedState.value = null;
    selectedDistrict.value = null;
    selectedCity.value = null;
    selectedVillage.value = null;
  }

  Future<void> sendEmail() async {
    final message = messageController.text.trim();
    if (message.isEmpty) {
      Get.snackbar('Error', 'Please enter a message');
      return;
    }

    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // TODO: Integrate with backend API to send email
      await Future.delayed(Duration(seconds: 1));
      Get.back(); // Close loading
      Get.snackbar(
        'Success',
        'Email sent to ${getFilteredFarmerCount()} farmers',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF7BB53B).withOpacity(0.1),
      );
      messageController.clear();
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to send email');
    }
  }

  Future<void> generateEmailWithAI(String prompt) async {
    if (prompt.trim().isEmpty) return;

    // Add user message
    chatMessages.add(ChatMessage(text: prompt, isUser: true));
    aiMessageController.clear();
    isGenerating.value = true;

    try {
      // TODO: Integrate with Gemini API
      await Future.delayed(Duration(seconds: 2));
      
      // Mock AI response
      final aiResponse = '''Subject: Important Update for Farmers

Dear Farmers,

We hope this message finds you well. We are writing to inform you about the upcoming agricultural initiatives and support programs available in your region.

Key Points:
• New subsidy schemes for crop insurance
• Training programs on modern farming techniques
• Access to quality seeds and fertilizers at subsidized rates

Please feel free to reach out for more information.

Best regards,
Government Agricultural Department''';

      chatMessages.add(ChatMessage(text: aiResponse, isUser: false));
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate email');
    } finally {
      isGenerating.value = false;
    }
  }

  void copyToClipboard(String text) {
    // TODO: Implement clipboard copy
    Get.snackbar('Copied', 'Email content copied to clipboard');
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class SendEmailWidget extends StatelessWidget {
  const SendEmailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SendEmailController());

    return Container(
      color: Color(0xFFF5F7FA),
      child: Column(
        children: [
          // Toggle buttons
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() => Row(
              children: [
                Expanded(
                  child: _buildToggleButton(
                    'Send Email',
                    Icons.email,
                    0,
                    controller,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildToggleButton(
                    'Generate Email',
                    Icons.auto_awesome,
                    1,
                    controller,
                  ),
                ),
              ],
            )),
          ),
          // Content
          Expanded(
            child: Obx(() => controller.selectedTab.value == 0
                ? _buildSendEmailSection(controller)
                : _buildAIChatSection(controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, IconData icon, int index, SendEmailController controller) {
    final isSelected = controller.selectedTab.value == index;
    return Material(
      color: isSelected ? Color(0xFF7BB53B) : Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => controller.changeTab(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[700],
                size: 20,
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendEmailSection(SendEmailController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // From section with location filter
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Icon(Icons.filter_list, color: Color(0xFF2A6E9B)),
    SizedBox(width: 8),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter Recipients',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A6E9B),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "From",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF2A6E9B),
          ),
        ),
      ],
    ),
    Spacer(), // This will push the icon to the right
  ],
),
                SizedBox(height: 16),
                _buildLocationDropdowns(controller),
                SizedBox(height: 16),
                Obx(() => Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF7BB53B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF7BB53B).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people, color: Color(0xFF7BB53B), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${controller.getFilteredFarmerCount()} Farmers Selected',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2A6E9B),
                              ),
                            ),
                            Text(
                              controller.getLocationPath(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.selectedState.value != null)
                        IconButton(
                          icon: Icon(Icons.clear, size: 20),
                          onPressed: controller.resetLocationFilters,
                          color: Colors.grey[600],
                        ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          SizedBox(height: 16),
          // From Email (constant)
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.mail_outline, color: Color(0xFF2A6E9B)),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      controller.fromEmail,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2A6E9B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Message box
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A6E9B),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: controller.messageController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'Type your email message here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF7BB53B), width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          // Send button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.sendEmail,
              icon: Icon(Icons.send, size: 20),
              label: Text('Send Email', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7BB53B),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDropdowns(SendEmailController controller) {
    return Obx(() => Column(
      children: [
        _buildDropdown(
          label: 'State',
          value: controller.selectedState.value,
          items: controller.states,
          onChanged: (value) {
            controller.selectedState.value = value;
            controller.selectedDistrict.value = null;
            controller.selectedCity.value = null;
            controller.selectedVillage.value = null;
          },
          icon: Icons.map,
        ),
        if (controller.selectedState.value != null) ...[
          SizedBox(height: 12),
          _buildDropdown(
            label: 'District',
            value: controller.selectedDistrict.value,
            items: controller.getDistricts(),
            onChanged: (value) {
              controller.selectedDistrict.value = value;
              controller.selectedCity.value = null;
              controller.selectedVillage.value = null;
            },
            icon: Icons.location_city,
          ),
        ],
        if (controller.selectedDistrict.value != null) ...[
          SizedBox(height: 12),
          _buildDropdown(
            label: 'City',
            value: controller.selectedCity.value,
            items: controller.getCities(),
            onChanged: (value) {
              controller.selectedCity.value = value;
              controller.selectedVillage.value = null;
            },
            icon: Icons.apartment,
          ),
        ],
        if (controller.selectedCity.value != null) ...[
          SizedBox(height: 12),
          _buildDropdown(
            label: 'Village',
            value: controller.selectedVillage.value,
            items: controller.getVillages(),
            onChanged: (value) {
              controller.selectedVillage.value = value;
            },
            icon: Icons.home_work,
          ),
        ],
      ],
    ));
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF7BB53B)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        hint: Text('Select $label'),
      ),
    );
  }

  Widget _buildAIChatSection(SendEmailController controller) {
    return Column(
      children: [
        // Chat messages
        Expanded(
          child: Obx(() {
            if (controller.chatMessages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'Ask AI to generate email content',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Example: "Write an email about new farming subsidies"',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: controller.chatMessages.length,
              itemBuilder: (context, index) {
                final message = controller.chatMessages[index];
                return _buildChatBubble(message, controller);
              },
            );
          }),
        ),
        // Input section
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: controller.aiMessageController,
                      decoration: InputDecoration(
                        hintText: 'Ask AI to generate email...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          controller.generateEmailWithAI(text);
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Obx(() => controller.isGenerating.value
                    ? SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF7BB53B),
                          ),
                        ),
                      )
                    : Material(
                        color: Color(0xFF7BB53B),
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          onTap: () {
                            final text = controller.aiMessageController.text;
                            if (text.trim().isNotEmpty) {
                              controller.generateEmailWithAI(text);
                            }
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            child: Icon(Icons.send, color: Colors.white, size: 22),
                          ),
                        ),
                      )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble(ChatMessage message, SendEmailController controller) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: 300),
        child: Column(
          crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? Color(0xFF7BB53B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.grey[800],
                  fontSize: 14,
                ),
              ),
            ),
            if (!message.isUser)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: () {
                    controller.copyToClipboard(message.text);
                    controller.messageController.text = message.text;
                    controller.changeTab(0); // Switch to Send Email tab
                  },
                  icon: Icon(Icons.copy, size: 16),
                  label: Text('Copy & Use'),
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF7BB53B),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}