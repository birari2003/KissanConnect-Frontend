// registration_form.dart

import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/ui_utils.dart';
import '../services/farmerServices.dart';
import '../services/adminServices.dart';

// Dummy implementations for compilation
class AuthService {
  Future<bool> isSessionValid() async => true;
}

class NewAuthScreen extends StatelessWidget {
  final String selectedLanguage;
  const NewAuthScreen({super.key, required this.selectedLanguage});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Auth Screen')));
}

// Searchable Dropdown Modal Widget
class SearchableDropdownModal extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final String? selectedValue;
  final Function(String?, String?) onChanged;
  final String Function(dynamic) getItemId;
  final String Function(dynamic) getItemName;

  const SearchableDropdownModal({
    super.key,
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.getItemId,
    required this.getItemName,
  });

  @override
  State<SearchableDropdownModal> createState() =>
      _SearchableDropdownModalState();
}

class _SearchableDropdownModalState extends State<SearchableDropdownModal> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final name = widget.getItemName(item).toLowerCase();
          return name.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.green.shade600,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Items list
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final itemId = widget.getItemId(item);
                      final itemName = widget.getItemName(item);
                      final isSelected = itemId == widget.selectedValue;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              widget.onChanged(itemId, itemName);
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green.shade50
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.green.shade300
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      itemName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.green.shade800
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green.shade700,
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  final String selectedLanguage;
  const RegistrationForm({super.key, required this.selectedLanguage});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _farmerNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _landAreaController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _familyInfoController = TextEditingController();
  final TextEditingController _cropDescriptionController =
      TextEditingController();
  final TextEditingController _poultryInfoController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  // Existing controllers
  // final TextEditingController _cityController = TextEditingController();
  // final TextEditingController _districtController = TextEditingController();
  // final TextEditingController _stateController = TextEditingController();
  // final TextEditingController _villageController = TextEditingController();

  final FarmerService _farmerService = FarmerService();

  // State variables
  String? selectedGender;
  String? selectedCultivationType;
  String? selectedTrainingType;
  String? selectedWorkType;
  String? selectedSoilType;
  DateTime? _selectedDate;
  File? _passportPhoto;
  List<String> selectedCrops = [];
  List<String> selectedIrrigationSources = [];
  List<String> selectedCattle = [];

  // Location Data
  final AdminService _adminService = AdminService();
  List<dynamic> states = [];
  List<dynamic> districts = [];
  List<dynamic> talukas = [];
  List<dynamic> villages = [];

  String? selectedStateId;
  String? selectedDistrictId;
  String? selectedTalukaId;
  String? selectedVillageId;

  // Names for submission
  String? selectedStateName;
  String? selectedDistrictName;
  String? selectedTalukaName;
  String? selectedVillageName;

  // Validation errors for dropdowns
  String? stateError;
  String? districtError;
  String? talukaError;
  String? villageError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _checkLoginStatus();
    _fetchStates();
    _loadUserData(); // Load user data to auto-populate fields
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);

        if (mounted) {
          setState(() {
            // Auto-populate name, email, and phone from user data
            if (userData['name'] != null) {
              _farmerNameController.text = userData['name'];
            }
            if (userData['email'] != null &&
                userData['email'].toString().isNotEmpty) {
              _emailController.text = userData['email'];
            }
            if (userData['phone'] != null) {
              _contactController.text = userData['phone'];
            }
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Continue without auto-populating if there's an error
    }
  }

  Future<void> _fetchStates() async {
    try {
      final data = await _adminService.getStates();
      if (mounted) {
        setState(() {
          states = data;
        });
      }
    } catch (e) {
      print('Error fetching states: $e');
    }
  }

  Future<void> _onStateChanged(String? stateId) async {
    if (stateId == null) return;
    final state = states.firstWhere(
      (element) => element['id'].toString() == stateId,
    );
    setState(() {
      selectedStateId = stateId;
      selectedStateName = state['name'];
      selectedDistrictId = null;
      selectedDistrictName = null;
      selectedTalukaId = null;
      selectedTalukaName = null;
      selectedVillageId = null;
      selectedVillageName = null;
      districts = [];
      talukas = [];
      villages = [];
    });

    try {
      final data = await _adminService.getDistrictsByState(stateId);
      if (mounted) {
        setState(() {
          districts = data;
        });
      }
    } catch (e) {
      print('Error fetching districts: $e');
    }
  }

  Future<void> _onDistrictChanged(String? districtId) async {
    if (districtId == null) return;
    final district = districts.firstWhere(
      (element) => element['id'].toString() == districtId,
    );
    setState(() {
      selectedDistrictId = districtId;
      selectedDistrictName = district['name'];
      selectedTalukaId = null;
      selectedTalukaName = null;
      selectedVillageId = null;
      selectedVillageName = null;
      talukas = [];
      villages = [];
    });

    try {
      final data = await _adminService.getTalukasByDistrict(districtId);
      if (mounted) {
        setState(() {
          talukas = data;
        });
      }
    } catch (e) {
      print('Error fetching talukas: $e');
    }
  }

  void _onTalukaChanged(String? talukaId) {
    if (talukaId == null) return;
    final taluka = talukas.firstWhere(
      (element) => element['id'].toString() == talukaId,
    );
    setState(() {
      selectedTalukaId = talukaId;
      selectedTalukaName = taluka['name'];
      selectedVillageId = null;
      selectedVillageName = null;
      villages = taluka['villages'] ?? [];
    });
  }

  void _onVillageChanged(String? villageId) {
    if (villageId == null) return;
    final village = villages.firstWhere(
      (element) => element['id'].toString() == villageId,
    );
    setState(() {
      selectedVillageId = villageId;
      selectedVillageName = village['name'];
    });
  }

  // Translations
  final Map<String, Map<String, dynamic>> translations = {
    'en-US': {
      'title': 'Farmer Registration',
      'personalInfo': 'Personal Information',
      'farmerName': 'Farmer Name',
      'age': 'Age',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'other': 'Other',
      'contact': 'Mobile Number',
      'aadharCard': 'Aadhaar Card Number',
      'address': 'Address',
      'city': 'City', // Added
      'district': 'District', // Added
      ''
              'state':
          'State', // Added
      'village': 'Village', // Added
      'email': 'Email (Optional)',
      'dob': 'Date of Birth',
      'selectDate': 'Select Date',
      'passportPhoto': 'Passport Size Photo',
      'uploadPhoto': 'Upload Photo',
      'farmInfo': 'Farm Information',
      'landArea': 'Land Area (in Acres)',
      'soilType': 'Soil Type',
      'soilTypes': [
        'Alluvial',
        'Black',
        'Red',
        'Laterite',
        'Desert',
        'Mountain',
      ],
      'irrigationSources': 'Sources of Irrigation',
      'irrigationOptions': [
        'Well',
        'Borewell',
        'Canal',
        'River',
        'Pond',
        'Other',
      ],
      'farmingDetails': 'Farming Details',
      'cropsGrown': 'Crops Grown (Select multiple)',
      'cultivationType': 'Cultivation Method',
      'traditional': 'Traditional',
      'modern': 'Modern',
      'organic': 'Organic',
      'cropDescription': 'Description of Crops',
      'otherInfo': 'Other Information',
      'occupation': 'Occupation',
      'familyInfo': 'Family Information',
      'workType': 'Additional Work Type',
      'workTypes': ['Extra Work/Job', 'Business/Support Work'],
      'cattleBreeder': 'Cattle Owned (Select multiple)',
      'cattleOptions': ['Cow', 'Buffalo', 'Goat', 'Sheep', 'None'],
      'poultryInfo': 'Poultry Information (e.g., number of chickens)',
      'trainingProgram': 'Training Programs',
      'trainingType': 'Select Training Type',
      'feedback': 'Feedback / Opinion',
      'submit': 'Submit Registration',
      'reset': 'Reset Form',
      'crops': [
        'Wheat',
        'Rice',
        'Corn',
        'Soybean',
        'Sugarcane',
        'Cotton',
        'Gram',
        'Sunflower',
      ],
      'trainings': [
        'Modern Farming Techniques',
        'Organic Farming',
        'Pest Management',
        'Soil Health',
      ],
      'requiredField': 'This field is required',
      'invalidContact': 'Please enter a valid 10-digit mobile number',
      'invalidAadhar': 'Please enter a valid 12-digit Aadhaar number',
      'invalidEmail': 'Please enter a valid email address',
      'optional': 'Optional',
    },
    'hi-IN': {
      'title': 'किसान पंजीकरण फॉर्म',
      'personalInfo': 'व्यक्तिगत जानकारी',
      'farmerName': 'किसान का नाम',
      'age': 'उम्र',
      'gender': 'लिंग',
      'male': 'पुरुष',
      'female': 'महिला',
      'other': 'अन्य',
      'contact': 'मोबाइल नंबर',
      'aadharCard': 'आधार कार्ड नंबर',
      'address': 'पता',
      'city': 'शहर', // Added
      'district': 'जिला', // Added
      'state': 'राज्य', // Added
      'village': 'गाँव', // Added
      'email': 'ईमेल (वैकल्पिक)',
      'dob': 'जन्म तिथि',
      'selectDate': 'तारीख चुनें',
      'passportPhoto': 'पासपोर्ट साइज फोटो',
      'uploadPhoto': 'फोटो अपलोड करें',
      'farmInfo': 'खेत की जानकारी',
      'landArea': 'भूमि क्षेत्र (एकड़ में)',
      'soilType': 'मिट्टी का प्रकार',
      'soilTypes': ['जलोढ़', 'काली', 'लाल', 'लैटेराइट', 'रेगिस्तानी', 'पहाड़ी'],
      'irrigationSources': 'सिंचाई के स्रोत',
      'irrigationOptions': ['कुआं', 'बोरवेल', 'नहर', 'नदी', 'तालाब', 'अन्य'],
      'farmingDetails': 'खेती का विवरण',
      'cropsGrown': 'उगाई जाने वाली फसलें (कई चुनें)',
      'cultivationType': 'खेती की विधि',
      'traditional': 'पारंपरिक',
      'modern': 'आधुनिक',
      'organic': 'जैविक',
      'cropDescription': 'फसलों का विवरण',
      'otherInfo': 'अन्य जानकारी',
      'occupation': 'व्यवसाय',
      'familyInfo': 'परिवार की जानकारी',
      'workType': 'अतिरिक्त कार्य प्रकार',
      'workTypes': ['अतिरिक्त काम/नौकरी', 'व्यवसाय/सहायक कार्य'],
      'cattleBreeder': 'पालतू पशु (कई चुनें)',
      'cattleOptions': ['गाय', 'भैंस', 'बकरी', ' भेड़', 'कोई नहीं'],
      'poultryInfo': 'मुर्गीपालन की जानकारी (जैसे, मुर्गियों की संख्या)',
      'trainingProgram': 'प्रशिक्षण कार्यक्रम',
      'trainingType': 'प्रशिक्षण प्रकार चुनें',
      'feedback': 'प्रतिक्रिया / राय',
      'submit': 'पंजीकरण जमा करें',
      'reset': 'फॉर्म रीसेट करें',
      'crops': [
        'गेहूं',
        'चावल',
        'मक्का',
        'सोयाबीन',
        'गन्ना',
        'कपास',
        'चना',
        'सूरजमुखी',
      ],
      'pendingApproval': 'Your request is pending approval',
      'approved': 'Your application has been approved!',
      'errorLoading': 'Error loading farmer information',
      'noData': 'No farmer data found',
      'loading': 'Loading...',
      'trainings': [
        'आधुनिक कृषि तकनीक',
        'जैविक खेती',
        'कीट प्रबंधन',
        'मृदा स्वास्थ्य',
      ],
      'requiredField': 'यह फ़ील्ड आवश्यक है',
      'invalidContact': 'कृपया एक वैध 10-अंकीय मोबाइल नंबर दर्ज करें',
      'invalidAadhar': 'कृपया एक वैध 12-अंकीय आधार संख्या दर्ज करें',
      'invalidEmail': 'कृपया एक वैध ईमेल पता दर्ज करें',
      'optional': 'वैकल्पिक',
    },
    'mr-IN': {
      'title': 'शेतकरी नोंदणी फॉर्म',
      'personalInfo': 'वैयक्तिक माहिती',
      'farmerName': 'शेतकऱ्याचे नाव',
      'age': 'वय',
      'gender': 'लिंग',
      'male': 'पुरुष',
      'female': 'महिला',
      'other': 'इतर',
      'contact': 'मोबाइल नंबर',
      'aadharCard': 'आधार कार्ड नंबर',
      'address': 'पत्ता',
      'city': 'शहर', // Added
      'district': 'जिल्हा', // Added
      'state': 'राज्य', // Added
      'village': 'गाव', // Added
      'email': 'ईमेल (पर्यायी)',
      'dob': 'जन्म तारीख',
      'selectDate': 'तारीख निवडा',
      'passportPhoto': 'पासपोर्ट आकाराचा फोटो',
      'uploadPhoto': 'फोटो अपलोड करा',
      'farmInfo': 'शेतीची माहिती',
      'landArea': 'जमीन क्षेत्र (एकर मध्ये)',
      'soilType': 'मातीचा प्रकार',
      'soilTypes': ['गाळाची', 'काळी', 'लाल', 'जांभी', 'वाळवंटी', 'पर्वतीय'],
      'irrigationSources': 'सिंचनाचे स्रोत',
      'irrigationOptions': ['विहीर', 'बोरवेल', 'कालवा', 'नदी', 'तलाव', 'इतर'],
      'farmingDetails': 'शेती तपशील',
      'cropsGrown': 'पिकवलेली पिके (अनेक निवडा)',
      'cultivationType': 'लागवड पद्धत',
      'traditional': 'पारंपारिक',
      'modern': 'आधुनिक',
      'organic': 'सेंद्रिय',
      'cropDescription': 'पिकांचे वर्णन',
      'otherInfo': 'इतर माहिती',
      'occupation': 'व्यवसाय',
      'familyInfo': 'कौटुंबिक माहिती',
      'workType': 'अतिरिक्त कामाचा प्रकार',
      'workTypes': ['अतिरिक्त काम/नोकरी', 'व्यवसाय/सहाय्यक काम'],
      'cattleBreeder': 'मालकीची गुरे (अनेक निवडा)',
      'cattleOptions': ['गाय', 'म्हैस', 'शेळी', 'मेंढी', 'काहीही नाही'],
      'poultryInfo': 'पोल्ट्री माहिती (उदा. कोंबड्यांची संख्या)',
      'trainingProgram': 'प्रशिक्षण कार्यक्रम',
      'trainingType': 'प्रशिक्षण प्रकार निवडा',
      'feedback': 'अभिप्राय / मत',
      'submit': 'नोंदणी सादर करा',
      'reset': 'फॉर्म रीसेट करा',
      'crops': [
        'गहू',
        'तांदूळ',
        'मका',
        'सोयाबीन',
        'ऊस',
        'कापूस',
        'हरभरा',
        'सूर्यफूल',
      ],
      'trainings': [
        'आधुनिक शेती तंत्रज्ञान',
        'सेंद्रिय शेती',
        'कीड व्यवस्थापन',
        'जमिनीचे आरोग्य',
      ],
      'requiredField': 'हे फील्ड आवश्यक आहे',
      'invalidContact': 'कृपया वैध १०-अंकी मोबाइल नंबर प्रविष्ट करा',
      'invalidAadhar': 'कृपया वैध १२-अंकी आधार क्रमांक प्रविष्ट करा',
      'invalidEmail': 'कृपया वैध ईमेल पत्ता प्रविष्ट करा',
      'optional': 'पर्यायी',
    },
  };

  // Get the selected language from the parent widget
  String get selectedLanguage => widget.selectedLanguage;

  String getText(String key) {
    final languageMap = translations[selectedLanguage];
    if (languageMap == null || !languageMap.containsKey(key)) {
      // Fallback to English if selected language or key is not found
      return translations['en-US']?[key] ?? key;
    }
    return languageMap[key] ?? key;
  }

  List<String> getList(String key) {
    final languageMap = translations[selectedLanguage];
    if (languageMap == null || !languageMap.containsKey(key)) {
      // Fallback to English if selected language or key is not found
      return List<String>.from(translations['en-US']?[key] ?? []);
    }
    return List<String>.from(languageMap[key] ?? []);
  }

  Future<void> _checkLoginStatus() async {
    final authService = AuthService();
    final isLoggedIn = await authService.isSessionValid();
    if (!isLoggedIn && mounted) {
      // If not logged in, navigate to auth screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const NewAuthScreen(selectedLanguage: 'en-US'),
        ),
      );
    }
  }

  // Dispose all controllers
  @override
  void dispose() {
    _animationController.dispose();
    _farmerNameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _aadharController.dispose();
    _landAreaController.dispose();
    _addressController.dispose();
    // _cityController.dispose();
    // _districtController.dispose();
    // _stateController.dispose();
    // _villageController.dispose(); // Dispose new controller
    _emailController.dispose();
    _dobController.dispose();
    _occupationController.dispose();
    _familyInfoController.dispose();
    _cropDescriptionController.dispose();
    _poultryInfoController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  // --- Helper Functions ---
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      // Try to get the image from the gallery
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
      );
      if (image == null) return; // User canceled the picker
      // Handle the image file
      try {
        // On web, we can use the XFile directly
        if (kIsWeb) {
          if (mounted) {
            setState(() {
              _passportPhoto = File(image.path);
            });
          }
          return;
        }
        // For mobile/desktop, check if the file exists and is valid
        final file = File(image.path);
        final exists = await file.exists();
        if (!exists) {
          // If file doesn't exist, try to get it from the cache
          final bytes = await image.readAsBytes();
          final tempDir = await getTemporaryDirectory();
          final tempFile = File(
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          await tempFile.writeAsBytes(bytes);
          if (mounted) {
            setState(() {
              _passportPhoto = tempFile;
            });
          }
          return;
        }
        // Check file size if file exists
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('Image size should be less than 5MB');
        }
        if (mounted) {
          setState(() {
            _passportPhoto = file;
          });
        }
      } catch (e) {
        // If we get a _Namespace error, try to read the file as bytes
        if (e.toString().contains('_Namespace')) {
          try {
            final bytes = await image.readAsBytes();
            final tempDir = await getTemporaryDirectory();
            final tempFile = File(
              '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
            await tempFile.writeAsBytes(bytes);
            if (mounted) {
              setState(() {
                _passportPhoto = tempFile;
              });
            }
          } catch (e) {
            _showError('Failed to process image: ${e.toString()}');
          }
        } else {
          rethrow;
        }
      }
    } catch (e) {
      _showError('Error selecting image: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (mounted) {
      UiUtils.showErrorSnackbar('Error', message);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate searchable dropdowns
    bool hasDropdownErrors = false;
    setState(() {
      stateError = selectedStateId == null ? getText('requiredField') : null;
      districtError = selectedDistrictId == null
          ? getText('requiredField')
          : null;
      talukaError = selectedTalukaId == null ? getText('requiredField') : null;
      villageError = selectedVillageId == null
          ? getText('requiredField')
          : null;

      hasDropdownErrors =
          stateError != null ||
          districtError != null ||
          talukaError != null ||
          villageError != null;
    });

    if (hasDropdownErrors) {
      UiUtils.showErrorSnackbar(
        'Error',
        'Please fill all required location fields',
      );
      return;
    }

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userDataString = prefs.getString('user_data');

      if (token == null || userDataString == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Extract user ID from user_data JSON
      final userData = jsonDecode(userDataString);
      final userId = userData['id'];

      if (userId == null) {
        throw Exception('User ID not found. Please log in again.');
      }

      // Create the farmer info map
      final Map<String, dynamic> farmerData = {
        'user_id': userId is int ? userId : int.parse(userId.toString()),

        'farmer_name': _farmerNameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'gender': selectedGender,
        'contact_number': _contactController.text.trim(),
        'aadhar_number': _aadharController.text.trim(),
        'dob': _selectedDate?.toIso8601String().split('T')[0],
        'address': _addressController.text.trim(),
        'village': selectedVillageName,
        'city': selectedTalukaName,
        'district': selectedDistrictName,
        'state': selectedStateName,
        'email': _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        'land_area': double.tryParse(_landAreaController.text.trim()),
        'soil_type': selectedSoilType,
        'irrigation_sources': selectedIrrigationSources,
        'crops': selectedCrops,
        'cultivation_type': selectedCultivationType,
        'crop_description': _cropDescriptionController.text.trim(),
        'occupation': _occupationController.text.trim(),
        'family_info': _familyInfoController.text.trim(),
        'work_type': selectedWorkType,
        'cattle': selectedCattle,
        'poultry_info': _poultryInfoController.text.trim(),
        'training_type': selectedTrainingType,
        'feedback': _feedbackController.text.trim(),
        'language_code': widget.selectedLanguage,
      };

      // Add passport photo if available
      if (_passportPhoto != null) {
        try {
          final List<int> imageBytes = await _passportPhoto!.readAsBytes();
          if (imageBytes.isNotEmpty) {
            farmerData['passport_photo'] = base64Encode(imageBytes);
          }
        } catch (e) {
          print('Error reading image file: $e');
          // Continue without the photo if there's an error
        }
      }

      // Call the service
      final response = await _farmerService.registerFarmerProfile(farmerData);

      if (mounted) {
        _resetForm();
        UiUtils.showSuccessSnackbar(
          'Success',
          response['message'] ?? 'Farmer information submitted successfully!',
        );
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackbar('Error', e.toString());
      }
      print('Error submitting form: $e');
    } on SocketException catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackbar('Error', e.toString());
      }
      print('Error submitting form: $e');
    } on HttpException catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackbar('Error', e.toString());
      }
      print('Error submitting form: $e');
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackbar('Error', e.toString());
      }
      print('Error submitting form: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _farmerNameController.clear();
      _ageController.clear();
      _contactController.clear();
      _aadharController.clear();
      _landAreaController.clear();
      _landAreaController.clear();
      _addressController.clear();
      // _cityController.clear();
      // _districtController.clear();
      // _stateController.clear();
      // _villageController.clear(); // Clear new controller
      selectedStateId = null;
      selectedDistrictId = null;
      selectedTalukaId = null;
      selectedVillageId = null;
      selectedStateName = null;
      selectedDistrictName = null;
      selectedTalukaName = null;
      selectedVillageName = null;
      districts = [];
      talukas = [];
      villages = [];
      // Clear validation errors
      stateError = null;
      districtError = null;
      talukaError = null;
      villageError = null;
      _emailController.clear();
      _dobController.clear();
      _occupationController.clear();
      _familyInfoController.clear();
      _cropDescriptionController.clear();
      _poultryInfoController.clear();
      _feedbackController.clear();
      selectedGender = null;
      selectedCultivationType = null;
      selectedTrainingType = null;
      selectedWorkType = null;
      selectedSoilType = null;
      _selectedDate = null;
      _passportPhoto = null;
      selectedCrops.clear();
      selectedIrrigationSources.clear();
      selectedCattle.clear();
    });
  }

  // --- UI Builder Widgets ---
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    TextEditingController controller, {
    bool isRequired = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator:
            validator ??
            (isRequired
                ? (value) {
                    if (value == null || value.isEmpty)
                      return getText('requiredField');
                    return null;
                  }
                : null),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.green.shade800),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade600, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        validator: isRequired
            ? (val) =>
                  (val == null || val.isEmpty) ? getText('requiredField') : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.green.shade800),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items
            .map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMultiSelect(
    String title,
    List<String> allItems,
    List<String> selectedItems,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allItems.map((item) {
                bool isSelected = selectedItems.contains(item);
                return FilterChip(
                  label: Text(item),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedItems.add(item);
                      } else {
                        selectedItems.remove(item);
                      }
                    });
                  },
                  selectedColor: Colors.green.shade200,
                  checkmarkColor: Colors.green.shade800,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Custom searchable dropdown widget
  Widget _buildSearchableDropdown({
    required String label,
    required String? selectedValue,
    required String? selectedDisplayText,
    required List<dynamic> items,
    required Function(String?, String?) onChanged,
    required String Function(dynamic) getItemId,
    required String Function(dynamic) getItemName,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: items.isEmpty
                ? null
                : () => _showSearchableDropdownModal(
                    context: context,
                    title: label,
                    items: items,
                    selectedValue: selectedValue,
                    onChanged: onChanged,
                    getItemId: getItemId,
                    getItemName: getItemName,
                  ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: errorText != null
                      ? Colors.red.shade400
                      : Colors.grey.shade400,
                  width: errorText != null ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: items.isEmpty ? Colors.grey.shade100 : Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDisplayText ?? label,
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedDisplayText == null
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: items.isEmpty
                        ? Colors.grey.shade400
                        : Colors.green.shade700,
                  ),
                ],
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Text(
                errorText,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  void _showSearchableDropdownModal({
    required BuildContext context,
    required String title,
    required List<dynamic> items,
    required String? selectedValue,
    required Function(String?, String?) onChanged,
    required String Function(dynamic) getItemId,
    required String Function(dynamic) getItemName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SearchableDropdownModal(
          title: title,
          items: items,
          selectedValue: selectedValue,
          onChanged: onChanged,
          getItemId: getItemId,
          getItemName: getItemName,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF2E8B57),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    getText('title'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2E8B57),
                          const Color(0xFF5CC96F),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -30,
                          top: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -50,
                          bottom: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Personal Information ---
                          _buildSectionTitle(
                            getText('personalInfo'),
                            Icons.person,
                            Colors.blue.shade700,
                          ),
                          _buildTextFormField(
                            getText('farmerName'),
                            _farmerNameController,
                          ),
                          _buildTextFormField(
                            getText('age'),
                            _ageController,
                            keyboardType: TextInputType.number,
                          ),
                          _buildDropdown(
                            getText('gender'),
                            selectedGender,
                            [
                              getText('male'),
                              getText('female'),
                              getText('other'),
                            ],
                            (v) => setState(() => selectedGender = v),
                          ),
                          _buildTextFormField(
                            getText('contact'),
                            _contactController,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return getText('requiredField');
                              if (v.length != 10)
                                return getText('invalidContact');
                              return null;
                            },
                          ),
                          _buildTextFormField(
                            getText('aadharCard'),
                            _aadharController,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return getText('requiredField');
                              if (v.length != 12)
                                return getText('invalidAadhar');
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: getText('dob'),
                              labelStyle: TextStyle(
                                color: Colors.green.shade800,
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.green.shade700,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onTap: () => _selectDate(context),
                            validator: (v) => (v == null || v.isEmpty)
                                ? getText('requiredField')
                                : null,
                          ),
                          const SizedBox(height: 16),
                          // State Dropdown
                          _buildSearchableDropdown(
                            label: getText('state'),
                            selectedValue: selectedStateId,
                            selectedDisplayText: selectedStateName,
                            items: states,
                            onChanged: (id, name) {
                              setState(() {
                                stateError = null;
                              });
                              _onStateChanged(id);
                            },
                            getItemId: (item) => item['id'].toString(),
                            getItemName: (item) => item['name'],
                            errorText: stateError,
                          ),

                          // District Dropdown
                          _buildSearchableDropdown(
                            label: getText('district'),
                            selectedValue: selectedDistrictId,
                            selectedDisplayText: selectedDistrictName,
                            items: districts,
                            onChanged: (id, name) {
                              setState(() {
                                districtError = null;
                              });
                              _onDistrictChanged(id);
                            },
                            getItemId: (item) => item['id'].toString(),
                            getItemName: (item) => item['name'],
                            errorText: districtError,
                          ),

                          // Taluka Dropdown
                          _buildSearchableDropdown(
                            label: 'Taluka',
                            selectedValue: selectedTalukaId,
                            selectedDisplayText: selectedTalukaName,
                            items: talukas,
                            onChanged: (id, name) {
                              setState(() {
                                talukaError = null;
                              });
                              _onTalukaChanged(id);
                            },
                            getItemId: (item) => item['id'].toString(),
                            getItemName: (item) => item['name'],
                            errorText: talukaError,
                          ),

                          // Village Dropdown
                          _buildSearchableDropdown(
                            label: getText('village'),
                            selectedValue: selectedVillageId,
                            selectedDisplayText: selectedVillageName,
                            items: villages,
                            onChanged: (id, name) {
                              setState(() {
                                villageError = null;
                              });
                              _onVillageChanged(id);
                            },
                            getItemId: (item) => item['id'].toString(),
                            getItemName: (item) => item['name'],
                            errorText: villageError,
                          ),

                          _buildTextFormField(
                            getText('email'),
                            _emailController,
                            isRequired: false,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v != null &&
                                  v.isNotEmpty &&
                                  !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                                return getText('invalidEmail');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${getText('passportPhoto')} (${getText('optional')})',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _pickImage,
                                child: Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: _passportPhoto == null
                                      ? Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.add_a_photo,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                getText('uploadPhoto'),
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                              child: Image.file(
                                                _passportPhoto!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _passportPhoto = null;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                          // --- Farm Information ---
                          _buildSectionTitle(
                            getText('farmInfo'),
                            Icons.eco,
                            Colors.green.shade800,
                          ),
                          _buildTextFormField(
                            getText('landArea'),
                            _landAreaController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          _buildDropdown(
                            getText('soilType'),
                            selectedSoilType,
                            getList('soilTypes'),
                            (v) => setState(() => selectedSoilType = v),
                          ),
                          _buildMultiSelect(
                            getText('irrigationSources'),
                            getList('irrigationOptions'),
                            selectedIrrigationSources,
                          ),
                          // --- Farming Details ---
                          _buildSectionTitle(
                            getText('farmingDetails'),
                            Icons.agriculture,
                            Colors.orange.shade800,
                          ),
                          _buildMultiSelect(
                            getText('cropsGrown'),
                            getList('crops'),
                            selectedCrops,
                          ),
                          _buildDropdown(
                            getText('cultivationType'),
                            selectedCultivationType,
                            [
                              getText('traditional'),
                              getText('modern'),
                              getText('organic'),
                            ],
                            (v) => setState(() => selectedCultivationType = v),
                          ),
                          _buildTextFormField(
                            getText('cropDescription'),
                            _cropDescriptionController,
                            isRequired: false,
                            maxLines: 3,
                          ),
                          // --- Other Information ---
                          _buildSectionTitle(
                            getText('otherInfo'),
                            Icons.info,
                            Colors.purple.shade700,
                          ),
                          _buildTextFormField(
                            getText('occupation'),
                            _occupationController,
                          ),
                          _buildTextFormField(
                            getText('familyInfo'),
                            _familyInfoController,
                            isRequired: false,
                            maxLines: 2,
                          ),
                          _buildDropdown(
                            getText('workType'),
                            selectedWorkType,
                            getList('workTypes'),
                            (v) => setState(() => selectedWorkType = v),
                            isRequired: false,
                          ),
                          _buildMultiSelect(
                            getText('cattleBreeder'),
                            getList('cattleOptions'),
                            selectedCattle,
                          ),
                          _buildTextFormField(
                            getText('poultryInfo'),
                            _poultryInfoController,
                            isRequired: false,
                          ),
                          _buildDropdown(
                            getText('trainingType'),
                            selectedTrainingType,
                            getList('trainings'),
                            (v) => setState(() => selectedTrainingType = v),
                            isRequired: false,
                          ),
                          _buildTextFormField(
                            getText('feedback'),
                            _feedbackController,
                            isRequired: false,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 30),
                          // --- Action Buttons ---
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _resetForm,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  child: Text(
                                    getText('reset'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: _isSubmitting
                                      ? null
                                      : _submitForm, // Disable button when submitting
                                  icon: _isSubmitting
                                      ? Container(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.white,
                                        ),
                                  label: Text(
                                    getText('submit'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
