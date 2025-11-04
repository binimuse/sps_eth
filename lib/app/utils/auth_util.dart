import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sps_eth_app/app/utils/constants.dart';
import 'package:sps_eth_app/app/utils/validator_util.dart';


class AuthUtil {
  static final _storage = const FlutterSecureStorage();

  Future<void> saveTokenAndUserInfo({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    try {
      await _storage.write(key: Constants.accessToken, value: accessToken);
      await _storage.write(key: Constants.refreshToken, value: refreshToken);
      await _storage.write(key: Constants.userData, value: jsonEncode(user));
    } catch (e) {
      print("Error saving tokens and user info: $e");
      rethrow;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: Constants.accessToken);
    } catch (e) {
      print("Error getting access token: $e");
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: Constants.refreshToken);
    } catch (e) {
      print("Error getting refresh token: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    try {
      String? userData = await _storage.read(key: Constants.userData);
      if (userData?.isEmpty ?? true) {
        return {};
      }
      return json.decode(userData!);
    } catch (e) {
      print("Error reading user data: $e");
      return {};
    }
  }

  Future<String> getUserId() async {
    try {
      Map<String, dynamic> userDataMap = await getUserData();
      return userDataMap['id']?.toString() ?? '';
    } catch (e) {
      print("Error getting user ID: $e");
      return '';
    }
  }

  Future<bool> isUserPhoneVerified() async {
    try {
      Map<String, dynamic> userDataMap = await getUserData();
      return userDataMap['phone_otp_verified'] == true;
    } catch (e) {
      print("Error getting phone verification status: $e");
      return false;
    }
  }

  Future<String> getUserPhone() async {
    try {
      Map<String, dynamic> userDataMap = await getUserData();
      return userDataMap['username']?.toString() ?? '';
    } catch (e) {
      print("Error getting user phone: $e");
      return '';
    }
  }

  Future<void> updateUserPhoneNumber(String newPhone) async {
    try {
      Map<String, dynamic> userDataMap = await getUserData();
      userDataMap['username'] = ValidatorUtil.formatPhoneNumber(newPhone, true);
      userDataMap['phone_otp_verified'] = true;
      await _storage.write(
        key: Constants.userData,
        value: jsonEncode(userDataMap),
      );
    } catch (e) {
      print("Error updating phone number: $e");
      rethrow;
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      String? accessToken = await getAccessToken();
      String? refreshToken = await getRefreshToken();
      return accessToken != null && refreshToken != null;
    } catch (e) {
      print("Error checking authentication status: $e");
      return false;
    }
  }

  // Enhanced authentication check that validates token content
  Future<bool> isFullyAuthenticated() async {
    try {
      String? accessToken = await getAccessToken();
      String? refreshToken = await getRefreshToken();

      bool hasValidTokens =
          accessToken != null &&
          refreshToken != null &&
          accessToken.isNotEmpty &&
          refreshToken.isNotEmpty;

      if (!hasValidTokens) {
        print("Authentication validation failed:");
        print(
          "  Access Token: ${accessToken != null ? "exists (${accessToken.length} chars)" : "null"}",
        );
        print(
          "  Refresh Token: ${refreshToken != null ? "exists (${refreshToken.length} chars)" : "null"}",
        );
      }

      return hasValidTokens;
    } catch (e) {
      print("Error in isFullyAuthenticated: $e");
      return false;
    }
  }

  Future<void> logOut() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print("Error during logout: $e");
      rethrow;
    }
  }

  // Debug method to check token status
  Future<void> debugTokenStatus() async {
    try {
      String? accessToken = await getAccessToken();
      String? refreshToken = await getRefreshToken();

      print("=== Token Debug Info ===");
      print("Access Token: ${accessToken ?? "null"}");
      print("Refresh Token: ${refreshToken ?? "null"}");
      print("========================");
    } catch (e) {
      print("Error in debugTokenStatus: $e");
    }
  }

  // Test method to verify token storage
  Future<bool> testTokenStorage() async {
    try {
      const testAccessToken = "test_access_token_123";
      const testRefreshToken = "test_refresh_token_456";
      const testUser = {"id": "test_user", "name": "Test User"};

      // Save test tokens
      await saveTokenAndUserInfo(
        accessToken: testAccessToken,
        refreshToken: testRefreshToken,
        user: testUser,
      );

      // Retrieve tokens
      String? retrievedAccessToken = await getAccessToken();
      String? retrievedRefreshToken = await getRefreshToken();

      // Verify tokens match
      bool tokensMatch =
          retrievedAccessToken == testAccessToken &&
          retrievedRefreshToken == testRefreshToken;

      print("=== Token Storage Test ===");
      print("Test passed: $tokensMatch");
      print("Expected Access Token: $testAccessToken");
      print("Retrieved Access Token: $retrievedAccessToken");
      print("Expected Refresh Token: $testRefreshToken");
      print("Retrieved Refresh Token: $retrievedRefreshToken");
      print("==========================");

      // Clean up test tokens
      await logOut();

      return tokensMatch;
    } catch (e) {
      print("Error in testTokenStorage: $e");
      return false;
    }
  }

  /// Detects the type of username provided (email, phone, or Fayda ID)
  static String detectUsernameType(String username) {
    final trimmedUsername = username.trim();
    
    // Check if it's an email
    if (RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(trimmedUsername)) {
      return 'email';
    }
    
    // Check if it's a phone number (contains only digits and common phone characters)
    if (RegExp(r'^[\d\s\-\+\(\)]+$').hasMatch(trimmedUsername) && 
        trimmedUsername.replaceAll(RegExp(r'[\s\-\+\(\)]'), '').length >= 10) {
      return 'phone';
    }
    
    // If it's not email or phone, assume it's a Fayda ID
    return 'fayda';
  }

  /// Validates username based on its detected type
  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'Username is required';
    }

    final trimmedUsername = username.trim();
    final usernameType = detectUsernameType(trimmedUsername);

    switch (usernameType) {
      case 'email':
        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(trimmedUsername)) {
          return 'Please enter a valid email address';
        }
        break;
      case 'phone':
        final phoneDigits = trimmedUsername.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
        if (phoneDigits.length < 10) {
          return 'Please enter a valid phone number';
        }
        break;
      case 'fayda':
        if (trimmedUsername.length < 5) {
          return 'Fayda ID must be at least 5 characters';
        }
        break;
    }

    return null;
  }
}
