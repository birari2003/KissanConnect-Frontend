import 'package:get/get.dart';
import '../../../services/adminServices.dart';

class SuperAdmin {
  final String id;
  final String name;
  final String level; // e.g., "State", "District", "City", "Village"
  final String levelPath; // e.g., "Maharashtra > Pune > Kothrud"

  SuperAdmin({
    required this.id,
    required this.name,
    required this.level,
    required this.levelPath,
  });

  // Factory constructor to create SuperAdmin from API response
  factory SuperAdmin.fromJson(Map<String, dynamic> json) {
    // Determine level based on what's set
    String level;
    String levelPath = 'Unknown';

    final superAdminLevel = json['super_admin_level'] ?? '';

    if (superAdminLevel == 'village') {
      level = 'Village';
    } else if (superAdminLevel == 'city' || superAdminLevel == 'taluka') {
      level = 'City';
    } else if (superAdminLevel == 'district') {
      level = 'District';
    } else if (superAdminLevel == 'state') {
      level = 'State';
    } else {
      level = 'Unknown';
    }

    // Build level path from nested location objects
    List<String> levels = [];

    if (json['adminState'] != null) {
      levels.add(json['adminState']['name']);
    }

    if (json['adminDistrict'] != null) {
      levels.add(json['adminDistrict']['name']);
    }

    if (json['adminTaluka'] != null) {
      levels.add(json['adminTaluka']['name']);
    }

    if (json['adminVillage'] != null) {
      levels.add(json['adminVillage']['name']);
    }

    levelPath = levels.isNotEmpty ? levels.join(' > ') : 'Unknown';

    return SuperAdmin(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      level: level,
      levelPath: levelPath,
    );
  }
}

class SuperadminlistController extends GetxController {
  final AdminService _adminService = AdminService();

  // List of super admins
  final superAdmins = <SuperAdmin>[].obs;

  // Selected ids
  final selectedIds = <String>{}.obs;

  // Loading states
  final isLoading = false.obs;
  final isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSuperAdmins();
  }

  Future<void> loadSuperAdmins() async {
    try {
      isLoading.value = true;

      // Fetch super admins from API
      final data = await _adminService.getSuperAdmins();

      // Convert API response to SuperAdmin objects
      superAdmins.value = data
          .map((json) => SuperAdmin.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading super admins: $e');
      Get.snackbar(
        'Error',
        'Failed to load super admins: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
      // Keep empty list on error
      superAdmins.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSelection(String id, bool? value) {
    if (value == true) {
      selectedIds.add(id);
    } else {
      selectedIds.remove(id);
    }
  }

  void selectAll() {
    selectedIds.addAll(superAdmins.map((e) => e.id));
  }

  void clearSelection() {
    selectedIds.clear();
  }

  Future<void> sendMessageToSelected(String message) async {
    if (message.trim().isEmpty || selectedIds.isEmpty) {
      Get.snackbar(
        'Error',
        'Select at least one super admin and enter a message',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSending.value = true;
    try {
      // Convert selected IDs to integers
      final recipientIds = selectedIds.map((id) => int.parse(id)).toList();

      // Call API to send message
      await _adminService.addMessage(
        message: message,
        recipientIds: recipientIds,
      );

      Get.snackbar(
        'Success',
        'Message sent to ${selectedIds.length} super admin(s)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        duration: Duration(seconds: 2),
      );
      clearSelection();
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        duration: Duration(seconds: 3),
      );
    } finally {
      isSending.value = false;
    }
  }
}
