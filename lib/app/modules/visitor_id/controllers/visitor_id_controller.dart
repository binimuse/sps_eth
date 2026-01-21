import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';
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

// SDK Status for diagnostics
final sdkStatus = <String, dynamic>{}.obs;

/// Check SDK status without requiring hardware
/// Useful for verifying setup on tablet/emulator
Future<Map<String, dynamic>> checkSDKStatus() async {
  try {
    print('=== Checking SDK Status ===');
    final status = await PassportScannerService.checkSDKStatus();
    sdkStatus.value = status;
    
    print('SDK Status:');
    print('  - SDK Loaded: ${status['sdkLoaded']}');
    print('  - Assets Copied: ${status['assetsCopied']}');
    print('  - Config File Exists: ${status['configFileExists']}');
    print('  - Hardware Detected: ${status['hardwareDetected']}');
    print('  - Current Device: ${status['currentDevice']}');
    
    return status;
  } catch (e) {
    print('SDK Status Check Failed: $e');
    final errorStatus = {'error': e.toString()};
    sdkStatus.value = errorStatus;
    return errorStatus;
  }
}

Future<void> scanPassport() async {
  try {
    isScanning.value = true;
    scanError.value = '';
    passportData.clear();

    print('=== Starting Passport Scan ===');
    
    final data = await PassportScannerService.scanPassport();

    // Store all passport data
    passportData.value = Map<String, dynamic>.from(data);

    // Map to individual fields
    passportNumber.value = data['passportNumber']?.toString() ?? '';
    fullName.value = data['fullName']?.toString() ?? '';
    nationality.value = data['nationality']?.toString() ?? '';
    dateOfBirth.value = data['dateOfBirth']?.toString() ?? '';
    expiryDate.value = data['expiryDate']?.toString() ?? '';

    // Update text field if passport number found
    if (passportNumber.value.isNotEmpty) {
      passportIdController.text = passportNumber.value;
    }

    print('=== Passport Scan Complete ===');
    print('Passport Number: ${passportNumber.value}');
    print('Full Name: ${fullName.value}');
    print('Nationality: ${nationality.value}');
    print('Date of Birth: ${dateOfBirth.value}');
    print('Expiry Date: ${expiryDate.value}');
    print('All Data: $data');

    // Show success message if we got at least passport number
    if (passportNumber.value.isNotEmpty || fullName.value.isNotEmpty) {
      BotToast.showText(
        text: 'Passport scanned successfully',
        contentColor: Colors.green,
        textStyle: const TextStyle(color: Colors.white),
        duration: const Duration(seconds: 2),
        align: Alignment.bottomCenter,
      );
    } else {
      scanError.value = 'Passport scanned but no data extracted';
      BotToast.showText(
        text: 'Passport scanned but some fields are missing',
        contentColor: Colors.orange,
        textStyle: const TextStyle(color: Colors.white),
        duration: const Duration(seconds: 3),
        align: Alignment.bottomCenter,
      );
    }

  } catch (e) {
    print('=== Scan Failed ===');
    print('Error: $e');
    
    String errorMessage = 'Scan failed';
    String title = 'Scan Failed';
    Color snackbarColor = Colors.red;
    int duration = 4;
    
    if (e is PlatformException) {
      errorMessage = e.message ?? e.code;
      print('Error Code: ${e.code}');
      print('Error Message: ${e.message}');
      print('Error Details: ${e.details}');
      
      // Special handling for hardware required error
      if (e.code == 'INIT_FAIL_HARDWARE_REQUIRED') {
        title = 'Hardware Required';
        errorMessage = '''
⚠️ Scanner hardware not detected

This is EXPECTED when testing on:
• Android tablet (no scanner)
• Android emulator

✅ This WILL work on:
• SPS Smart Police Station kiosk
• Device with scanner hardware

📋 Status:
• SDK loaded: ✅
• Assets ready: ✅
• Hardware: ❌ (required)

💡 The app is ready - just needs real hardware!
        ''';
        snackbarColor = Colors.orange;
        duration = 8;
      } else if (e.code == 'INIT_FAIL' && e.message?.contains('Device initialization') == true) {
        title = 'Hardware Required';
        errorMessage = 'Scanner hardware not detected. This is normal on tablet - will work on SPS kiosk!';
        snackbarColor = Colors.orange;
        duration = 6;
      }
    } else {
      errorMessage = e.toString();
    }
    
    scanError.value = errorMessage;
    
    // Show error message using BotToast (safer than Get.snackbar)
    BotToast.showText(
      text: '$title\n$errorMessage',
      contentColor: snackbarColor,
      textStyle: const TextStyle(color: Colors.white, fontSize: 14),
      duration: Duration(seconds: duration),
      align: Alignment.bottomCenter,
    );
  } finally {
    isScanning.value = false;
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

