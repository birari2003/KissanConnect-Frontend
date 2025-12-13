import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../utils/ui_utils.dart';
import '../services/farmerServices.dart';

class CropComplaintController extends GetxController {
  final FarmerService _farmerService = FarmerService();
  final complaintController = TextEditingController();

  // Crop information
  final int cropId;
  final int sellerId;
  final String cropName;

  // Speech to Text
  late stt.SpeechToText _speech;
  final isListening = false.obs;
  final isSubmitting = false.obs;

  CropComplaintController({
    required this.cropId,
    required this.sellerId,
    required this.cropName,
  });

  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
  }

  @override
  void onClose() {
    complaintController.dispose();
    super.onClose();
  }

  Future<void> startListening() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      UiUtils.showErrorSnackbar(
        translate('permission_denied'),
        translate('microphone_permission_required'),
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
          translate('error'),
          '${translate('voice_recognition_error')}: ${error.errorMsg}',
        );
      },
    );

    if (available) {
      isListening.value = true;
      _speech.listen(
        onResult: (result) {
          complaintController.text = result.recognizedWords;
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
      );
    } else {
      UiUtils.showErrorSnackbar(
        translate('error'),
        translate('speech_recognition_not_available'),
      );
    }
  }

  void stopListening() {
    _speech.stop();
    isListening.value = false;
  }

  Future<void> submitComplaint() async {
    final complaint = complaintController.text.trim();

    if (complaint.isEmpty) {
      UiUtils.showErrorSnackbar(
        translate('error'),
        translate('please_enter_complaint'),
      );
      return;
    }

    isSubmitting.value = true;

    try {
      await _farmerService.submitCropComplaint(
        againstUserId: sellerId,
        complaintText: complaint,
      );

      UiUtils.showSuccessSnackbar(
        translate('success'),
        translate('complaint_submitted_success'),
      );

      complaintController.clear();

      // Delay closing the popup to ensure success message is visible
      await Future.delayed(Duration(milliseconds: 500));
      Get.back(); // Close the popup
    } catch (e) {
      UiUtils.showErrorSnackbar(
        translate('error'),
        '${translate('failed_to_submit_complaint')}: ${e.toString().replaceAll('Exception: ', '')}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}

class CropComplaintPopup extends StatelessWidget {
  final int cropId;
  final int sellerId;
  final String cropName;

  const CropComplaintPopup({
    super.key,
    required this.cropId,
    required this.sellerId,
    required this.cropName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CropComplaintController(
        cropId: cropId,
        sellerId: sellerId,
        cropName: cropName,
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color.fromARGB(255, 245, 117, 58).withOpacity(0.02),
            ],
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
                  colors: [
                    Color.fromARGB(255, 245, 117, 58),
                    Color.fromARGB(255, 245, 117, 58).withOpacity(0.5),
                  ],
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
                      Icons.report_problem,
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
                          translate('file_complaint'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${translate('report_issue_with')}: $cropName',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  // Complaint input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: controller.complaintController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: translate('describe_crop_issue'),
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
                                            color: Color.fromARGB(
                                              255,
                                              245,
                                              117,
                                              58,
                                            ),
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            translate('listening'),
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                245,
                                                117,
                                                58,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        translate('tap_mic_to_speak'),
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
                                      ? Color.fromARGB(
                                          255,
                                          245,
                                          117,
                                          58,
                                        ).withOpacity(0.1)
                                      : Colors.grey[200],
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
                                            ? Color.fromARGB(255, 245, 117, 58)
                                            : Colors.grey[700],
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
                            : controller.submitComplaint,
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
                              ? translate('submitting')
                              : translate('submit_complaint'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 245, 117, 58),
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
