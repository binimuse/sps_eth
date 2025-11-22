import 'package:get/get.dart';

class ServiceDetailController extends GetxController {
  final selectedService = 'Crime Report'.obs;

  @override
  void onInit() {
    super.onInit();
    // Get service title from arguments if passed
    final args = Get.arguments;
    if (args != null && args is String) {
      selectedService.value = args;
    }
  }

  void selectService(String service) {
    selectedService.value = service;
  }
}

