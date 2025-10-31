import 'package:flutter/material.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/app/theme/app_text_styles.dart';

class SideInfoPanel extends StatelessWidget {
  final String title;
  final String description;
  final String logoAsset;
  final String illustrationAsset;

  const SideInfoPanel({
    super.key,
    required this.title,
    required this.description,
    required this.logoAsset,
    required this.illustrationAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteOff,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Image.asset(
            logoAsset,
            width: 72,
            height: 72,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.menuBold.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingBody,
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.asset(
                illustrationAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


