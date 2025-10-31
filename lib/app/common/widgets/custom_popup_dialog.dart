import 'package:flutter/material.dart';

import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import '../../theme/app_colors.dart';

class CustomPopupDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final IconData? icon;
  final Color? iconColor;
  final Color? primaryButtonColor;
  final Color? secondaryButtonColor;
  final bool showCelebration;

  const CustomPopupDialog({
    super.key,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.icon,
    this.iconColor,
    this.primaryButtonColor,
    this.secondaryButtonColor,
    this.showCelebration = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppColors.whiteOff,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration dots (if enabled)
            if (showCelebration) _buildCelebrationDots(),

            // Icon
            SizedBox(height: 3.h),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontFamily: 'DMSans',
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grayDefault,
                fontFamily: 'DMSans',
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Buttons
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationDots() {
    return SizedBox(
      height: 12.h,
      child: Center(
        child: Image.asset(
          Assets.images.sucess.path, // Use your uploaded success image
          width: 25.w,
          height: 25.w,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // Primary button
        if (primaryButtonText != null)
          GestureDetector(
            onTap: onPrimaryButtonPressed,
            child: Container(
              width: double.infinity,
              height: 12.w,
              decoration: BoxDecoration(
                color: primaryButtonColor ?? AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  primaryButtonText!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteOff,
                    fontFamily: 'DMSans',
                  ),
                ),
              ),
            ),
          ),

        // Secondary button
        if (secondaryButtonText != null) ...[
          SizedBox(height: 2.h),
          GestureDetector(
            onTap: onSecondaryButtonPressed,
            child: Container(
              width: double.infinity,
              height: 12.w,
              decoration: BoxDecoration(
                color: secondaryButtonColor ?? AppColors.whiteOff,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Center(
                child: Text(
                  secondaryButtonText!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: 'DMSans',
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Helper function to show the custom popup
class CustomPopupHelper {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryButtonPressed,
    VoidCallback? onSecondaryButtonPressed,
    IconData? icon,
    Color? iconColor,
    Color? primaryButtonColor,
    Color? secondaryButtonColor,
    bool showCelebration = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomPopupDialog(
          title: title,
          message: message,
          primaryButtonText: primaryButtonText,
          secondaryButtonText: secondaryButtonText,
          onPrimaryButtonPressed: onPrimaryButtonPressed,
          onSecondaryButtonPressed: onSecondaryButtonPressed,
          icon: icon,
          iconColor: iconColor,
          primaryButtonColor: primaryButtonColor,
          secondaryButtonColor: secondaryButtonColor,
          showCelebration: showCelebration,
        );
      },
    );
  }
}
