import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Utility class for managing device ID
/// 
/// Device ID is used for anonymous login and should be:
/// - Generated once on first app launch
/// - Stored persistently across app restarts
/// - Reused for subsequent anonymous logins
/// 
/// Uses real device identifiers when available, falls back to UUID if not.
class DeviceIdUtil {
  static const String _deviceIdKey = 'DEVICE_ID';
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const Uuid _uuid = Uuid();
  
  /// Get device ID - returns stored ID or generates new one
  /// 
  /// Priority:
  /// 1. Returns stored device ID if exists
  /// 2. Tries to get real device identifier (Android ID, iOS identifierForVendor)
  /// 3. Falls back to generating UUID if device identifier not available
  /// 4. Stores the ID for future use
  static Future<String> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? storedDeviceId = prefs.getString(_deviceIdKey);
      
      if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
        print('📱 [DEVICE ID] Using stored device ID: $storedDeviceId');
        return storedDeviceId;
      }
      
      // No stored ID, generate new one
      print('📱 [DEVICE ID] No stored device ID found, generating new one...');
      String? deviceId;
      
      try {
        // Try to get real device identifier
        if (Platform.isAndroid) {
          final androidInfo = await _deviceInfo.androidInfo;
          // Use Android ID (unique per device/app combination)
          deviceId = androidInfo.id;
          print('📱 [DEVICE ID] Got Android ID: $deviceId');
        } else if (Platform.isIOS) {
          final iosInfo = await _deviceInfo.iosInfo;
          // Use identifierForVendor (unique per vendor on device)
          deviceId = iosInfo.identifierForVendor;
          print('📱 [DEVICE ID] Got iOS identifierForVendor: $deviceId');
        } else if (Platform.isMacOS) {
          final macInfo = await _deviceInfo.macOsInfo;
          // Use system UUID for macOS
          deviceId = macInfo.systemGUID;
          print('📱 [DEVICE ID] Got macOS system GUID: $deviceId');
        } else if (Platform.isWindows) {
          final windowsInfo = await _deviceInfo.windowsInfo;
          // Use machine GUID for Windows
          deviceId = windowsInfo.deviceId;
          print('📱 [DEVICE ID] Got Windows device ID: $deviceId');
        } else if (Platform.isLinux) {
          final linuxInfo = await _deviceInfo.linuxInfo;
          // Use machine ID for Linux
          deviceId = linuxInfo.machineId;
          print('📱 [DEVICE ID] Got Linux machine ID: $deviceId');
        }
      } catch (e) {
        print('⚠️ [DEVICE ID] Error getting device identifier: $e');
      }
      
      // If device identifier is null or empty, generate UUID
      if (deviceId == null || deviceId.isEmpty) {
        deviceId = _uuid.v4();
        print('📱 [DEVICE ID] Generated UUID device ID: $deviceId');
      }
      
      // Store the device ID for future use
      await prefs.setString(_deviceIdKey, deviceId);
      print('📱 [DEVICE ID] Device ID stored: $deviceId');
      
      return deviceId;
    } catch (e) {
      print('❌ [DEVICE ID] Error getting device ID: $e');
      // Fallback: generate UUID and try to store it
      try {
        final fallbackId = _uuid.v4();
        print('📱 [DEVICE ID] Using fallback UUID: $fallbackId');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_deviceIdKey, fallbackId);
        return fallbackId;
      } catch (fallbackError) {
        print('❌ [DEVICE ID] Fallback also failed: $fallbackError');
        // Last resort: return a generated UUID without storing
        return _uuid.v4();
      }
    }
  }
  
  /// Store device ID (for future use when implementing real device IDs)
  static Future<void> setDeviceId(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_deviceIdKey, deviceId);
      print('📱 [DEVICE ID] Device ID stored: $deviceId');
    } catch (e) {
      print('❌ [DEVICE ID] Error storing device ID: $e');
    }
  }
  
  /// Clear stored device ID (useful for testing or logout)
  static Future<void> clearDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceIdKey);
      print('📱 [DEVICE ID] Device ID cleared');
    } catch (e) {
      print('❌ [DEVICE ID] Error clearing device ID: $e');
    }
  }
  
  /// Check if device ID exists in storage
  static Future<bool> hasDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_deviceIdKey);
    } catch (e) {
      print('❌ [DEVICE ID] Error checking device ID: $e');
      return false;
    }
  }
  
  /// Get device serial number
  /// For kiosk machines, returns the Android serial number or a constant value
  static Future<String> getDeviceSerialNumber() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Try to get serial number (available on Android 8.0+)
        final serialNumber = androidInfo.serialNumber;
        if (serialNumber.isNotEmpty && serialNumber != 'unknown') {
          print('📱 [DEVICE SERIAL] Got Android serial number: $serialNumber');
          return serialNumber;
        }
      }
      
      // Fallback: use a constant for kiosk machines
      const kioskSerialNumber = 'SPS-KIOSK-001';
      print('📱 [DEVICE SERIAL] Using constant serial number: $kioskSerialNumber');
      return kioskSerialNumber;
    } catch (e) {
      print('❌ [DEVICE SERIAL] Error getting serial number: $e');
      // Fallback to constant
      const kioskSerialNumber = 'SPS-KIOSK-001';
      return kioskSerialNumber;
    }
  }
}

