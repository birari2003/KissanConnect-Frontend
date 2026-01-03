import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widhets/subscriptionPopUp.dart';
import '../../../services/farmerServices.dart';
import '../../../services/translation_service.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../../controllers/subscription_controller.dart';

enum RequestStatus { accepted, rejected, pending }

class FarmerscreendashboardController extends GetxController {
  final FarmerService _farmerService = FarmerService();
  final TranslationService _translationService = TranslationService();

  // Bottom navigation
  final RxInt currentTabIndex = 0.obs;
  // Side navigation
  final RxBool isNavigationOpen = false.obs;
  final RxInt selectedIndex = 0
      .obs; // 0: Dashboard, 1: Registration, 2: Crop Claim, 3: Settings, 4: Sell Crop, 5: Marketplace, 6: Gov Schemes, 7: Job Application

  // Request status - this will determine which scenario to show
  final Rx<RequestStatus> requestStatus = RequestStatus.pending.obs;

  // User data from SharedPreferences
  final RxString farmerName = 'Loading...'.obs;
  final RxString farmerEmail = ''.obs;
  final RxString farmerPhone = ''.obs;
  final RxString farmLocation = translate('my_location').obs;
  final RxString farmerPhoto = ''.obs;

  // Sample data for dashboard (can be replaced with real API data later)
  final RxInt totalRequests = 0.obs;
  final RxInt acceptedRequests = 0.obs;
  final RxInt rejectedRequests = 0.obs;
  final RxInt pendingRequests = 0.obs;

  // Language preference
  final RxString selectedLanguage = 'en-US'.obs;

  // Messages from admin/super admin
  final RxList<dynamic> messages = <dynamic>[].obs;
  final RxBool isLoadingMessages = false.obs;

  @override
  void onInit() {
    super.onInit();
    _showSubscriptionPopupAfterDelay();
  }

  @override
  void onReady() {
    super.onReady();
    _loadUserData();
    loadMessages();
  }

  // Show subscription popup after 10 seconds
  void _showSubscriptionPopupAfterDelay() {
    Future.delayed(const Duration(seconds: 10), () {
      // Check if user is still on the dashboard before showing popup
      if (Get.isRegistered<FarmerscreendashboardController>()) {
        _showSubscriptionPopup();
      }
    });
  }

