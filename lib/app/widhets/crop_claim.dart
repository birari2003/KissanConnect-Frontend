import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_translate/flutter_translate.dart';
import 'dart:ui';
import '../utils/ui_utils.dart';
import '../utils/api.dart';

import '../services/farmerServices.dart';
import '../services/translation_service.dart';
import '../controllers/subscription_controller.dart';
import '../controllers/payment_controller.dart';

class CropClaimController extends GetxController {
  final cropNameController = TextEditingController();
  final messageController = TextEditingController();

  final attachedFiles = <ClaimAttachment>[].obs;
  final isSending = false.obs;
  final myClaims = <dynamic>[].obs;
  final isLoadingClaims = false.obs;
  final TranslationService _translationService = TranslationService();

  Future<String> _translateIfNeed(String text) async {
    try {
      String languageCode = 'en';
      if (Get.context != null) {
        try {
          languageCode = LocalizedApp.of(
            Get.context!,
          ).delegate.currentLocale.languageCode;
        } catch (e) {
          // Fallback or ignore
        }
      }
      return await _translationService.translateText(text, languageCode);
    } catch (e) {
      print('Error translating: $e');
      return text;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchClaims();
  }

  @override
  void onClose() {
    cropNameController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      attachedFiles.add(
        ClaimAttachment(
          name: image.name,
          path: image.path,
          type: ClaimFileType.image,
          size: await File(image.path).length(),
        ),
      );
    }
  }

