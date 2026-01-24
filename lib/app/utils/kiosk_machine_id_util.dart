import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sps_eth_app/app/utils/prefrence_utility.dart';
import 'package:sps_eth_app/app/utils/constants.dart';

/// Utility class for managing Kiosk Machine ID (Android ID and Serial Number)
/// 
/// This is specifically for Smart Police Station (SPS) kiosk machines
/// to uniquely identify each machine across the country.
/// 
/// The Android ID and Serial Number are:
/// - Retrieved every time the app starts
/// - Stored persistently for future reference
/// - Unique per device/app combination
class KioskMachineIdUtil {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  /// Initialize and store the Android ID and Serial Number for the kiosk machine
  /// 
  /// This should be called on app startup to ensure the Android ID and Serial Number
  /// are always stored and available for machine identification.
  /// 
  /// Returns a map with 'androidId' and 'serialNumber' keys
  static Future<Map<String, String>> initializeAndStoreDeviceInfo() async {
    try {
      String androidId = '';
      String serialNumber = '';
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        androidId = androidInfo.id;
        serialNumber = androidInfo.serialNumber;
        print('🖥️ [KIOSK MACHINE ID] Android ID retrieved: $androidId');
        print('🖥️ [KIOSK MACHINE ID] Serial Number retrieved: $serialNumber');
      } else {
        print('⚠️ [KIOSK MACHINE ID] Not running on Android platform');
        // For non-Android platforms, you might want to handle differently
        // For now, we'll return empty strings
        return {'androidId': '', 'serialNumber': ''};
      }
      
      // Store the Android ID persistently
      if (androidId.isNotEmpty) {
        await PreferenceUtils.setString(Constants.kioskMachineId, androidId);
        print('✅ [KIOSK MACHINE ID] Android ID stored successfully: $androidId');
      } else {
        print('⚠️ [KIOSK MACHINE ID] Android ID is empty, not storing');
      }
      
      // Store the Serial Number persistently
      if (serialNumber.isNotEmpty && serialNumber != 'unknown') {
        await PreferenceUtils.setString(Constants.kioskMachineSerialNumber, serialNumber);
        print('✅ [KIOSK MACHINE ID] Serial Number stored successfully: $serialNumber');
      } else {
        print('⚠️ [KIOSK MACHINE ID] Serial Number is empty or unknown, not storing');
      }
      
      return {'androidId': androidId, 'serialNumber': serialNumber};
    } catch (e) {
      print('❌ [KIOSK MACHINE ID] Error initializing device info: $e');
      return {'androidId': '', 'serialNumber': ''};
    }
  }
  
  /// Initialize and store the Android ID for the kiosk machine
  /// 
  /// This is a convenience method that calls initializeAndStoreDeviceInfo()
  /// and returns only the Android ID for backward compatibility.
  /// 
  /// This should be called on app startup to ensure the Android ID
  /// is always stored and available for machine identification.
  /// 
  /// Returns the Android ID string, or empty string if not available
  static Future<String> initializeAndStoreAndroidId() async {
    final deviceInfo = await initializeAndStoreDeviceInfo();
    return deviceInfo['androidId'] ?? '';
  }
  
  /// Get the stored Android ID for the kiosk machine
  /// 
  /// Returns the stored Android ID, or empty string if not found
  static String getStoredAndroidId() {
    try {
      final androidId = PreferenceUtils.getString(Constants.kioskMachineId, '');
      if (androidId.isNotEmpty) {
        print('📱 [KIOSK MACHINE ID] Retrieved stored Android ID: $androidId');
      } else {
        print('⚠️ [KIOSK MACHINE ID] No stored Android ID found');
      }
      return androidId;
    } catch (e) {
      print('❌ [KIOSK MACHINE ID] Error getting stored Android ID: $e');
      return '';
    }
  }
  
  /// Get the current Android ID directly from the device
  /// 
  /// This retrieves the Android ID without checking storage first
  static Future<String> getCurrentAndroidId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        final androidId = androidInfo.id;
        print('📱 [KIOSK MACHINE ID] Current Android ID: $androidId');
        return androidId;
      } else {
        print('⚠️ [KIOSK MACHINE ID] Not running on Android platform');
        return '';
      }
    } catch (e) {
      print('❌ [KIOSK MACHINE ID] Error getting current Android ID: $e');
      return '';
    }
  }
  
  /// Check if Android ID is stored
  static bool hasStoredAndroidId() {
    try {
      final androidId = PreferenceUtils.getString(Constants.kioskMachineId, '');
      return androidId.isNotEmpty;
    } catch (e) {
      print('❌ [KIOSK MACHINE ID] Error checking stored Android ID: $e');
      return false;
    }
  }
  
  /// Get the stored Serial Number for the kiosk machine
  /// 
  /// Returns the stored Serial Number, or empty string if not found
  static String getStoredSerialNumber() {
    try {
      final serialNumber = PreferenceUtils.getString(Constants.kioskMachineSerialNumber, '');
      if (serialNumber.isNotEmpty) {
        print('📱 [KIOSK MACHINE ID] Retrieved stored Serial Number: $serialNumber');
      } else {
        print('⚠️ [KIOSK MACHINE ID] No stored Serial Number found');
      }
      return serialNumber;
    } catch (e) {
      print('❌ [KIOSK MACHINE ID] Error getting stored Serial Number: $e');
      return '';
    }
  }
  
  /// Get the current Serial Number directly from the device
  /// 
  /// This retrieves the Serial Number without checking storage first
  static Future<String> getCurrentSerialNumber() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        final serialNumber = androidInfo.serialNumber;
        print('📱 [KIOSK MACHINE ID] Current Serial Number: $serialNumber');
        return serialNumber;
      } else {
        print('⚠️ [KIOSK MACHINE ID] Not running on Android platform');
        return '';
      }
    } catch (e) {
      print('❌ [KIOSK MACHINE ID] Error getting current Serial Number: $e');
      return '';
    }
  }
  
  /// Get both stored Android ID and Serial Number
  /// 
  /// Returns a map with 'androidId' and 'serialNumber' keys
  static Map<String, String> getStoredDeviceInfo() {
    return {
      'androidId': getStoredAndroidId(),
      'serialNumber': getStoredSerialNumber(),
    };
  }
  
  /// Check if Serial Number is stored
  static bool hasStoredSerialNumber() {
    try {
      final serialNumber = PreferenceUtils.getString(Constants.kioskMachineSerialNumber, '');
      return serialNumber.isNotEmpty && serialNumber != 'unknown';
    } catch (e) {
      print('❌ [KIOSK MACHINE ID] Error checking stored Serial Number: $e');
      return false;
    }
  }
  
  /// Clear the stored Android ID (useful for testing)
  static Future<void> clearStoredAndroidId() async {
    try {
      await PreferenceUtils.setString(Constants.kioskMachineId, '');
      print('🗑️ [KIOSK MACHINE ID] Stored Android ID cleared');
    } catch (e) {
      print('❌ [KIOSK MACHINE ID] Error clearing stored Android ID: $e');
    }
  }
  
  /// Clear the stored Serial Number (useful for testing)
  static Future<void> clearStoredSerialNumber() async {
    try {
      await PreferenceUtils.setString(Constants.kioskMachineSerialNumber, '');
      print('🗑️ [KIOSK MACHINE ID] Stored Serial Number cleared');
    } catch (e) {
      print('❌ [KIOSK MACHINE ID] Error clearing stored Serial Number: $e');
    }
  }
  
  /// Clear both stored Android ID and Serial Number (useful for testing)
  static Future<void> clearAllStoredDeviceInfo() async {
    await clearStoredAndroidId();
    await clearStoredSerialNumber();
  }
}
