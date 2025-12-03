import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../utils/ui_utils.dart';

class GlobalChatbotController extends GetxController {
  final chatMessages = <GlobalChatMessage>[].obs;
  final messageController = TextEditingController();
  final isGenerating = false.obs;
  final isOpen = false.obs; // Controls visibility of the chat window
  final isVisible = true
      .obs; // Controls visibility of the entire widget (FAB + Window) based on route

  final List<String> excludedRoutes = [
    '/splashscreen',
    '/farmerscreendashboard',
    '/login',
    '/register',
    '/selectlanguage',
    '/view-demo',
    '/otp-verification',
    '/forgot-password',
    '/initial-screen',
  ];

  void checkVisibility(String? route) {
    if (route == null) return;
    // Check if the current route is in the excluded list
    // We check if the route STARTS with the excluded string to handle arguments if any,
    // though GetX usually puts args separately.
    // Exact match is safer for now unless we have sub-routes.

    // Normalize route (remove leading slash if needed or handle consistency)
    // GetX routes usually start with /

    bool shouldHide = excludedRoutes.any(
      (excluded) => route == excluded || route.startsWith('$excluded/'),
    );

    // Schedule the update to avoid "setState() called during build" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isVisible.value = !shouldHide;
    });
  }

  // Speech to Text
  late stt.SpeechToText _speech;
  final isListening = false.obs;

  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  void toggleChat() {
    isOpen.value = !isOpen.value;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    chatMessages.add(GlobalChatMessage(text: text, isUser: true));
    messageController.clear();
    isGenerating.value = true;

    const apiKey = '37cc701d-6e56-4ced-b116-d8a482f16b7c';
    final url = Uri.parse('https://api.sambanova.ai/v1/chat/completions');

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
                  'You are a helpful assistant for the KissanConnect app. Answer questions concisely and helpfully.',
            },
            {'role': 'user', 'content': text},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final aiResponse = responseData['choices'][0]['message']['content'];

        chatMessages.add(GlobalChatMessage(text: aiResponse, isUser: false));
      } else {
        throw Exception(
          'Failed to get response from API: ${response.statusCode}',
        );
      }
    } catch (e) {
      chatMessages.add(
        GlobalChatMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
        ),
      );
      print('Chatbot Error: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> startListening() async {
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
        // Don't show snackbar for every error to avoid spamming
        print('Voice error: ${error.errorMsg}');
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
    }
  }

  void stopListening() {
    _speech.stop();
    isListening.value = false;
  }
}

class GlobalChatMessage {
  final String text;
  final bool isUser;

  GlobalChatMessage({required this.text, required this.isUser});
}
