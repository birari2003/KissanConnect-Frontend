import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/nursery_management_controller.dart';

class NurseryManagementView extends GetView<NurseryManagementController> {
  const NurseryManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    if (!Get.isRegistered<NurseryManagementController>()) {
      Get.put(NurseryManagementController());
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Color(0xFF2E7D32),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF2E7D32),
              tabs: [
                Tab(text: 'Add Single'),
                Tab(text: 'Bulk Add'),
              ],
            ),
          ),
        ),
        body: TabBarView(children: [_buildSingleAddTab(), _buildBulkAddTab()]),
      ),
    );
  }

  Widget _buildSingleAddTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
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
              'Add New Nursery',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: controller.nameController,
              label: 'Nursery Name *',
              icon: Icons.store_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.ownerNameController,
              label: 'Owner Name *',
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.contactController,
              label: 'Contact Number *',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.locationController,
              label: 'Location *',
              icon: Icons.location_on_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.availableItemsController,
              label: 'Available Items (optional)',
              icon: Icons.inventory_2_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isAddingSingle.value
                      ? null
                      : () => controller.addSingleNursery(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isAddingSingle.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'ADD NURSERY',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
      ),
    );
  }

  Widget _buildBulkAddTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildUploadSection(),
          const SizedBox(height: 24),
          _buildPreviewSection(),
        ],
      ),
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
            'Step 1: Select Excel File',
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
                  leading: const Icon(Icons.store_rounded),
                  title: const Text('Total Nurseries Found'),
                  trailing: Text(
                    '${controller.parsedNurseries.length}',
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
                        controller.parsedNurseries.isEmpty ||
                            controller.isUploading.value
                        ? null
                        : () => controller.uploadNurseries(),
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
                  onPressed: controller.clearBulkData,
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
              Icon(Icons.info_outline, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Expanded(
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
          Text('• Required: "name", "owner_name", "contact", "location"'),
          Text('• Optional: "available_items"'),
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
          const Text(
            'Data Preview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.parsedNurseries.isEmpty) {
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
                      'No data to preview.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  const Color(0xFFF5F7FA),
                ),
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Owner')),
                  DataColumn(label: Text('Contact')),
                  DataColumn(label: Text('Location')),
                ],
                rows: controller.parsedNurseries.map((nursery) {
                  return DataRow(
                    cells: [
                      DataCell(Text(nursery['name'] ?? '-')),
                      DataCell(Text(nursery['owner_name'] ?? '-')),
                      DataCell(Text(nursery['contact'] ?? '-')),
                      DataCell(Text(nursery['location'] ?? '-')),
                    ],
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}
