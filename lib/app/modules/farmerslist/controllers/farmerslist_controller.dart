import 'package:get/get.dart';
import '../../../services/adminServices.dart';
import 'package:http/http.dart' as http;
import '../../../utils/ui_utils.dart';

class Farmer {
  final String id; // farmer_profile.id
  final String userId; // user.id - needed for API calls
  final String name;
  final String contact;
  final String status; // 'pending', 'approved', 'rejected'
  final bool isSuperAdmin;
  final String? superAdminLevel; // 'State: Maharashtra > District: Pune'

  Farmer({
    required this.id,
    required this.userId,
    required this.name,
    required this.contact,
    required this.status,
    this.isSuperAdmin = false,
    this.superAdminLevel,
  });

  // Factory constructor to create Farmer from API response
  factory Farmer.fromJson(Map<String, dynamic> json) {
    // Check if user is a super admin
    final userRole = json['user']?['role'] ?? '';
    final isSuperAdmin = userRole == 'super_admin';

    // Build super admin level text if they are a super admin
    String? superAdminLevel;
    if (isSuperAdmin) {
      List<String> levels = [];
      if (json['user']?['state_name'] != null) {
        levels.add(json['user']['state_name']);
      }
      if (json['user']?['district_name'] != null) {
        levels.add(json['user']['district_name']);
      }
      if (json['user']?['taluka_name'] != null) {
        levels.add(json['user']['taluka_name']);
      }
      if (json['user']?['village_name'] != null) {
        levels.add(json['user']['village_name']);
      }
      superAdminLevel = levels.isNotEmpty ? levels.join(' > ') : null;
    }

    return Farmer(
      id: json['id'].toString(),
      userId: json['user']?['id'].toString() ?? '0',
      name: json['user']?['name'] ?? 'Unknown',
      contact: json['user']?['phone'] ?? 'N/A',
      status: json['request_status'] ?? 'pending',
      isSuperAdmin: isSuperAdmin,
      superAdminLevel: superAdminLevel,
    );
  }
}

class FarmerslistController extends GetxController {
  final AdminService _adminService = AdminService();

  // Observable list of farmers
  final farmers = <Farmer>[].obs;

  // Loading state
  final isLoading = false.obs;

  // Filter options
  final selectedFilter = 'all'.obs; // 'all', 'pending', 'approved', 'rejected'

  // Super admin assignment state - store IDs
  final selectedStateId = Rxn<String>();
  final selectedDistrictId = Rxn<String>();
  final selectedTalukaId = Rxn<String>();
  final selectedVillageId = Rxn<String>();

  // Super admin assignment state - store names for display
  final selectedStateName = Rxn<String>();
  final selectedDistrictName = Rxn<String>();
  final selectedTalukaName = Rxn<String>();
  final selectedVillageName = Rxn<String>();

