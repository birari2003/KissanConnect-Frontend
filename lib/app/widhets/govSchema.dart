import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import '../utils/ui_utils.dart';
import '../utils/api.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../services/farmerServices.dart';
import '../services/translation_service.dart';
import '../controllers/subscription_controller.dart';
import '../controllers/payment_controller.dart';

class GovSchemaController extends GetxController {
  final schemes = <dynamic>[].obs;
  final isLoading = false.obs;
  final TranslationService _translationService = TranslationService();
  final SubscriptionController _subscriptionController = Get.put(
    SubscriptionController(),
  );

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

  @override
  void onInit() {
    super.onInit();
    fetchSchemes();
  }

  Future<void> fetchSchemes() async {
    isLoading.value = true;
    try {
      final fetchedSchemes = await FarmerService().getGovernmentSchemes();

      // Clear existing schemes
      schemes.clear();

      // Translate and add schemes progressively
      for (int i = 0; i < fetchedSchemes.length; i++) {
        var scheme = fetchedSchemes[i];

        if (scheme['title'] != null) {
          scheme['title'] = await _translateIfNeed(scheme['title']);
        }
        if (scheme['description'] != null) {
          scheme['description'] = await _translateIfNeed(scheme['description']);
        }

        // Add scheme to UI immediately after translation
        schemes.add(scheme);

        // Stop loading indicator after first scheme is added
        if (i == 0) {
          isLoading.value = false;
        }
      }

      // If no schemes were fetched, stop loading
      if (fetchedSchemes.isEmpty) {
        isLoading.value = false;
      }
    } catch (e) {
      print('Error fetching schemes: $e');
      isLoading.value = false;
    }
  }

  Future<void> openSchemeUrl(String? url) async {
    if (url != null && url.isNotEmpty) {
      // If it's a relative path (uploaded file), append base URL
      final fullUrl = url.startsWith('http')
          ? url
          : ApiConfig.getUploadUrl(url);

      final uri = Uri.parse(fullUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        UiUtils.showErrorSnackbar('Error', 'Could not launch URL');
      }
    } else {
      UiUtils.showInfoSnackbar('Info', 'No document attached');
    }
  }
}

class GovSchema extends StatelessWidget {
  const GovSchema({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GovSchemaController());

    return Container(
      color: const Color(0xFFF5F7FA),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.schemes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No active schemes found',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.schemes.length,
          itemBuilder: (context, index) {
            final scheme = controller.schemes[index];
            final isBlurred = !controller.hasSubscription.value && index >= 3;

            if (isBlurred) {
              return _buildBlurredSchemeCard(scheme, controller);
            }
            return _buildSchemeCard(scheme, controller);
          },
        );
      }),
    );
  }

  Widget _buildSchemeCard(
    Map<String, dynamic> scheme,
    GovSchemaController controller,
  ) {
    // Parse date if needed, assuming it's a string like '2024-01-15'
    final publishedDate = scheme['published_at'] != null
        ? scheme['published_at'].toString().split('T')[0]
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Get.to(
            () => SchemeDetailView(scheme: scheme, controller: controller),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        scheme['title'] ?? 'Unknown Scheme',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A6E9B),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF2E8B57),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        translate('active_status'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E8B57),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  scheme['description'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${translate('posted_on')}: $publishedDate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      translate('read_more'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7BB53B),
                      ),
                    ),

                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: const Color(0xFF7BB53B),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlurredSchemeCard(
    Map<String, dynamic> scheme,
    GovSchemaController controller,
  ) {
    return Stack(
      children: [
        Opacity(opacity: 0.3, child: _buildSchemeCard(scheme, controller)),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 12),
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
                        SizedBox(height: 2),
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
                            final paymentController = Get.put(
                              PaymentController(),
                            );
                            await paymentController.startPayment();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF2E8B57),
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 9,
                            ),
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
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SchemeDetailView extends StatelessWidget {
  final Map<String, dynamic> scheme;
  final GovSchemaController controller;

  const SchemeDetailView({
    super.key,
    required this.scheme,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final publishedDate = scheme['published_at'] != null
        ? scheme['published_at'].toString().split('T')[0]
        : 'N/A';

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF2A6E9B),
        elevation: 0,
        title: Text(
          translate('scheme_details'),
          style: TextStyle(color: Colors.white),
        ),

        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              scheme['title'] ?? 'Unknown Scheme',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A6E9B),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  '${translate('posted_on')}: $publishedDate',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translate('description_label'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    scheme['description'] ??
                        translate('no_description_available'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 24),

                  if (scheme['attachment'] != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            controller.openSchemeUrl(scheme['attachment']),
                        icon: Icon(Icons.picture_as_pdf),
                        label: Text(translate('view_official_document')),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2A6E9B),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
}
