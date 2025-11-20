import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import '../controllers/visitor_id_controller.dart';
import 'package:sps_eth_app/app/common/widgets/promo_card.dart';

class VisitorIdView extends GetView<VisitorIdController> {
  const VisitorIdView({super.key});
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
        resizeToAvoidBottomInset: false,
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

                // CENTER CONTENT
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          side: const BorderSide(color: Color(0xFFCBDCE7)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF0F3955)),
                        label: const Text('Back', style: TextStyle(color: Color(0xFF0F3955))),
                      ),
                      const SizedBox(height: 16),
                      // Main Card with Passport ID Input
                      Expanded(
                        child: _buildPassportIdCard(),
                      ),
                    ],
                  ),
                ),

               
                   const SizedBox(width: 24),

                // RIGHT SIDEBAR
                Image.asset(
                  Assets.images.machineGif.path,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPassportIdCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Passport Icon
          SizedBox(
            height: 80,
            width: 80,
            child: Image.asset(
              Assets.images.passport.path,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          // "Insert Passport ID" Text
          const Text(
            'Insert Passport ID',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 24),
          // Passport ID Input Field with Start Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.passportIdController,
                  decoration: InputDecoration(
                    hintText: 'Passport ID',
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  // Handle start action
                  if (controller.passportIdController.text.isNotEmpty) {
                    Get.toNamed(Routes.SERVICE_LIST);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Separator: "or" text
          const Text(
            'or',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 24),
          // Continue as a Guest Button
             GestureDetector(
                                  onTap: () {
                                    // Handle guest continuation
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 35,
                                    ),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(Assets.images.background.path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 32,
                                          color: const Color(0xFF1976D2),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Continue as a Guest',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF4A4A4A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
        ],
      ),
    );
  }

}

