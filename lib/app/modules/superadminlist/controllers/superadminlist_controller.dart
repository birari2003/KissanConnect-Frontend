import 'package:get/get.dart';

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
}

class SuperadminlistController extends GetxController {
  // List of super admins
  final superAdmins = <SuperAdmin>[].obs;

  // Selected ids
  final selectedIds = <String>{}.obs;

  // Loading state for sending
  final isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSuperAdmins();
  }

  void loadSuperAdmins() {
    // Mock data - replace with API integration
    superAdmins.value = [
      SuperAdmin(
        id: 'sa1',
        name: 'Mahesh Deshmukh',
        level: 'City',
        levelPath: 'Maharashtra > Pune > Kothrud',
      ),
      SuperAdmin(
        id: 'sa2',
        name: 'Suresh Patil',
        level: 'District',
        levelPath: 'Maharashtra > Nashik',
      ),
      SuperAdmin(
        id: 'sa3',
        name: 'Ramesh Kumar',
        level: 'State',
        levelPath: 'Gujarat',
      ),
      SuperAdmin(
        id: 'sa4',
        name: 'Prakash Yadav',
        level: 'Village',
        levelPath: 'Karnataka > Bangalore > Koramangala > 6th Block',
      ),
    ];
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
      Get.snackbar('Error', 'Select at least one super admin and enter a message');
      return;
    }
    isSending.value = true;
    try {
      // TODO: Integrate with backend API for sending messages (email/WhatsApp etc.)
      await Future.delayed(const Duration(milliseconds: 800));
      Get.snackbar('Sent', 'Message sent to ${selectedIds.length} super admin(s)');
      clearSelection();
    } finally {
      isSending.value = false;
    }
  }
}
