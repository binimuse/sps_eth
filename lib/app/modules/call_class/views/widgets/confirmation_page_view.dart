import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sps_eth_app/app/modules/form_class/services/pdf_service.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:sps_eth_app/app/common/widgets/promo_card.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';

class ConfirmationPageView extends StatefulWidget {
  final Map<String, String> formData;

  const ConfirmationPageView({super.key, required this.formData});

  static void show(BuildContext context, Map<String, String> formData) {
    Get.to(() => ConfirmationPageView(formData: formData));
  }

  @override
  State<ConfirmationPageView> createState() => _ConfirmationPageViewState();
}

class _ConfirmationPageViewState extends State<ConfirmationPageView> {
  int _printCooldownSeconds = 0;
  Timer? _printCooldownTimer;

  @override
  void dispose() {
    _printCooldownTimer?.cancel();
    super.dispose();
  }

  void _startPrintCooldown() {
    _printCooldownTimer?.cancel();
    setState(() => _printCooldownSeconds = 60);
    _printCooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_printCooldownSeconds <= 0) {
        _printCooldownTimer?.cancel();
        return;
      }
      setState(() => _printCooldownSeconds--);
    });
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
                                      _buildReportInfoRow('Case Number', widget.formData['id'] ?? widget.formData['caseNumber'] ?? 'N/A'),
                                      const SizedBox(height: 12),
                                      _buildReportInfoRow('Category', widget.formData['category'] ?? 'N/A'),
                                      const SizedBox(height: 12),
                                      _buildReportInfoRow('Type', widget.formData['incidentType'] ?? widget.formData['type'] ?? 'N/A'),
                                      const SizedBox(height: 12),
                                      if (widget.formData['fullName'] != null && widget.formData['fullName']!.isNotEmpty)
                                        _buildReportInfoRow('Full Name', widget.formData['fullName']!),
                                      if (widget.formData['fullName'] != null && widget.formData['fullName']!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      if (widget.formData['phoneNumber'] != null && widget.formData['phoneNumber']!.isNotEmpty)
                                        _buildReportInfoRow('Phone Number', widget.formData['phoneNumber']!),
                                      if (widget.formData['phoneNumber'] != null && widget.formData['phoneNumber']!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      if (widget.formData['age'] != null && widget.formData['age']!.isNotEmpty)
                                        _buildReportInfoRow('Age', widget.formData['age']!),
                                      if (widget.formData['age'] != null && widget.formData['age']!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      if (widget.formData['sex'] != null && widget.formData['sex']!.isNotEmpty)
                                        _buildReportInfoRow('Sex', widget.formData['sex']!),
                                      if (widget.formData['sex'] != null && widget.formData['sex']!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      if (widget.formData['nationality'] != null && widget.formData['nationality']!.isNotEmpty)
                                        _buildReportInfoRow('Nationality', widget.formData['nationality']!),
                                      if (widget.formData['nationality'] != null && widget.formData['nationality']!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      if (widget.formData['dateOfBirth'] != null && widget.formData['dateOfBirth']!.isNotEmpty)
                                        _buildReportInfoRow('Date of Birth', widget.formData['dateOfBirth']!),
                                      if (widget.formData['dateOfBirth'] != null && widget.formData['dateOfBirth']!.isNotEmpty)
                                        const SizedBox(height: 12),
                                      _buildReportInfoRow('Address', widget.formData['address'] ?? widget.formData['location'] ?? 'N/A'),
                                      if (widget.formData['statement'] != null && widget.formData['statement']!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        _buildStatementSection(widget.formData['statement']!),
                                      ],
                                      if (widget.formData['statementDate'] != null && widget.formData['statementDate']!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        _buildReportInfoRow('Statement Date', widget.formData['statementDate']!),
                                      ],
                                      if (widget.formData['statementTime'] != null && widget.formData['statementTime']!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        _buildReportInfoRow('Statement Time', widget.formData['statementTime']!),
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
                              // Print Button (disabled 20s after tap)
                              ElevatedButton.icon(
                                onPressed: _printCooldownSeconds > 0
                                    ? null
                                    : () async {
                                        _startPrintCooldown();
                                        await _printConfirmationPage(context);
                                      },
                                icon: Icon(
                                  Icons.print,
                                  size: 20,
                                  color: _printCooldownSeconds > 0 ? Colors.grey : Colors.white,
                                ),
                                label: Text(
                                  _printCooldownSeconds > 0
                                      ? 'Print again in ${_printCooldownSeconds}s'
                                      : 'Print',
                                  style: TextStyle(
                                    color: _printCooldownSeconds > 0 ? Colors.grey : Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _printCooldownSeconds > 0
                                      ? Colors.grey.shade400
                                      : const Color(0xFF1976D2),
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
      'id': widget.formData['id'] ?? widget.formData['caseNumber'] ?? 'N/A',
      'category': widget.formData['category'] ?? 'N/A',
      'type': widget.formData['incidentType'] ?? widget.formData['type'] ?? 'N/A',
      'address': widget.formData['address'] ?? widget.formData['location'] ?? 'N/A',
      'scheduleTime': widget.formData['scheduleTime'] ?? widget.formData['submitTime'] ?? 'N/A',
    };
    
    // Convert to JSON string for QR code
    return qrData.entries
        .map((e) => '${e.key}:${e.value}')
        .join('|');
  }

  Future<void> _printConfirmationPage(BuildContext context) async {
    try {
      await PdfService.directPrintPdf(widget.formData);
      if (context.mounted) {
        Get.snackbar(
          'Print',
          'Sent to printer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } on PlatformException catch (e) {
      if (context.mounted) {
        final message = e.message ?? e.code;
        Get.snackbar(
          'Print failed',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Get.snackbar(
          'Print failed',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}

