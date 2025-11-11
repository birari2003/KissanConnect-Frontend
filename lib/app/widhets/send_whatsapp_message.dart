import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kissan_connect/app/utils/ui_utils.dart';

class WhatsAppFarmer {
  final String id;
  final String name;
  final String phone;
  final String location;

  WhatsAppFarmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
  });
}

class SendWhatsappController extends GetxController {
  // List of farmers
  final farmers = <WhatsAppFarmer>[].obs;

  // Selected farmer IDs
  final selectedIds = <String>{}.obs;

  // Message controller
  final messageController = TextEditingController();

  // Sending state
  final isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFarmers();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  void loadFarmers() {
    // Mock data - replace with API call to get farmers in admin's region
    farmers.value = [
      WhatsAppFarmer(
        id: '1',
        name: 'Ramesh Kumar',
        phone: '+91 9876543210',
        location: 'Maharashtra > Pune > Kothrud',
      ),
      WhatsAppFarmer(
        id: '2',
        name: 'Suresh Patil',
        phone: '+91 9876543211',
        location: 'Maharashtra > Pune > Shivajinagar',
      ),
      WhatsAppFarmer(
        id: '3',
        name: 'Mahesh Deshmukh',
        phone: '+91 9876543212',
        location: 'Maharashtra > Pune > Hadapsar',
      ),
      WhatsAppFarmer(
        id: '4',
        name: 'Ganesh Jadhav',
        phone: '+91 9876543213',
        location: 'Maharashtra > Nashik > Deolali',
      ),
      WhatsAppFarmer(
        id: '5',
        name: 'Rajesh Sharma',
        phone: '+91 9876543214',
        location: 'Maharashtra > Mumbai > Andheri',
      ),
      WhatsAppFarmer(
        id: '6',
        name: 'Prakash Yadav',
        phone: '+91 9876543215',
        location: 'Maharashtra > Pune > Wakad',
      ),
      WhatsAppFarmer(
        id: '7',
        name: 'Vijay Pawar',
        phone: '+91 9876543216',
        location: 'Maharashtra > Pune > Hinjewadi',
      ),
      WhatsAppFarmer(
        id: '8',
        name: 'Anil Bhosale',
        phone: '+91 9876543217',
        location: 'Maharashtra > Nagpur > Sitabuldi',
      ),
    ];
  }

  void toggleSelection(String id, bool? value) {
    if (value == true) {
      selectedIds.add(id);
    } else {
      selectedIds.remove(id);
    }
  }

  void selectAll() {
    selectedIds.addAll(farmers.map((e) => e.id));
  }

  void clearSelection() {
    selectedIds.clear();
  }

  Future<void> sendWhatsAppMessage() async {
    final message = messageController.text.trim();

    if (selectedIds.isEmpty) {
      UiUtils.showErrorSnackbar('Error', 'Please select at least one farmer');
      return;
    }

    if (message.isEmpty) {
      UiUtils.showErrorSnackbar('Error', 'Please enter a message');
      return;
    }

    isSending.value = true;

    try {
      // TODO: Integrate with WhatsApp Business API or backend service
      await Future.delayed(Duration(seconds: 2));

      UiUtils.showSuccessSnackbar(
        'Success',
        'WhatsApp message sent to ${selectedIds.length} farmer(s)',
      );

      messageController.clear();
      clearSelection();
    } catch (e) {
      UiUtils.showErrorSnackbar('Error', 'Failed to send WhatsApp message');
    } finally {
      isSending.value = false;
    }
  }
}

class SendWhatsappWidget extends StatelessWidget {
  const SendWhatsappWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SendWhatsappController());

    return Container(
      color: Color(0xFFF5F7FA),
      child: Column(
        children: [
          // Selection toolbar
          Obx(
            () => controller.selectedIds.isNotEmpty
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF25D366).withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF25D366).withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF25D366),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${controller.selectedIds.length} selected',
                          style: TextStyle(
                            color: Color(0xFF2A6E9B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: controller.clearSelection,
                          child: Text('Clear'),
                        ),
                        TextButton(
                          onPressed: controller.selectAll,
                          child: Text('Select All'),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
          ),
          // Farmers list
          Expanded(
            child: Obx(() {
              final list = controller.farmers;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No farmers found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final farmer = list[index];
                  return Obx(() {
                    final selected = controller.selectedIds.contains(farmer.id);
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? Color(0xFF25D366)
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(0xFF25D366).withOpacity(0.1),
                            child: Icon(Icons.person, color: Color(0xFF25D366)),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  farmer.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2A6E9B),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      farmer.phone,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Color(0xFF54B5D9),
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        farmer.location,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: selected,
                            onChanged: (v) =>
                                controller.toggleSelection(farmer.id, v),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            activeColor: Color(0xFF25D366),
                          ),
                        ],
                      ),
                    );
                  });
                },
              );
            }),
          ),
          // Message composer
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Message input
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: controller.messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your WhatsApp message...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Send button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isSending.value
                            ? null
                            : controller.sendWhatsAppMessage,
                        icon: controller.isSending.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.send, size: 20),
                        label: Text(
                          controller.isSending.value
                              ? 'Sending...'
                              : 'Send WhatsApp Message',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
