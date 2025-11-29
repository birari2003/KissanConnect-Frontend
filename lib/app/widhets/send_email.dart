import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/sendEmailService.dart';
import '../services/adminServices.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../utils/ui_utils.dart';

// User model for sender list
class UserModel {
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? superAdminLevel;
  final Map<String, dynamic>? farmerProfile;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.superAdminLevel,
    this.farmerProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      superAdminLevel: json['super_admin_level'],
      farmerProfile: json['farmerProfile'],
    );
  }

  String get displayName => '$name ($email)';
}

class SendEmailController extends GetxController {
  // Toggle between Send Email and Generate Email with AI
  final selectedTab = 0.obs; // 0 = Send Email, 1 = Generate with AI

  // Email fields
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  // Admin service for fetching users
  final adminService = AdminService();

  // User list from API
  final users = <UserModel>[].obs;
  final isLoadingUsers = false.obs;
  final userLoadError = ''.obs;

  // Location Filters
  final states = <dynamic>[].obs;
  final districts = <dynamic>[].obs;
  final talukas = <dynamic>[].obs;
  final villages = <dynamic>[].obs;

  final selectedState = Rxn<String>();
  final selectedDistrict = Rxn<String>();
  final selectedTaluka = Rxn<String>();
  final selectedVillage = Rxn<String>();

  final isLoadingLocations = false.obs;

  // Filtered Users
  List<UserModel> get filteredUsers {
    return users.where((user) {
      if (user.role != 'farmer' || user.farmerProfile == null) return false;

      final profile = user.farmerProfile!;

      if (selectedState.value != null &&
          profile['state_id'].toString() != selectedState.value) {
        return false;
      }
      if (selectedDistrict.value != null &&
          profile['district_id'].toString() != selectedDistrict.value) {
        return false;
      }
      if (selectedTaluka.value != null &&
          profile['taluka_id'].toString() != selectedTaluka.value) {
        return false;
      }
      if (selectedVillage.value != null &&
          profile['village_id'].toString() != selectedVillage.value) {
        return false;
      }

      return true;
    }).toList();
  }

  // AI Chat
  final chatMessages = <ChatMessage>[].obs;
  final aiMessageController = TextEditingController();
  final isGenerating = false.obs;

