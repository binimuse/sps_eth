import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Utility class for JWT token operations
class JwtUtil {
  /// Decode JWT token and extract user ID
  /// Tries to get 'sub' field first, then 'id', then 'userId'
  static String? getUserIdFromToken(String? token) {
    if (token == null || token.isEmpty) return null;

    try {
      final decoded = JwtDecoder.decode(token);
      
      // Try different possible fields for user ID
      return decoded['sub']?.toString() ?? 
             decoded['id']?.toString() ?? 
             decoded['userId']?.toString() ??
             decoded['user_id']?.toString();
    } catch (e) {
      print('Error decoding JWT token: $e');
      return null;
    }
  }

  /// Check if token is expired
  static bool isTokenExpired(String? token) {
    if (token == null || token.isEmpty) return true;

    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      print('Error checking token expiration: $e');
      return true;
    }
  }

  /// Get token expiration date
  static DateTime? getTokenExpirationDate(String? token) {
    if (token == null || token.isEmpty) return null;

    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      print('Error getting token expiration date: $e');
      return null;
    }
  }

  /// Decode entire JWT payload
  static Map<String, dynamic>? decodeToken(String? token) {
    if (token == null || token.isEmpty) return null;

    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      print('Error decoding JWT token: $e');
      return null;
    }
  }
}

