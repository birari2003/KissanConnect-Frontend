import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../controllers/global_chatbot_controller.dart';

class GlobalChatbotWidget extends StatelessWidget {
  final Widget child;

  const GlobalChatbotWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GlobalChatbotController(), permanent: true);

    return Stack(
      children: [
        child,
        // Floating Action Button
        Obx(() {
          if (!controller.isVisible.value) return SizedBox.shrink();
          return Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => _showChatDialog(controller),
              backgroundColor: Color(0xFF7BB53B),
              child: Icon(Icons.chat, color: Colors.white),
              elevation: 4,
            ),
          );
        }),
      ],
    );
  }

  void _showChatDialog(GlobalChatbotController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          height: 500,
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF7BB53B),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.smart_toy, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          translate('app_title'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Messages
              Expanded(
                child: Obx(() {
                  if (controller.chatMessages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 16),
                          Text(
                            translate('chatbot_greeting'),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: controller.chatMessages.length,
                    itemBuilder: (context, index) {
                      final msg = controller.chatMessages[index];
                      return Align(
                        alignment: msg.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(12),
                          constraints: BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: msg.isUser
                                ? Color(0xFF7BB53B)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12).copyWith(
                              bottomRight: msg.isUser
                                  ? Radius.zero
                                  : Radius.circular(12),
                              bottomLeft: msg.isUser
                                  ? Radius.circular(12)
                                  : Radius.zero,
                            ),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: msg.isUser ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              // Input Area
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.messageController,
                        decoration: InputDecoration(
                          hintText: translate('chatbot_input_hint'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onSubmitted: (text) => controller.sendMessage(text),
                      ),
                    ),
                    SizedBox(width: 8),
                    Obx(
                      () => IconButton(
                        icon: Icon(
                          controller.isListening.value
                              ? Icons.mic
                              : Icons.mic_none,
                          color: controller.isListening.value
                              ? Colors.red
                              : Color(0xFF7BB53B),
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
                    Obx(
                      () => controller.isGenerating.value
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF7BB53B),
                              ),
                            )
                          : IconButton(
                              icon: Icon(Icons.send, color: Color(0xFF7BB53B)),
                              onPressed: () => controller.sendMessage(
                                controller.messageController.text,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
