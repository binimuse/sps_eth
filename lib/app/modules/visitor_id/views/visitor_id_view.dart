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
                  child: SingleChildScrollView(
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
                          label: Text('Back'.tr, style: TextStyle(color: Color(0xFF0F3955))),
                        ),
                        const SizedBox(height: 16),
                        // Main Card with Passport Scanner
                        _buildPassportIdCard(),
                      ],
                    ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Passport Icon
          SizedBox(
            height: 60,
            width: 60,
            child: Image.asset(
              Assets.images.passport.path,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          // "Scan Passport" Text
          Text(
            'Scan Passport Document'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Place your passport within the frame'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 20),
          
          // Scanner View Area
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Scanner frame overlay
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF1976D2),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        // Corner indicators
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFF1976D2), width: 4),
                                left: BorderSide(color: Color(0xFF1976D2), width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFF1976D2), width: 4),
                                right: BorderSide(color: Color(0xFF1976D2), width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF1976D2), width: 4),
                                left: BorderSide(color: Color(0xFF1976D2), width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF1976D2), width: 4),
                                right: BorderSide(color: Color(0xFF1976D2), width: 4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Scanning animation line
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF1976D2).withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Center instruction text
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Align passport within the frame'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Scan Button
          Obx(() => SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: controller.isScanning.value
        ? null
        : () async {
          //  await controller.scanPassport();
          Get.toNamed(Routes.CALL_CLASS, arguments: {'isVisitor': true});
            if (controller.scanError.isEmpty) {
              print('UI received passport data: ${controller.passportData}');
            } else {
              Get.snackbar(
                'Scan Failed',
                controller.scanError.value,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
    icon: controller.isScanning.value
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Icon(Icons.camera_alt, size: 20),
    label: Text(
      controller.isScanning.value
          ? 'Scanning...'.tr
          : 'Scan Passport'.tr,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1976D2),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    ),
  ),
)),

          const SizedBox(height: 20),
          
          // Separator: "or" text
          Text(
            'or'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 20),
          
          // Continue as a Guest Button
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.CALL_CLASS, arguments: {'isVisitor': false});
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 28,
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.images.background.path),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 28,
                    color: const Color(0xFF1976D2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Continue as a Guest'.tr,
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

