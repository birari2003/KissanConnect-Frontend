import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../services/farmerServices.dart';
import '../services/translation_service.dart';

class JobApplicationController extends GetxController {
  final jobs = <dynamic>[].obs;
  final isLoading = false.obs;
  final TranslationService _translationService = TranslationService();

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
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    isLoading.value = true;
    try {
      final fetchedJobs = await FarmerService().getJobs();

      for (var job in fetchedJobs) {
        if (job['job_title'] != null) {
          job['job_title'] = await _translateIfNeed(job['job_title']);
        }
        if (job['company_name'] != null) {
          job['company_name'] = await _translateIfNeed(job['company_name']);
        }
        if (job['location'] != null) {
          job['location'] = await _translateIfNeed(job['location']);
        }
        if (job['description'] != null) {
          job['description'] = await _translateIfNeed(job['description']);
        }
        // Translate job_type if it's a known key
        if (job['job_type'] != null) {
          String jobType = job['job_type']
              .toString()
              .toLowerCase()
              .replaceAll('-', '_')
              .replaceAll(' ', '_');
          // Check if it matches a translation key
          if (jobType == 'full_time' || jobType == 'fulltime') {
            job['job_type'] = translate('full_time');
          } else if (jobType == 'part_time' || jobType == 'parttime') {
            job['job_type'] = translate('part_time');
          } else if (jobType == 'contract') {
            job['job_type'] = translate('contract');
          } else if (jobType == 'temporary') {
            job['job_type'] = translate('temporary');
          } else {
            // Otherwise translate the raw value
            job['job_type'] = await _translateIfNeed(job['job_type']);
          }
        }
      }

      jobs.assignAll(fetchedJobs);
    } catch (e) {
      print('Error fetching jobs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openJobUrl(String urlString) async {
    // Construct full URL if it's a relative path (filename)
    String fullUrl = urlString;
    if (!urlString.startsWith('http')) {
      fullUrl = 'http://192.168.43.43:5000/uploads/$urlString';
    }

    final Uri url = Uri.parse(fullUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // The original instruction provided a success snackbar for a failure case
      // and referenced a 'job' object not available in this method.
      // To maintain syntactic correctness and the original intent of showing an error
      // when a URL cannot be launched, the UiUtils.showErrorSnackbar is used.
      // If the intent was to show a success message for a different action,
      // please provide the correct context or method for that change.
      UiUtils.showErrorSnackbar('Error', 'Could not open document');
    }
  }
}

class JobApplication extends StatelessWidget {
  const JobApplication({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JobApplicationController());

    return Container(
      color: const Color(0xFFF5F7FA),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF2E8B57)),
          );
        }

        if (controller.jobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.work_off_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No active jobs found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Check back later for new opportunities',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: controller.jobs.length,
          itemBuilder: (context, index) {
            final job = controller.jobs[index];
            return _buildJobCard(context, job);
          },
        );
      }),
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job) {
    // Parse date if needed
    final postedDate = job['created_at'] != null
        ? job['created_at'].toString().split('T')[0]
        : translate('posted_recently');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E8B57).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Get.to(() => JobDetailView(job: job));
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.business,
                        color: Color(0xFF2E8B57),
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['job_title'] ?? 'Unknown Role',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D323A),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            job['company_name'] ?? 'Unknown Company',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(job['job_type'] ?? translate('full_time')),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.grey[200], height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoItem(
                      Icons.location_on_outlined,
                      job['location'] ?? 'Remote',
                    ),
                    const SizedBox(width: 24),
                    _buildInfoItem(
                      Icons.currency_rupee,
                      job['salary_range'] ?? translate('negotiable'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${translate('posted_on')}: $postedDate',

                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          translate('view_details'),

                          style: TextStyle(
                            color: Color(0xFF2E8B57),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Color(0xFF2E8B57),
                        ),
                      ],
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

  Widget _buildStatusChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2196F3).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1976D2),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class JobDetailView extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailView({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobApplicationController>();
    final postedDate = job['created_at'] != null
        ? job['created_at'].toString().split('T')[0]
        : translate('posted_recently');
    final attachment = job['attachment'];

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF2E8B57),
        elevation: 0,
        title: Text(
          translate('job_details'),

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.business,
                          color: Color(0xFF2E8B57),
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job['job_title'] ?? 'Unknown Role',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D323A),
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              job['company_name'] ?? 'Unknown Company',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Divider(height: 1),
                  SizedBox(height: 24),
                  _buildDetailRow(
                    Icons.work_outline,
                    translate('job_type'),
                    job['job_type'] ?? translate('full_time'),
                  ),
                  SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    translate('location_label'),
                    job['location'] ?? 'Remote',
                  ),
                  SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.currency_rupee,
                    translate('salary'),
                    job['salary_range'] ?? translate('negotiable'),
                  ),
                  SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    translate('posted_on'),

                    postedDate,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            Text(
              translate('description'),

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D323A),
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                job['description'] ?? 'No description provided.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ),
            SizedBox(height: 30),

            if (attachment != null && attachment.toString().isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.openJobUrl(attachment),
                  icon: Icon(Icons.picture_as_pdf, size: 22),
                  label: Text(
                    translate('view_official_document'),

                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E8B57),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: Color(0xFF2E8B57).withOpacity(0.4),
                  ),
                ),
              ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey[700]),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D323A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
