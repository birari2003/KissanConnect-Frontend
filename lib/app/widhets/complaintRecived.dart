import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/farmerServices.dart';
import '../services/adminServices.dart';

class ComplaintItem {
  final String id;
  final String complainantName;
  final String complainantContact;
  final String accusedName;
  final String accusedContact;
  final String complaintText;
  final DateTime date;
  final String status; // 'pending', 'resolved', 'in_progress'
  final String? resolverName;

  ComplaintItem({
    required this.id,
    required this.complainantName,
    required this.complainantContact,
    required this.accusedName,
    required this.accusedContact,
    required this.complaintText,
    required this.date,
    required this.status,
    this.resolverName,
  });
}

class ComplaintController extends GetxController {
  final complaints = <ComplaintItem>[].obs;
  final queries = <dynamic>[].obs;
  final isLoading = false.obs;
  final showComplaints = true.obs; // true = complaints, false = queries
  final FarmerService _farmerService = FarmerService();
  final AdminService _adminService = AdminService();

  @override
  void onInit() {
    super.onInit();
    loadComplaints();
    loadQueries();
  }

  Future<void> loadComplaints() async {
    isLoading.value = true;
    try {
      final data = await _farmerService.getComplaints();

      final items = data.map((item) {
        // Extract complainant info
        final complainant = item['complainant'] ?? {};
        final complainantName = complainant['name'] ?? 'Unknown';
        final complainantContact = complainant['phone'] ?? 'N/A';

        // Extract accused info
        final accused = item['accused'] ?? {};
        final accusedName = accused['name'] ?? 'Unknown';
        final accusedContact = accused['phone'] ?? 'N/A';

        // Extract resolver info (if any)
        final resolver = item['resolver'];
        final resolverName = resolver != null ? resolver['name'] : null;

        // Parse timestamp
        DateTime date;
        try {
          date = DateTime.parse(
            item['created_at'] ?? DateTime.now().toString(),
          );
        } catch (e) {
          date = DateTime.now();
        }

        return ComplaintItem(
          id: item['id']?.toString() ?? '0',
          complainantName: complainantName,
          complainantContact: complainantContact,
          accusedName: accusedName,
          accusedContact: accusedContact,
          complaintText: item['complaint_text'] ?? 'No details provided',
          date: date,
          status: item['status'] ?? 'pending',
          resolverName: resolverName,
        );
      }).toList();

      complaints.value = items;
    } catch (e) {
      print('Error loading complaints: $e');
      complaints.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void refreshComplaints() {
    loadComplaints();
  }

  Future<void> loadQueries() async {
    isLoading.value = true;
    print('Loading queries...');
    try {
      // Use FarmerService since the endpoint is /farmer/get-queries
      final data = await _farmerService.getQueries();
      print('Received ${data.length} queries');
      queries.value = data;
      print('Queries assigned to observable: ${queries.length}');
    } catch (e) {
      print('Error loading queries: $e');
      queries.value = [];
    } finally {
      isLoading.value = false;
      print('Loading complete. showComplaints: ${showComplaints.value}');
    }
  }

  void toggleView() {
    showComplaints.value = !showComplaints.value;
  }

  Future<void> updateQueryWithResponse({
    required int queryId,
    required String status,
    String? adminResponse,
  }) async {
    try {
      await _adminService.updateQuery(
        queryId: queryId,
        status: status,
        adminResponse: adminResponse,
      );

      // Reload queries to get updated data
      await loadQueries();

      Get.snackbar(
        'Success',
        'Query updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update query: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateComplaintStatus(
    String complaintId,
    String newStatus,
  ) async {
    try {
      // Update in backend first
      await _farmerService.updateComplaintStatus(
        complaintId: int.parse(complaintId),
        status: newStatus,
      );

      // Update locally after successful backend update
      final index = complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1) {
        final updatedComplaint = ComplaintItem(
          id: complaints[index].id,
          complainantName: complaints[index].complainantName,
          complainantContact: complaints[index].complainantContact,
          accusedName: complaints[index].accusedName,
          accusedContact: complaints[index].accusedContact,
          complaintText: complaints[index].complaintText,
          date: complaints[index].date,
          status: newStatus,
          resolverName: complaints[index].resolverName,
        );

        complaints[index] = updatedComplaint;
        complaints.refresh();

        // Show success message
        Get.snackbar(
          'Success',
          'Complaint status updated to ${newStatus.replaceAll('_', ' ').toUpperCase()}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error updating complaint status: $e');
      Get.snackbar(
        'Error',
        'Failed to update complaint status',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class ComplaintReceived extends StatelessWidget {
  const ComplaintReceived({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ComplaintController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Toggle Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => GestureDetector(
                      onTap: () {
                        if (!controller.showComplaints.value) {
                          controller.toggleView();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: controller.showComplaints.value
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Complaints',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: controller.showComplaints.value
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => GestureDetector(
                      onTap: () {
                        if (controller.showComplaints.value) {
                          controller.toggleView();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !controller.showComplaints.value
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Queries',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: !controller.showComplaints.value
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                );
              }

              // Show Complaints
              if (controller.showComplaints.value) {
                if (controller.complaints.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No complaints received',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.complaints.length,
                  itemBuilder: (context, index) {
                    final item = controller.complaints[index];
                    return _buildComplaintCard(item, controller);
                  },
                );
              }
              // Show Queries
              else {
                if (controller.queries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No queries received',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.queries.length,
                  itemBuilder: (context, index) {
                    final query = controller.queries[index];
                    return _buildQueryCard(query, controller);
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(
    ComplaintItem item,
    ComplaintController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showComplaintDetailSheet(item, controller),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  child: Text(
                    item.complainantName[0],
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.complainantName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          _buildStatusBadge(item.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Against: ${item.accusedName}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.complaintText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(item.date),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'resolved':
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        label = 'Resolved';
        break;
      case 'in_progress':
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        label = 'In Progress';
        break;
      default:
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  void _showComplaintDetailSheet(
    ComplaintItem item,
    ComplaintController controller,
  ) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header - Complainant
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.red.withOpacity(0.1),
                          child: Text(
                            item.complainantName[0],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Complainant',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                item.complainantName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                item.complainantContact,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Accused Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(
                            0xFF2E7D32,
                          ).withOpacity(0.1),
                          child: Text(
                            item.accusedName[0],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Complaint Against',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                item.accusedName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                item.accusedContact,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Complaint Details
                    const Text(
                      'Complaint Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.complaintText,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Received on: ${_formatDate(item.date)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Status Section
                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildStatusBadge(item.status),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Status Update Buttons
                    if (item.status != 'resolved')
                      Column(
                        children: [
                          if (item.status == 'pending')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  controller.updateComplaintStatus(
                                    item.id,
                                    'in_progress',
                                  );
                                  Get.back();
                                },
                                icon: const Icon(
                                  Icons.hourglass_empty,
                                  size: 20,
                                ),
                                label: const Text('Mark as In Progress'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                controller.updateComplaintStatus(
                                  item.id,
                                  'resolved',
                                );
                                Get.back();
                              },
                              icon: const Icon(Icons.check_circle, size: 20),
                              label: const Text('Mark as Resolved'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildQueryCard(
    Map<String, dynamic> query,
    ComplaintController controller,
  ) {
    final status = query['status'] ?? 'pending';
    Color statusColor;
    String statusLabel;

    switch (status.toLowerCase()) {
      case 'answered':
        statusColor = Colors.green;
        statusLabel = 'Answered';
        break;
      case 'closed':
        statusColor = Colors.grey;
        statusLabel = 'Closed';
        break;
      default:
        statusColor = Colors.orange;
        statusLabel = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showQueryDetailSheet(query, controller),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.help_outline, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              query['user_name']?.toString() ?? 'User',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        query['description']?.toString() ?? 'No description',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        query['created_at']?.toString() ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQueryDetailSheet(
    Map<String, dynamic> query,
    ComplaintController controller,
  ) {
    final responseController = TextEditingController(
      text: query['admin_response']?.toString() ?? '',
    );
    final statusController = TextEditingController(
      text: query['status']?.toString() ?? 'pending',
    );

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: const Icon(
                            Icons.help_outline,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Query from',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                query['user_name']?.toString() ?? 'User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (query['user_contact'] != null)
                                Text(
                                  query['user_contact'].toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Query Description
                    const Text(
                      'Query Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Text(
                        query['description']?.toString() ?? 'No description',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Status Dropdown
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: statusController.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'answered',
                          child: Text('Answered'),
                        ),
                        DropdownMenuItem(
                          value: 'closed',
                          child: Text('Closed'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          statusController.text = value;
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Admin Response
                    const Text(
                      'Admin Response',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: responseController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter your response...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final queryId = query['id'];
                          if (queryId != null) {
                            // Close bottom sheet first
                            Get.back();

                            // Then update query and show success message
                            await controller.updateQueryWithResponse(
                              queryId: int.parse(queryId.toString()),
                              status: statusController.text,
                              adminResponse: responseController.text.isEmpty
                                  ? null
                                  : responseController.text,
                            );
                          }
                        },
                        icon: const Icon(Icons.send, size: 20),
                        label: const Text('Submit Response'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
      isScrollControlled: true,
    );
  }
}
