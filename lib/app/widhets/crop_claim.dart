import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_translate/flutter_translate.dart';
import '../utils/ui_utils.dart';

import '../services/farmerServices.dart';
import '../services/translation_service.dart';

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
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
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
                                      color: Color(0xFF2A6E9B).withOpacity(0.1),
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
    final String imageBaseUrl = 'http://192.168.43.43:5000';
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
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey[500],
                        ),
                      ),
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
