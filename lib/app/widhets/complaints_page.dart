import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../utils/ui_utils.dart';
import '../services/farmerServices.dart';
import '../services/translation_service.dart';
import '../controllers/global_chatbot_controller.dart';

class ComplaintsController extends GetxController {
  final FarmerService _farmerService = FarmerService();
  final TranslationService _translationService = TranslationService();

  // Form controllers
  final againstNameController = TextEditingController();
  final againstContactController = TextEditingController();
  final complaintTextController = TextEditingController();

  final complaints = <dynamic>[].obs;
  final queries = <dynamic>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final showComplaints =
      true.obs; // Toggle state: true = complaints, false = queries

  // Speech to Text
  late stt.SpeechToText _speech;
  final isListening = false.obs;

  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
    fetchComplaints();
    fetchQueries();

    // Hide global chatbot when on complaints page
    // Schedule after build to avoid setState during build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final chatbotController = Get.find<GlobalChatbotController>();
        chatbotController.isVisible.value = false;
      } catch (e) {
        // Chatbot controller might not be initialized
        print('Chatbot controller not found: $e');
      }
    });
  }

  @override
  void onClose() {
    // Show global chatbot again when leaving complaints page
    try {
      final chatbotController = Get.find<GlobalChatbotController>();
      chatbotController.isVisible.value = true;
    } catch (e) {
      print('Chatbot controller not found: $e');
    }

    againstNameController.dispose();
    againstContactController.dispose();
    complaintTextController.dispose();
    super.onClose();
  }

  Future<void> fetchComplaints() async {
    isLoading.value = true;
    try {
      final fetchedComplaints = await _farmerService.getMyComplaints();
      complaints.assignAll(fetchedComplaints);
    } catch (e) {
      print('Error fetching complaints: $e');
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('failed_to_load_complaints'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchQueries() async {
    isLoading.value = true;
    try {
      final fetchedQueries = await _farmerService.getMyQueries();
      queries.assignAll(fetchedQueries);
    } catch (e) {
      print('Error fetching queries: $e');
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('failed_to_load_queries'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleView() {
    showComplaints.value = !showComplaints.value;
  }

  /// Translates API response text to the user's current language
  Future<String> translateApiText(String text) async {
    if (text.isEmpty) return text;

    try {
      // Get current locale from flutter_translate
      final currentLocale = LocalizedApp.of(
        Get.context!,
      ).delegate.currentLocale;
      final languageCode = currentLocale.languageCode;

      // Translate the text
      return await _translationService.translateText(text, languageCode);
    } catch (e) {
      print('Error translating text: $e');
      return text; // Return original text if translation fails
    }
  }

  Future<void> startListening() async {
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
      },
    );

    if (available) {
      isListening.value = true;
      _speech.listen(
        onResult: (result) {
          complaintTextController.text = result.recognizedWords;
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

  Future<void> searchFarmerByContact() async {
    final contact = againstContactController.text.trim();

    if (contact.isEmpty) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('please_enter_farmer_contact'),
      );
      return;
    }

    // Validate phone number (10 digits)
    if (!RegExp(r'^\d{10}$').hasMatch(contact)) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('invalid_phone_number'),
      );
      return;
    }

    isLoading.value = true;
    try {
      // Search for farmer by contact number
      final result = await _farmerService.searchFarmerByContact(contact);

      if (result != null && result['id'] != null) {
        // Auto-fill the name
        againstNameController.text = result['name'] ?? '';

        UiUtils.showSuccessSnackbar(
          translate('success'),
          '${translate('farmer_found')}: ${result['name']}',
        );
      } else {
        UiUtils.showErrorSnackbar(
          translate('error_title'),
          translate('farmer_not_found'),
        );
      }
    } catch (e) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('farmer_not_found'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitComplaint() async {
    final againstContact = againstContactController.text.trim();
    final complaintText = complaintTextController.text.trim();

    if (againstContact.isEmpty) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('please_enter_farmer_contact'),
      );
      return;
    }

    // Validate phone number (10 digits)
    if (!RegExp(r'^\d{10}$').hasMatch(againstContact)) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('invalid_phone_number'),
      );
      return;
    }

    if (complaintText.isEmpty) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('please_enter_complaint_details'),
      );
      return;
    }

    if (complaintText.length < 10) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('complaint_too_short'),
      );
      return;
    }

    isSubmitting.value = true;

    try {
      // First, get the user ID by contact number
      final farmerResult = await _farmerService.searchFarmerByContact(
        againstContact,
      );

      if (farmerResult == null || farmerResult['id'] == null) {
        throw Exception(translate('farmer_not_found'));
      }

      final againstUserId = farmerResult['id'];

      // Now submit the complaint with the user ID
      await _farmerService.submitCropComplaint(
        againstUserId: againstUserId,
        complaintText: complaintText,
      );

      UiUtils.showSuccessSnackbar(
        translate('success'),
        translate('complaint_submitted_success'),
      );

      againstNameController.clear();
      againstContactController.clear();
      complaintTextController.clear();

      // Refresh complaints list
      await fetchComplaints();
    } catch (e) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        '${translate('failed_to_submit_complaint')}: ${e.toString().replaceAll('Exception: ', '')}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}

