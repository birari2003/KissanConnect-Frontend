import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/superadminlist_controller.dart';

class SuperadminlistView extends GetView<SuperadminlistController> {
  final bool embedded;
  const SuperadminlistView({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();
    
    final body = Container(
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          // Selection toolbar
          Obx(() => controller.selectedIds.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7BB53B).withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(color: const Color(0xFF7BB53B).withOpacity(0.3)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: const Color(0xFF7BB53B), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${controller.selectedIds.length} selected',
                        style: const TextStyle(
                          color: Color(0xFF2A6E9B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: controller.clearSelection,
                        child: const Text('Clear'),
                      ),
                      TextButton(
                        onPressed: controller.selectAll,
                        child: const Text('Select All'),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink()),
          // List
          Expanded(
            child: Obx(() {
              final list = controller.superAdmins;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.supervisor_account_rounded, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No super admins found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return Obx(() {
                    final selected = controller.selectedIds.contains(item.id);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF7BB53B)
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFF4B23B).withOpacity(0.2),
                          child: const Icon(Icons.star, color: Color(0xFFF4B23B), size: 22),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2A6E9B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7BB53B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF7BB53B).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                item.level,
                                style: const TextStyle(
                                  color: Color(0xFF7BB53B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Row(
                            children: [
                              const Icon(Icons.place, size: 14, color: Color(0xFF54B5D9)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.levelPath,
                                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Checkbox(
                          value: selected,
                          onChanged: (v) => controller.toggleSelection(item.id, v),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          activeColor: const Color(0xFF7BB53B),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
          // Message composer (chat-like bottom section)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (text) {
                          if (text.trim().isNotEmpty) {
                            controller.sendMessageToSelected(text);
                            messageController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Obx(() => controller.isSending.value
                      ? const SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF7BB53B),
                            ),
                          ),
                        )
                      : Material(
                          color: const Color(0xFF7BB53B),
                          borderRadius: BorderRadius.circular(24),
                          child: InkWell(
                            onTap: () {
                              final text = messageController.text;
                              if (text.trim().isNotEmpty) {
                                controller.sendMessageToSelected(text);
                                messageController.clear();
                              }
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (embedded) return body;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Super Admins',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2A6E9B),
        elevation: 0,
      ),
      body: body,
    );
  }
}
