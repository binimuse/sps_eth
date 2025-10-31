import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

class AppTextStyles {
  ///MENU
  static final menuRegular = TextStyle(
    fontSize: AppSizes.font_12,
    fontWeight: FontWeight.w400,
    color: AppColors.grayDark,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  static final menuBold = TextStyle(
    fontSize: AppSizes.font_12,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  ///CAPTION
  static final captionRegular = TextStyle(
    fontSize: AppSizes.font_12,
    fontWeight: FontWeight.w400,
    color: AppColors.grayDark,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  static final captionBold = TextStyle(
    fontSize: AppSizes.font_12,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  ///BODY
  static final bodySmallUnderlineRegular = TextStyle(
    fontSize: AppSizes.font_14,
    fontWeight: FontWeight.w700,
    color: AppColors.grayDark,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
    decoration: TextDecoration.underline,
  );

  static final bodySmallRegular = TextStyle(
    fontSize: AppSizes.font_12,
    fontWeight: FontWeight.w200,
    color: AppColors.grayDark,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  static final bodySmallBold = TextStyle(
    fontSize: AppSizes.font_14,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  static final bodyLargeUnderlineRegular = TextStyle(
    fontSize: AppSizes.font_16,
    fontWeight: FontWeight.w700,
    color: AppColors.grayDark,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
    decoration: TextDecoration.underline,
  );

  static final bodyLargeRegular = TextStyle(
    fontSize: AppSizes.font_16,
    fontWeight: FontWeight.w400,
    color: AppColors.grayDark,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  static final bodyLargeBold = TextStyle(
    fontSize: AppSizes.font_16,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  ///TITLE
  static final titleRegular = TextStyle(
    fontSize: AppSizes.font_18,
    fontWeight: FontWeight.w400,
    color: AppColors.grayDark,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  static final titleBold = TextStyle(
    fontSize: AppSizes.font_18,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  //HEADLINE
  static final headlineRegular = TextStyle(
    fontSize: AppSizes.font_20,
    fontWeight: FontWeight.w400,
    color: AppColors.grayDark,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  static final headlineBold = TextStyle(
    fontSize: AppSizes.font_20,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  //DISPLAY
  static final displayOneRegular = TextStyle(
    fontSize: AppSizes.font_24,
    fontWeight: FontWeight.w400,
    color: AppColors.grayDark,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  static final displayOneBold = TextStyle(
    fontSize: AppSizes.font_24,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  static final displayTwoRegular = TextStyle(
    fontSize: AppSizes.font_28,
    fontWeight: FontWeight.w400,
    color: AppColors.grayDark,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  static final displayTwoBold = TextStyle(
    fontSize: AppSizes.font_28,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  static final displayThreeRegular = TextStyle(
    fontSize: AppSizes.font_32,
    fontWeight: FontWeight.w400,
    color: AppColors.grayDark,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  static final displayThreeBold = TextStyle(
    fontSize: AppSizes.font_32,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'DMSans',
    letterSpacing: 0.6,
  );

  ///ONBOARDING SPECIFIC STYLES
  static final onboardingTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'DMSans',
    letterSpacing: -0.5,
  );

  static final onboardingBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.grayDefault,
    fontFamily: 'DMSans',
    height: 1.5,
  );

  static final onboardingSkip = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.grayDefault,
    fontFamily: 'DMSans',
  );

  static final onboardingButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.whiteOff,
    fontFamily: 'DMSans',
  );

  ///SPLASH SPECIFIC STYLES
  static final splashAppName = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.whiteOff,
    fontFamily: 'DMSans',
    letterSpacing: -0.5,
  );

  static final splashTagline = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.white70,
    fontFamily: 'DMSans',
    letterSpacing: 0.2,
  );

  static final splashSwipeUp = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.white50,
    fontFamily: 'DMSans',
    letterSpacing: 2,
  );
}
