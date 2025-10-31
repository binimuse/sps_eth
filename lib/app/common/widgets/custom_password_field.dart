import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/app/theme/app_text_styles.dart';


class CustomPasswordField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isVisible;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final bool showStrengthIndicator;
  final Function(String)? onPasswordChanged;
  final RxString? passwordStrength;
  final RxDouble? passwordStrengthValue;
  final Rx<Color>? passwordStrengthColor;

  const CustomPasswordField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.focusNode,
    required this.isVisible,
    required this.onToggle,
    this.validator,
    this.showStrengthIndicator = false,
    this.onPasswordChanged,
    this.passwordStrength,
    this.passwordStrengthValue,
    this.passwordStrengthColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.onboardingBody.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: !isVisible,
          validator: validator,
          onChanged: (value) {
            // Trigger validation on change for real-time feedback
            validator?.call(value);
            // Call custom password change handler
            onPasswordChanged?.call(value);
          },
          style: AppTextStyles.onboardingBody,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTextStyles.onboardingBody.copyWith(
              color: AppColors.grayDefault,
              fontSize: 12,
            ),
            filled: true,
            fillColor: AppColors.whiteOff,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grayLighter),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grayLighter),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 1.5.h,
            ),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Container(
                padding: EdgeInsets.only(right: 4.w),
                child: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.grayDefault,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        // Password strength indicator (only if enabled)
        if (showStrengthIndicator && passwordStrength != null) ...[
          SizedBox(height: 0.5.h),
          Obx(() => _buildPasswordStrengthIndicator()),
        ],
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    if (passwordStrength?.value.isEmpty ?? true) return SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: passwordStrengthValue?.value ?? 0.0,
            backgroundColor: AppColors.grayLighter,
            valueColor: AlwaysStoppedAnimation<Color>(
              passwordStrengthColor?.value ?? Colors.grey,
            ),
            minHeight: 4,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          passwordStrength?.value ?? '',
          style: TextStyle(
            fontSize: 12,
            color: passwordStrengthColor?.value ?? Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
