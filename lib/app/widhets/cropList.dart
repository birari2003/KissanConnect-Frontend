import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widhets/subscriptionPopUp.dart';
import '../services/farmerServices.dart';

// Crop Model
class CropModel {
  final String name;
  final double quantity;
  final String unit;
  final double price;
  final String farmerName;
  final String location;
  final String phone;
  final List<String> imageUrls;

  CropModel({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.farmerName,
    required this.location,
    required this.phone,
    required this.imageUrls,
  });
}

class CropListController extends GetxController {
  // Static data for now
  final crops = <CropModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCrops();
  }

  Future<void> fetchCrops() async {
    isLoading.value = true;
    try {
      final fetchedCrops = await FarmerService().getAllCrops();
      crops.assignAll(
        fetchedCrops.map((data) {
          final seller = data['seller'] ?? {};
          final photos = data['photos'] as List? ?? [];
          List<String> imageUrls = [];

          if (photos.isNotEmpty) {
            imageUrls = photos
                .map(
                  (photo) =>
                      'http://192.168.43.43:5000/uploads/${photo['file_path']}',
                )
                .cast<String>()
                .toList();
          }

          return CropModel(
            name: data['crop_name'] ?? 'Unknown',
            quantity: double.tryParse(data['quantity'].toString()) ?? 0.0,
            unit: data['unit'] ?? '',
            price: double.tryParse(data['price_per_unit'].toString()) ?? 0.0,
            farmerName: seller['name'] ?? 'Unknown Farmer',
            location: 'Unknown Location', // Location not in API response yet
            phone: seller['phone'] ?? 'N/A',
            imageUrls: imageUrls,
          );
        }).toList(),
      );
    } catch (e) {
      print('Error fetching crops: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Check if user has subscription (mock for now)
  final hasSubscription = false.obs;

  void showCropDetail(CropModel crop) {
    Get.dialog(
      CropDetailDialog(crop: crop, controller: this),
      barrierDismissible: true,
    );
  }

  void showContactInfo(CropModel crop) {
    if (hasSubscription.value) {
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
                  'Contact Information',
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
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E8B57),
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
                  child: Text('Close'),
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
                        'Crop Marketplace',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Browse crops from nearby farmers',
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
                        'No crops available',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: controller.crops.length,
                itemBuilder: (context, index) {
                  final crop = controller.crops[index];
                  return _buildCropCard(crop, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(CropModel crop, CropListController controller) {
    return GestureDetector(
      onTap: () => controller.showCropDetail(crop),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Image
            // Crop Image Carousel
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 110,
                child: crop.imageUrls.isNotEmpty
                    ? PageView.builder(
                        itemCount: crop.imageUrls.length,
                        itemBuilder: (context, imageIndex) {
                          return Image.network(
                            crop.imageUrls[imageIndex],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey[500],
                                ),
                              );
                            },
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey[500],
                        ),
                      ),
              ),
            ),

            // Crop Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D323A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.scale, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          '${crop.quantity} ${crop.unit}',
                          style: TextStyle(
                            fontSize: 12,
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
                          size: 14,
                          color: Color(0xFF2E8B57),
                        ),
                        Text(
                          '${crop.price}/${crop.unit}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E8B57),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Icon(Icons.person, size: 12, color: Colors.grey[500]),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            crop.farmerName,
                            style: TextStyle(
                              fontSize: 11,
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
}

class CropDetailDialog extends StatelessWidget {
  final CropModel crop;
  final CropListController controller;

  const CropDetailDialog({
    super.key,
    required this.crop,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Crop Image
            // Crop Image Carousel
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 250,
                child: crop.imageUrls.isNotEmpty
                    ? Stack(
                        children: [
                          PageView.builder(
                            itemCount: crop.imageUrls.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                crop.imageUrls[index],
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.image,
                                      size: 60,
                                      color: Colors.grey[500],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          if (crop.imageUrls.length > 1)
                            Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  crop.imageUrls.length,
                                  (index) => Container(
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey[500],
                        ),
                      ),
              ),
            ),

            // Details
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
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
                      'Quantity',
                      '${crop.quantity} ${crop.unit}',
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.currency_rupee,
                      'Price',
                      '₹${crop.price} per ${crop.unit}',
                      valueColor: Color(0xFF2E8B57),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(Icons.person, 'Farmer', crop.farmerName),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.location_on,
                      'Location',
                      crop.location,
                    ),
                    SizedBox(height: 24),

                    // Contact Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => controller.showContactInfo(crop),
                        icon: Obx(
                          () => Icon(
                            controller.hasSubscription.value
                                ? Icons.phone
                                : Icons.lock,
                            size: 20,
                          ),
                        ),
                        label: Obx(
                          () => Text(
                            controller.hasSubscription.value
                                ? 'Get Contact Info'
                                : 'Get Contact Info (Premium)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
