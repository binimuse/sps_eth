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
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
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
          // "Scan Passport or ID" Text
          Text(
            'Scan Passport or ID Document'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Place your passport or ID within the frame'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 20),
                        
                        // Check SDK Status Button (for testing)
                   
          
  // Scanner View Area with Animation
         Obx(() => Container(
           height: 200,
           width: double.infinity,
           decoration: BoxDecoration(
             color: Colors.black.withOpacity(0.8),
             borderRadius: BorderRadius.circular(12),
           ),
           child: controller.isScanning.value
               ? _buildScanningAnimation()
               : _buildIdleState(),
         )),
          const SizedBox(height: 20),
          
          // SDK Status Info (for debugging)
          Obx(() {
            if (controller.sdkStatus.isNotEmpty) {
              final status = Map<String, dynamic>.from(controller.sdkStatus);
              return Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SDK Status:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SDK Loaded: ${status['sdkLoaded'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      'Assets: ${status['assetsCopied'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      'Hardware: ${status['hardwareDetected'] == true ? '✅ Detected' : '❌ Not Detected (Expected on tablet)'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: status['hardwareDetected'] == true ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Simple error message (details are in console logs)
          Obx(() {
            if (controller.scanError.value.isNotEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.scanError.value,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => controller.scanError.value = '',
                      color: Colors.orange,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          
          const SizedBox(height: 20),
          
          // Scan Button
          Obx(() {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.isScanning.value
                    ? null
                    : () async {
                        // Call passport scanner
                        await controller.scanPassport();
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
                      : 'Scan Document'.tr,
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
            );
          }),

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

  // Scanning animation widget
  Widget _buildScanningAnimation() {
    return Stack(
      children: [
        // GIF Animation - centered and fills the container
        Center(
          child: Image.asset(
            'assets/images/scanning_animation.gif',
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Status text overlay
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Scanning document...'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Idle state widget
  Widget _buildIdleState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.document_scanner_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 20),
          Text(
            'Insert your passport or ID card into the scanner'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Then press "Scan Document" button below'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

}

