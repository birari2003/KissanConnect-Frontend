import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/ui_utils.dart';

class CropClaimController extends GetxController {
  final cropNameController = TextEditingController();
  final messageController = TextEditingController();
  
  final attachedFiles = <ClaimAttachment>[].obs;
  final isSending = false.obs;
  
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
      attachedFiles.add(ClaimAttachment(
        name: image.name,
        path: image.path,
        type: ClaimFileType.image,
        size: await File(image.path).length(),
      ));
    }
  }
  
  Future<void> pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    
    if (video != null) {
      attachedFiles.add(ClaimAttachment(
        name: video.name,
        path: video.path,
        type: ClaimFileType.video,
        size: await File(video.path).length(),
      ));
    }
  }
  
  void removeFile(int index) {
    attachedFiles.removeAt(index);
  }
  
  Future<void> submitClaim() async {
    final cropName = cropNameController.text.trim();
    final message = messageController.text.trim();
    
    if (cropName.isEmpty) {
      UiUtils.showErrorSnackbar('Error', 'Please enter crop name');
      return;
    }
    
    if (message.isEmpty) {
      UiUtils.showErrorSnackbar('Error', 'Please enter claim details');
      return;
    }
    
    if (attachedFiles.isEmpty) {
      UiUtils.showErrorSnackbar('Error', 'Please attach at least one image or video');
      return;
    }
    
    isSending.value = true;
    
    try {
      // TODO: Implement API call to submit crop claim
      await Future.delayed(Duration(seconds: 2));
      
      UiUtils.showSuccessSnackbar('Success', 'Crop claim submitted successfully');
      
      // Clear form
      cropNameController.clear();
      messageController.clear();
      attachedFiles.clear();
    } catch (e) {
      UiUtils.showErrorSnackbar('Error', 'Failed to submit claim: $e');
    } finally {
      isSending.value = false;
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
                          'Crop Claim',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Submit your crop damage or insurance claim',
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
                        'Crop Name',
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
                      hintText: 'e.g., Wheat, Rice, Cotton',
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
                        borderSide: BorderSide(color: Color(0xFF7BB53B), width: 2),
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
                      Icon(Icons.description, color: Color(0xFF2A6E9B), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Claim Details',
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
                      hintText: 'Describe the damage, loss, or claim details...',
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
                        borderSide: BorderSide(color: Color(0xFF7BB53B), width: 2),
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
                      Icon(Icons.attach_file, color: Color(0xFF2A6E9B), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Evidence (Photos/Videos)',
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
                          label: Text('Add Photo'),
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
                          label: Text('Add Video'),
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
                              Icon(Icons.cloud_upload_outlined, 
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
                              SizedBox(height: 4),
                              Text(
                                'Add photos or videos as evidence',
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
                      children: controller.attachedFiles.asMap().entries.map((entry) {
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
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.isSending.value ? null : controller.submitClaim,
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
                  controller.isSending.value ? 'Submitting...' : 'Submit Claim',
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
            )),
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
  
  Widget _buildFileCard(ClaimAttachment file, int index, CropClaimController controller) {
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
              color: file.type == ClaimFileType.video ? Color(0xFF54B5D9) : Color(0xFF7BB53B),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
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
