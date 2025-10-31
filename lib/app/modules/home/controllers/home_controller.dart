import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final count = 0.obs;
  
  // Time ticker for the digital clock
  final Rx<DateTime> now = DateTime.now().obs;
  Timer? _ticker;
  
  // Alerts data (placeholder)
  final RxList<String> alerts =
      List.generate(6, (i) => 'Recent alert item ${i + 1}').obs;
  
  String get formattedTime => DateFormat('hh:mm:ss a').format(now.value);
  @override
  void onInit() {
    super.onInit();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      now.value = DateTime.now();
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    _ticker?.cancel();
  }

  void increment() => count.value++;

  // Actions
  void onSwipeToCallComplete() {
    Get.snackbar('Calling', 'Dialing...');
  }

  void goToFilling() {
    Get.toNamed(Routes.FIILING_CLASS);
  }
}
