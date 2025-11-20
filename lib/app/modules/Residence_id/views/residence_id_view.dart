import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:sps_eth_app/app/common/widgets/promo_card.dart';
import 'package:sps_eth_app/app/common/widgets/custom_loading_widget.dart';
import 'package:sps_eth_app/app/utils/enums.dart';
import '../controllers/residence_id_controller.dart';

class ResidenceIdView extends GetView<ResidenceIdController> {
  const ResidenceIdView({super.key});
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
                  child: PromoCard(
                  ),
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
                      // Main Card
                      Expanded(
                        child: Container(
                          width: double.infinity,
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
                          child: Obx(() {
                            // Show loading overlay
                            if (controller.networkStatus.value == NetworkStatus.LOADING) {
                              return const Center(child: CustomLoadingWidget());
                            }

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Top Section: ID Scanning Icon and Text
                                SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: Image.asset(
                                    Assets.images.scanid.path,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Scanning For ID ....',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4A4A4A),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // ID Input Field
                                TextField(
                                  controller: controller.idController,
                                  decoration: InputDecoration(
                                    hintText: 'ID',
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
                                const SizedBox(height: 16),
                                
                                // Phone Number Input Field
                                TextField(
                                  controller: controller.phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: 'Phone Number',
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
                                const SizedBox(height: 20),
                                
                                // Find Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
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
                                    onPressed: () => controller.signup(),
                                    child: const Text(
                                      'Find',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // Separator: "or" text
                                const Text(
                                  'or',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF9E9E9E),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // Bottom Section: Guest Option Card
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
                            );
                          }),
                        ),
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
}
