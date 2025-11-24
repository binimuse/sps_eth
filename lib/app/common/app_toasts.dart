// ignore_for_file: deprecated_member_use

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


import 'package:get/get.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/app/theme/app_sizes.dart';
import 'package:sps_eth_app/app/theme/app_text_styles.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';


class AppToasts {
  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static void showWarning(String message) {
    Get.snackbar(
      'Warning',
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Show error dialog with detailed information for debugging
  /// This allows users to take screenshots of errors
  static void showErrorDialog({
    required String title,
    required String message,
    String? errorDetails,
    String? stackTrace,
    VoidCallback? onClose,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error Icon and Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        color: AppColors.danger,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Error Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grayDark,
                    height: 1.5,
                  ),
                ),
                
                // Error Details (if provided)
                if (errorDetails != null && errorDetails.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.grayLighter,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Error Details:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grayDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          errorDetails,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grayDark,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Stack Trace (if provided)
                if (stackTrace != null && stackTrace.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.grayLighter,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stack Trace:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grayDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          stackTrace,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.grayDark,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 10,
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      onClose?.call();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: AppColors.whiteOff,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

class ToastSuccessWidget extends StatelessWidget {
  const ToastSuccessWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        BotToast.cleanAll();
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.toastMessageBackground,
          borderRadius: BorderRadius.circular(AppSizes.radius_20 * 2),
        ),
        margin: EdgeInsets.symmetric(horizontal: AppSizes.mp_w_4),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.mp_w_4 * 0.7,
          vertical: AppSizes.mp_v_1,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Assets.icons.doneRound.path,
              color: AppColors.success,
              width: AppSizes.icon_size_8,
              height: AppSizes.icon_size_8,
            ),
            SizedBox(width: AppSizes.mp_w_2),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodySmallBold.copyWith(
                  color: AppColors.backgroundDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ToastErrorWidget extends StatelessWidget {
  const ToastErrorWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        BotToast.cleanAll();
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.toastMessageBackground,
          borderRadius: BorderRadius.circular(AppSizes.radius_20 * 2),
        ),
        margin: EdgeInsets.symmetric(horizontal: AppSizes.mp_w_4),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.mp_w_4 * 0.7,
          vertical: AppSizes.mp_v_1,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Assets.icons.dangerCircle.path,
              width: AppSizes.icon_size_8,
              height: AppSizes.icon_size_8,
            ),
            SizedBox(width: AppSizes.mp_w_2),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodySmallBold.copyWith(
                  color: AppColors.backgroundDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
