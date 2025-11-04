import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.back1.path),
          fit: BoxFit.contain,
        ),
      ),
      child: Scaffold(
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
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Back document (dark blue, offset)
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Container(
                                width: 120,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1976D2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            // Front document (white)
                            Container(
                              width: 120,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF1976D2),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Checkmark at top
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF1976D2),
                                      size: 24,
                                    ),
                                  ),
                                  // Three lines representing text
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 2,
                                            width: double.infinity,
                                            color: Colors.grey[300],
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            height: 2,
                                            width: double.infinity,
                                            color: Colors.grey[300],
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            height: 2,
                                            width: 60,
                                            color: Colors.grey[300],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Gear icon at bottom right
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1976D2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Status Text
                        const Text(
                          'Scanning Document....',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Loading indicator
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
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
      ),
    );
  }
}

