import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/app/utils/enums.dart';
import 'package:sps_eth_app/app/utils/dio_util.dart';
import 'package:sps_eth_app/app/common/app_toasts.dart';
import 'package:sps_eth_app/app/modules/Residence_id/services/id_integration_service.dart';
import 'package:sps_eth_app/app/modules/Residence_id/models/id_integration_model.dart';
import 'package:sps_eth_app/app/modules/Residence_id/views/widgets/residence_service_list_view.dart';
import 'package:sps_eth_app/app/modules/Residence_id/views/widgets/residence_service_detail_view.dart';

class ResidenceIdController extends GetxController {
  // Selected ID type
  final RxString selectedIdType = ''.obs;
  final RxString otpError = ''.obs;
  final Rx<NetworkStatus> otpNetworkStatus = NetworkStatus.IDLE.obs;
  
  // OTP state
  final RxBool isOtpSent = false.obs;
  final RxString transactionID = ''.obs;
  final RxString maskedMobile = ''.obs;

  // Service selection
  final RxString selectedService = 'Crime Report'.obs;

  // Text controllers
  final phoneController = TextEditingController();
  final idController = TextEditingController();
  final tinController = TextEditingController();
  final otpController = TextEditingController();
  
  // Service
  late final IdIntegrationService _idIntegrationService;
  
  // Store user data for later use
  Map<String, dynamic>? _userData;

  @override
  void onInit() {
    super.onInit();
    // Initialize service
    final dio = DioUtil().getDio(useAccessToken: false);
    _idIntegrationService = IdIntegrationService(dio);
  }

  @override
  void onClose() {
    phoneController.dispose();
    idController.dispose();
    otpController.dispose();
    tinController.dispose();
    super.onClose();
  }

  /// Select ID type
  void selectIdType(String type) {
    selectedIdType.value = type;
  }

  /// Clear selection and reset
  void clearSelection() {
    selectedIdType.value = '';
    phoneController.clear();
    idController.clear();
    otpController.clear();
    tinController.clear();
    isOtpSent.value = false;
    transactionID.value = '';
    maskedMobile.value = '';
    otpError.value = '';
    otpNetworkStatus.value = NetworkStatus.IDLE;
  }
  
