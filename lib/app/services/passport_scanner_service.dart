import 'package:flutter/services.dart';

class PassportScannerService {
  static const _channel = MethodChannel('passport_scanner');

  static Future<Map<String, dynamic>> scanPassport() async {
    final result = await _channel.invokeMethod('scanPassport');
    return Map<String, dynamic>.from(result);
  }
}
