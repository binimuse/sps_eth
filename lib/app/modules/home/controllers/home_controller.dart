import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/app/common/app_toasts.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';

class HomeController extends GetxController {
  final Rx<DateTime> now = DateTime.now().obs;
  Timer? _ticker;

  final RxList<String> alerts = <String>[].obs;

  // Hero section images for carousel slider
  final List<String> heroImages = [
    'assets/images/bg4.jpg',
    'assets/images/bg3.jpg',
    'assets/images/bg5.jpg',
    'assets/images/news.png',
  ];

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
      // Navigate first, then show snackbar if needed (avoid overlay issues)
      await Get.toNamed(Routes.CALL_CLASS, arguments: {'autoStart': true});
      // Note: Snackbar removed to avoid overlay issues during navigation
      // The call class will handle its own status messages
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

  /// Handle back button press - show confirmation dialog
  Future<bool> onWillPop() async {
    final shouldExit = await Get.dialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Exit App?'.tr,
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to close the app?'.tr,
          style: TextStyle(color: AppColors.grayDark),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel'.tr,
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: Text('Exit'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (shouldExit == true) {
      // Exit the app
      if (Platform.isAndroid) {
        exit(0);
      } else if (Platform.isIOS) {
        exit(0);
      }
      return true;
    }
    return false;
  }
}