  Future<void> pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      attachedFiles.add(
        ClaimAttachment(
          name: video.name,
          path: video.path,
          type: ClaimFileType.video,
          size: await File(video.path).length(),
        ),
      );
    }
  }

  void removeFile(int index) {
    attachedFiles.removeAt(index);
  }

  Future<void> submitClaim() async {
    // Check subscription status and claim limit for unsubscribed users
    final subscriptionController = Get.put(SubscriptionController());
    if (!subscriptionController.isSubscribed.value && myClaims.length >= 1) {
      _showLimitExceededPopup();
      return;
    }

    final cropName = cropNameController.text.trim();
    final message = messageController.text.trim();

    if (cropName.isEmpty) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('enter_crop_name_error'),
      );
      return;
    }

    if (message.isEmpty) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('enter_claim_details_error'),
      );
      return;
    }

    if (attachedFiles.isEmpty) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('attach_evidence_error'),
      );
      return;
    }

    isSending.value = true;

    try {
      String? evidencePath;
      if (attachedFiles.isNotEmpty) {
        evidencePath = attachedFiles.first.path;
      }

      await FarmerService().addCropClaim(cropName, message, evidencePath);

      UiUtils.showSuccessSnackbar(
        translate('success_title'),
        translate('claim_submitted_success'),
      );

      // Clear form
      cropNameController.clear();
      messageController.clear();
      attachedFiles.clear();

      // Refresh claims list
      fetchClaims();
    } catch (e) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('claim_submission_failed', args: {'error': e.toString()}),
      );
    } finally {
      isSending.value = false;
    }
  }

  void _showLimitExceededPopup() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7BB53B).withOpacity(0.1),
                Color(0xFF54B5D9).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Premium Icon
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7BB53B), Color(0xFF54B5D9)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF7BB53B).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.workspace_premium,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),

              // Title
              Text(
                translate('claim_limit_exceeded_title'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A6E9B),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),

              // Message
              Text(
                translate('claim_limit_exceeded_message'),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              // Premium Features
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFF7BB53B).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    _buildFeatureRow(
                      Icons.check_circle,
                      translate('unlimited_claims'),
                    ),
                    SizedBox(height: 8),
                    _buildFeatureRow(
                      Icons.contact_phone,
                      translate('view_all_contacts'),
                    ),
                    SizedBox(height: 8),
                    _buildFeatureRow(
                      Icons.support_agent,
                      translate('priority_support'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF7BB53B),
                        side: BorderSide(color: Color(0xFF7BB53B)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        translate('maybe_later_button'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final paymentController = Get.put(PaymentController());
                        await paymentController.startPayment();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF7BB53B),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        translate('subscribe_now'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF7BB53B), size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2A6E9B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> fetchClaims() async {
    isLoadingClaims.value = true;
    try {
      final claims = await FarmerService().getClaims();

      // Translate claims data
      for (var claim in claims) {
        if (claim['crop_name'] != null) {
          claim['crop_name'] = await _translateIfNeed(claim['crop_name']);
        }
        if (claim['claim_details'] != null) {
          claim['claim_details'] = await _translateIfNeed(
            claim['claim_details'],
          );
        }
        // Translate status if it matches known static keys, otherwise dynamic translation
        if (claim['status'] != null) {
          String status = claim['status'].toString().toLowerCase();
          if (status == 'pending') {
            claim['status'] = translate('pending_status');
          } else if (status == 'approved') {
            claim['status'] = translate('approved');
          } else if (status == 'rejected') {
            claim['status'] = translate('rejected');
          } else {
            claim['status'] = await _translateIfNeed(claim['status']);
          }
        }
      }

      myClaims.assignAll(claims);
    } catch (e) {
      print('Error fetching claims: $e');
    } finally {
      isLoadingClaims.value = false;
    }
  }

  // Edit crop claim
  Future<void> editClaim(Map<String, dynamic> claim) async {
    final editCropNameController = TextEditingController(
      text: claim['crop_name'],
    );
    final editMessageController = TextEditingController(
      text: claim['claim_details'],
    );
    final editAttachedFiles = <ClaimAttachment>[].obs;

    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.height * 0.8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7BB53B).withOpacity(0.05),
                Color(0xFF54B5D9).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      translate('edit_claim'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A6E9B),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Crop Name Field
                Text(
                  translate('crop_name_label'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A6E9B),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: editCropNameController,
                  decoration: InputDecoration(
                    hintText: translate('crop_name_hint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFF7BB53B),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Claim Details Field
                Text(
                  translate('claim_details_label'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A6E9B),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: editMessageController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: translate('claim_details_hint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFF7BB53B),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Evidence Update
                Text(
                  translate('update_evidence'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A6E9B),
                  ),
                ),
                SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      editAttachedFiles.clear();
                      editAttachedFiles.add(
                        ClaimAttachment(
                          name: image.name,
                          path: image.path,
                          type: ClaimFileType.image,
                          size: await File(image.path).length(),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.image),
                  label: Text(translate('change_evidence')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF7BB53B),
                    side: BorderSide(color: Color(0xFF7BB53B)),
                  ),
                ),
                SizedBox(height: 8),
                Obx(() {
                  if (editAttachedFiles.isEmpty) {
                    return Text(
                      translate('current_evidence_kept'),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    );
                  }
                  return Text(
                    '${translate('new_evidence')}: ${editAttachedFiles.first.name}',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7BB53B)),
                  );
                }),
                SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[400]!),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(translate('cancel')),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final cropName = editCropNameController.text.trim();
                          final claimDetails = editMessageController.text
                              .trim();

                          if (cropName.isEmpty || claimDetails.isEmpty) {
                            UiUtils.showErrorSnackbar(
                              translate('error_title'),
                              translate('fill_all_fields'),
                            );
                            return;
                          }

                          try {
                            Get.back(); // Close dialog

                            // Show loading
                            Get.dialog(
                              Center(child: CircularProgressIndicator()),
                              barrierDismissible: false,
                            );

                            await FarmerService().updateCropClaim(
                              claimId: claim['id'],
                              cropName: cropName,
                              claimDetails: claimDetails,
                              newEvidencePath: editAttachedFiles.isNotEmpty
                                  ? editAttachedFiles.first.path
                                  : null,
                            );

                            Get.back(); // Close loading
                            UiUtils.showSuccessSnackbar(
                              translate('success_title'),
                              translate('claim_updated_success'),
                            );
                            fetchClaims();
                          } catch (e) {
                            Get.back(); // Close loading
                            UiUtils.showErrorSnackbar(
                              translate('error_title'),
                              e.toString(),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7BB53B),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(translate('update')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Delete crop claim
  Future<void> deleteClaim(Map<String, dynamic> claim) async {
    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 60),
              SizedBox(height: 16),
              Text(
                translate('delete_claim_title'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A6E9B),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                translate('delete_claim_message'),
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(translate('cancel')),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(translate('delete')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    if (confirmed == true) {
      try {
        // Show loading
        Get.dialog(
          Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        await FarmerService().deleteCropClaim(claim['id']);
        Get.back(); // Close loading
        UiUtils.showSuccessSnackbar(
          translate('success_title'),
          translate('claim_deleted_success'),
        );
        fetchClaims();
      } catch (e) {
        Get.back(); // Close loading
        UiUtils.showErrorSnackbar(translate('error_title'), e.toString());
      }
    }
  }
}

class ClaimAttachment {
  final String name;
  final String path;
  final ClaimFileType type;
  final int size;

  ClaimAttachment({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
  });
}

enum ClaimFileType { image, video }

class CropClaimWidget extends StatelessWidget {
  const CropClaimWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CropClaimController());

    return Container(
      color: Color(0xFFF5F7FA),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7BB53B), Color(0xFF54B5D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF7BB53B).withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.agriculture,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate('crop_claim_title'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          translate('crop_claim_subtitle'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Crop Name
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.grass, color: Color(0xFF7BB53B), size: 20),
                      SizedBox(width: 8),
                      Text(
                        translate('crop_name_label'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2A6E9B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: controller.cropNameController,
                    decoration: InputDecoration(
                      hintText: translate('crop_name_hint'),
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
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Claim Details
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Color(0xFF2A6E9B),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        translate('claim_details_label'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2A6E9B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: controller.messageController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: translate('claim_details_hint'),
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
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Attachments
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        color: Color(0xFF2A6E9B),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        translate('evidence_label'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2A6E9B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.pickImage,
                          icon: Icon(Icons.image, size: 20),
                          label: Text(translate('add_photo')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF7BB53B),
                            side: BorderSide(color: Color(0xFF7BB53B)),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.pickVideo,
                          icon: Icon(Icons.videocam, size: 20),
                          label: Text(translate('add_video')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF54B5D9),
                            side: BorderSide(color: Color(0xFF54B5D9)),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Obx(() {
                    if (controller.attachedFiles.isEmpty) {
                      return Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 8),
                              Text(
                                translate('no_files_attached'),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                translate('add_evidence_hint'),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: controller.attachedFiles.asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final file = entry.value;
                        return _buildFileCard(file, index, controller);
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Submit Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isSending.value
                      ? null
                      : controller.submitClaim,
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
                        ? translate('submitting')
                        : translate('submit_claim'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7BB53B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    disabledBackgroundColor: Colors.grey[400],
                  ),
                ),
              ),
            ),

            SizedBox(height: 32),

            // My Claims Section
            Text(
              translate('my_claims'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A6E9B),
              ),
            ),
            SizedBox(height: 16),

            Obx(() {
              if (controller.isLoadingClaims.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.myClaims.isEmpty) {
                return Center(
                  child: Text(
                    translate('no_claims_yet'),
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: controller.myClaims
                    .map(
                      (claim) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      claim['crop_name'] ??
                                          translate('unknown_crop'),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2A6E9B),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (claim['status'] == 'approved')
                                          ? Colors.green.withOpacity(0.1)
                                          : (claim['status'] == 'rejected')
                                          ? Colors.red.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      (claim['status'] ?? 'pending')
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: (claim['status'] == 'approved')
                                            ? Colors.green
                                            : (claim['status'] == 'rejected')
                                            ? Colors.red
                                            : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                claim['claim_details'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Edit and Delete buttons
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () =>
                                            controller.editClaim(claim),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(
                                              0xFF7BB53B,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                size: 16,
                                                color: Color(0xFF7BB53B),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                translate('edit'),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF7BB53B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      InkWell(
                                        onTap: () =>
                                            controller.deleteClaim(claim),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                size: 16,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                translate('delete'),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // View Details button
                                  InkWell(
                                    onTap: () => Get.to(
                                      () => ClaimDetailView(claim: claim),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFF2A6E9B,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            translate('view_details'),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2A6E9B),
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 16,
                                            color: Color(0xFF2A6E9B),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            }),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
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
      child: child,
    );
  }

  Widget _buildFileCard(
    ClaimAttachment file,
    int index,
    CropClaimController controller,
  ) {
    final sizeInMB = (file.size / (1024 * 1024)).toStringAsFixed(2);

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: file.type == ClaimFileType.video
            ? Color(0xFF54B5D9).withOpacity(0.05)
            : Color(0xFF7BB53B).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: file.type == ClaimFileType.video
              ? Color(0xFF54B5D9).withOpacity(0.2)
              : Color(0xFF7BB53B).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: file.type == ClaimFileType.video
                  ? Color(0xFF54B5D9).withOpacity(0.1)
                  : Color(0xFF7BB53B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              file.type == ClaimFileType.video ? Icons.videocam : Icons.image,
              color: file.type == ClaimFileType.video
                  ? Color(0xFF54B5D9)
                  : Color(0xFF7BB53B),
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A6E9B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  '$sizeInMB MB',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => controller.removeFile(index),
            icon: Icon(Icons.close, color: Colors.red),
            padding: EdgeInsets.all(4),
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class ClaimDetailView extends StatelessWidget {
  final Map<String, dynamic> claim;

  const ClaimDetailView({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    final String imageBaseUrl = ApiConfig.getBaseUrl();
    final evidencePath = claim['evidence'];

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF2A6E9B),
        elevation: 0,
        title: Text(
          translate('claim_details_title'),
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (evidencePath != null)
              Container(
                height: 250,
                width: double.infinity,
                child: Image.network(
                  '$imageBaseUrl/uploads/$evidencePath',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/crop.jpg',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          claim['crop_name'] ?? translate('unknown_crop'),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A6E9B),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (claim['status'] == 'approved')
                              ? Colors.green.withOpacity(0.1)
                              : (claim['status'] == 'rejected')
                              ? Colors.red.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (claim['status'] ?? 'pending').toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: (claim['status'] == 'approved')
                                ? Colors.green
                                : (claim['status'] == 'rejected')
                                ? Colors.red
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  Text(
                    translate('claim_description'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
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
                    child: Text(
                      claim['claim_details'] ?? 'No details provided.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
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