  void _showSubscriptionPopup() {
    final subscriptionController = Get.put(SubscriptionController());
    if (!subscriptionController.isSubscribed.value) {
      Get.dialog(const SubscriptionPopup(), barrierDismissible: true);
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      // 1. Load basic user data from local storage first (fast)
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        if (userData['name'] != null)
          farmerName.value = await _translateIfNeed(userData['name']);

        if (userData['email'] != null) farmerEmail.value = userData['email'];
        if (userData['phone'] != null) farmerPhone.value = userData['phone'];
      }

      // 2. Fetch full profile from API (fresh data)
      try {
        final profileData = await _farmerService.getFarmerProfile();
        if (profileData['success'] == true && profileData['data'] != null) {
          final data = profileData['data'];
          final user = data['user'];
          final profile = data['farmer_profile'];

          if (user != null) {
            if (user['name'] != null)
              farmerName.value = await _translateIfNeed(user['name']);

            if (user['email'] != null) farmerEmail.value = user['email'];
            if (user['phone'] != null) farmerPhone.value = user['phone'];
          }

          if (profile != null) {
            // Status
            if (profile['request_status'] != null) {
              final status = profile['request_status'].toString().toLowerCase();
              if (status == 'approved') {
                requestStatus.value = RequestStatus.accepted;
              } else if (status == 'rejected') {
                requestStatus.value = RequestStatus.rejected;
              } else {
                requestStatus.value = RequestStatus.pending;
              }
            }

            // Location
            List<String> locationParts = [];
            if (profile['village'] != null)
              locationParts.add(profile['village']['name']);
            if (profile['taluka'] != null)
              locationParts.add(profile['taluka']['name']);
            if (profile['district'] != null)
              locationParts.add(profile['district']['name']);
            if (profile['state'] != null)
              locationParts.add(profile['state']['name']);

            if (locationParts.isNotEmpty) {
              farmLocation.value = await _translateIfNeed(
                locationParts.join(', '),
              );
            } else {
              farmLocation.value = await _translateIfNeed('India');
            }

            // Photo
            if (profile['passport_photo'] != null) {
              farmerPhoto.value = profile['passport_photo'];
            }
          }
        }
      } catch (e) {
        print('Error fetching profile in dashboard: $e');
        // Fallback to local data if API fails, which is already loaded above
      }
    } catch (e) {
      print('Error loading user data: $e');
      farmerName.value = await _translateIfNeed('Farmer');
      farmLocation.value = await _translateIfNeed('India');
    }
  }

  Future<String> _translateIfNeed(String text) async {
    try {
      String languageCode = 'en';

      // Try getting from LocalizedApp
      if (Get.context != null) {
        try {
          languageCode = LocalizedApp.of(
            Get.context!,
          ).delegate.currentLocale.languageCode;
        } catch (e) {
          print('DEBUG: LocalizedApp lookup failed: $e');
        }
      }

      // Fallback to SharedPreferences if still default or context missing
      if (languageCode == 'en' || Get.context == null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          // Try 'language_code' first (common convention), then check if flutter_translate uses something else.
          // flutter_translate uses 'locale' key by default.
          final savedLocale = prefs.getString('locale');
          if (savedLocale != null) {
            // savedLocale might be 'en_US' or 'hi'
            languageCode = savedLocale;
            if (languageCode.contains('_')) {
              languageCode = languageCode.split('_')[0];
            }
            print(
              'DEBUG: Found locale in SharedPreferences: $savedLocale -> $languageCode',
            );
          }
        } catch (e) {
          print('DEBUG: Prefs lookup failed: $e');
        }
      }

      print('DEBUG: Detected Language: $languageCode, Translating: $text');
      return await _translationService.translateText(text, languageCode);
    } catch (e) {
      print('Error getting locale or translating: $e');
      return text;
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  // Side navigation helpers
  void toggleNavigation() {
    isNavigationOpen.value = !isNavigationOpen.value;
  }

  void selectTab(int index) {
    selectedIndex.value = index;
  }

  void changeRequestStatus(RequestStatus status) {
    requestStatus.value = status;
  }

  // Simulate status change for demo purposes
  void simulateStatusChange() {
    final statuses = RequestStatus.values;
    final currentIndex = statuses.indexOf(requestStatus.value);
    final nextIndex = (currentIndex + 1) % statuses.length;
    requestStatus.value = statuses[nextIndex];
  }

  // Load messages from admin/super admin
  Future<void> loadMessages() async {
    try {
      isLoadingMessages.value = true;

      final data = await _farmerService.getMessages();

      messages.value = data.map((item) {
        final messageData = item['message'] ?? {};
        final adminData = messageData['admin'] ?? {};

        // Determine sender role based on some logic or default
        // The view expects 'super_admin' or 'admin'
        // Since we don't have explicit role in the response, we might need to infer or just show name
        // For now, let's map what we have

        return {
          'message': messageData['message'] ?? 'No message',
          'sender_name': adminData['name'] ?? 'Admin',
          'sender_role': 'admin', // Defaulting to admin as role isn't in JSON
          'created_at': item['created_at'] ?? '',
        };
      }).toList();

      // Translate messages
      final translatedMessages = <dynamic>[];
      for (var item in messages) {
        final msg = item['message'] as String;
        final senderName = item['sender_name'] as String;

        final translatedMsg = await _translateIfNeed(msg);
        final translatedSender = await _translateIfNeed(
          senderName,
        ); // Optional: Translate name if needed

        translatedMessages.add({
          ...item,
          'message': translatedMsg,
          'sender_name': translatedSender,
        });
      }
      messages.value = translatedMessages;
    } catch (e) {
      print('Error loading messages: $e');
      messages.value = [];
    } finally {
      isLoadingMessages.value = false;
    }
  }

  // Submit query to admin
  Future<void> submitQuery(String query) async {
    try {
      await _farmerService.submitQuery(query);
      // Optionally reload messages after submitting query
      await loadMessages();
    } catch (e) {
      print('Error submitting query: $e');
      rethrow;
    }
  }
}
