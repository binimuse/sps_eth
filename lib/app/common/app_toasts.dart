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