class ComplaintsPage extends StatelessWidget {
  const ComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ComplaintsController());

    return Container(
      color: Color(0xFFF5F7FA),
      child: Column(
        children: [
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Submit Complaint Form
                  _buildComplaintForm(controller),

                  SizedBox(height: 24),

                  // My Complaints List
                  _buildComplaintsList(controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintForm(ComplaintsController controller) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate('file_complaint_against_farmer'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D323A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            translate('complaint_form_description'),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 20),

          // Against Farmer Name
          TextField(
            controller: controller.againstNameController,
            decoration: InputDecoration(
              labelText: translate('farmer_name_label'),
              hintText: translate('farmer_name_hint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.person, color: Color(0xFF2E8B57)),
            ),
          ),
          SizedBox(height: 16),

          // Against Farmer Contact
          TextField(
            controller: controller.againstContactController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: translate('farmer_contact_label'),
              hintText: translate('farmer_contact_hint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.phone, color: Color(0xFF2E8B57)),
              counterText: '',
            ),
          ),
          SizedBox(height: 16),

          // Complaint Details
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    translate('complaint_details_label'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextField(
                  controller: controller.complaintTextController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: translate('complaint_details_hint'),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
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
                                  Icon(Icons.mic, color: Colors.red, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    translate('listening'),
                                    style: TextStyle(
                                      color: Colors.red,
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

          // Submit Button
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
    );
  }

  Widget _buildComplaintsList(ComplaintsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle Buttons
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
              Expanded(
                child: Obx(
                  () => Material(
                    color: controller.showComplaints.value
                        ? Color(0xFF2E8B57)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        if (!controller.showComplaints.value) {
                          controller.toggleView();
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            translate('my_complaints'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: controller.showComplaints.value
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Obx(
                  () => Material(
                    color: !controller.showComplaints.value
                        ? Color(0xFF2E8B57)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        if (controller.showComplaints.value) {
                          controller.toggleView();
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            translate('my_queries'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: !controller.showComplaints.value
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

        // Content based on toggle
        Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.showComplaints.value) {
            // Show Complaints
            if (controller.complaints.isEmpty) {
              return Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                      SizedBox(height: 16),
                      Text(
                        translate('no_complaints_yet'),
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.complaints.length,
              itemBuilder: (context, index) {
                final complaint = controller.complaints[index];
                return _buildComplaintCard(complaint);
              },
            );
          } else {
            // Show Queries
            if (controller.queries.isEmpty) {
              return Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                      SizedBox(height: 16),
                      Text(
                        translate('no_queries_yet'),
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.queries.length,
              itemBuilder: (context, index) {
                final query = controller.queries[index];
                return _buildQueryCard(query);
              },
            );
          }
        }),
      ],
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final controller = Get.find<ComplaintsController>();
    final status = complaint['status'] ?? 'pending';
    final Color statusColor = status == 'resolved'
        ? Colors.green
        : status == 'under_review'
        ? Colors.orange
        : status == 'dismissed'
        ? Colors.red
        : Colors.grey;

    // Prepare texts that need translation - convert to String to handle int/String types
    final againstName = (complaint['against_name'] ?? '').toString();
    final complaintText = (complaint['complaint_text'] ?? '').toString();

    return FutureBuilder<Map<String, String>>(
      future:
          Future.wait([
            controller.translateApiText(againstName),
            controller.translateApiText(complaintText),
          ]).then(
            (translations) => {
              'againstName': translations[0],
              'complaintText': translations[1],
            },
          ),
      builder: (context, snapshot) {
        // Use original text while loading or if translation fails
        final translatedAgainstName =
            snapshot.data?['againstName'] ?? againstName;
        final translatedComplaintText =
            snapshot.data?['complaintText'] ?? complaintText;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${translate('against')}: ${translatedAgainstName.isEmpty ? translate('unknown') : translatedAgainstName}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D323A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          complaint['against_contact'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      translate('complaint_status_$status'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                translatedComplaintText,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  SizedBox(width: 4),
                  Text(
                    complaint['created_at'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQueryCard(Map<String, dynamic> query) {
    final controller = Get.find<ComplaintsController>();
    final status = query['status'] ?? 'pending';
    final Color statusColor = status == 'resolved'
        ? Colors.green
        : status == 'under_review'
        ? Colors.orange
        : status == 'dismissed'
        ? Colors.red
        : Colors.grey;

    final hasAdminResponse =
        query['admin_response'] != null &&
        query['admin_response'].toString().isNotEmpty;

    // Prepare all texts that need translation - convert to String to handle int/String types
    final description = (query['description'] ?? '').toString();
    final adminResponse = (query['admin_response'] ?? '').toString();

    return FutureBuilder<Map<String, String>>(
      future:
          Future.wait([
            controller.translateApiText(description),
            controller.translateApiText(adminResponse),
          ]).then(
            (translations) => {
              'description': translations[0],
              'adminResponse': translations[1],
            },
          ),
      builder: (context, snapshot) {
        // Use original text while loading or if translation fails
        final translatedDescription =
            snapshot.data?['description'] ?? description;
        final translatedAdminResponse =
            snapshot.data?['adminResponse'] ?? adminResponse;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
              // Header with Status only
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      translate('query_status_$status'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Query Description (Translated)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translate('your_query'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      translatedDescription,
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),

              // Admin Response (Translated, if available)
              if (hasAdminResponse) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF2E8B57).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(0xFF2E8B57).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            size: 16,
                            color: Color(0xFF2E8B57),
                          ),
                          SizedBox(width: 6),
                          Text(
                            translate('admin_response'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E8B57),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        translatedAdminResponse,
                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
