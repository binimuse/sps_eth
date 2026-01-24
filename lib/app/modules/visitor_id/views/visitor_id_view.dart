import 'dart:convert';
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
                        
                        // Check SDK Status Button (for testing)
                   
          
  // Scanner View Area with Animation
         Obx(() => Container(
           height: 250,
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
          
          // Scanned Document Display (shows after successful scan)
          Obx(() {
            if (controller.scanSuccess.value && controller.passportData.isNotEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Document Scanned Successfully',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Display scanned document image
                    if (controller.scannedImageBase64.value.isNotEmpty)
                      Container(
                        width: double.infinity,
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                          color: Colors.grey.withOpacity(0.1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Builder(
                            builder: (context) {
                              try {
                                final imageBytes = base64Decode(controller.scannedImageBase64.value);
                                print('📸 Displaying image from base64: ${imageBytes.length} bytes');
                                return Image.memory(
                                  imageBytes,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('📸 Error displaying base64 image: $error');
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                                          SizedBox(height: 8),
                                          Text(
                                            'Unable to display image',
                                            style: TextStyle(color: Colors.red, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              } catch (e) {
                                print('📸 Exception decoding base64: $e');
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        'Image format error',
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),

                    if (!controller.scannedImageBase64.value.isNotEmpty)
                      _buildDataRow('Scanned Image', controller.scannedImageBase64.value),
                      
                    
                    // Display scanned data
                    if (controller.fullName.value.isNotEmpty)
                      _buildDataRow('Full Name', controller.fullName.value),
                    if (controller.passportNumber.value.isNotEmpty)
                      _buildDataRow('ID/Passport Number', controller.passportNumber.value),
                    if (controller.nationality.value.isNotEmpty)
                      _buildDataRow('Nationality', controller.nationality.value),
                    if (controller.dateOfBirth.value.isNotEmpty)
                      _buildDataRow('Date of Birth', controller.dateOfBirth.value),
                    if (controller.expiryDate.value.isNotEmpty)
                      _buildDataRow('Expiry Date', controller.expiryDate.value),
                    
                    const SizedBox(height: 20),
                    
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to call class
                          Get.toNamed(
                            Routes.CALL_CLASS,
                            arguments: {
                              'isVisitor': true,
                              'autoStart': true,
                              'passportData': Map<String, dynamic>.from(controller.passportData),
                              'passportNumber': controller.passportNumber.value,
                              'fullName': controller.fullName.value,
                              'nationality': controller.nationality.value,
                              'dateOfBirth': controller.dateOfBirth.value,
                              'expiryDate': controller.expiryDate.value,
                              'idPhoto': controller.scannedImageBase64.value, // Pass base64 image
                            },
                          );
                        },
                        icon: const Icon(Icons.arrow_forward, size: 22),
                        label: Text(
                          'Continue to Call Class',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Scan Again Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Reset and scan again
                          controller.scanSuccess.value = false;
                          controller.passportData.clear();
                          controller.scanError.value = '';
                        },
                        icon: const Icon(Icons.refresh, size: 20),
                        label: Text(
                          'Scan Again',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: BorderSide(color: Colors.green.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Scan Button (hidden when scan is successful)
          Obx(() {
            if (controller.scanSuccess.value) {
              return const SizedBox.shrink();
            }
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

  // Helper method to build data row
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
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
        // Document icon sliding through
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, -50 + (value * 100)),
                    child: Opacity(
                      opacity: 1.0 - (value * 0.3),
                      child: Icon(
                        Icons.credit_card,
                        size: 80,
                        color: const Color(0xFF1976D2).withOpacity(0.8),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  // Animation will restart automatically
                },
              ),
              const SizedBox(height: 20),
              // Animated dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 600 + (index * 200)),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1976D2).withOpacity(value),
                        ),
                      );
                    },
                    onEnd: () {
                      // Animation will restart automatically
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        // Scanning lines
        Positioned.fill(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 2000),
            curve: Curves.linear,
            builder: (context, value, child) {
              return CustomPaint(
                painter: ScanningLinePainter(progress: value),
              );
            },
            onEnd: () {
              // Animation will restart automatically
            },
          ),
        ),
        // Status text
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
            'Insert your ID card into the scanner'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Then press "Scan Passport" button below'.tr,
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

// Custom painter for scanning line effect
class ScanningLinePainter extends CustomPainter {
  final double progress;

  ScanningLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0xFF1976D2).withOpacity(0.3),
          const Color(0xFF1976D2).withOpacity(0.8),
          const Color(0xFF1976D2).withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final yPosition = size.height * progress;
    final rect = Rect.fromLTWH(0, yPosition - 2, size.width, 4);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(ScanningLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

