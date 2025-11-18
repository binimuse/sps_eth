import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:sps_eth_app/app/modules/Residence_id/models/auth_model.dart';
import 'package:sps_eth_app/app/modules/Residence_id/services/auth_service.dart';
import 'package:sps_eth_app/app/utils/dio_util.dart';
import 'package:sps_eth_app/app/utils/enums.dart';
import 'package:sps_eth_app/app/utils/auth_util.dart';
import 'package:sps_eth_app/app/common/app_toasts.dart';
import 'package:sps_eth_app/app/modules/Residence_id/views/id_information_view.dart';
import 'package:sps_eth_app/app/modules/Residence_id/views/otp_verification_view.dart';

class ResidenceIdController extends GetxController {
  // Text controllers
  final idController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  // Network status
  final Rx<NetworkStatus> networkStatus = NetworkStatus.IDLE.obs;
  final Rx<NetworkStatus> otpNetworkStatus = NetworkStatus.IDLE.obs;

  // Signup response
  final Rx<SignupUser?> signupUser = Rx<SignupUser?>(null);
  
  // OTP error message
  final RxString otpError = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    idController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  /// Signup user with ID and phone number
  Future<void> signup() async {
    // Validate inputs
    if (idController.text.trim().isEmpty) {
      AppToasts.showError('Please enter name');
      return;
    }

    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      AppToasts.showError('Please enter phone number');
      return;
    }

