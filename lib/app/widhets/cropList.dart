import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'dart:convert';
import '../widhets/subscriptionPopUp.dart';
import '../utils/api.dart';

import '../services/farmerServices.dart';
import '../services/translation_service.dart';
import '../controllers/subscription_controller.dart';
import '../controllers/payment_controller.dart';

// Crop Model
class CropModel {
  final int cropId;
  final String name;
  final double quantity;
  final String unit;
  final double price;
  final String farmerName;
  final String location;
  final String phone;
  final List<String> imageUrls;
  final int sellerId; // Added to filter own crops

  CropModel({
    required this.cropId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.farmerName,
    required this.location,
    required this.phone,
    required this.imageUrls,
    required this.sellerId,
  });
}

class CropListController extends GetxController {
  // Static data for now
  final crops = <CropModel>[].obs;
  final isLoading = false.obs;
  final TranslationService _translationService = TranslationService();
  final SubscriptionController _subscriptionController = Get.put(
    SubscriptionController(),
  );

  // Expose hasSubscription from the controller
  RxBool get hasSubscription => _subscriptionController.isSubscribed;

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

  @override
  void onInit() {
    super.onInit();
    fetchCrops();
    // Ensure subscription status is checked
    _subscriptionController.checkSubscriptionStatus();
  }

  Future<void> fetchCrops() async {
    isLoading.value = true;
    try {
      // Get current user ID
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      int? currentUserId;
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        currentUserId = userData['id'];
      }

      final fetchedCrops = await FarmerService().getAllCrops();

      // Filter out own crops
      final filteredCrops = fetchedCrops.where((data) {
        final seller = data['seller'] ?? {};
        final sellerId = seller['id'];
        return sellerId != currentUserId; // Exclude own crops
      }).toList();

      final cropsList = await Future.wait(
        filteredCrops.map((data) async {
          final seller = data['seller'] ?? {};
          final photos = data['photos'] as List? ?? [];
          List<String> imageUrls = [];

          if (photos.isNotEmpty) {
            imageUrls = photos
                .map((photo) => ApiConfig.getUploadUrl(photo['file_path']))
                .cast<String>()
                .toList();
          }

          String cropName = data['crop_name'] ?? translate('unknown_crop');
          cropName = await _translateIfNeed(cropName);

          String farmerName = seller['name'] ?? translate('unknown_farmer');
          farmerName = await _translateIfNeed(farmerName);

          return CropModel(
            cropId: (data['id'] is int)
                ? data['id']
                : (int.tryParse(data['id'].toString()) ?? 0),
            name: cropName,
            quantity: double.tryParse(data['quantity'].toString()) ?? 0.0,
            unit: data['unit'] ?? '',
            price: double.tryParse(data['price_per_unit'].toString()) ?? 0.0,
            farmerName: farmerName,
            location: translate(
              'unknown_location',
            ), // Location not in API response yet
            phone: seller['phone'] ?? translate('not_available'),
            imageUrls: imageUrls,
            sellerId: (seller['id'] is int)
                ? seller['id']
                : (int.tryParse(seller['id']?.toString() ?? '0') ?? 0),
          );
        }),
      );

      crops.assignAll(cropsList);
    } catch (e) {
      print('Error fetching crops: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showCropDetail(CropModel crop, int cropIndex) {
    Get.dialog(
      CropDetailDialog(crop: crop, controller: this, cropIndex: cropIndex),
      barrierDismissible: true,
    );
  }

  void showContactInfo(CropModel crop, int cropIndex) async {
    // Allow contact info for first 3 crops (index 0-2) even without subscription
    bool canViewContact = hasSubscription.value || cropIndex < 3;

    if (canViewContact) {
      // Save farmer history to database
      try {
        await FarmerService().addFarmerHistory(
          cropSellId: crop.cropId,
          cropOwnerUserId: crop.sellerId,
          cropName: crop.name,
          cropImagePath: crop.imageUrls.isNotEmpty
              ? crop.imageUrls.first
              : null,
        );
        print('Farmer history saved successfully');
      } catch (e) {
        print('Error saving farmer history: $e');
        // Continue to show contact info even if history saving fails
      }

      // Show contact info
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone, color: Color(0xFF2E8B57), size: 48),
                SizedBox(height: 16),
                Text(
                  translate('contact_info_title'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  crop.farmerName,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF2E8B57).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, color: Color(0xFF2E8B57)),
                      SizedBox(width: 8),
                      Text(
                        crop.phone,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D323A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: crop.phone));
                          Get.snackbar(
                            translate('copied'),
                            translate('phone_copied_message'),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Color(0xFF2E8B57),
                            colorText: Colors.white,
                            duration: Duration(seconds: 2),
                            margin: EdgeInsets.all(16),
                            borderRadius: 8,
                            icon: Icon(Icons.check_circle, color: Colors.white),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF2E8B57).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.copy,
                            size: 20,
                            color: Color(0xFF2E8B57),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E8B57),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(translate('close')),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Show subscription popup
      Get.back(); // Close detail dialog first
      Get.dialog(SubscriptionPopup(), barrierDismissible: true);
    }
  }
}

