import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/app/common/app_toasts.dart';

class HomeController extends GetxController {
  final Rx<DateTime> now = DateTime.now().obs;
  Timer? _ticker;

  final RxList<String> alerts = <String>[].obs;

  String get heroVideoUrl =>
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  String get formattedDate =>
      DateFormat('dd MMMM , yyyy').format(now.value).toUpperCase();

  String get formattedTime => DateFormat('hh:mm:ss a').format(now.value);

  @override
  void onInit() {
    super.onInit();
    _startClockTicker();
    fetchAlerts();
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  void _startClockTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      now.value = DateTime.now();
    });
  }

  Future<void> fetchAlerts() async {
    // Placeholder for API integration; keep existing UI populated.
    final updatedAlerts = List.generate(
      6,
      (index) => 'Recent alert item ${index + 1}',
    );
    alerts.assignAll(updatedAlerts);
  }

  Future<void> onSwipeToCallComplete() async {
    try {
      Get.snackbar('Calling', 'Dialing...');
      await Get.toNamed(Routes.CALL_CLASS, arguments: {'autoStart': true});
    } catch (e, stackTrace) {
      print('❌ [HOME] Error navigating to call class: $e');
      print('❌ [HOME] Stack trace: $stackTrace');
      AppToasts.showError('Failed to open call screen: ${e.toString()}');
    }
  }

  void openRecentAlerts() {
    Get.toNamed(Routes.RECENT_ALERTS);
  }

  void openLanguageSelection() {
    Get.toNamed(Routes.LANGUAGE);
  }

  void openNearbyPoliceStations() {
    Get.toNamed(Routes.NEARBY_POLICE);
  }

  void goToFilling() {
    Get.toNamed(Routes.FIILING_CLASS);
  }
}