  // Speech to Text
  late stt.SpeechToText _speech;
  final isListening = false.obs;
  final isListeningSubject = false.obs;
  final isListeningMessage = false.obs;
  final isListeningAI = false.obs;

  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
    loadUsers(); // Load users from API on initialization
    fetchStates();
  }

  // Fetch States
  Future<void> fetchStates() async {
    try {
      final data = await adminService.getStates();
      states.assignAll(data);
    } catch (e) {
      print('Error fetching states: $e');
    }
  }

  // Fetch Districts
  Future<void> fetchDistricts(String stateId) async {
    try {
      districts.clear();
      talukas.clear();
      villages.clear();
      selectedDistrict.value = null;
      selectedTaluka.value = null;
      selectedVillage.value = null;

      final data = await adminService.getDistrictsByState(stateId);
      districts.assignAll(data);
    } catch (e) {
      print('Error fetching districts: $e');
    }
  }

  // Fetch Talukas
  Future<void> fetchTalukas(String districtId) async {
    try {
      talukas.clear();
      villages.clear();
      selectedTaluka.value = null;
      selectedVillage.value = null;

      final data = await adminService.getTalukasByDistrict(districtId);
      talukas.assignAll(data);
    } catch (e) {
      print('Error fetching talukas: $e');
    }
  }

  // Fetch Villages
  void fetchVillages(String talukaId) {
    try {
      villages.clear();
      selectedVillage.value = null;

      final taluka = talukas.firstWhere(
        (t) => t['id'].toString() == talukaId,
        orElse: () => null,
      );

      if (taluka != null && taluka['villages'] != null) {
        villages.assignAll(taluka['villages']);
      }
    } catch (e) {
      print('Error fetching villages: $e');
    }
  }

  // Load users from API
  Future<void> loadUsers() async {
    isLoadingUsers.value = true;
    userLoadError.value = '';

    try {
      final usersData = await adminService.getAllUsers();
      users.value = usersData
          .map((userData) => UserModel.fromJson(userData))
          .where(
            (user) => user.email.isNotEmpty,
          ) // Only include users with email
          .toList();

      if (users.isEmpty) {
        userLoadError.value = 'No users with email addresses found';
      }
    } catch (e) {
      userLoadError.value = 'Failed to load users: $e';
      print('Error loading users: $e');
    } finally {
      isLoadingUsers.value = false;
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    aiMessageController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> sendEmail() async {
    final subject = subjectController.text.trim();
    final message = messageController.text.trim();

    if (subject.isEmpty) {
      UiUtils.showErrorSnackbar('Error', 'Please enter subject');
      return;
    }

    if (message.isEmpty) {
      UiUtils.showErrorSnackbar('Error', 'Please enter a message');
      return;
    }

    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Validate that users are loaded
      if (filteredUsers.isEmpty) {
        Get.back();
        UiUtils.showErrorSnackbar(
          'Error',
          'No users found with the selected filters.',
        );
        return;
      }

      // Get emails from filtered users
      final senders = filteredUsers.map((u) => u.email).toList();

      // Create EmailService instance
      final emailService = EmailService();

      // Send email with single or multiple senders
      final response = await emailService.sendEmail(
        subject: subject,
        message: message,
        senderEmail: senders.length == 1 ? senders.first : senders,
      );

      Get.back(); // Close loading

      // Check response success
      if (response['success'] == true) {
        final totalSent = response['totalSent'] ?? senders.length;
        UiUtils.showSuccessSnackbar(
          'Success',
          'Email sent successfully from $totalSent sender(s)',
        );
        subjectController.clear();
        messageController.clear();
      } else {
        // Partial success or failure
        final totalSent = response['totalSent'] ?? 0;
        final totalFailed = response['totalFailed'] ?? 0;
        if (totalSent > 0) {
          UiUtils.showErrorSnackbar(
            'Partial Success',
            '$totalSent email(s) sent, $totalFailed failed. Check logs for details.',
          );
        } else {
          UiUtils.showErrorSnackbar(
            'Error',
            'Failed to send emails. Please try again.',
          );
        }
      }
    } catch (e) {
      Get.back();
      UiUtils.showErrorSnackbar('Error', 'Failed to send email: $e');
    }
  }

  Future<void> generateEmailWithAI(String prompt) async {
    if (prompt.trim().isEmpty) return;

    const apiKey = '37cc701d-6e56-4ced-b116-d8a482f16b7c';
    final url = Uri.parse('https://api.sambanova.ai/v1/chat/completions');

    // Add user message
    chatMessages.add(ChatMessage(text: prompt, isUser: true));
    aiMessageController.clear();
    isGenerating.value = true;

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'stream': false,
          'model': 'DeepSeek-V3.1-Terminus',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful assistant that helps write professional emails. Generate concise, clear email content based on the user\'s prompts.',
            },
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final aiResponse = responseData['choices'][0]['message']['content'];

        chatMessages.add(ChatMessage(text: aiResponse, isUser: false));
      } else {
        throw Exception(
          'Failed to get response from DeepSeek API: ${response.statusCode}',
        );
      }
    } catch (e) {
      chatMessages.add(
        ChatMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
        ),
      );
      UiUtils.showErrorSnackbar('Error', 'Failed to generate email: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  void copyToClipboard(String text) {
    // TODO: Implement clipboard copy
    UiUtils.showSuccessSnackbar('Copied', 'Email content copied to clipboard');
  }

  Future<void> startListening(
    TextEditingController controller,
    RxBool listeningState,
  ) async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      UiUtils.showErrorSnackbar(
        'Permission Denied',
        'Microphone permission is required for voice input',
      );
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          listeningState.value = false;
        }
      },
      onError: (error) {
        listeningState.value = false;
        UiUtils.showErrorSnackbar(
          'Error',
          'Voice recognition error: ${error.errorMsg}',
        );
      },
    );

    if (available) {
      listeningState.value = true;
      _speech.listen(
        onResult: (result) {
          controller.text = result.recognizedWords;
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
      );
    } else {
      UiUtils.showErrorSnackbar('Error', 'Speech recognition not available');
    }
  }

  void stopListening(RxBool listeningState) {
    _speech.stop();
    listeningState.value = false;
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
            child: Obx(
              () => Row(
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
              ),
            ),
          ),
          // Content
          Expanded(
            child: Obx(
              () => controller.selectedTab.value == 0
                  ? _buildSendEmailSection(controller)
                  : _buildAIChatSection(controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    String label,
    IconData icon,
    int index,
    SendEmailController controller,
  ) {
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
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
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
          // From (sender)
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
                  'Filter Recipients by Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A6E9B),
                  ),
                ),
                SizedBox(height: 16),

                // State Dropdown
                Obx(
                  () => _buildDropdown(
                    label: 'State',
                    value: controller.selectedState.value,
                    items: controller.states,
                    onChanged: (val) {
                      controller.selectedState.value = val;
                      if (val != null) controller.fetchDistricts(val);
                    },
                  ),
                ),

                // District Dropdown
                Obx(
                  () => controller.selectedState.value != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12),
                            _buildDropdown(
                              label: 'District',
                              value: controller.selectedDistrict.value,
                              items: controller.districts,
                              onChanged: (val) {
                                controller.selectedDistrict.value = val;
                                if (val != null) controller.fetchTalukas(val);
                              },
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                ),

                // Taluka Dropdown
                Obx(
                  () => controller.selectedDistrict.value != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12),
                            _buildDropdown(
                              label: 'Taluka',
                              value: controller.selectedTaluka.value,
                              items: controller.talukas,
                              onChanged: (val) {
                                controller.selectedTaluka.value = val;
                                if (val != null) controller.fetchVillages(val);
                              },
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                ),

                // Village Dropdown
                Obx(
                  () => controller.selectedTaluka.value != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12),
                            _buildDropdown(
                              label: 'Village',
                              value: controller.selectedVillage.value,
                              items: controller.villages,
                              onChanged: (val) {
                                controller.selectedVillage.value = val;
                              },
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                ),

                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 12),

                // Recipient Count
                Obx(() {
                  final count = controller.filteredUsers.length;
                  return Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF7BB53B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFF7BB53B).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.people, color: Color(0xFF7BB53B)),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target Audience',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '$count Farmers',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D323A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Subject
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
                  'Subject',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A6E9B),
                  ),
                ),
                SizedBox(height: 12),
                Obx(
                  () => TextField(
                    controller: controller.subjectController,
                    decoration: InputDecoration(
                      hintText: 'Enter subject...',
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
                        borderSide: BorderSide(
                          color: Color(0xFF7BB53B),
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(Icons.subject, color: Color(0xFF7BB53B)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isListeningSubject.value
                              ? Icons.mic
                              : Icons.mic_none,
                          color: controller.isListeningSubject.value
                              ? Colors.red
                              : Color(0xFF7BB53B),
                        ),
                        onPressed: () {
                          if (controller.isListeningSubject.value) {
                            controller.stopListening(
                              controller.isListeningSubject,
                            );
                          } else {
                            controller.startListening(
                              controller.subjectController,
                              controller.isListeningSubject,
                            );
                          }
                        },
                      ),
                    ),
                  ),
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
                Obx(
                  () => TextField(
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
                        borderSide: BorderSide(
                          color: Color(0xFF7BB53B),
                          width: 2,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(top: 8, right: 8),
                        child: IconButton(
                          icon: Icon(
                            controller.isListeningMessage.value
                                ? Icons.mic
                                : Icons.mic_none,
                            color: controller.isListeningMessage.value
                                ? Colors.red
                                : Color(0xFF7BB53B),
                          ),
                          onPressed: () {
                            if (controller.isListeningMessage.value) {
                              controller.stopListening(
                                controller.isListeningMessage,
                              );
                            } else {
                              controller.startListening(
                                controller.messageController,
                                controller.isListeningMessage,
                              );
                            }
                          },
                        ),
                      ),
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
                    child: Row(
                      children: [
                        Expanded(
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
                        Obx(
                          () => IconButton(
                            icon: Icon(
                              controller.isListeningAI.value
                                  ? Icons.mic
                                  : Icons.mic_none,
                              color: controller.isListeningAI.value
                                  ? Colors.red
                                  : Color(0xFF7BB53B),
                            ),
                            onPressed: () {
                              if (controller.isListeningAI.value) {
                                controller.stopListening(
                                  controller.isListeningAI,
                                );
                              } else {
                                controller.startListening(
                                  controller.aiMessageController,
                                  controller.isListeningAI,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Obx(
                  () => controller.isGenerating.value
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
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                ),
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
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<dynamic> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: [
        DropdownMenuItem<String>(value: null, child: Text('Select $label')),
        ...items.map((item) {
          return DropdownMenuItem<String>(
            value: item['id'].toString(),
            child: Text(item['name']),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}
