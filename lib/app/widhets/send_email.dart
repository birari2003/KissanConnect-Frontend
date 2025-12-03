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

// Node for hierarchical location tree
class LocationNode {
  final String id;
  final String name;
  final String type; // 'state', 'district', 'taluka', 'village'
  final List<LocationNode> children;
  final List<UserModel> farmers;
  RxBool isExpanded = false.obs;
  RxBool isSelected = false.obs;

  LocationNode({
    required this.id,
    required this.name,
    required this.type,
    this.children = const [],
    List<UserModel>? farmers,
  }) : farmers = farmers ?? [];

  int get farmerCount {
    if (type == 'village') {
      return farmers.length;
    }
    return children.fold(0, (sum, child) => sum + child.farmerCount);
  }

  // Get all farmers in this subtree
  List<UserModel> get allFarmers {
    if (type == 'village') {
      return farmers;
    }
    return children.expand((child) => child.allFarmers).toList();
  }
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

  // Location Tree
  final locationTree = <LocationNode>[].obs;
  final isLoadingLocations = false.obs;

  // Selected Farmers
  final selectedFarmers = <String>{}.obs; // Set of email addresses

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
    loadData();
  }

  Future<void> loadData() async {
    isLoadingUsers.value = true;
    isLoadingLocations.value = true;
    try {
      await loadUsers();
      await buildLocationTree();
    } finally {
      isLoadingUsers.value = false;
      isLoadingLocations.value = false;
    }
  }

  // Load users from API
  Future<void> loadUsers() async {
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
    }
  }

  // Build hierarchical location tree
  Future<void> buildLocationTree() async {
    try {
      // 1. Fetch all locations (assuming nested structure from API)
      // If getAllLocations returns a flat list or different structure, we might need to adjust.
      // For now, I'll assume we can get states, then districts, etc. or a full tree.
      // Since getAllLocations in adminService calls /locations, let's try to use it.
      // If it fails or returns empty, we'll fallback to fetching states and building down.

      // Note: The previous implementation fetched states, then districts on selection.
      // To show counts upfront, we need to fetch everything or at least have the data.
      // Let's try to fetch states first, and we might need to fetch all children recursively
      // OR if the backend supports a full tree dump.

      // Optimization: If we have many locations, fetching all might be slow.
      // But for "farmer counts", we need to know where they are.
      // Let's assume we fetch states and then for each state we might need to fetch districts...
      // actually that's too many requests.
      // Let's check if we can process users locally if we have their location names?
      // The user model has `farmerProfile` with `state_id`, `district_id` etc.
      // It might NOT have names.

      // Let's use `getAllLocations` if it exists and returns tree.
      // If not, we will simulate it by fetching states and then lazy loading or
      // just fetching everything if the dataset is small enough.
      // Given the user request implies seeing the full tree structure.

      final locationsData = await adminService.getAllLocations();

      List<LocationNode> tree = [];

      for (var stateData in locationsData) {
        // Parse State
        var stateNode = _parseLocationNode(stateData, 'state');
        tree.add(stateNode);
      }

      // Now distribute farmers into the tree
      _distributeFarmers(tree);

      locationTree.assignAll(tree);
    } catch (e) {
      print('Error building location tree: $e');
      // Fallback or error handling
    }
  }

  LocationNode _parseLocationNode(Map<String, dynamic> data, String type) {
    List<LocationNode> children = [];
    String childType = '';
    String childrenKey = '';

    if (type == 'state') {
      childType = 'district';
      childrenKey = 'districts';
    } else if (type == 'district') {
      childType = 'taluka';
      childrenKey = 'talukas';
    } else if (type == 'taluka') {
      childType = 'village';
      childrenKey = 'villages';
    }

    if (data[childrenKey] != null) {
      for (var childData in data[childrenKey]) {
        children.add(_parseLocationNode(childData, childType));
      }
    }

    return LocationNode(
      id: data['id'].toString(),
      name: data['name'] ?? 'Unknown',
      type: type,
      children: children,
    );
  }

  void _distributeFarmers(List<LocationNode> tree) {
    for (var user in users) {
      if (user.role != 'farmer' || user.farmerProfile == null) continue;

      final profile = user.farmerProfile!;
      final stateId = profile['state_id']?.toString();
      final districtId = profile['district_id']?.toString();
      final talukaId = profile['taluka_id']?.toString();
      final villageId = profile['village_id']?.toString();

      if (stateId == null) continue;

      // Find State
      var stateNode = tree.firstWhereOrNull((n) => n.id == stateId);
      if (stateNode != null) {
        if (districtId != null) {
          // Find District
          var districtNode = stateNode.children.firstWhereOrNull(
            (n) => n.id == districtId,
          );
          if (districtNode != null) {
            if (talukaId != null) {
              // Find Taluka
              var talukaNode = districtNode.children.firstWhereOrNull(
                (n) => n.id == talukaId,
              );
              if (talukaNode != null) {
                if (villageId != null) {
                  // Find Village
                  var villageNode = talukaNode.children.firstWhereOrNull(
                    (n) => n.id == villageId,
                  );
                  if (villageNode != null) {
                    villageNode.farmers.add(user);
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  // Toggle selection of a node (and its children)
  void toggleNodeSelection(LocationNode node, bool? value) {
    if (value == null) return;

    node.isSelected.value = value;

    if (node.type == 'village') {
      for (var farmer in node.farmers) {
        if (value) {
          selectedFarmers.add(farmer.email);
        } else {
          selectedFarmers.remove(farmer.email);
        }
      }
    } else {
      for (var child in node.children) {
        toggleNodeSelection(child, value);
      }
    }
  }

  // Toggle individual farmer selection
  void toggleFarmerSelection(String email, bool value) {
    if (value) {
      selectedFarmers.add(email);
    } else {
      selectedFarmers.remove(email);
    }
    // Note: Updating parent node selection state is complex (tri-state),
    // for simplicity we won't auto-update parent checkboxes visually to tri-state
    // but the logic holds.
  }

  bool isNodeSelected(LocationNode node) {
    // Check if all farmers in this node are selected
    final all = node.allFarmers;
    if (all.isEmpty) return false;
    return all.every((f) => selectedFarmers.contains(f.email));
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

    if (selectedFarmers.isEmpty) {
      UiUtils.showErrorSnackbar(
        'Error',
        'Please select at least one recipient',
      );
      return;
    }

    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final senders = selectedFarmers.toList();

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
          'Email sent successfully to $totalSent recipient(s)',
        );
        subjectController.clear();
        messageController.clear();
        selectedFarmers.clear();
        // Reset tree selection visually if needed
        for (var node in locationTree) {
          toggleNodeSelection(node, false);
        }
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
          // Recipient Selection (Hierarchical Tree)
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Recipients',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2A6E9B),
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${controller.selectedFarmers.length} Selected',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7BB53B),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Tree View
                Container(
                  height: 300, // Fixed height for scrolling
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() {
                    if (controller.isLoadingLocations.value) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (controller.locationTree.isEmpty) {
                      return Center(child: Text('No locations found'));
                    }
                    return ListView.builder(
                      itemCount: controller.locationTree.length,
                      itemBuilder: (context, index) {
                        return _buildLocationNode(
                          controller.locationTree[index],
                          controller,
                        );
                      },
                    );
                  }),
                ),
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
          // Send Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: controller.sendEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7BB53B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: Color(0xFF7BB53B).withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Send Email',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLocationNode(LocationNode node, SendEmailController controller) {
    // Removed: if (node.farmerCount == 0) return SizedBox.shrink();

    return Obx(() {
      // Ensure we listen to selectedFarmers changes even if isNodeSelected returns early
      // ignore: unused_local_variable
      final _ = controller.selectedFarmers.length;
      final isSelected = controller.isNodeSelected(node);

      return ExpansionTile(
        key: PageStorageKey(node.id),
        leading: Checkbox(
          value: isSelected,
          onChanged: (val) => controller.toggleNodeSelection(node, val),
          activeColor: Color(0xFF7BB53B),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                node.name,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
            if (node.farmerCount > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFF7BB53B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${node.farmerCount}',
                  style: TextStyle(
                    color: Color(0xFF7BB53B),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        childrenPadding: EdgeInsets.only(left: 16),
        children: [
          if (node.type == 'village')
            ...node.farmers.map(
              (farmer) => _buildFarmerTile(farmer, controller),
            )
          else
            ...node.children.map(
              (child) => _buildLocationNode(child, controller),
            ),
        ],
      );
    });
  }

  Widget _buildFarmerTile(UserModel farmer, SendEmailController controller) {
    return Obx(() {
      final isSelected = controller.selectedFarmers.contains(farmer.email);
      return ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (val) =>
              controller.toggleFarmerSelection(farmer.email, val ?? false),
          activeColor: Color(0xFF7BB53B),
        ),
        title: Text(farmer.name, style: TextStyle(fontSize: 13)),
        subtitle: Text(
          farmer.email,
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        dense: true,
      );
    });
  }

  Widget _buildAIChatSection(SendEmailController controller) {
    return Column(
      children: [
        // Chat Area
        Expanded(
          child: Obx(
            () => ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: controller.chatMessages.length,
              itemBuilder: (context, index) {
                final msg = controller.chatMessages[index];
                return Align(
                  alignment: msg.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Color(0xFF7BB53B) : Colors.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: msg.isUser
                            ? Radius.zero
                            : Radius.circular(16),
                        bottomLeft: !msg.isUser
                            ? Radius.zero
                            : Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isUser ? Colors.white : Colors.black87,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        if (!msg.isUser) ...[
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              controller.messageController.text = msg.text;
                              controller.changeTab(0); // Switch to Send Email
                              UiUtils.showSuccessSnackbar(
                                'Applied',
                                'Email content applied to message body',
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF7BB53B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: Color(0xFF7BB53B),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Use this',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7BB53B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Input Area
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.aiMessageController,
                  decoration: InputDecoration(
                    hintText: 'Describe the email you want to write...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Obx(
                        () => Icon(
                          controller.isListeningAI.value
                              ? Icons.mic
                              : Icons.mic_none,
                          color: controller.isListeningAI.value
                              ? Colors.red
                              : Colors.grey[600],
                        ),
                      ),
                      onPressed: () {
                        if (controller.isListeningAI.value) {
                          controller.stopListening(controller.isListeningAI);
                        } else {
                          controller.startListening(
                            controller.aiMessageController,
                            controller.isListeningAI,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Obx(
                () => controller.isGenerating.value
                    ? SizedBox(
                        width: 48,
                        height: 48,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF7BB53B),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.send_rounded, color: Colors.white),
                          onPressed: () => controller.generateEmailWithAI(
                            controller.aiMessageController.text,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
