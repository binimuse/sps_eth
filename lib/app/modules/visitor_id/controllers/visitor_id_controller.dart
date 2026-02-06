import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
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
final scanSuccess = false.obs;

// Passport result
final passportData = <String, dynamic>{}.obs;

// Error message
final scanError = ''.obs;

// Detailed diagnostic log for on-screen display
final diagnosticLog = ''.obs;

var passportNumber = ''.obs;
var fullName = ''.obs;
var nationality = ''.obs;
var dateOfBirth = ''.obs;
var expiryDate = ''.obs;
var scannedImageBase64 = ''.obs;

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
    scanSuccess.value = false;
    passportData.clear();

    print('=== Starting Passport Scan ===');
    
    final data = await PassportScannerService.scanPassport();

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📦 DATA RECEIVED FROM NATIVE');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Data type: ${data.runtimeType}');
    print('Data keys: ${data.keys.toList()}');
    print('Has imageBase64 key: ${data.containsKey("imageBase64")}');
    
    if (data.containsKey("imageBase64")) {
      final imageBase64Raw = data["imageBase64"];
      print('imageBase64 value type: ${imageBase64Raw.runtimeType}');
      print('imageBase64 is null: ${imageBase64Raw == null}');
      print('imageBase64 is empty: ${imageBase64Raw?.toString().isEmpty ?? true}');
      if (imageBase64Raw != null && imageBase64Raw.toString().isNotEmpty) {
        print('imageBase64 length: ${imageBase64Raw.toString().length} characters');
        print('');
        print('🔥🔥🔥 FULL BASE64 STRING RECEIVED IN FLUTTER 🔥🔥🔥');
        print('════════════════════════════════════════════════════════════');
        print(imageBase64Raw.toString());
        print('════════════════════════════════════════════════════════════');
        print('🔥🔥🔥 END OF BASE64 STRING 🔥🔥🔥');
        print('');
      }
    } else {
      print('❌ imageBase64 key NOT found in data from native!');
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Extract image first (always needed)
    scannedImageBase64.value = data['imageBase64']?.toString() ?? '';
    
    print('');
    print('📸 FINAL IMAGE STATUS:');
    if (scannedImageBase64.value.isNotEmpty) {
      print('   ✅ Image base64 stored in controller: YES (${scannedImageBase64.value.length} chars)');
      print('   ✅ Ready to display in UI');
    } else {
      print('   ❌ Image base64 received: NO - string is empty!');
    }
    print('');

    // Check if image was captured
    if (scannedImageBase64.value.isEmpty) {
      scanError.value = 'Document scanned but no image captured';
      return;
    }

    // Check if it's a passport (has passportNumber) or ID card (no passportNumber)
    final extractedPassportNumber = data['passportNumber']?.toString()?.trim() ?? '';
    final isPassport = extractedPassportNumber.isNotEmpty;
    
    print('=== Document Type Detection ===');
    print('Passport Number found: $extractedPassportNumber');
    print('Document Type: ${isPassport ? "PASSPORT" : "ID CARD"}');
    
    if (isPassport) {
      // PASSPORT: Extract all data + image
      print('📘 Processing as PASSPORT - extracting all data');
      
      // Store all passport data
      passportData.value = Map<String, dynamic>.from(data);

      // Map to individual fields
      passportNumber.value = extractedPassportNumber;
      fullName.value = data['fullName']?.toString() ?? '';
      nationality.value = data['nationality']?.toString() ?? '';
      dateOfBirth.value = data['dateOfBirth']?.toString() ?? '';
      expiryDate.value = data['expiryDate']?.toString() ?? '';
      
      // Update text field
      passportIdController.text = passportNumber.value;

      print('=== Passport Scan Complete ===');
      print('Passport Number: ${passportNumber.value}');
      print('Full Name: ${fullName.value}');
      print('Nationality: ${nationality.value}');
      print('Date of Birth: ${dateOfBirth.value}');
      print('Expiry Date: ${expiryDate.value}');
      print('Image Base64: ${scannedImageBase64.value.isNotEmpty ? "YES (${scannedImageBase64.value.length} chars)" : "NO"}');
      
      // Success! Navigate to call class with passport data + image
      scanSuccess.value = true;
      
      // Ensure base64 image is included in passportData map as well
      passportData.value['imageBase64'] = scannedImageBase64.value;
      
      Get.toNamed(
        Routes.CALL_CLASS,
        arguments: {
          'isVisitor': true,
          'autoStart': true,
          'passportData': Map<String, dynamic>.from(passportData),
          'passportNumber': passportNumber.value,
          'fullName': fullName.value,
          'nationality': nationality.value,
          'dateOfBirth': dateOfBirth.value,
          'expiryDate': expiryDate.value,
          'idPhoto': scannedImageBase64.value, // Pass base64 image (REQUIRED)
        },
      );
    } else {
      // ID CARD: Only use image, skip data extraction
      print('🆔 Processing as ID CARD - using image only, skipping data extraction');
      
      // Clear data fields (we don't need them for ID cards)
      passportNumber.value = '';
      fullName.value = '';
      nationality.value = '';
      dateOfBirth.value = '';
      expiryDate.value = '';
      
      // Store only the image in passportData for consistency
      passportData.value = {
        'imageBase64': scannedImageBase64.value,
        'documentType': 'ID_CARD',
      };
      
      print('=== ID Card Scan Complete ===');
      print('Document Type: ID Card');
      print('Image captured: YES');
      print('Image Base64: ${scannedImageBase64.value.isNotEmpty ? "YES (${scannedImageBase64.value.length} chars)" : "NO"}');
      print('Data extraction: SKIPPED (not needed for ID cards)');
      
      // Success! Navigate to call class with image only
      scanSuccess.value = true;
      
      // Verify base64 is not empty before navigating
      if (scannedImageBase64.value.isEmpty) {
        scanError.value = 'ID card scanned but no image captured';
        return;
      }
      
      Get.toNamed(
        Routes.CALL_CLASS,
        arguments: {
          'isVisitor': true,
          'autoStart': true,
          'idPhoto': scannedImageBase64.value, // Pass base64 image (REQUIRED)
          'documentType': 'ID_CARD', // Indicate it's an ID card, not passport
        },
      );
    }

  } catch (e) {
    print('=== Scan Failed ===');
    print('Error: $e');
    
    // User-friendly message (shown on screen)
    String userMessage = 'Unable to scan document. Please try again.';
    
    // Detailed technical log (console only)
    if (e is PlatformException) {
      print('╔════════════════════════════════════════════════════════════════');
      print('║ ERROR CODE: ${e.code}');
      print('║ ERROR MESSAGE: ${e.message}');
      print('╚════════════════════════════════════════════════════════════════');
      
      // Log full diagnostic data to console
      if (e.code == 'INIT_FAIL_DETAILED') {
        if (e.details != null && e.details is Map) {
          final details = Map<String, dynamic>.from(e.details as Map);
          print('');
          print('═══════════════════════ FULL DIAGNOSTIC DATA ═══════════════════════');
          details.forEach((key, value) {
            print('$key: $value');
          });
          print('═════════════════════════════════════════════════════════════════════');
          print('');
        }
        // User-friendly message
        userMessage = 'Unable to connect to scanner. Please check the device.';
        
      } else if (e.code == 'NO_DOC_DETAILED') {
        if (e.details != null && e.details is Map) {
          final details = Map<String, dynamic>.from(e.details as Map);
          print('');
          print('═══════════════════════ DETECTION FAILURE DETAILS ═══════════════════════');
          details.forEach((key, value) {
            print('$key: $value');
          });
          print('═════════════════════════════════════════════════════════════════════════');
          print('');
        }
        // User-friendly message
        userMessage = 'Please place your ID card on the scanner and try again.';
        
      } else if (e.code == 'NO_DOC') {
        userMessage = 'Please place your ID card on the scanner.';
        
      } else if (e.code == 'RECOG_FAIL') {
        userMessage = 'Unable to read the document. Please ensure it is placed correctly.';
        
      } else if (e.code == 'INIT_FAIL' || e.code == 'INIT_FAIL_HARDWARE_REQUIRED') {
        userMessage = 'Scanner device is not ready. Please contact support.';
      }
      
      // Always log error details to console
      if (e.details != null) {
        print('ERROR DETAILS:');
        print(e.details);
      }
    } else {
      print('Non-PlatformException error: ${e.toString()}');
      userMessage = 'An unexpected error occurred. Please try again.';
    }
    
    scanError.value = userMessage;
    
    // No popup - error is shown in the banner only
    // All debugging info is in console logs
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

