import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sps_eth_app/app/utils/constants.dart';
import 'package:sps_eth_app/app/utils/validator_util.dart';


class AuthUtil {
  // Configure FlutterSecureStorage with Android-specific options for Android 11 compatibility
  // Android 11 has known issues with Keystore initialization, so we use encryptedSharedPreferences
  // and resetOnError to handle NullPointerException issues
  static final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      // Use encrypted shared preferences for better Android 11 compatibility
      encryptedSharedPreferences: true,
      // Reset storage on error to handle Android 11 Keystore NullPointerException
      resetOnError: true,
    ),
    // iOS options (keep default)
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> saveTokenAndUserInfo({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    // Retry logic for Android 11 compatibility
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 500);
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print("💾 [AUTH UTIL] Attempting to save tokens (attempt $attempt/$maxRetries)...");
        
        // Save tokens with retry logic
        await _storage.write(key: Constants.accessToken, value: accessToken);
        await Future.delayed(const Duration(milliseconds: 100)); // Small delay between writes
        
        await _storage.write(key: Constants.refreshToken, value: refreshToken);
        await Future.delayed(const Duration(milliseconds: 100));
        
        await _storage.write(key: Constants.userData, value: jsonEncode(user));
        
        print("✅ [AUTH UTIL] Tokens saved successfully on attempt $attempt");
        return; // Success, exit retry loop
      } catch (e, stackTrace) {
        print("❌ [AUTH UTIL] Error saving tokens on attempt $attempt: $e");
        print("❌ [AUTH UTIL] Stack trace: $stackTrace");
        
        // If it's the last attempt, rethrow the error
        if (attempt == maxRetries) {
          print("❌ [AUTH UTIL] All retry attempts failed");
          rethrow;
        }
        
        // Wait before retrying
        print("⏳ [AUTH UTIL] Waiting ${retryDelay.inMilliseconds}ms before retry...");
        await Future.delayed(retryDelay);
        
        // On Android 11, sometimes the Keystore needs to be reset
        if (e.toString().contains('NullPointerException') || 
            e.toString().contains('do.k.f')) {
          print("⚠️ [AUTH UTIL] Detected Android 11 Keystore issue, attempting reset...");
          try {
            // Try to delete and recreate (this might help reset the Keystore state)
            await _storage.delete(key: Constants.accessToken);
            await Future.delayed(const Duration(milliseconds: 200));
          } catch (_) {
            // Ignore errors during cleanup
          }
        }
      }
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
  // Note: refreshToken is optional for OTP-based login, so we only require accessToken
  Future<bool> isFullyAuthenticated() async {
    try {
      String? accessToken = await getAccessToken();
      String? refreshToken = await getRefreshToken();

      // Access token is required, refresh token is optional (OTP login might not provide it)
      bool hasValidAccessToken =
          accessToken != null && accessToken.isNotEmpty;

      if (!hasValidAccessToken) {
        print("Authentication validation failed:");
        print(
          "  Access Token: ${accessToken != null ? "exists (${accessToken.length} chars)" : "null"}",
        );
        print(
          "  Refresh Token: ${refreshToken != null ? "exists (${refreshToken.length} chars)" : "null (optional)"}",
        );
        return false;
      }

      // If we have refresh token, it should also be valid
      if (refreshToken != null && refreshToken.isEmpty) {
        print("⚠️ Warning: Refresh token is empty string (this is OK for OTP login)");
      }

      print("✅ Authentication validation passed:");
      print("  Access Token: exists (${accessToken.length} chars)");
      print("  Refresh Token: ${refreshToken != null && refreshToken.isNotEmpty ? "exists (${refreshToken.length} chars)" : "not provided (OK)"}");
      
      return true;
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