class CropListWidget extends StatelessWidget {
  const CropListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CropListController());

    return Container(
      color: Color(0xFFF5F7FA),
      child: Column(
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
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_basket, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translate('crop_marketplace_title'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        translate('crop_marketplace_subtitle'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Crop List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.crops.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        translate('no_crops_available'),
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount:
                    !controller.hasSubscription.value &&
                        controller.crops.length > 3
                    ? controller.crops.length +
                          1 // Add 1 for subscribe card
                    : controller.crops.length,
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  // If unsubscribed and this is position after 3rd crop, show subscribe card
                  if (!controller.hasSubscription.value &&
                      index == 3 &&
                      controller.crops.length > 3) {
                    return _buildSubscribeCard(controller);
                  }

                  // Adjust index if we've inserted subscribe card
                  final cropIndex =
                      !controller.hasSubscription.value &&
                          controller.crops.length > 3 &&
                          index > 3
                      ? index - 1
                      : index;

                  if (cropIndex >= controller.crops.length)
                    return SizedBox.shrink();

                  final crop = controller.crops[cropIndex];
                  final isBlurred =
                      !controller.hasSubscription.value && cropIndex >= 3;

                  if (isBlurred) {
                    return _buildSimpleBlurredCropCard(
                      crop,
                      controller,
                      cropIndex,
                    );
                  }
                  return _buildCropCard(crop, controller, cropIndex);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(
    CropModel crop,
    CropListController controller,
    int cropIndex,
  ) {
    return GestureDetector(
      onTap: () => controller.showCropDetail(crop, cropIndex),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Crop Image with padding
            Padding(
              padding: EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: crop.imageUrls.isNotEmpty
                      ? Image.network(
                          crop.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/crop.jpg',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/crop.jpg',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),

            // Crop Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            crop.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D323A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (crop.imageUrls.length > 1)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.photo_library,
                                  size: 12,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${crop.imageUrls.length}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.scale, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          '${crop.quantity} ${crop.unit}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          size: 16,
                          color: Color(0xFF2E8B57),
                        ),
                        Text(
                          '₹${crop.price} ${translate('per')} ${controller._getTranslatedUnit(crop.unit)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E8B57),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.grey[500]),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            crop.farmerName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeCard(CropListController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E8B57), Color(0xFF5CC96F)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2E8B57).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, color: Colors.white, size: 18),
          SizedBox(height: 6),
          Text(
            translate('subscribe_to_see_more'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            translate('free_limit_reached'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final paymentController = Get.put(PaymentController());
              await paymentController.startPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF2E8B57),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              translate('subscribe_now'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBlurredCropCard(
    CropModel crop,
    CropListController controller,
    int cropIndex,
  ) {
    return Opacity(
      opacity: 0.4,
      child: IgnorePointer(child: _buildCropCard(crop, controller, cropIndex)),
    );
  }
}

class CropDetailDialog extends StatefulWidget {
  final CropModel crop;
  final CropListController controller;
  final int cropIndex;

  const CropDetailDialog({
    super.key,
    required this.crop,
    required this.controller,
    required this.cropIndex,
  });

  @override
  State<CropDetailDialog> createState() => _CropDetailDialogState();
}

class _CropDetailDialogState extends State<CropDetailDialog> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Crop Image Gallery
            Padding(
              padding: EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 180,
                  child: widget.crop.imageUrls.isNotEmpty
                      ? Stack(
                          children: [
                            PageView.builder(
                              itemCount: widget.crop.imageUrls.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Image.network(
                                  widget.crop.imageUrls[index],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/crop.jpg',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                );
                              },
                            ),
                            // Image Counter Indicator
                            if (widget.crop.imageUrls.length > 1)
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_currentImageIndex + 1}/${widget.crop.imageUrls.length}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Image.asset(
                          'assets/images/crop.jpg',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),

            // Crop Details Section
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.crop.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D323A),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    _buildDetailRow(
                      Icons.scale,
                      translate('quantity_label'),
                      '${widget.crop.quantity} ${widget.controller._getTranslatedUnit(widget.crop.unit)}',
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.currency_rupee,
                      translate('price_label'),
                      '₹${widget.crop.price} ${translate('per')} ${widget.controller._getTranslatedUnit(widget.crop.unit)}',

                      valueColor: Color(0xFF2E8B57),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.person,
                      translate('farmer_label'),
                      widget.crop.farmerName,
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.location_on,
                      translate('location_label'),
                      widget.crop.location,
                    ),
                    SizedBox(height: 24),

                    // Contact Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => widget.controller.showContactInfo(
                          widget.crop,
                          widget.cropIndex,
                        ),
                        icon: Obx(() {
                          // Show phone icon if subscribed OR if it's one of the first 3 crops
                          bool canView =
                              widget.controller.hasSubscription.value ||
                              widget.cropIndex < 3;
                          return Icon(
                            canView ? Icons.phone : Icons.lock,
                            size: 20,
                          );
                        }),
                        label: Obx(() {
                          // Show appropriate text based on subscription and crop index
                          bool canView =
                              widget.controller.hasSubscription.value ||
                              widget.cropIndex < 3;
                          return Text(
                            canView
                                ? translate('get_contact_info')
                                : translate('get_contact_info_premium'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E8B57),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF2E8B57).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Color(0xFF2E8B57)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Color(0xFF2D323A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