    // Format phone number (ensure it starts with +)
    String formattedPhone = phone;
    if (!formattedPhone.startsWith('+')) {
      // If it starts with 0, replace with +251
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '+251${formattedPhone.substring(1)}';
      } else if (formattedPhone.startsWith('251')) {
        formattedPhone = '+$formattedPhone';
      } else {
        // Default to +251 if no country code
        formattedPhone = '+251$formattedPhone';
      }
    }

    networkStatus.value = NetworkStatus.LOADING;

    // Prepare request data
    final requestData = {
      'name': idController.text.trim(),
      'phone': formattedPhone,
    };

    // Debug: Log request data
    print('Signup request data: $requestData');

    try {
      final response = await AuthService(
        DioUtil().getDio(useAccessToken: false), // Signup doesn't require auth
      ).signup(requestData);

      if (response.success == true && response.data?.success == true && response.data?.user != null) {
        signupUser.value = response.data!.user;
        networkStatus.value = NetworkStatus.SUCCESS;
        
        // Show success message
        AppToasts.showSuccess(response.data?.message ?? 'Account created successfully');
        
        // Request OTP and show OTP verification dialog
        await requestOtp(formattedPhone);
      } else {
        networkStatus.value = NetworkStatus.ERROR;
        // Check for error in response
        final errorMessage = response.error?.message ?? 
                            response.data?.message ?? 
                            'Failed to create account';
        AppToasts.showError(errorMessage);
      }
    } on dio.DioException catch (e) {
      print('DioException during signup: ${e.response?.data}');
      networkStatus.value = NetworkStatus.ERROR;
      
      // Try to extract error message from response
      String errorMessage = 'Failed to create account. Please try again.';
      
      if (e.response != null) {
        try {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic>) {
            // Try to parse as SignupResponse to get error message
            try {
              final errorResponse = SignupResponse.fromJson(responseData);
              errorMessage = errorResponse.error?.message ?? 
                           errorResponse.data?.message ?? 
                           errorMessage;
            } catch (_) {
              // If parsing fails, try to get error message directly
              if (responseData.containsKey('error')) {
                final error = responseData['error'];
                if (error is Map && error.containsKey('message')) {
                  errorMessage = error['message'] ?? errorMessage;
                }
              } else if (responseData.containsKey('message')) {
                errorMessage = responseData['message'] ?? errorMessage;
              }
            }
          }
        } catch (_) {
          // If all parsing fails, use default message
        }
      }
      
      AppToasts.showError(errorMessage);
    } catch (e, s) {
      print('Error during signup: $e');
      print('Stack trace: $s');
      networkStatus.value = NetworkStatus.ERROR;
      AppToasts.showError('Failed to create account. Please try again.');
    }
  }

  /// Request OTP
  Future<void> requestOtp(String phone) async {
    otpNetworkStatus.value = NetworkStatus.LOADING;
    otpError.value = '';

    try {
      final response = await AuthService(
        DioUtil().getDio(useAccessToken: false),
      ).requestOtp({
        'phone': phone,
      });

      if (response.success == true && response.data?.success == true) {
        otpNetworkStatus.value = NetworkStatus.SUCCESS;
        AppToasts.showSuccess(response.data?.message ?? 'OTP sent successfully');
        
        // Show OTP verification dialog if not already shown
        final context = Get.context;
        if (context != null) {
          OtpVerificationView.show(context, phone);
        }
      } else {
        otpNetworkStatus.value = NetworkStatus.ERROR;
        final errorMessage = response.error?.message ?? 
                            response.data?.message ?? 
                            'Failed to send OTP';
        otpError.value = errorMessage;
        AppToasts.showError(errorMessage);
      }
    } on dio.DioException catch (e) {
      print('DioException during request OTP: ${e.response?.data}');
      otpNetworkStatus.value = NetworkStatus.ERROR;
      
      String errorMessage = 'Failed to send OTP. Please try again.';
      if (e.response != null) {
        try {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic>) {
            try {
              final errorResponse = RequestOtpResponse.fromJson(responseData);
              errorMessage = errorResponse.error?.message ?? 
                           errorResponse.data?.message ?? 
                           errorMessage;
            } catch (_) {
              if (responseData.containsKey('error')) {
                final error = responseData['error'];
                if (error is Map && error.containsKey('message')) {
                  errorMessage = error['message'] ?? errorMessage;
                }
              }
            }
          }
        } catch (_) {}
      }
      
      otpError.value = errorMessage;
      AppToasts.showError(errorMessage);
    } catch (e, s) {
      print('Error during request OTP: $e');
      print('Stack trace: $s');
      otpNetworkStatus.value = NetworkStatus.ERROR;
      otpError.value = 'Failed to send OTP. Please try again.';
      AppToasts.showError('Failed to send OTP. Please try again.');
    }
  }

  /// Verify OTP
  Future<void> verifyOtp(String phone) async {
    final code = otpController.text.trim();
    
    if (code.isEmpty || code.length != 6) {
      otpError.value = 'Please enter a valid 6-digit OTP';
      return;
    }

    otpNetworkStatus.value = NetworkStatus.LOADING;
    otpError.value = '';

    try {
      final response = await AuthService(
        DioUtil().getDio(useAccessToken: false),
      ).verifyOtp({
        'phone': phone,
        'code': code,
      });

      if (response.success == true && response.data?.success == true) {
        otpNetworkStatus.value = NetworkStatus.SUCCESS;
        
        // Save tokens if provided
        if (response.data?.accessToken != null && response.data?.refreshToken != null) {
          await AuthUtil().saveTokenAndUserInfo(
            accessToken: response.data!.accessToken!,
            refreshToken: response.data!.refreshToken!,
            user: response.data!.user?.toJson() ?? {},
          );
        }
        
        // Close OTP dialog
        Get.back();
        
        // Show success message
        AppToasts.showSuccess(response.data?.message ?? 'OTP verified successfully');
        
        // Show ID information dialog
        if (signupUser.value != null) {
          _showIdInformation(signupUser.value!);
        }
      } else {
        otpNetworkStatus.value = NetworkStatus.ERROR;
        final errorMessage = response.error?.message ?? 
                            response.data?.message ?? 
                            'Invalid OTP code';
        otpError.value = errorMessage;
        AppToasts.showError(errorMessage);
      }
    } on dio.DioException catch (e) {
      print('DioException during verify OTP: ${e.response?.data}');
      otpNetworkStatus.value = NetworkStatus.ERROR;
      
      String errorMessage = 'Invalid OTP code';
      if (e.response != null) {
        try {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic>) {
            try {
              final errorResponse = VerifyOtpResponse.fromJson(responseData);
              errorMessage = errorResponse.error?.message ?? 
                           errorResponse.data?.message ?? 
                           errorMessage;
            } catch (_) {
              if (responseData.containsKey('error')) {
                final error = responseData['error'];
                if (error is Map && error.containsKey('message')) {
                  errorMessage = error['message'] ?? errorMessage;
                }
              }
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
      otpError.value = 'Failed to verify OTP. Please try again.';
      AppToasts.showError('Failed to verify OTP. Please try again.');
    }
  }

  /// Show ID information dialog with user data
  void _showIdInformation(SignupUser user) {
    // Get current context
    final context = Get.context;
    if (context == null) return;

    // Show ID information dialog
    IdInformationView.show(
      context,
      {
        'id': user.id ?? '',
        'name': user.name ?? '',
        'phoneNumber': user.phone ?? '',
        'birthDate': '-', // Not provided in signup response
        'email': '-', // Not provided in signup response
        'residenceAddress': '-', // Not provided in signup response
      },
    );
  }
}
