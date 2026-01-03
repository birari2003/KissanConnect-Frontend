import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bulk_add_farmers_controller.dart';

class BulkAddFarmersView extends GetView<BulkAddFarmersController> {
  const BulkAddFarmersView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    if (!Get.isRegistered<BulkAddFarmersController>()) {
      Get.put(BulkAddFarmersController());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUploadSection(),
                    const SizedBox(height: 24),
                    _buildPreviewSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bulk Add Farmers',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload an Excel file to register multiple farmers at once.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 1: Select File',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8BC34A),
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.upload_file,
                    size: 48,
                    color: Color(0xFF689F38),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.fileName.value.isEmpty
                        ? 'No file selected'
                        : controller.fileName.value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.pickExcelFile(),
                    icon: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: const Text('Browse Files'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Step 2: Review & Upload',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Total Users Found'),
                  trailing: Text(
                    '${controller.parsedUsers.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        controller.parsedUsers.isEmpty ||
                            controller.isUploading.value
                        ? null
                        : () => controller.uploadUsers(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7BB53B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: controller.isUploading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'UPLOAD TO SERVER',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: controller.clearData,
                  child: const Text(
                    'Clear Selection',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Excel Format Requirements:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('• First row must be headers.'),
          Text('• Required columns: "name", "phone"'),
          Text('• Optional: "email", "preferred_language", "role"'),
          Text('• Languages: "en" (English), "mr" (Marathi), "hi" (Hindi)'),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Data Preview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Obx(
                () => controller.uploadResults.isNotEmpty
                    ? _buildResultsBadge()
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.parsedUsers.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.table_chart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No data to preview. Select an Excel file first.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      const Color(0xFFF5F7FA),
                    ),
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Language')),
                      DataColumn(label: Text('Role')),
                    ],
                    rows: controller.parsedUsers.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(Text(user['name'] ?? '-')),
                          DataCell(Text(user['phone'] ?? '-')),
                          DataCell(Text(user['email'] ?? '-')),
                          DataCell(Text(user['preferred_language'] ?? '-')),
                          DataCell(Text(user['role'] ?? 'farmer')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                if (controller.uploadResults.isNotEmpty) _buildResultsSummary(),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultsBadge() {
    final successful = controller.uploadResults['successful']?.length ?? 0;
    final failed = controller.uploadResults['failed']?.length ?? 0;

    return Row(
      children: [
        _badge('Success: $successful', Colors.green),
        const SizedBox(width: 8),
        _badge('Failed: $failed', Colors.red),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildResultsSummary() {
    final failed = controller.uploadResults['failed'] as List? ?? [];
    if (failed.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Errors Found:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: failed.length,
              itemBuilder: (context, index) {
                final error = failed[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    '• Row ${error['row']}: ${error['error']}',
                    style: const TextStyle(fontSize: 12, color: Colors.red),
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
