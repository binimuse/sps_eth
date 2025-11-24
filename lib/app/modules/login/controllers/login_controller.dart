import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:sps_eth_app/app/modules/Residence_id/services/auth_service.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/app/utils/dio_util.dart';
import 'package:sps_eth_app/app/utils/enums.dart';
import 'package:sps_eth_app/app/utils/auth_util.dart';
import 'package:sps_eth_app/app/common/app_toasts.dart';

class LoginController extends GetxController {
  // Text controllers
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Network status
  final Rx<NetworkStatus> networkStatus = NetworkStatus.IDLE.obs;
  final Rx<NetworkStatus> otpNetworkStatus = NetworkStatus.IDLE.obs;

  // OTP error message
  final RxString otpError = ''.obs;

  // Step tracking: 'phone' or 'otp'
  final RxString currentStep = 'phone'.obs;

  // Auth service
  final AuthService _authService = AuthService(
    DioUtil().getDio(useAccessToken: false),
  );

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  /// Request OTP for login
  Future<void> requestOtp() async {
    // Validate phone number
    if (phoneController.text.trim().isEmpty) {
      AppToasts.showError('Please enter your phone number');
      return;
    }

    if (!phoneController.text.trim().startsWith('+')) {
      AppToasts.showError('Phone number must start with +');
      return;
    }

    networkStatus.value = NetworkStatus.LOADING;
    otpError.value = '';

    try {
      final response = await _authService.requestOtp({
        'phone': phoneController.text.trim(),
      });

      if (response.success == true && response.data?.success == true) {
        networkStatus.value = NetworkStatus.SUCCESS;
        currentStep.value = 'otp';
        AppToasts.showSuccess('OTP sent successfully');
        // Clear OTP field
        otpController.clear();
      } else {
        networkStatus.value = NetworkStatus.ERROR;
        final errorMessage = response.error?.message ?? 
                            'Failed to send OTP. Please try again.';
        AppToasts.showError(errorMessage);
      }
    } on dio.DioException catch (e) {
      print('DioException during request OTP: ${e.response?.data}');
      networkStatus.value = NetworkStatus.ERROR;
      
      String errorMessage = 'Failed to send OTP. Please try again.';
      if (e.response != null) {
        try {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('error')) {
              final error = responseData['error'];
              if (error is Map && error.containsKey('message')) {
                errorMessage = error['message'] ?? errorMessage;
              }
            } else if (responseData.containsKey('message')) {
              errorMessage = responseData['message'] ?? errorMessage;
            }
          }
        } catch (_) {}
      }
      
