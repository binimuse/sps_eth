import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sps_eth_app/app/modules/form_class/services/pdf_service.dart';
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
                    child: Column(
                      children: [
                        // Scrollable content
                        Expanded(
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
                                     
                                      const SizedBox(height: 2),

                                      // Schedule Time Section
                                   

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
                                      _buildReportInfoRow('Case Number', formData['id'] ?? formData['caseNumber'] ?? 'N/A'),
                                      const SizedBox(height: 12),
                                      _buildReportInfoRow('Category', formData['category'] ?? 'N/A'),
                                      const SizedBox(height: 12),
                                      _buildReportInfoRow('Type', formData['incidentType'] ?? formData['type'] ?? 'N/A'),
                                      const SizedBox(height: 12),
                                      if (formData['fullName'] != null && formData['fullName']!.isNotEmpty)
                                        _buildReportInfoRow('Full Name', formData['fullName']!),
                                      if (formData['fullName'] != null && formData['fullName']!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      if (formData['phoneNumber'] != null && formData['phoneNumber']!.isNotEmpty)
                                        _buildReportInfoRow('Phone Number', formData['phoneNumber']!),
                                      if (formData['phoneNumber'] != null && formData['phoneNumber']!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      if (formData['age'] != null && formData['age']!.isNotEmpty)
                                        _buildReportInfoRow('Age', formData['age']!),
                                      if (formData['age'] != null && formData['age']!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      if (formData['sex'] != null && formData['sex']!.isNotEmpty)
                                        _buildReportInfoRow('Sex', formData['sex']!),
                                      if (formData['sex'] != null && formData['sex']!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      if (formData['nationality'] != null && formData['nationality']!.isNotEmpty)
                                        _buildReportInfoRow('Nationality', formData['nationality']!),
                                      if (formData['nationality'] != null && formData['nationality']!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      if (formData['dateOfBirth'] != null && formData['dateOfBirth']!.isNotEmpty)
                                        _buildReportInfoRow('Date of Birth', formData['dateOfBirth']!),
                                      if (formData['dateOfBirth'] != null && formData['dateOfBirth']!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      _buildReportInfoRow('Address', formData['address'] ?? formData['location'] ?? 'N/A'),
                                      if (formData['statement'] != null && formData['statement']!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        _buildStatementSection(formData['statement']!),
                                      ],
                                      if (formData['statementDate'] != null && formData['statementDate']!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        _buildReportInfoRow('Statement Date', formData['statementDate']!),
                                      ],
                                      if (formData['statementTime'] != null && formData['statementTime']!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        _buildReportInfoRow('Statement Time', formData['statementTime']!),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),

                          // Footer Section (Outside the white card) - Scrollable
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
                              ],
                            ),
                          ),
                              ],
                            ),
                          ),
                        ),
                        // Fixed Footer with Buttons at Bottom
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Print Button
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Print functionality
                                  _printConfirmationPage(context);
                                },
                                icon: const Icon(Icons.print, size: 20),
                                label: const Text('Print'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1976D2),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 4,
                                ),
                              ),
                              const SizedBox(width: 16),
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
          width: 120,
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

  Widget _buildStatementSection(String statement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statement',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF9E9E9E),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          child: Text(
            statement,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  String _generateQRData() {
    // Generate QR code data from form data
    final qrData = {
      'id': formData['id'] ?? formData['caseNumber'] ?? 'N/A',
      'category': formData['category'] ?? 'N/A',
      'type': formData['incidentType'] ?? formData['type'] ?? 'N/A',
      'address': formData['address'] ?? formData['location'] ?? 'N/A',
      'scheduleTime': formData['scheduleTime'] ?? formData['submitTime'] ?? 'N/A',
    };
    
    // Convert to JSON string for QR code
    return qrData.entries
        .map((e) => '${e.key}:${e.value}')
        .join('|');
  }

  void _printConfirmationPage(BuildContext context)async {
    // Print functionality - can be implemented with printing package
    // For now, show a message
  
    
    // TODO: Implement actual print functionality using printing package
   await Printing.layoutPdf(onLayout: (format) async => await PdfService.getPdfBytes(formData));
  }
}

