import 'package:get/get.dart';

class Farmer {
  final String id;
  final String name;
  final String contact;
  final String status; // 'pending', 'approved', 'rejected'
  final bool isSuperAdmin;
  final String? superAdminLevel; // 'State: Maharashtra > District: Pune'

  Farmer({
    required this.id,
    required this.name,
    required this.contact,
    required this.status,
    this.isSuperAdmin = false,
    this.superAdminLevel,
  });
}

class FarmerslistController extends GetxController {
  // Observable list of farmers
  final farmers = <Farmer>[].obs;
  
  // Filter options
  final selectedFilter = 'all'.obs; // 'all', 'pending', 'approved', 'rejected'
  
  // Super admin assignment state
  final selectedState = Rxn<String>();
  final selectedDistrict = Rxn<String>();
  final selectedCity = Rxn<String>();
  final selectedVillage = Rxn<String>();
  
  // Location data (mock data - replace with API calls)
  final states = <String>[
    'Maharashtra',
    'Gujarat',
    'Karnataka',
    'Tamil Nadu',
    'Uttar Pradesh',
  ].obs;
  
  final districts = <String, List<String>>{
    'Maharashtra': ['Pune', 'Mumbai', 'Nagpur', 'Nashik', 'Aurangabad'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot'],
    'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Mangalore'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Agra', 'Varanasi'],
  };
  
  final cities = <String, List<String>>{
    'Pune': ['Kothrud', 'Shivajinagar', 'Hadapsar', 'Wakad', 'Hinjewadi'],
    'Mumbai': ['Andheri', 'Bandra', 'Borivali', 'Dadar', 'Thane'],
    'Nagpur': ['Sitabuldi', 'Dharampeth', 'Sadar', 'Kamptee'],
    'Ahmedabad': ['Satellite', 'Navrangpura', 'Maninagar', 'Vastrapur'],
    'Bangalore': ['Koramangala', 'Indiranagar', 'Whitefield', 'Jayanagar'],
  };
  
  final villages = <String, List<String>>{
    'Kothrud': ['Karve Nagar', 'Paud Road', 'Mayur Colony', 'Dahanukar Colony'],
    'Shivajinagar': ['Deccan', 'JM Road', 'Nal Stop', 'Shivaji Market'],
    'Hadapsar': ['Magarpatta', 'Mundhwa', 'Wanowrie', 'Fatimanagar'],
    'Andheri': ['Versova', 'Lokhandwala', 'Oshiwara', 'Chakala'],
    'Koramangala': ['5th Block', '6th Block', '7th Block', '8th Block'],
  };

  @override
  void onInit() {
    super.onInit();
    loadFarmers();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void loadFarmers() {
    // Mock data - replace with API call
    farmers.value = [
      Farmer(
        id: '1',
        name: 'Ramesh Kumar',
        contact: '+91 9876543210',
        status: 'pending',
      ),
      Farmer(
        id: '2',
        name: 'Suresh Patil',
        contact: '+91 9876543211',
        status: 'approved',
      ),
      Farmer(
        id: '3',
        name: 'Mahesh Deshmukh',
        contact: '+91 9876543212',
        status: 'approved',
        isSuperAdmin: true,
        superAdminLevel: 'Maharashtra > Pune > Kothrud',
      ),
      Farmer(
        id: '4',
        name: 'Ganesh Jadhav',
        contact: '+91 9876543213',
        status: 'rejected',
      ),
      Farmer(
        id: '5',
        name: 'Rajesh Sharma',
        contact: '+91 9876543214',
        status: 'pending',
      ),
      Farmer(
        id: '6',
        name: 'Prakash Yadav',
        contact: '+91 9876543215',
        status: 'approved',
      ),
    ];
  }

  List<Farmer> get filteredFarmers {
    if (selectedFilter.value == 'all') {
      return farmers;
    }
    return farmers.where((f) => f.status == selectedFilter.value).toList();
  }

  void approveFarmer(String farmerId) {
    final index = farmers.indexWhere((f) => f.id == farmerId);
    if (index != -1) {
      farmers[index] = Farmer(
        id: farmers[index].id,
        name: farmers[index].name,
        contact: farmers[index].contact,
        status: 'approved',
        isSuperAdmin: farmers[index].isSuperAdmin,
        superAdminLevel: farmers[index].superAdminLevel,
      );
      farmers.refresh();
      Get.snackbar(
        'Success',
        'Farmer approved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        duration: Duration(seconds: 2),
      );
    }
  }

  void rejectFarmer(String farmerId) {
    final index = farmers.indexWhere((f) => f.id == farmerId);
    if (index != -1) {
      farmers[index] = Farmer(
        id: farmers[index].id,
        name: farmers[index].name,
        contact: farmers[index].contact,
        status: 'rejected',
        isSuperAdmin: false,
        superAdminLevel: null,
      );
      farmers.refresh();
      Get.snackbar(
        'Success',
        'Farmer rejected',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        duration: Duration(seconds: 2),
      );
    }
  }

  void resetSuperAdminSelection() {
    selectedState.value = null;
    selectedDistrict.value = null;
    selectedCity.value = null;
    selectedVillage.value = null;
  }

  List<String> getDistricts() {
    if (selectedState.value == null) return [];
    return districts[selectedState.value] ?? [];
  }

  List<String> getCities() {
    if (selectedDistrict.value == null) return [];
    return cities[selectedDistrict.value] ?? [];
  }

  List<String> getVillages() {
    if (selectedCity.value == null) return [];
    return villages[selectedCity.value] ?? [];
  }

  String getSuperAdminLevelText() {
    List<String> levels = [];
    if (selectedState.value != null) levels.add(selectedState.value!);
    if (selectedDistrict.value != null) levels.add(selectedDistrict.value!);
    if (selectedCity.value != null) levels.add(selectedCity.value!);
    if (selectedVillage.value != null) levels.add(selectedVillage.value!);
    return levels.isEmpty ? 'No level selected' : levels.join(' > ');
  }

  void assignSuperAdmin(String farmerId) {
    if (selectedState.value == null) {
      Get.snackbar(
        'Error',
        'Please select at least a state',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      );
      return;
    }

    final index = farmers.indexWhere((f) => f.id == farmerId);
    if (index != -1) {
      farmers[index] = Farmer(
        id: farmers[index].id,
        name: farmers[index].name,
        contact: farmers[index].contact,
        status: farmers[index].status,
        isSuperAdmin: true,
        superAdminLevel: getSuperAdminLevelText(),
      );
      farmers.refresh();
      resetSuperAdminSelection();
      Get.back(); // Close bottom sheet
      Get.snackbar(
        'Success',
        '${farmers[index].name} assigned as Super Admin',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        duration: Duration(seconds: 2),
      );
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }
}