      AppToasts.showError(errorMessage);
    } catch (e, s) {
      print('Error during request OTP: $e');
      print('Stack trace: $s');
      networkStatus.value = NetworkStatus.ERROR;
      AppToasts.showError('An unexpected error occurred. Please try again.');
      // Show detailed error dialog for debugging
      AppToasts.showErrorDialog(
        title: 'OTP Request Error',
        message: 'An unexpected error occurred while requesting OTP. Please try again.',
        errorDetails: e.toString(),
        stackTrace: s.toString(),
      );
    }
  }

  /// Verify OTP and complete login
  Future<void> verifyOtp() async {
    if (otpController.text.trim().length != 6) {
      otpError.value = 'Please enter a valid 6-digit OTP';
      return;
    }

    otpNetworkStatus.value = NetworkStatus.LOADING;
    otpError.value = '';

    try {
      final response = await _authService.verifyOtp({
        'phone': phoneController.text.trim(),
        'code': otpController.text.trim(),
      });

      if (response.success == true && 
          response.data?.accessToken != null &&
          response.data?.user != null) {
        
        // Store tokens and user data in local variables for use in closure
        final accessToken = response.data!.accessToken!;
        final refreshToken = response.data!.refreshToken ?? '';
        final userData = response.data!.user!.toJson();
        
        // Save tokens and user info to secure storage
        print('💾 [LOGIN] Saving tokens and user data to secure storage...');
        await AuthUtil().saveTokenAndUserInfo(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: userData,
        );
        print('💾 [LOGIN] Tokens saved, verifying...');

        // Verify token was actually saved before proceeding
        final savedToken = await AuthUtil().getAccessToken();
        if (savedToken == null || savedToken != accessToken) {
          print('❌ [LOGIN] Token verification failed! Saved token does not match.');
          print('❌ [LOGIN] Expected: $accessToken');
          print('❌ [LOGIN] Got: $savedToken');
          otpNetworkStatus.value = NetworkStatus.ERROR;
          otpError.value = 'Failed to save authentication token. Please try again.';
          AppToasts.showError('Failed to save authentication token. Please try again.');
          return;
        }

        print('✅ [LOGIN] Token verification successful!');
        print('✅ [LOGIN] Login successful - Tokens and user data saved to secure storage');
        print('✅ [LOGIN] User ID: ${response.data!.user!.id}');
        print('✅ [LOGIN] User Name: ${response.data!.user!.name}');
        print('✅ [LOGIN] User Role: ${response.data!.user!.role?.name}');

        otpNetworkStatus.value = NetworkStatus.SUCCESS;
        AppToasts.showSuccess('Login successful');

        // Small delay to ensure data is fully flushed and toast is shown
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Navigate back to previous screen (call-class view)
        // This will return to the screen that navigated to login
        print('✅ [LOGIN] Login successful, navigating to call-class view...');
        
        // Use SchedulerBinding to ensure navigation happens after current frame
        SchedulerBinding.instance.addPostFrameCallback((_) async {
          try {
            print('✅ [LOGIN] Attempting to navigate to call-class...');
            // Verify token one more time before navigation
            final tokenBeforeNav = await AuthUtil().getAccessToken();
            if (tokenBeforeNav == null || tokenBeforeNav != accessToken) {
              print('⚠️ [LOGIN] Token verification failed before navigation! Retrying save...');
              await AuthUtil().saveTokenAndUserInfo(
                accessToken: accessToken,
                refreshToken: refreshToken,
                user: userData,
              );
              // Wait a bit longer after retry
              await Future.delayed(const Duration(milliseconds: 300));
              
              // Verify again
              final retryToken = await AuthUtil().getAccessToken();
              if (retryToken == null || retryToken != accessToken) {
                print('❌ [LOGIN] Token still not saved after retry! Cannot proceed.');
                AppToasts.showError('Failed to save authentication. Please try logging in again.');
                return;
              }
              print('✅ [LOGIN] Token saved successfully after retry');
            }
            
            print('✅ [LOGIN] Token verified, navigating to call-class route...');
            Get.offNamed(Routes.CALL_CLASS);
            print('✅ [LOGIN] Navigation completed');
          } catch (e, stackTrace) {
            print('❌ [LOGIN] Error during navigation: $e');
            print('❌ [LOGIN] Stack trace: $stackTrace');
            // Show error dialog instead of just printing
            AppToasts.showErrorDialog(
              title: 'Navigation Error',
              message: 'Failed to navigate to call class after login. Please try again.',
              errorDetails: e.toString(),
              stackTrace: stackTrace.toString(),
            );
            // Fallback: navigate directly to call-class route
            print('⚠️ [LOGIN] Using fallback navigation to call-class');
            try {
              Get.offNamed(Routes.CALL_CLASS);
            } catch (e2) {
              print('❌ [LOGIN] Fallback navigation also failed: $e2');
              AppToasts.showErrorDialog(
                title: 'Navigation Error',
                message: 'Failed to navigate to call class. Please restart the app.',
                errorDetails: e2.toString(),
              );
            }
          }
        });
      } else {
        otpNetworkStatus.value = NetworkStatus.ERROR;
        final errorMessage = response.error?.message ?? 
                            'Invalid OTP code. Please try again.';
        otpError.value = errorMessage;
        AppToasts.showError(errorMessage);
      }
    } on dio.DioException catch (e) {
      print('DioException during verify OTP: ${e.response?.data}');
      otpNetworkStatus.value = NetworkStatus.ERROR;
      
      String errorMessage = 'Invalid OTP code. Please try again.';
      if (e.response != null) {
        try {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('error')) {
              final error = responseData['error'];
              if (error is Map && error.containsKey('message')) {
                errorMessage = error['message'] ?? errorMessage;
              }
            } else if (responseData.containsKey('message')) {
              errorMessage = responseData['message'] ?? errorMessage;
            }
          }
        } catch (_) {}
      }
      
      otpError.value = errorMessage;
      AppToasts.showError(errorMessage);
    } catch (e, s) {
      print('Error during verify OTP: $e');
      print('Stack trace: $s');
      otpNetworkStatus.value = NetworkStatus.ERROR;
      otpError.value = 'An unexpected error occurred. Please try again.';
      AppToasts.showError('An unexpected error occurred. Please try again.');
      // Show detailed error dialog for debugging
      AppToasts.showErrorDialog(
        title: 'OTP Verification Error',
        message: 'An unexpected error occurred while verifying OTP. Please try again.',
        errorDetails: e.toString(),
        stackTrace: s.toString(),
      );
    }
  }

  /// Go back to phone input step
  void goBackToPhone() {
    currentStep.value = 'phone';
    otpController.clear();
    otpError.value = '';
  }
}

