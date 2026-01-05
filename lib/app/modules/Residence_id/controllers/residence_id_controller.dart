import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/app/utils/enums.dart';

class ResidenceIdController extends GetxController {
  // Selected ID type
  final RxString selectedIdType = ''.obs;
  final RxString otpError = ''.obs;
  final Rx<NetworkStatus> otpNetworkStatus = NetworkStatus.IDLE.obs;

  // Text controllers
  final phoneController = TextEditingController();
  final idController = TextEditingController();
  final tinController = TextEditingController();
  final otpController = TextEditingController();

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
  }

  /// Submit the form
  void submit() {
    String value = '';
    if (selectedIdType.value == 'fayda') {
      value = phoneController.text.trim();
      if (value.isEmpty) {
        return;
      }
    } else if (selectedIdType.value == 'residence') {
      value = idController.text.trim();
      if (value.isEmpty) {
        return;
      }
    } else if (selectedIdType.value == 'tin') {
      value = tinController.text.trim();
      if (value.isEmpty) {
        return;
      }
    }
    
    // Navigate to service list
    Get.toNamed(Routes.CALL_CLASS);
  }
}
