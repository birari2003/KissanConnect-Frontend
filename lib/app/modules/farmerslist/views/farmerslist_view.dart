import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/farmerslist_controller.dart';

class FarmerslistView extends GetView<FarmerslistController> {
  final bool embedded;
  const FarmerslistView({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final body = Container(
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              final filteredFarmers = controller.filteredFarmers;
              if (filteredFarmers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.agriculture_rounded,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No farmers found',
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
                padding: EdgeInsets.all(16),
                itemCount: filteredFarmers.length,
                itemBuilder: (context, index) {
                  final farmer = filteredFarmers[index];
                  return _buildFarmerCard(farmer);
                },
              );
            }),
          ),
        ],
      ),
    );

    if (embedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Farmers List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2A6E9B),
        elevation: 0,
      ),
      body: body,
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
          children: [
            _buildFilterChip('All', 'all'),
            SizedBox(width: 8),
            _buildFilterChip('Pending', 'pending'),
            SizedBox(width: 8),
            _buildFilterChip('Approved', 'approved'),
            SizedBox(width: 8),
            _buildFilterChip('Rejected', 'rejected'),
          ],
        )),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = controller.selectedFilter.value == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        controller.changeFilter(value);
      },
      selectedColor: Color(0xFF7BB53B).withOpacity(0.2),
      checkmarkColor: Color(0xFF7BB53B),
      labelStyle: TextStyle(
        color: isSelected ? Color(0xFF7BB53B) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildFarmerCard(farmer) {
    return GestureDetector(
      onLongPress: () {
        if (farmer.status == 'approved') {
          _showSuperAdminBottomSheet(farmer);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getStatusColor(farmer.status).withOpacity(0.1),
                    radius: 28,
                    child: Icon(
                      Icons.person,
                      color: _getStatusColor(farmer.status),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                farmer.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2A6E9B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (farmer.isSuperAdmin)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFF4B23B), Color(0xFFF4B23B).withOpacity(0.7)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Super Admin',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              farmer.contact,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (farmer.isSuperAdmin && farmer.superAdminLevel != null) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Color(0xFF7BB53B)),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  farmer.superAdminLevel!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7BB53B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  _buildStatusChip(farmer.status),
                  Spacer(),
                  if (farmer.status == 'pending') ...[
                    TextButton.icon(
                      onPressed: () => controller.rejectFarmer(farmer.id),
                      icon: Icon(Icons.close, size: 18),
                      label: Text('Reject'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => controller.approveFarmer(farmer.id),
                      icon: Icon(Icons.check, size: 18),
                      label: Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF7BB53B),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                      ),
                    ),
                  ],
                  if (farmer.status == 'approved' && !farmer.isSuperAdmin)
                    Text(
                      'Long press to assign as Super Admin',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Color(0xFF7BB53B);
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Color(0xFFF4B23B);
      default:
        return Colors.grey;
    }
  }

  void _showSuperAdminBottomSheet(farmer) {
    controller.resetSuperAdminSelection();
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFF4B23B), size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Assign Super Admin',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A6E9B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Make ${farmer.name} a Super Admin?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Select Administrative Level',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A6E9B),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildLocationDropdowns(),
                  SizedBox(height: 16),
                  Obx(() => Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF54B5D9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFF54B5D9).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: Color(0xFF54B5D9)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selected: ${controller.getSuperAdminLevelText()}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2A6E9B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            padding: EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => controller.assignSuperAdmin(farmer.id),
                          child: Text('Assign Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF7BB53B),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
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
      isScrollControlled: true,
      isDismissible: true,
    );
  }

  Widget _buildLocationDropdowns() {
    return Obx(() => Column(
      children: [
        // State Dropdown
        _buildDropdown(
          label: 'State',
          value: controller.selectedState.value,
          items: controller.states,
          onChanged: (value) {
            controller.selectedState.value = value;
            controller.selectedDistrict.value = null;
            controller.selectedCity.value = null;
            controller.selectedVillage.value = null;
          },
          icon: Icons.map,
        ),
        if (controller.selectedState.value != null) ...[
          SizedBox(height: 12),
          _buildDropdown(
            label: 'District',
            value: controller.selectedDistrict.value,
            items: controller.getDistricts(),
            onChanged: (value) {
              controller.selectedDistrict.value = value;
              controller.selectedCity.value = null;
              controller.selectedVillage.value = null;
            },
            icon: Icons.location_city,
          ),
        ],
        if (controller.selectedDistrict.value != null) ...[
          SizedBox(height: 12),
          _buildDropdown(
            label: 'City',
            value: controller.selectedCity.value,
            items: controller.getCities(),
            onChanged: (value) {
              controller.selectedCity.value = value;
              controller.selectedVillage.value = null;
            },
            icon: Icons.apartment,
          ),
        ],
        if (controller.selectedCity.value != null) ...[
          SizedBox(height: 12),
          _buildDropdown(
            label: 'Village',
            value: controller.selectedVillage.value,
            items: controller.getVillages(),
            onChanged: (value) {
              controller.selectedVillage.value = value;
            },
            icon: Icons.home_work,
          ),
        ],
      ],
    ));
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF7BB53B)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        hint: Text('Select $label'),
      ),
    );
  }
}
