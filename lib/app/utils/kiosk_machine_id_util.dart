import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sps_eth_app/app/utils/prefrence_utility.dart';
import 'package:sps_eth_app/app/utils/constants.dart';

/// Utility class for managing Kiosk Machine ID (Android ID)
/// 
/// This is specifically for Smart Police Station (SPS) kiosk machines
/// to uniquely identify each machine across the country.
/// 
/// The Android ID is:
/// - Retrieved every time the app starts
/// - Stored persistently for future reference
/// - Unique per device/app combination
class KioskMachineIdUtil {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  /// Initialize and store the Android ID for the kiosk machine
  /// 
  /// This should be called on app startup to ensure the Android ID
  /// is always stored and available for machine identification.
  /// 
  /// Returns the Android ID string, or empty string if not available
  static Future<String> initializeAndStoreAndroidId() async {
    try {
      String androidId = '';
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        androidId = androidInfo.id;
        print('🖥️ [KIOSK MACHINE ID] Android ID retrieved: $androidId');
      } else {
        print('⚠️ [KIOSK MACHINE ID] Not running on Android platform');
        // For non-Android platforms, you might want to handle differently
        // For now, we'll return empty string
        return '';
      }
      
      // Store the Android ID persistently
      if (androidId.isNotEmpty) {
        await PreferenceUtils.setString(Constants.kioskMachineId, androidId);
        print('✅ [KIOSK MACHINE ID] Android ID stored successfully: $androidId');
      } else {
        print('⚠️ [KIOSK MACHINE ID] Android ID is empty, not storing');
      }
      
      return androidId;
    } catch (e) {
      print('❌ [KIOSK MACHINE ID] Error initializing Android ID: $e');
      return '';
    }
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
  
  /// Clear the stored Android ID (useful for testing)
  static Future<void> clearStoredAndroidId() async {
    try {
      await PreferenceUtils.setString(Constants.kioskMachineId, '');
      print('🗑️ [KIOSK MACHINE ID] Stored Android ID cleared');
    } catch (e) {
      print('❌ [KIOSK MACHINE ID] Error clearing stored Android ID: $e');
    }
  }
}
