import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/services/passport_scanner_service.dart';


class VisitorIdController extends GetxController {
  // Passport ID controller
  final passportIdController = TextEditingController();

  // Keyboard state
  final selectedLanguage = 'English'.obs;
  final TextEditingController keyboardController = TextEditingController();
  TextEditingController? focusedController;
  FocusNode? focusedField = FocusNode();
// Scan state
final isScanning = false.obs;

// Passport result
final passportData = <String, dynamic>{}.obs;

// Error message
final scanError = ''.obs;

var passportNumber = ''.obs;
var fullName = ''.obs;
var nationality = ''.obs;
var dateOfBirth = ''.obs;
var expiryDate = ''.obs;


Future<void> scanPassport() async {
  try {
    final data = await PassportScannerService.scanPassport();

    passportNumber.value = data['passportNumber'] ?? '';
    fullName.value = data['fullName'] ?? '';
    nationality.value = data['nationality'] ?? '';
    dateOfBirth.value = data['dateOfBirth'] ?? '';
    expiryDate.value = data['expiryDate'] ?? '';

    print('Passport Scan Result: $data');

  } catch (e) {
    print('Scan failed: $e');
  }
}


  @override
  void onClose() {
    passportIdController.dispose();
    keyboardController.dispose();
    focusedField?.dispose();
    super.onClose();
  }

  void setFocusedField(FocusNode? focusNode, TextEditingController textController) {
    focusedField = focusNode;
    focusedController = textController;
    keyboardController.text = textController.text;
    keyboardController.selection = textController.selection;
  }
}

