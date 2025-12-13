import 'package:get/get.dart';
import '../../../services/farmerServices.dart';

class HistoryItem {
  final String id;
  final String farmer1Name; // Viewer
  final String farmer1Contact;
  final String farmer2Name; // Crop Owner
  final String farmer2Contact;
  final String communicationMode; // 'Phone' or 'WhatsApp'
  final String summary;
  final String? query;
  final String? complaint;
  final DateTime timestamp;
  final String cropImageUrl;
  final String caller; // Name of the person who initiated the call
  final String? cropName;

  HistoryItem({
    required this.id,
    required this.farmer1Name,
    required this.farmer1Contact,
    required this.farmer2Name,
    required this.farmer2Contact,
    required this.communicationMode,
    required this.summary,
    this.query,
    this.complaint,
    required this.timestamp,
    required this.cropImageUrl,
    required this.caller,
    this.cropName,
  });
}

class HistoryController extends GetxController {
  final historyItems = <HistoryItem>[].obs;
  final isLoading = false.obs;
  final FarmerService _farmerService = FarmerService();

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final data = await _farmerService.getFarmerHistory();

      final items = data.map((item) {
        // Extract viewer info
        final viewer = item['viewer'] ?? {};
        final viewerName = viewer['name'] ?? 'Unknown';
        final viewerContact = viewer['phone'] ?? 'N/A';

        // Extract crop owner info
        final cropOwner = item['cropOwner'] ?? {};
        final ownerName = cropOwner['name'] ?? 'Unknown';
        final ownerContact = cropOwner['phone'] ?? 'N/A';

        // Extract crop info
        final crop = item['crop'] ?? {};
        final cropName =
            crop['crop_name'] ?? item['crop_name'] ?? 'Unknown Crop';

        // Get crop image
        String cropImageUrl =
            'https://via.placeholder.com/400x300?text=No+Image';
        if (crop['photos'] != null && (crop['photos'] as List).isNotEmpty) {
          final photo = crop['photos'][0];
          cropImageUrl =
              'http://192.168.43.43:5000/uploads/${photo['file_path']}';
        } else if (item['crop_image_path'] != null) {
          cropImageUrl =
              'http://192.168.43.43:5000/uploads/${item['crop_image_path']}';
        }

        // Parse timestamp
        DateTime timestamp;
        try {
          timestamp = DateTime.parse(
            item['viewed_at'] ?? DateTime.now().toString(),
          );
        } catch (e) {
          timestamp = DateTime.now();
        }

        return HistoryItem(
          id: item['id']?.toString() ?? '0',
          farmer1Name: viewerName,
          farmer1Contact: viewerContact,
          farmer2Name: ownerName,
          farmer2Contact: ownerContact,
          communicationMode: 'Phone', // Default to Phone
          summary: 'Viewed $cropName listing',
          timestamp: timestamp,
          cropImageUrl: cropImageUrl,
          caller: viewerName, // Viewer is the one who initiated
          cropName: cropName,
        );
      }).toList();

      historyItems.value = items;
    } catch (e) {
      print('Error loading history: $e');
      historyItems.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void refreshHistory() {
    loadHistory();
  }
}