  /// Request OTP for Fayda ID
  Future<void> requestFaydaOtp() async {
    final fanOrFin = phoneController.text.trim();
    if (fanOrFin.isEmpty) {
      otpError.value = 'Please enter your FAN or FIN number';
      return;
    }
    
    // Use the FAN/FIN number directly as individualId
    // Remove any spaces or special characters
    String individualId = fanOrFin.replaceAll(RegExp(r'[^\d]'), '');
    
    // The API requires individualId to be at least 12 characters
    if (individualId.length < 12) {
      otpError.value = 'FAN/FIN number must be at least 12 digits';
      otpNetworkStatus.value = NetworkStatus.ERROR;
      return;
    }
    
    otpNetworkStatus.value = NetworkStatus.LOADING;
    otpError.value = '';
    
    try {
      print('📱 [FAYDA OTP] Requesting OTP for individualId: $individualId (length: ${individualId.length})');
      
      final request = FaydaOtpRequest(individualId: individualId);
      final response = await _idIntegrationService.requestOtp(request);
      
      print('📱 [FAYDA OTP] Response received: ${response.success}');
      
      if (response.success == true && response.data != null) {
        // OTP sent successfully
        isOtpSent.value = true;
        transactionID.value = response.data!.transactionID ?? '';
        maskedMobile.value = response.data!.response?.maskedMobile ?? '';
        
        print('✅ [FAYDA OTP] OTP sent successfully');
        print('  - Transaction ID: ${transactionID.value}');
        print('  - Masked Mobile: ${maskedMobile.value}');
        
        // Use Get.context to safely show toast
        final context = Get.context;
        if (context != null) {
          AppToasts.showSuccess('OTP sent successfully to ${maskedMobile.value}');
        }
        otpNetworkStatus.value = NetworkStatus.SUCCESS;
      } else if (response.statusCode != null) {
        // Error response
        final errorMessage = response.message ?? response.error ?? 'Failed to send OTP';
        otpError.value = errorMessage;
        otpNetworkStatus.value = NetworkStatus.ERROR;
        print('❌ [FAYDA OTP] Error: $errorMessage');
      } else {
        otpError.value = 'Failed to send OTP. Please try again.';
        otpNetworkStatus.value = NetworkStatus.ERROR;
      }
    } catch (e, stackTrace) {
      print('❌ [FAYDA OTP] Exception: $e');
      print('❌ [FAYDA OTP] Stack trace: $stackTrace');
      
      // Parse error from response if available
      String errorMessage = 'Failed to send OTP. Please try again.';
      if (e is DioException && e.response != null) {
        try {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic>) {
            // Try to extract error message from response
            if (responseData.containsKey('error')) {
              final error = responseData['error'];
              if (error is Map<String, dynamic>) {
                if (error.containsKey('message')) {
                  errorMessage = error['message'] ?? errorMessage;
                } else if (error.containsKey('details')) {
                  final details = error['details'];
                  if (details is Map<String, dynamic> && details.containsKey('validationErrors')) {
                    final validationErrors = details['validationErrors'];
                    if (validationErrors is List && validationErrors.isNotEmpty) {
                      final firstError = validationErrors[0];
                      if (firstError is Map<String, dynamic> && firstError.containsKey('messages')) {
                        final messages = firstError['messages'];
                        if (messages is List && messages.isNotEmpty) {
                          errorMessage = messages[0] ?? errorMessage;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        } catch (_) {
          // Use default error message
        }
      }
      
      otpError.value = errorMessage;
      otpNetworkStatus.value = NetworkStatus.ERROR;
      print('❌ [FAYDA OTP] Parsed error message: $errorMessage');
    }
  }
  
  /// Verify OTP and get user data
  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      otpError.value = 'Please enter the OTP code';
      return;
    }
    
    if (transactionID.value.isEmpty) {
      otpError.value = 'No active OTP session. Please request OTP again.';
      return;
    }
    
    final fanOrFin = phoneController.text.trim();
    if (fanOrFin.isEmpty) {
      otpError.value = 'FAN/FIN number is missing';
      return;
    }
    
    // Clean the FAN/FIN number
    final individualId = fanOrFin.replaceAll(RegExp(r'[^\d]'), '');
    
    otpNetworkStatus.value = NetworkStatus.LOADING;
    otpError.value = '';
    
    try {
      print('🔐 [FAYDA VERIFY] Verifying OTP...');
      print('  - Individual ID: $individualId');
      print('  - Transaction ID: ${transactionID.value}');
      print('  - OTP: $otp');
      
      final request = FaydaVerifyRequest(
        individualId: individualId,
        transactionID: transactionID.value,
        otp: otp,
      );
      
      final response = await _idIntegrationService.verifyOtp(request);
      
      print('🔐 [FAYDA VERIFY] Response received');
      print('  - Success: ${response.success}');
      print('  - Status Code: ${response.statusCode}');
      print('  - Has Data: ${response.data != null}');
      if (response.data != null) {
        print('  - Has Response: ${response.data!.response != null}');
        if (response.data!.response != null) {
          print('  - KYC Status: ${response.data!.response!.kycStatus}');
          print('  - Has Identity: ${response.data!.response!.identity != null}');
        }
      }
      print('  - Is Success: ${response.isSuccess}');
      
      if (response.isSuccess) {
        // OTP verified successfully
        print('✅ [FAYDA VERIFY] OTP verified successfully');
        print('  - Name: ${response.name}');
        print('  - Date of Birth: ${response.dateOfBirth}');
        print('  - Status: ${response.status}');
        print('  - Nationality: ${response.nationality}');
        print('  - Gender: ${response.gender}');
        print('  - Phone Number: ${response.phoneNumber}');
        print('  - Transaction ID: ${response.transactionID}');
        
        // Show success message
        final context = Get.context;
        if (context != null) {
          AppToasts.showSuccess('OTP verified successfully');
        }
        
        otpNetworkStatus.value = NetworkStatus.SUCCESS;
        
        // Use transactionID from response if available, otherwise use the one from OTP request
        final finalTransactionID = response.transactionID ?? transactionID.value;
        
        // Store user data for later use
        _userData = {
          'isVisitor': false,
          'transactionID': finalTransactionID,
          'idType': 'fayda',
          'faydaData': {
            'individualId': individualId,
            'name': response.name,
            'nameAm': response.nameAm,
            'dateOfBirth': response.dateOfBirth,
            'status': response.status,
            'nationality': response.nationality,
            'gender': response.gender,
            'phoneNumber': response.phoneNumber,
            'address': response.address,
            'photo': response.photo,
          },
        };
        
        print('📋 [FAYDA VERIFY] User data stored, navigating to service list');
        
        // Navigate to service list
        Get.to(() => const ResidenceServiceListView());
      } else {
        // Error response
        final errorMessage = response.message ?? 
                            response.error ?? 
                            'Failed to verify OTP. Please try again.';
        otpError.value = errorMessage;
        otpNetworkStatus.value = NetworkStatus.ERROR;
        print('❌ [FAYDA VERIFY] Error: $errorMessage');
      }
    } catch (e, stackTrace) {
      print('❌ [FAYDA VERIFY] Exception: $e');
      print('❌ [FAYDA VERIFY] Stack trace: $stackTrace');
      
      // Parse error from response if available
      String errorMessage = 'Failed to verify OTP. Please try again.';
      if (e is DioException && e.response != null) {
        try {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('message')) {
              errorMessage = responseData['message'] ?? errorMessage;
            } else if (responseData.containsKey('error')) {
              errorMessage = responseData['error'] ?? errorMessage;
            }
          }
        } catch (_) {
          // Use default error message
        }
      }
      
      otpError.value = errorMessage;
      otpNetworkStatus.value = NetworkStatus.ERROR;
      print('❌ [FAYDA VERIFY] Parsed error message: $errorMessage');
    }
  }

  /// Submit the form
  void submit() {
    if (selectedIdType.value == 'fayda') {
      final value = phoneController.text.trim();
      if (value.isEmpty) {
        otpError.value = 'Please enter your FAN or FIN number';
        return;
      }
      
      // If OTP is already sent, verify it
      if (isOtpSent.value) {
        verifyOtp();
      } else {
        // Request OTP
        requestFaydaOtp();
      }
    } else if (selectedIdType.value == 'residence') {
      final value = idController.text.trim();
      if (value.isEmpty) {
        final context = Get.context;
        if (context != null) {
          AppToasts.showError('Please enter your Residence ID');
        }
        return;
      }
      
      // Store user data for later use
      _userData = {
        'isVisitor': false,
        'idType': 'residence',
        'residenceId': value,
      };
      
      // Navigate to service list
      Get.to(() => const ResidenceServiceListView());
    } else if (selectedIdType.value == 'tin') {
      final value = tinController.text.trim();
      if (value.isEmpty) {
        final context = Get.context;
        if (context != null) {
          AppToasts.showError('Please enter your TIN Number');
        }
        return;
      }
      
      // Store user data for later use
      _userData = {
        'isVisitor': false,
        'idType': 'tin',
        'tinNumber': value,
      };
      
      // Navigate to service list
      Get.to(() => const ResidenceServiceListView());
    }
  }
  
  /// Select a service from the list
  void selectService(String service) {
    selectedService.value = service;
    print('📋 [SERVICE] Selected service: $service');
    
    // Navigate to service detail view
    Get.to(() => const ResidenceServiceDetailView());
  }
  
  /// Change selected service (when on detail page)
  void changeSelectedService(String service) {
    selectedService.value = service;
    print('📋 [SERVICE] Changed service to: $service');
  }
  
  /// Proceed to call class with all collected data
  void proceedToCallClass() {
    if (_userData == null) {
      final context = Get.context;
      if (context != null) {
        AppToasts.showError('User data not found. Please start over.');
      }
      return;
    }
    
    print('📞 [CALL CLASS] Proceeding with:');
    print('  - Service: ${selectedService.value}');
    print('  - ID Type: ${_userData!['idType']}');
    
    // Add selected service to user data
    final callData = Map<String, dynamic>.from(_userData!);
    callData['selectedService'] = selectedService.value;
    
    // Navigate to call class
    Get.toNamed(Routes.CALL_CLASS, arguments: callData);
  }
}
