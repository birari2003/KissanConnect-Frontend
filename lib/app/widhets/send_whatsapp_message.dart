import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shetkari/app/utils/ui_utils.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import '../services/adminServices.dart';

class WhatsAppFarmer {
  final String id;
  final String name;
  final String phone;
  final String location;

  WhatsAppFarmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
  });
}

class SendWhatsappController extends GetxController {
  final AdminService _adminService = AdminService();

  // List of farmers
  final farmers = <WhatsAppFarmer>[].obs;

  // Selected farmer IDs
  final selectedIds = <String>{}.obs;

  // Filter option
  final selectedFilter = 'all'.obs; // 'all', 'farmer', 'super_admin'

  // Message controller
  final messageController = TextEditingController();

  // Loading and sending states
  final isLoading = false.obs;
  final isSending = false.obs;

  // Speech to Text
  late stt.SpeechToText _speech;
  final isListening = false.obs;

  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
    loadFarmers();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  // Get filtered list based on selected filter
  List<WhatsAppFarmer> get filteredFarmers {
    if (selectedFilter.value == 'all') {
      return farmers;
    }
    return farmers.where((f) {
      if (selectedFilter.value == 'farmer') {
        return f.location == 'Farmer';
      } else if (selectedFilter.value == 'super_admin') {
        return f.location.startsWith('Super Admin');
      }
      return true;
    }).toList();
  }

