import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../../../services/farmerServices.dart';
import '../../../utils/ui_utils.dart';

class BulkAddFarmersController extends GetxController {
  final FarmerService _farmerService = FarmerService();

  final RxList<Map<String, dynamic>> parsedUsers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxString fileName = ''.obs;
  final RxMap<String, dynamic> uploadResults = <String, dynamic>{}.obs;

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
      List<Map<String, dynamic>> users = [];

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null || sheet.maxRows <= 1) continue;

        // Assuming first row is header
        // Expected headers: name, phone, email, preferred_language, role
        var headerRow = sheet.rows[0];
        Map<int, String> colMap = {};
        for (int i = 0; i < headerRow.length; i++) {
          var val = headerRow[i]?.value?.toString().toLowerCase().trim();
          if (val != null) colMap[i] = val;
        }

        for (int i = 1; i < sheet.maxRows; i++) {
          var row = sheet.rows[i];
          Map<String, dynamic> userData = {};
          bool hasData = false;

          for (int j = 0; j < row.length; j++) {
            var colName = colMap[j];
            var cellValue = row[j]?.value?.toString().trim();
            if (colName != null && cellValue != null && cellValue.isNotEmpty) {
              userData[colName] = cellValue;
              hasData = true;
            }
          }

          if (hasData &&
              userData.containsKey('name') &&
              userData.containsKey('phone')) {
            users.add(userData);
          }
        }
      }

      parsedUsers.assignAll(users);
      if (users.isEmpty) {
        UiUtils.showWarningSnackbar(
          'Warning',
          'No valid user data found in Excel. Ensure "name" and "phone" columns exist.',
        );
      }
    } catch (e) {
      print('Error parsing excel: $e');
      UiUtils.showErrorSnackbar('Error', 'Failed to parse Excel: $e');
    }
  }

  Future<void> uploadUsers() async {
    if (parsedUsers.isEmpty) {
      UiUtils.showWarningSnackbar('Warning', 'No users to upload');
      return;
    }

    try {
      isUploading.value = true;
      final response = await _farmerService.bulkAddUsers(parsedUsers);

      if (response['success'] == true) {
        uploadResults.value = response['results'];
        UiUtils.showSuccessSnackbar('Success', response['message']);
        // Clear parsed users after successful upload if needed, or keep for review
        // parsedUsers.clear();
      } else {
        UiUtils.showErrorSnackbar(
          'Error',
          response['message'] ?? 'Failed to upload users',
        );
      }
    } catch (e) {
      print('Error uploading users: $e');
      UiUtils.showErrorSnackbar('Error', 'Failed to upload users: $e');
    } finally {
      isUploading.value = false;
    }
  }

  void clearData() {
    parsedUsers.clear();
    fileName.value = '';
    uploadResults.clear();
  }
}
