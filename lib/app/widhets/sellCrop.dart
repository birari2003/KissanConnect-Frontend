import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_translate/flutter_translate.dart';
import '../utils/ui_utils.dart';
import '../services/farmerServices.dart';
import '../services/translation_service.dart';
import '../controllers/subscription_controller.dart';
import '../controllers/payment_controller.dart';

class SellCropController extends GetxController {
  final cropNameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  final selectedUnit = 'Quintal'.obs;
  final units = ['Quintal', 'Kg', 'Ton', 'Bag'];

  String _getTranslatedUnit(String unit) {
    switch (unit.toLowerCase()) {
      case 'quintal':
        return translate('quintal');
      case 'kg':
        return translate('kg');
      case 'ton':
        return translate('ton');
      case 'bag':
        return translate('bag');
      default:
        return unit;
    }
  }

  final selectedImages = <CropImage>[].obs;
  final isSending = false.obs;
  final myCrops = <dynamic>[].obs;
  final isLoadingCrops = false.obs;
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
    fetchCrops();
  }

  @override
  void onClose() {
    cropNameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.onClose();
  }

  Future<void> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      selectedImages.add(
        CropImage(
          name: image.name,
          path: image.path,
          size: await File(image.path).length(),
        ),
      );
    }
  }

  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 85);

    for (var image in images) {
      selectedImages.add(
        CropImage(
          name: image.name,
          path: image.path,
          size: await File(image.path).length(),
        ),
      );
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  Future<void> submitCropListing() async {
    // Check subscription status and listing limit for unsubscribed users
    final subscriptionController = Get.put(SubscriptionController());
    if (!subscriptionController.isSubscribed.value && myCrops.length >= 3) {
      _showLimitExceededPopup();
      return;
    }

    final cropName = cropNameController.text.trim();
    final quantity = quantityController.text.trim();
    final price = priceController.text.trim();

    if (cropName.isEmpty) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('enter_crop_name_error'),
      );
      return;
    }

    if (quantity.isEmpty) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('enter_quantity_error'),
      );
      return;
    }

    if (price.isEmpty) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('enter_price_error'),
      );
      return;
    }

    if (selectedImages.isEmpty) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('add_photo_error'),
      );
      return;
    }

    isSending.value = true;

    try {
      final photoPaths = selectedImages.map((image) => image.path).toList();

      await FarmerService().addCrop(
        cropName,
        quantity,
        selectedUnit.value,
        price,
        photoPaths,
      );

      UiUtils.showSuccessSnackbar(
        translate('success_title'),
        translate('listing_created_success'),
      );

      // Clear form
      cropNameController.clear();
      quantityController.clear();
      priceController.clear();
      selectedImages.clear();
      selectedUnit.value = 'Quintal';

      // Refresh crops list
      fetchCrops();
    } catch (e) {
      UiUtils.showErrorSnackbar(
        translate('error_title'),
        translate('listing_creation_failed', args: {'error': e.toString()}),
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
                Color(0xFF2E8B57).withOpacity(0.1),
                Color(0xFF5CC96F).withOpacity(0.1),
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
                    colors: [Color(0xFF2E8B57), Color(0xFF5CC96F)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2E8B57).withOpacity(0.3),
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
                translate('sell_limit_exceeded_title'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E8B57),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),

              // Message
              Text(
                translate('sell_limit_exceeded_message'),
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
                  border: Border.all(color: Color(0xFF2E8B57).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    _buildFeatureRow(
                      Icons.check_circle,
                      translate('unlimited_listings'),
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
                        foregroundColor: Color(0xFF2E8B57),
                        side: BorderSide(color: Color(0xFF2E8B57)),
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
                        backgroundColor: Color(0xFF2E8B57),
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
        Icon(icon, color: Color(0xFF2E8B57), size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2E8B57),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> fetchCrops() async {
    isLoadingCrops.value = true;
    try {
      final crops = await FarmerService().getCrops();

      for (var crop in crops) {
        if (crop['crop_name'] != null) {
          crop['crop_name'] = await _translateIfNeed(crop['crop_name']);
        }
        // Translate seller name
        if (crop['seller'] != null && crop['seller']['name'] != null) {
          crop['seller']['name'] = await _translateIfNeed(
            crop['seller']['name'],
          );
        }
      }

      myCrops.assignAll(crops);
    } catch (e) {
      print('Error fetching crops: $e');
    } finally {
      isLoadingCrops.value = false;
    }
  }
}

class CropImage {
  final String name;
  final String path;
  final int size;

  CropImage({required this.name, required this.path, required this.size});
}

class SellCropWidget extends StatelessWidget {
  const SellCropWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellCropController());

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
                  colors: [Color(0xFF2E8B57), Color(0xFF5CC96F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2E8B57).withOpacity(0.3),
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
                      Icons.storefront,
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
                          translate('sell_crop_title'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          translate('sell_crop_subtitle'),
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
                      Icon(Icons.grass, color: Color(0xFF2E8B57), size: 20),
                      SizedBox(width: 8),
                      Text(
                        translate('crop_name_label'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E8B57),
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
                          color: Color(0xFF2E8B57),
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

            // Quantity
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.scale, color: Color(0xFF2E8B57), size: 20),
                      SizedBox(width: 8),
                      Text(
                        translate('quantity_label'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E8B57),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: controller.quantityController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                          decoration: InputDecoration(
                            hintText: translate('quantity_hint'),
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
                                color: Color(0xFF2E8B57),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Obx(
                          () => Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.selectedUnit.value,
                                isExpanded: true,
                                items: controller.units.map((String unit) {
                                  return DropdownMenuItem<String>(
                                    value: unit,
                                    child: Text(
                                      controller._getTranslatedUnit(unit),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    controller.selectedUnit.value = newValue;
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Price
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.currency_rupee,
                        color: Color(0xFF2E8B57),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        translate('price_label'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E8B57),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: controller.priceController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      hintText: translate('price_hint'),
                      prefixIcon: Icon(
                        Icons.currency_rupee,
                        color: Color(0xFF2E8B57),
                      ),
                      suffixText: translate('price_suffix'),
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
                          color: Color(0xFF2E8B57),
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

            // Image Picker
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.photo_camera,
                        color: Color(0xFF2E8B57),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        translate('crop_photos_label'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E8B57),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.pickImageFromCamera,
                          icon: Icon(Icons.camera_alt, size: 20),
                          label: Text(translate('camera_label')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF2E8B57),
                            side: BorderSide(color: Color(0xFF2E8B57)),
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
                          onPressed: controller.pickImageFromGallery,
                          icon: Icon(Icons.photo_library, size: 20),
                          label: Text(translate('gallery_label')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF5CC96F),
                            side: BorderSide(color: Color(0xFF5CC96F)),
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
                    if (controller.selectedImages.isEmpty) {
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
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 8),
                              Text(
                                translate('no_photos_added'),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                translate('add_photos_hint'),
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

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: controller.selectedImages.length,
                      itemBuilder: (context, index) {
                        final image = controller.selectedImages[index];
                        return _buildImageCard(image, index, controller);
                      },
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
                      : controller.submitCropListing,
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
                        ? translate('creating_listing')
                        : translate('create_listing'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E8B57),
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

            // My Crops Section
            Text(
              translate('my_listings'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E8B57),
              ),
            ),
            SizedBox(height: 16),

            Obx(() {
              if (controller.isLoadingCrops.value) {
                return Center(child: CircularProgressIndicator());
              }

              return _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          translate('total_uploaded_crops'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF2E8B57).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${controller.myCrops.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E8B57),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (controller.myCrops.isNotEmpty) ...[
                      Divider(height: 24),
                      Text(
                        translate('recent_uploads'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...controller.myCrops
                          .take(5)
                          .map(
                            (crop) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: InkWell(
                                onTap: () =>
                                    Get.to(() => CropDetailView(crop: crop)),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Color(
                                            0xFF2E8B57,
                                          ).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.agriculture,
                                          size: 16,
                                          color: Color(0xFF2E8B57),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              crop['crop_name'] ??
                                                  translate('unknown_crop'),
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              '${crop['quantity']} ${controller._getTranslatedUnit(crop['unit'] ?? '')}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Color(
                                              0xFF2E8B57,
                                            ).withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              translate('view_label'),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF2E8B57),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 10,
                                              color: Color(0xFF2E8B57),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      if (controller.myCrops.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            translate(
                              'more_items',
                              args: {
                                'count': (controller.myCrops.length - 5)
                                    .toString(),
                              },
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
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

  Widget _buildImageCard(
    CropImage image,
    int index,
    SellCropController controller,
  ) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(0xFF2E8B57).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(image.path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => controller.removeImage(index),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class CropDetailView extends StatelessWidget {
  final Map<String, dynamic> crop;

  const CropDetailView({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final photos = crop['photos'] as List? ?? [];
    // Assuming images are served from root/uploads or similar.
    // Adjust base URL as needed. Using the same host as FarmerService but root.
    final String imageBaseUrl = 'http://192.168.43.43:5000';
    final SellCropController controller = Get.find<SellCropController>();

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF2E8B57),
        elevation: 0,
        title: Text(
          translate('crop_details_title'),
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
            // Image Slider
            if (photos.isNotEmpty)
              Container(
                height: 250,
                width: double.infinity,
                child: PageView.builder(
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photoPath = photos[index]['file_path'];
                    // If photoPath is just filename, prepend base url + /uploads/ or similar if needed.
                    // Based on user snippet, it is just filename.
                    // Assuming static files are served from root or /uploads.
                    // Let's try direct base url + / + filename first, or maybe /uploads/
                    // Usually it is /uploads/
                    final imageUrl = '$imageBaseUrl/uploads/$photoPath';
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to try without /uploads/ if needed or just show error
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
                    );
                  },
                ),
              )
            else
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Colors.grey[500],
                  ),
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
                          crop['crop_name'] ?? translate('unknown_crop'),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E8B57),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF2E8B57).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '₹${crop['price_per_unit']} ${translate('per')} ${controller._getTranslatedUnit(crop['unit'] ?? '')}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E8B57),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${translate('quantity_label')}: ${crop['quantity']} ${controller._getTranslatedUnit(crop['unit'] ?? '')}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 24),

                  Text(
                    translate('seller_info_title'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
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
                      children: [
                        _buildInfoRow(
                          Icons.person,
                          translate('name_label'),
                          crop['seller']?['name'] ?? 'N/A',
                        ),
                        Divider(),
                        _buildInfoRow(
                          Icons.phone,
                          translate('phone_label'),
                          crop['seller']?['phone'] ?? 'N/A',
                        ),
                        Divider(),
                        _buildInfoRow(
                          Icons.email,
                          translate('email_label'),
                          crop['seller']?['email'] ?? 'N/A',
                        ),
                      ],
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
