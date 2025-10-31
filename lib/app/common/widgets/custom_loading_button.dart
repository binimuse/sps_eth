import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/app/theme/app_text_styles.dart';


class CustomLoadingButton extends StatelessWidget {
  final String text;
  final String loadingText;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final Widget? icon;

  const CustomLoadingButton({
    super.key,
    required this.text,
    this.loadingText = 'Loading...',
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: isLoading
              ? AppColors.grayLighter
              : (backgroundColor ?? AppColors.primary),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: isLoading ? _buildLoadingIndicator() : _buildButtonContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              textColor ?? AppColors.whiteOff,
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          loadingText,
          style: TextStyle(
            color: textColor ?? AppColors.whiteOff,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          SizedBox(width: 2.w),
          Text(
            text,
            style: AppTextStyles.onboardingButton.copyWith(
              color: textColor ?? AppColors.whiteOff,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: AppTextStyles.onboardingButton.copyWith(
        color: textColor ?? AppColors.whiteOff,
      ),
    );
  }
}