  Future<void> loadFarmers() async {
    try {
      isLoading.value = true;

      // Fetch all users from API (farmers and super admins)
      final data = await _adminService.getAllUsers();

      // Convert to WhatsAppFarmer objects
      farmers.value = data
          .where(
            (user) => user['role'] == 'farmer' || user['role'] == 'super_admin',
          )
          .map((user) {
            // Build location based on role
            String location = 'Unknown';

            if (user['role'] == 'super_admin') {
              // For super admins, show their admin level
              final level = user['super_admin_level'] ?? 'Unknown';
              location = 'Super Admin - ${level.toUpperCase()}';
            } else {
              // For farmers, location would come from farmer profile
              location = 'Farmer';
            }

            // Ensure we have a valid ID
            final userId = user['id'];
            if (userId == null) {
              print('Warning: User has null ID: ${user['name']}');
            }

            return WhatsAppFarmer(
              id:
                  userId?.toString() ??
                  'unknown_${user['name']}_${user['phone']}',
              name: user['name'] ?? 'Unknown',
              phone: user['phone'] ?? 'N/A',
              location: location,
            );
          })
          .toList();
    } catch (e) {
      print('Error loading users: $e');
      UiUtils.showErrorSnackbar(
        'Error',
        'Failed to load users: ${e.toString().replaceAll('Exception: ', '')}',
      );
      farmers.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSelection(String id, bool? value) {
    if (value == true) {
      selectedIds.add(id);
    } else {
      selectedIds.remove(id);
    }
  }

  void selectAll() {
    // Use filteredFarmers instead of all farmers
    selectedIds.addAll(filteredFarmers.map((e) => e.id));
  }

  void clearSelection() {
    selectedIds.clear();
  }

  Future<void> sendWhatsAppMessage() async {
    final message = messageController.text.trim();

    if (selectedIds.isEmpty) {
      UiUtils.showErrorSnackbar(
        'Error',
        'Please select at least one recipient',
      );
      return;
    }

    if (message.isEmpty) {
      UiUtils.showErrorSnackbar('Error', 'Please enter a message');
      return;
    }

    isSending.value = true;

    try {
      final apiKey = 'QNVVTKKBVyqC'; // TextMeBot API key
      final encodedMessage = Uri.encodeComponent(message);

      // Get selected farmers from the full list
      final selectedFarmers = farmers
          .where((f) => selectedIds.contains(f.id))
          .toList();

      print('Sending WhatsApp to ${selectedFarmers.length} recipients');
      print('Selected IDs: $selectedIds');

      // Send WhatsApp message to each selected farmer
      int successCount = 0;
      int failCount = 0;

      for (var farmer in selectedFarmers) {
        try {
          final phoneNumber = farmer.phone.replaceAll(
            RegExp(r'[^0-9]'),
            '',
          ); // Remove non-numeric characters

          if (phoneNumber.isEmpty || phoneNumber == 'N/A') {
            print('Skipping ${farmer.name}: Invalid phone number');
            failCount++;
            continue;
          }

          final url = Uri.parse(
            'http://api.textmebot.com/send.php?recipient=+91$phoneNumber&apikey=$apiKey&text=$encodedMessage',
          );

          print('Sending to ${farmer.name} at +91$phoneNumber');
          final response = await http.get(url);

          if (response.statusCode == 200) {
            successCount++;
            print('✓ WhatsApp message sent to ${farmer.name} ($phoneNumber)');
          } else {
            failCount++;
            print('✗ Failed to send to ${farmer.name}: ${response.body}');
          }

          // Delay to comply with API rate limit (1 message per 5 seconds)
          // Using 8 seconds to be safe
          if (selectedFarmers.indexOf(farmer) < selectedFarmers.length - 1) {
            print('Waiting 6 seconds before next message...');
            await Future.delayed(Duration(seconds: 6));
          }
        } catch (e) {
          failCount++;
          print('✗ Error sending to ${farmer.name}: $e');
        }
      }

      if (successCount > 0) {
        UiUtils.showSuccessSnackbar(
          'Success',
          'WhatsApp message sent to $successCount recipient(s)${failCount > 0 ? ' ($failCount failed)' : ''}',
        );
      } else {
        UiUtils.showErrorSnackbar(
          'Error',
          'Failed to send WhatsApp messages to all recipients',
        );
      }

      messageController.clear();
      clearSelection();
    } catch (e) {
      UiUtils.showErrorSnackbar('Error', 'Failed to send WhatsApp message: $e');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> startListening() async {
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
          isListening.value = false;
        }
      },
      onError: (error) {
        isListening.value = false;
        UiUtils.showErrorSnackbar(
          'Error',
          'Voice recognition error: ${error.errorMsg}',
        );
      },
    );

    if (available) {
      isListening.value = true;
      _speech.listen(
        onResult: (result) {
          messageController.text = result.recognizedWords;
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

  void stopListening() {
    _speech.stop();
    isListening.value = false;
  }
}

class SendWhatsappWidget extends StatelessWidget {
  const SendWhatsappWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SendWhatsappController());

    return Container(
      color: Color(0xFFF5F7FA),
      child: Column(
        children: [
          // Selection toolbar
          Obx(
            () => controller.selectedIds.isNotEmpty
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF25D366).withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF25D366).withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF25D366),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${controller.selectedIds.length} selected',
                          style: TextStyle(
                            color: Color(0xFF2A6E9B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: controller.clearSelection,
                          child: Text('Clear'),
                        ),
                        TextButton(
                          onPressed: controller.selectAll,
                          child: Text('Select All'),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
          ),
          // Filter chips
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'Filter:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A6E9B),
                  ),
                ),
                SizedBox(width: 12),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: Text('All'),
                        selected: controller.selectedFilter.value == 'all',
                        onSelected: (selected) {
                          if (selected) controller.selectedFilter.value = 'all';
                        },
                        selectedColor: Color(0xFF25D366).withOpacity(0.2),
                        checkmarkColor: Color(0xFF25D366),
                      ),
                      FilterChip(
                        label: Text('Farmers'),
                        selected: controller.selectedFilter.value == 'farmer',
                        onSelected: (selected) {
                          if (selected)
                            controller.selectedFilter.value = 'farmer';
                        },
                        selectedColor: Color(0xFF25D366).withOpacity(0.2),
                        checkmarkColor: Color(0xFF25D366),
                      ),
                      FilterChip(
                        label: Text('Super Admins'),
                        selected:
                            controller.selectedFilter.value == 'super_admin',
                        onSelected: (selected) {
                          if (selected)
                            controller.selectedFilter.value = 'super_admin';
                        },
                        selectedColor: Color(0xFF25D366).withOpacity(0.2),
                        checkmarkColor: Color(0xFF25D366),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Farmers list
          Expanded(
            child: Obx(() {
              // Show loading indicator
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF25D366)),
                      SizedBox(height: 16),
                      Text(
                        'Loading farmers...',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              final list = controller.filteredFarmers;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No farmers found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final farmer = list[index];
                  return Obx(() {
                    final selected = controller.selectedIds.contains(farmer.id);
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? Color(0xFF25D366)
                              : Colors.transparent,
                          width: 2,
                        ),
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
                          CircleAvatar(
                            backgroundColor: Color(0xFF25D366).withOpacity(0.1),
                            child: Icon(Icons.person, color: Color(0xFF25D366)),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  farmer.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2A6E9B),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      farmer.phone,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Color(0xFF54B5D9),
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        farmer.location,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: selected,
                            onChanged: (v) =>
                                controller.toggleSelection(farmer.id, v),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            activeColor: Color(0xFF25D366),
                          ),
                        ],
                      ),
                    );
                  });
                },
              );
            }),
          ),
          // Message composer
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
              child: Column(
                children: [
                  // Message input
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.messageController,
                            decoration: InputDecoration(
                              hintText: 'Type your WhatsApp message...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            maxLines: 3,
                            minLines: 1,
                          ),
                        ),
                        Obx(
                          () => IconButton(
                            icon: Icon(
                              controller.isListening.value
                                  ? Icons.mic
                                  : Icons.mic_none,
                              color: controller.isListening.value
                                  ? Colors.red
                                  : Color(0xFF25D366),
                            ),
                            onPressed: () {
                              if (controller.isListening.value) {
                                controller.stopListening();
                              } else {
                                controller.startListening();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  // Send button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isSending.value
                            ? null
                            : controller.sendWhatsAppMessage,
                        icon: controller.isSending.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.send, size: 20),
                        label: Text(
                          controller.isSending.value
                              ? 'Sending...'
                              : 'Send WhatsApp Message',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
