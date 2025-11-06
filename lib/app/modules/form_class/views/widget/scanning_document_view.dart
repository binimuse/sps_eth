import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:sps_eth_app/app/common/widgets/promo_card.dart';

class ScanningDocumentView extends StatelessWidget {
  const ScanningDocumentView({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ScanningDocumentView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LEFT PROMO CARD
              SizedBox(
                width: 300,
                child: PromoCard(),
              ),
    
              const SizedBox(width: 24),
    
              // CENTER CONTENT - Scanning Document
              Expanded(
                flex: 2,
                child: Container(
                  height: 70.h,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Scanning Document Icon
                      Image.asset(
                        Assets.images.documentScan.path,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 32),
                      // Status Text
                       Text(
                        'Scanning Document....',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Loading indicator
                       SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    
              const SizedBox(width: 24),
    
              // RIGHT SIDEBAR - Machine Image
              Image.asset(
                Assets.images.machine.path,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

