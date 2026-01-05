import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:sps_eth_app/app/common/widgets/promo_card.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';

class ConfirmationPageView extends StatelessWidget {
  final Map<String, String> formData;

  const ConfirmationPageView({super.key, required this.formData});

  static void show(BuildContext context, Map<String, String> formData) {
    Get.to(() => ConfirmationPageView(formData: formData));
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
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT PROMO CARD
                SizedBox(
                  width: 300,
                  child: PromoCard(),
                ),

                const SizedBox(width: 24),

                // CENTER CONTENT - Confirmation Page
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Main White Card with Border
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE6F3FB),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Header Section with Logo and QR Code
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Logo Section (Left)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0F3955),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Image.asset(
                                                  Assets.images.efpLogo.path,
                                                  width: 70,
                                                  height: 70,
                                                  fit: BoxFit.contain,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // SMART POLICE STATION text
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'SMART POLICE',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0F3955),
                                                ),
                                              ),
                                              const Text(
                                                'STATION',
                                                style: TextStyle(
                                                 fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0F3955),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      // QR Code on right
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: QrImageView(
                                          data: _generateQRData(),
                                          version: QrVersions.auto,
                                          size: 84,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Main Content Section
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // FEDERAL POLICE APPOINTMENT Title (Centered)
                                      Text(
                                        'FEDERAL POLICE APPOINTMENT',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F3955),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 28),

                                      // Schedule Time Section
                                      Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0F3955),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: GridView.count(
                                              crossAxisCount: 3,
                                              padding: const EdgeInsets.all(6),
                                              mainAxisSpacing: 2,
                                              crossAxisSpacing: 2,
                                              children: List.generate(9, (index) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(1),
                                                  ),
                                                );
                                              }),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Schedule Time',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF9E9E9E),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                formData['scheduleTime'] ?? 'June 12, 2024',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0F3955),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 32),

                                      // Report Information Section
                                      const Text(
                                        'Report Information',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F3955),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Table-like structure
                                      _buildReportInfoRow('ID', formData['id'] ?? '12351361346'),
                                      const SizedBox(height: 12),
                                      _buildReportInfoRow('Category', formData['category'] ?? 'Economic'),
                                      const SizedBox(height: 12),
                                      _buildReportInfoRow('Type', formData['incidentType'] ?? 'Crime'),
                                      const SizedBox(height: 12),
                                      _buildReportInfoRow('Address', formData['address'] ?? 'A.A - K/K - Woreda 1'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),

                          // Footer Section (Outside the white card)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Print and Take Your Confirmation Page',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F3955),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'A technology-driven, modern police service outlet where users can serve themselves without human intervention. Designed to make police services more accessible, efficient, and convenient for the community.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Home Button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Get.offAllNamed(Routes.HOME);
                                  },
                                  icon: const Icon(Icons.home, size: 20),
                                  label: const Text('Go to Home'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F3955),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // RIGHT SIDEBAR - Machine Image
                Image.asset(
                  Assets.images.machineGif.path,
                  fit: BoxFit.cover,
                ),
              ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9E9E9E),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _generateQRData() {
    // Generate QR code data from form data
    final qrData = {
      'id': formData['id'] ?? '12351361346',
      'category': formData['category'] ?? 'Economic',
      'type': formData['incidentType'] ?? 'Crime',
      'address': formData['address'] ?? 'A.A - K/K - Woreda 1',
      'scheduleTime': formData['scheduleTime'] ?? 'June 12, 2024',
    };
    
    // Convert to JSON string for QR code
    return qrData.entries
        .map((e) => '${e.key}:${e.value}')
        .join('|');
  }
}

