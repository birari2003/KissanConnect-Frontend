import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AdminMessage {
  final String id;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  AdminMessage({
    required this.id,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

class AdminMessagesController extends GetxController {
  final messages = <AdminMessage>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }

  void loadMessages() {
    // Mock data - replace with API call
    messages.value = [
      AdminMessage(
        id: '1',
        message: 'Let\'s have a meeting at 10 AM on 19th September 2025 to discuss the new farming initiatives.',
        timestamp: DateTime(2025, 9, 15, 14, 30),
        isRead: false,
      ),
      AdminMessage(
        id: '2',
        message: 'Please submit your monthly report by the end of this week. Include all farmer registrations and training sessions conducted.',
        timestamp: DateTime(2025, 9, 14, 9, 15),
        isRead: true,
      ),
      AdminMessage(
        id: '3',
        message: 'New government subsidy scheme has been launched. Please inform all farmers in your region about the benefits and application process.',
        timestamp: DateTime(2025, 9, 13, 16, 45),
        isRead: true,
      ),
      AdminMessage(
        id: '4',
        message: 'Training program on organic farming will be conducted next month. Coordinate with farmers and ensure maximum participation.',
        timestamp: DateTime(2025, 9, 12, 11, 20),
        isRead: true,
      ),
      AdminMessage(
        id: '5',
        message: 'Reminder: Update farmer database with latest crop information and contact details.',
        timestamp: DateTime(2025, 9, 10, 8, 0),
        isRead: true,
      ),
    ];
  }

  void copyMessage(String message) {
    Clipboard.setData(ClipboardData(text: message));
    Get.snackbar(
      'Copied',
      'Message copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF7BB53B).withOpacity(0.1),
      duration: Duration(seconds: 2),
    );
  }

  void markAsRead(String id) {
    final index = messages.indexWhere((m) => m.id == id);
    if (index != -1) {
      messages[index] = AdminMessage(
        id: messages[index].id,
        message: messages[index].message,
        timestamp: messages[index].timestamp,
        isRead: true,
      );
      messages.refresh();
    }
  }
}

class AdminMessagesWidget extends StatelessWidget {
  const AdminMessagesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminMessagesController());

    return Container(
      color: Color(0xFFF5F7FA),
      child: Obx(() {
        final messageList = controller.messages;
        if (messageList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message_outlined, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No messages from admin',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: messageList.length,
          itemBuilder: (context, index) {
            final message = messageList[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isRead ? Colors.white : Color(0xFF54B5D9).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: message.isRead ? Colors.transparent : Color(0xFF54B5D9).withOpacity(0.3),
                  width: 1,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFF2A6E9B).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Color(0xFF2A6E9B),
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                message.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2A6E9B),
                                  height: 1.5,
                                ),
                              ),
                            ),
                            if (!message.isRead)
                              Container(
                                width: 10,
                                height: 10,
                                margin: EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF54B5D9),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              _formatTimestamp(message.timestamp),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            Spacer(),
                            Material(
                              color: Color(0xFF7BB53B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () {
                                  controller.copyMessage(message.message);
                                  if (!message.isRead) {
                                    controller.markAsRead(message.id);
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.copy, size: 16, color: Color(0xFF7BB53B)),
                                      SizedBox(width: 4),
                                      Text(
                                        'Copy',
                                        style: TextStyle(
                                          color: Color(0xFF7BB53B),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