  // Location data from API
  final states = <dynamic>[].obs;
  final districts = <dynamic>[].obs;
  final talukas = <dynamic>[].obs;
  final villages = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFarmers();
    _fetchStates();
  }

  // Fetch states from API
  Future<void> _fetchStates() async {
    try {
      final data = await _adminService.getStates();
      states.value = data;
    } catch (e) {
      print('Error fetching states: $e');
    }
  }

  // Fetch districts when state is selected
  Future<void> _fetchDistricts(String stateId) async {
    try {
      districts.clear();
      talukas.clear();
      villages.clear();

      final data = await _adminService.getDistrictsByState(stateId);
      districts.value = data;
    } catch (e) {
      print('Error fetching districts: $e');
    }
  }

  // Fetch talukas when district is selected
  Future<void> _fetchTalukas(String districtId) async {
    try {
      talukas.clear();
      villages.clear();

      final data = await _adminService.getTalukasByDistrict(districtId);
      talukas.value = data;
    } catch (e) {
      print('Error fetching talukas: $e');
    }
  }

  // Note: Add getVillagesByTaluka API method to AdminService if available
  // For now, villages will remain empty until that API is added

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> loadFarmers() async {
    try {
      isLoading.value = true;

      List<Farmer> allFarmers = [];

      // Fetch farmers from getFarmersList API (has all needed fields including id)
      try {
        final farmersData = await _adminService.getFarmersList();
        final farmersList = farmersData
            .map((json) => Farmer.fromJson(json))
            .toList();
        allFarmers.addAll(farmersList);
      } catch (e) {
        print('Error loading farmers list: $e');
      }

      // Fetch super admins from getAllUsers API
      try {
        final usersData = await _adminService.getAllUsers();

        // Filter to get only super_admins
        final superAdmins = usersData
            .where((user) => user['role'] == 'super_admin')
            .map((user) {
              // Build super admin level text
              String? superAdminLevel;
              if (user['super_admin_level'] != null) {
                superAdminLevel = user['super_admin_level'];
              }

              return Farmer(
                id: user['id']?.toString() ?? '0',
                userId: user['id']?.toString() ?? '0',
                name: user['name'] ?? 'Unknown',
                contact: user['phone'] ?? 'N/A',
                status: 'approved', // Super admins are always approved
                isSuperAdmin: true,
                superAdminLevel: superAdminLevel,
              );
            })
            .toList();

        allFarmers.addAll(superAdmins);
      } catch (e) {
        print('Error loading super admins: $e');
      }

      farmers.value = allFarmers;
    } catch (e) {
      print('Error loading farmers: $e');
      UiUtils.showErrorSnackbar(
        'Error',
        'Failed to load farmers: ${e.toString().replaceAll('Exception: ', '')}',
      );
      // Keep empty list on error
      farmers.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  List<Farmer> get filteredFarmers {
    if (selectedFilter.value == 'all') {
      return farmers;
    }
    return farmers.where((f) => f.status == selectedFilter.value).toList();
  }

  // Send WhatsApp message using TextMeBot API
  Future<void> sendWhatsAppMessage(String phoneNumber, String message) async {
    try {
      final apiKey = 'QNVVTKKBVyqC'; // Your TextMeBot API key
      final encodedMessage = Uri.encodeComponent(message);
      final url = Uri.parse(
        'http://api.textmebot.com/send.php?recipient=+91$phoneNumber&apikey=$apiKey&text=$encodedMessage',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('WhatsApp message sent successfully to $phoneNumber');
      } else {
        print('Failed to send WhatsApp message: ${response.body}');
      }
    } catch (e) {
      print('Error sending WhatsApp message: $e');
    }
  }

  Future<void> approveFarmer(String farmerId) async {
    try {
      // Find the farmer to get the userId
      final farmer = farmers.firstWhere((f) => f.id == farmerId);

      print('Approving farmer: farmerId=$farmerId, userId=${farmer.userId}');

      // Call API to approve farmer using userId
      await _adminService.updateFarmerStatus(
        userId: int.parse(farmer.userId),
        status: 'approved',
      );

      // Send WhatsApp notification
      final message =
          'Congratulations! Your farmer registration has been approved. You can now access all features of KissanConnect.';
      await sendWhatsAppMessage(farmer.contact, message);

      // Update local state
      final index = farmers.indexWhere((f) => f.id == farmerId);
      if (index != -1) {
        farmers[index] = Farmer(
          id: farmers[index].id,
          userId: farmers[index].userId,
          name: farmers[index].name,
          contact: farmers[index].contact,
          status: 'approved',
          isSuperAdmin: farmers[index].isSuperAdmin,
          superAdminLevel: farmers[index].superAdminLevel,
        );
        farmers.refresh();
      }

      UiUtils.showSuccessSnackbar('Success', 'Farmer approved successfully');
    } catch (e) {
      print('Error approving farmer: $e');
      UiUtils.showErrorSnackbar(
        'Error',
        'Failed to approve farmer: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  Future<void> rejectFarmer(String farmerId) async {
    try {
      // Find the farmer to get the userId
      final farmer = farmers.firstWhere((f) => f.id == farmerId);

      // Call API to reject farmer using userId
      await _adminService.updateFarmerStatus(
        userId: int.parse(farmer.userId),
        status: 'rejected',
        rejectionReason: 'Rejected by admin',
      );

      // Send WhatsApp notification
      final message =
          'We regret to inform you that your farmer registration has been rejected. Please contact the admin for more information.';
      await sendWhatsAppMessage(farmer.contact, message);

      // Update local state
      final index = farmers.indexWhere((f) => f.id == farmerId);
      if (index != -1) {
        farmers[index] = Farmer(
          id: farmers[index].id,
          userId: farmers[index].userId,
          name: farmers[index].name,
          contact: farmers[index].contact,
          status: 'rejected',
          isSuperAdmin: false,
          superAdminLevel: null,
        );
        farmers.refresh();
      }

      UiUtils.showSuccessSnackbar('Success', 'Farmer rejected');
    } catch (e) {
      print('Error rejecting farmer: $e');
      UiUtils.showErrorSnackbar(
        'Error',
        'Failed to reject farmer: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  void resetSuperAdminSelection() {
    selectedStateId.value = null;
    selectedDistrictId.value = null;
    selectedTalukaId.value = null;
    selectedVillageId.value = null;
    selectedStateName.value = null;
    selectedDistrictName.value = null;
    selectedTalukaName.value = null;
    selectedVillageName.value = null;
    districts.clear();
    talukas.clear();
    villages.clear();
  }

  // Called when state is selected
  void onStateSelected(String? stateId, String? stateName) {
    selectedStateId.value = stateId;
    selectedStateName.value = stateName;
    selectedDistrictId.value = null;
    selectedTalukaId.value = null;
    selectedVillageId.value = null;
    selectedDistrictName.value = null;
    selectedTalukaName.value = null;
    selectedVillageName.value = null;

    if (stateId != null) {
      _fetchDistricts(stateId);
    } else {
      districts.clear();
      talukas.clear();
      villages.clear();
    }
  }

  // Called when district is selected
  void onDistrictSelected(String? districtId, String? districtName) {
    selectedDistrictId.value = districtId;
    selectedDistrictName.value = districtName;
    selectedTalukaId.value = null;
    selectedVillageId.value = null;
    selectedTalukaName.value = null;
    selectedVillageName.value = null;

    if (districtId != null) {
      _fetchTalukas(districtId);
    } else {
      talukas.clear();
      villages.clear();
    }
  }

  // Called when taluka is selected
  void onTalukaSelected(String? talukaId, String? talukaName) {
    selectedTalukaId.value = talukaId;
    selectedTalukaName.value = talukaName;
    selectedVillageId.value = null;
    selectedVillageName.value = null;

    // TODO: Fetch villages when API is available
    // if (talukaId != null) {
    //   _fetchVillages(talukaId);
    // }
  }

  // Called when village is selected
  void onVillageSelected(String? villageId, String? villageName) {
    selectedVillageId.value = villageId;
    selectedVillageName.value = villageName;
  }

  String getSuperAdminLevelText() {
    List<String> levels = [];
    if (selectedStateName.value != null) levels.add(selectedStateName.value!);
    if (selectedDistrictName.value != null)
      levels.add(selectedDistrictName.value!);
    if (selectedTalukaName.value != null) levels.add(selectedTalukaName.value!);
    if (selectedVillageName.value != null)
      levels.add(selectedVillageName.value!);
    return levels.isEmpty ? 'No level selected' : levels.join(' > ');
  }

  Future<void> assignSuperAdmin(String farmerId) async {
    if (selectedStateId.value == null) {
      UiUtils.showErrorSnackbar('Error', 'Please select at least a state');
      return;
    }

    try {
      // Find the farmer to get the userId
      final farmer = farmers.firstWhere((f) => f.id == farmerId);

      // Determine the level based on what's selected
      String level;
      if (selectedVillageId.value != null) {
        level = 'village';
      } else if (selectedTalukaId.value != null) {
        level = 'city'; // Backend uses 'city' for taluka
      } else if (selectedDistrictId.value != null) {
        level = 'district';
      } else {
        level = 'state';
      }

      // Call API to assign super admin using userId
      await _adminService.assignSuperAdmin(
        userId: int.parse(farmer.userId),
        level: level,
        stateId: selectedStateId.value,
        districtId: selectedDistrictId.value,
        talukaId: selectedTalukaId.value,
        villageId: selectedVillageId.value,
      );

      // Send WhatsApp notification about super admin assignment
      String locationInfo = getSuperAdminLevelText();
      final whatsappMessage =
          'Congratulations! You have been appointed as a Super Admin for $locationInfo. You now have administrative privileges for this region in KissanConnect.';
      await sendWhatsAppMessage(farmer.contact, whatsappMessage);

      // Update local state
      final index = farmers.indexWhere((f) => f.id == farmerId);
      if (index != -1) {
        farmers[index] = Farmer(
          id: farmers[index].id,
          userId: farmers[index].userId,
          name: farmers[index].name,
          contact: farmers[index].contact,
          status: farmers[index].status,
          isSuperAdmin: true,
          superAdminLevel: getSuperAdminLevelText(),
        );
        farmers.refresh();
      }

      resetSuperAdminSelection();
      Get.back(); // Close bottom sheet

      UiUtils.showSuccessSnackbar(
        'Success',
        'Super Admin assigned successfully',
      );
    } catch (e) {
      print('Error assigning super admin: $e');
      UiUtils.showErrorSnackbar(
        'Error',
        'Failed to assign super admin: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }
}
