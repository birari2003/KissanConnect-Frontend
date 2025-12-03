import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:smart_shetkari/app/services/farmerServices.dart';
import 'dart:io';
import '../utils/ui_utils.dart';
import '../services/adminServices.dart';

class GovernmentSchemeController extends GetxController {
  final titleController = TextEditingController();
  final messageController = TextEditingController();

  final attachedFiles = <AttachedFile>[].obs;
  final selectedRecipients = <String>[].obs;
  final isSending = false.obs;

  // Recipient options
  final recipientOptions = [
    'All Farmers',
    'All Super Admins',
    'Specific Region',
  ];
  final selectedRecipientType = 'All Farmers'.obs;

  final mySchemes = <dynamic>[].obs;
  final isLoadingSchemes = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSchemes();
  }

  Future<void> fetchSchemes() async {
    isLoadingSchemes.value = true;
    try {
      final schemes = await FarmerService().getGovernmentSchemes();
      mySchemes.assignAll(schemes);
    } catch (e) {
      print('Error fetching schemes: $e');
    } finally {
      isLoadingSchemes.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      attachedFiles.add(
        AttachedFile(
          name: image.name,
          path: image.path,
          type: AttachmentType.image,
          size: await File(image.path).length(),
        ),
      );
    }
  }

  Future<void> pickPDF() async {
    file_picker.FilePickerResult? result = await file_picker.FilePicker.platform
        .pickFiles(
          type: file_picker.FileType.custom,
          allowedExtensions: ['pdf'],
        );

    if (result != null) {
      final file = result.files.first;
      attachedFiles.add(
        AttachedFile(
          name: file.name,
          path: file.path!,
          type: AttachmentType.pdf,
          size: file.size,
        ),
      );
    }
  }

  void removeFile(int index) {
    attachedFiles.removeAt(index);
  }

  Future<void> sendScheme() async {
    final title = titleController.text.trim();
    final message = messageController.text.trim();

    if (title.isEmpty) {
      UiUtils.showErrorSnackbar('Error', 'Please enter scheme title');
      return;
    }

    if (message.isEmpty) {
      UiUtils.showErrorSnackbar('Error', 'Please enter scheme message');
      return;
    }

    isSending.value = true;

    try {
      String? attachmentPath;
      if (attachedFiles.isNotEmpty) {
        attachmentPath = attachedFiles.first.path;
      }

      // Map UI selection to backend values
      String targetAudience = 'all';
      if (selectedRecipientType.value == 'All Super Admins') {
        targetAudience = 'super_admins';
      } else if (selectedRecipientType.value == 'Specific Region') {
        targetAudience = 'region';
      }

      await AdminService().createScheme(
        title: title,
        description: message,
        targetAudience: targetAudience,
        status: 'published',
        attachmentPath: attachmentPath,
      );

      UiUtils.showSuccessSnackbar(
        'Success',
        'Government scheme created successfully for ${selectedRecipientType.value}',
      );

      // Clear form
      titleController.clear();
      messageController.clear();
      attachedFiles.clear();

      // Refresh list
      fetchSchemes();
    } catch (e) {
      UiUtils.showErrorSnackbar('Error', 'Failed to create scheme: $e');
    } finally {
      isSending.value = false;
    }
  }
}

class AttachedFile {
  final String name;
  final String path;
  final AttachmentType type;
  final int size;

  AttachedFile({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
  });
}

enum AttachmentType { image, pdf }

class GovernmentSchemeWidget extends StatelessWidget {
  const GovernmentSchemeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GovernmentSchemeController());

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
                  colors: [Color(0xFF2A6E9B), Color(0xFF54B5D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2A6E9B).withOpacity(0.3),
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
                      Icons.account_balance,
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
                          'Government Schemes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Share important schemes with farmers',
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

            // Scheme Title
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.title, color: Color(0xFF2A6E9B), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Scheme Title',
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
                    controller: controller.titleController,
                    decoration: InputDecoration(
                      hintText: 'e.g., PM-KISAN Scheme 2025',
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

            // Message
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.message, color: Color(0xFF2A6E9B), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Scheme Details',
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
                      hintText:
                          'Enter detailed information about the scheme...',
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
                        'Attachments',
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
                          label: Text('Add Image'),
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
                          onPressed: controller.pickPDF,
                          icon: Icon(Icons.picture_as_pdf, size: 20),
                          label: Text('Add PDF'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red),
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
                                'No files attached',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
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
            SizedBox(height: 16),

            // Recipients
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, color: Color(0xFF2A6E9B), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Send To',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2A6E9B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Obx(
                    () => Column(
                      children: controller.recipientOptions.map((option) {
                        return RadioListTile<String>(
                          title: Text(option),
                          value: option,
                          groupValue: controller.selectedRecipientType.value,
                          onChanged: (value) {
                            controller.selectedRecipientType.value = value!;
                          },
                          activeColor: Color(0xFF7BB53B),
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Send Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isSending.value
                      ? null
                      : controller.sendScheme,
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
                    controller.isSending.value ? 'Sending...' : 'Send Scheme',
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

            // Uploaded Schemes Section
            Text(
              'My Uploaded Schemes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D323A),
              ),
            ),
            SizedBox(height: 16),

            Obx(() {
              if (controller.isLoadingSchemes.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.mySchemes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No schemes uploaded yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.mySchemes.length,
                itemBuilder: (context, index) {
                  final scheme = controller.mySchemes[index];
                  return _buildSchemeItem(scheme);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemeItem(Map<String, dynamic> scheme) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  scheme['title'] ?? 'No Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A6E9B),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (scheme['status'] == 'published')
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (scheme['status'] ?? 'draft').toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: (scheme['status'] == 'published')
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            scheme['description'] ?? 'No Description',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people_outline, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                'Target: ${scheme['target_audience'] ?? 'All'}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Spacer(),
              if (scheme['attachment'] != null)
                Icon(Icons.attach_file, size: 16, color: Color(0xFF2A6E9B)),
            ],
          ),
        ],
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
    AttachedFile file,
    int index,
    GovernmentSchemeController controller,
  ) {
    final sizeInMB = (file.size / (1024 * 1024)).toStringAsFixed(2);

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: file.type == AttachmentType.pdf
            ? Colors.red.withOpacity(0.05)
            : Color(0xFF7BB53B).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: file.type == AttachmentType.pdf
              ? Colors.red.withOpacity(0.2)
              : Color(0xFF7BB53B).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: file.type == AttachmentType.pdf
                  ? Colors.red.withOpacity(0.1)
                  : Color(0xFF7BB53B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              file.type == AttachmentType.pdf
                  ? Icons.picture_as_pdf
                  : Icons.image,
              color: file.type == AttachmentType.pdf
                  ? Colors.red
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
