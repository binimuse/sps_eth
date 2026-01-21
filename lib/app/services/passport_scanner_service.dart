import 'package:flutter/services.dart';

class PassportScannerService {
  static const _channel = MethodChannel('passport_scanner');

  /// Checks SDK status without requiring hardware
  /// Useful for diagnostics on tablet/emulator
  static Future<Map<String, dynamic>> checkSDKStatus() async {
    try {
      final result = await _channel.invokeMethod('checkSDKStatus');
      
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        throw PlatformException(
          code: 'INVALID_RESULT',
          message: 'Invalid result type from native code',
        );
      }
    } on PlatformException {
      rethrow;
    } catch (e) {
      throw PlatformException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }

  /// Scans passport using the native SDK
  /// Returns a map containing passport fields
  /// Throws PlatformException on error
  static Future<Map<String, dynamic>> scanPassport() async {
    try {
      final result = await _channel.invokeMethod('scanPassport');
      
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        throw PlatformException(
          code: 'INVALID_RESULT',
          message: 'Invalid result type from native code',
        );
      }
    } on PlatformException {
      // Re-throw platform exceptions as-is
      rethrow;
    } catch (e) {
      // Wrap other exceptions
      throw PlatformException(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      );
    }
  }
}
