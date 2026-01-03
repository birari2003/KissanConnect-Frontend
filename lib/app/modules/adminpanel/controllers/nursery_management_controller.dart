import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/adminServices.dart';
import '../../../utils/ui_utils.dart';

class NurseryManagementController extends GetxController {
  final AdminService _adminService = AdminService();

  // Single Nursery Addition
  final nameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final contactController = TextEditingController();
  final locationController = TextEditingController();
  final availableItemsController = TextEditingController();
  final RxBool isAddingSingle = false.obs;

  // Bulk Nursery Addition
  final RxList<Map<String, dynamic>> parsedNurseries =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxString fileName = ''.obs;
  final RxMap<String, dynamic> uploadResults = <String, dynamic>{}.obs;

  @override
  void onClose() {
    nameController.dispose();
    ownerNameController.dispose();
    contactController.dispose();
    locationController.dispose();
    availableItemsController.dispose();
    super.onClose();
  }

  // Single Nursery Logic
  Future<void> addSingleNursery() async {
    if (nameController.text.isEmpty ||
        ownerNameController.text.isEmpty ||
        contactController.text.isEmpty ||
        locationController.text.isEmpty) {
      UiUtils.showWarningSnackbar('Warning', 'Please fill all required fields');
      return;
    }

    try {
      isAddingSingle.value = true;
      final nurseryData = {
        'name': nameController.text.trim(),
        'owner_name': ownerNameController.text.trim(),
        'contact': contactController.text.trim(),
        'location': locationController.text.trim(),
        'available_items': availableItemsController.text.trim(),
      };

      final response = await _adminService.addNursery(nurseryData);

      if (response['success'] == true) {
        UiUtils.showSuccessSnackbar('Success', 'Nursery added successfully');
        _clearSingleForm();
      } else {
        UiUtils.showErrorSnackbar(
          'Error',
          response['message'] ?? 'Failed to add nursery',
        );
      }
    } catch (e) {
      UiUtils.showErrorSnackbar('Error', 'Failed to add nursery: $e');
    } finally {
      isAddingSingle.value = false;
    }
  }

  void _clearSingleForm() {
    nameController.clear();
    ownerNameController.clear();
    contactController.clear();
    locationController.clear();
    availableItemsController.clear();
  }

  // Bulk Nursery Logic
  Future<void> pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        isLoading.value = true;
        fileName.value = result.files.single.name;

        Uint8List? bytes;
        if (GetPlatform.isWeb) {
          bytes = result.files.single.bytes;
        } else {
          final file = File(result.files.single.path!);
          bytes = await file.readAsBytes();
        }

        if (bytes != null) {
          await _parseExcel(bytes);
        } else {
          UiUtils.showErrorSnackbar('Error', 'Could not read file bytes');
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      UiUtils.showErrorSnackbar('Error', 'Failed to pick file: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _parseExcel(Uint8List bytes) async {
    try {
      var excel = Excel.decodeBytes(bytes);
      List<Map<String, dynamic>> nurseries = [];

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null || sheet.maxRows <= 1) continue;

        var headerRow = sheet.rows[0];
        Map<int, String> colMap = {};
        for (int i = 0; i < headerRow.length; i++) {
          var val = headerRow[i]?.value?.toString().toLowerCase().trim();
          if (val != null) colMap[i] = val;
        }

        for (int i = 1; i < sheet.maxRows; i++) {
          var row = sheet.rows[i];
          Map<String, dynamic> nurseryData = {};
          bool hasData = false;

          for (int j = 0; j < row.length; j++) {
            var colName = colMap[j];
            var cellValue = row[j]?.value?.toString().trim();
            if (colName != null && cellValue != null && cellValue.isNotEmpty) {
              // Map Excel headers to backend fields
              String fieldName = colName;
              if (colName == 'owner name' || colName == 'owner_name')
                fieldName = 'owner_name';
              if (colName == 'available items' || colName == 'available_items')
                fieldName = 'available_items';

              nurseryData[fieldName] = cellValue;
              hasData = true;
            }
          }

          if (hasData &&
              nurseryData.containsKey('name') &&
              nurseryData.containsKey('owner_name') &&
              nurseryData.containsKey('contact') &&
              nurseryData.containsKey('location')) {
            nurseries.add(nurseryData);
          }
        }
      }

      parsedNurseries.assignAll(nurseries);
      if (nurseries.isEmpty) {
        UiUtils.showWarningSnackbar(
          'Warning',
          'No valid nursery data found. Ensure "name", "owner_name", "contact", and "location" columns exist.',
        );
      }
    } catch (e) {
      print('Error parsing excel: $e');
      UiUtils.showErrorSnackbar('Error', 'Failed to parse Excel: $e');
    }
  }

  Future<void> uploadNurseries() async {
    if (parsedNurseries.isEmpty) {
      UiUtils.showWarningSnackbar('Warning', 'No nurseries to upload');
      return;
    }

    try {
      isUploading.value = true;
      final response = await _adminService.bulkAddNurseries(parsedNurseries);

      if (response['success'] == true) {
        uploadResults.value = response['data'] ?? {};
        UiUtils.showSuccessSnackbar('Success', response['message']);
      } else {
        UiUtils.showErrorSnackbar(
          'Error',
          response['message'] ?? 'Failed to upload nurseries',
        );
      }
    } catch (e) {
      print('Error uploading nurseries: $e');
      UiUtils.showErrorSnackbar('Error', 'Failed to upload nurseries: $e');
    } finally {
      isUploading.value = false;
    }
  }

  void clearBulkData() {
    parsedNurseries.clear();
    fileName.value = '';
    uploadResults.clear();
  }
}
