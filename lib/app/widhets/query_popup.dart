import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../utils/ui_utils.dart';
import '../services/farmerServices.dart';

class QueryPopupController extends GetxController {
  final FarmerService _farmerService = FarmerService();
  final queryController = TextEditingController();

  // Speech to Text
  late stt.SpeechToText _speech;
  final isListening = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
  }

  @override
  void onClose() {
    queryController.dispose();
    super.onClose();
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
          queryController.text = result.recognizedWords;
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

  Future<void> submitQuery() async {
    final query = queryController.text.trim();

    if (query.isEmpty) {
      UiUtils.showErrorSnackbar('Error', 'Please enter your query');
      return;
    }

    isSubmitting.value = true;

    try {
      await _farmerService.submitQuery(query);

      UiUtils.showSuccessSnackbar(
        'Success',
        'Your query has been submitted. Admin will respond soon.',
      );

      queryController.clear();
      Get.back(); // Close the popup
    } catch (e) {
      UiUtils.showErrorSnackbar(
        'Error',
        'Failed to submit query: ${e.toString().replaceAll('Exception: ', '')}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}

class QueryPopup extends StatelessWidget {
  const QueryPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QueryPopupController());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFF5CC96F).withOpacity(0.05)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E8B57), Color(0xFF5CC96F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.question_answer,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ask Your Query',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Type or speak your question',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Query input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: controller.queryController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Enter your question or issue here...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Obx(
                                () => controller.isListening.value
                                    ? Row(
                                        children: [
                                          Icon(
                                            Icons.mic,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Listening...',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Tap mic to speak',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                              ),
                              Spacer(),
                              Obx(
                                () => Material(
                                  color: controller.isListening.value
                                      ? Colors.red.withOpacity(0.1)
                                      : Color(0xFF2E8B57).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    onTap: () {
                                      if (controller.isListening.value) {
                                        controller.stopListening();
                                      } else {
                                        controller.startListening();
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        controller.isListening.value
                                            ? Icons.mic
                                            : Icons.mic_none,
                                        color: controller.isListening.value
                                            ? Colors.red
                                            : Color(0xFF2E8B57),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Submit button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : controller.submitQuery,
                        icon: controller.isSubmitting.value
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
                          controller.isSubmitting.value
                              ? 'Submitting...'
                              : 'Submit Query',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E8B57),
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
          ],
        ),
      ),
    );
  }
}
