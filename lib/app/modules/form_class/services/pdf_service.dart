import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';

class PdfService {
  /// Generate and print PDF from form data
  static Future<void> generateAndPrintPdf(Map<String, String> formData) async {
    try {
      final pdf = await _createPdf(formData);
      
      // Use sharePdf which provides print and share options
      await Printing.sharePdf(
        bytes: pdf,
        filename: 'form_submission_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow;
    }
  }

  /// Direct print PDF (alternative method)
  /// This opens a preview with a print button
  static Future<void> directPrintPdf(Map<String, String> formData) async {
    try {
      final pdf = await _createPdf(formData);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf,
        format: PdfPageFormat.a4,
        name: 'Form Submission',
      );
    } catch (e) {
      print('Error printing PDF: $e');
      rethrow;
    }
  }

  /// Get PDF bytes for saving/sharing
  static Future<Uint8List> getPdfBytes(Map<String, String> formData) async {
    return await _createPdf(formData);
  }

  /// Generate PDF document
  static Future<Uint8List> _createPdf(Map<String, String> formData) async {
    final pdf = pw.Document();

    // Load logo image
    final logoImage = await _loadImage(Assets.images.efpLogo.path);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with Logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      if (logoImage != null)
                        pw.Image(
                          logoImage,
                          width: 60,
                          height: 60,
                        ),
                      pw.SizedBox(width: 12),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Ethiopian Federal Police',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blueGrey900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'SMART POLICE STATION FORM',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.blueGrey700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.amber,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          '(SPS)',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.Text(
                          'SMART POLICE STATION',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Title
              pw.Center(
                child: pw.Text(
                  'FORM SUBMISSION DETAILS',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              // Personal Information Section
              _buildSectionHeader('PERSONAL INFORMATION'),
              pw.SizedBox(height: 12),
              _buildInfoRow('Clearance For', formData['clearanceFor'] ?? '-'),
              _buildInfoRow('Email', formData['email'] ?? '-'),
              _buildInfoRow('Phone Number', formData['phone'] ?? '-'),
              _buildInfoRow('Current Address', formData['address'] ?? '-'),
              _buildInfoRow('Marital Status', formData['maritalStatus'] ?? '-'),
              pw.SizedBox(height: 20),

              // Residence Information Section
              _buildSectionHeader('RESIDENCE INFORMATION'),
              pw.SizedBox(height: 12),
              _buildInfoRow('Ethiopian / Foreigner', formData['ethiopianOrForeigner'] ?? '-'),
              _buildInfoRow('Region', formData['region'] ?? '-'),
              _buildInfoRow('Subcity', formData['subcity'] ?? '-'),
              _buildInfoRow('Woreda', formData['woreda'] ?? '-'),
              _buildInfoRow('Kebele', formData['kebele'] ?? '-'),
              _buildInfoRow('House Number', formData['houseNumber'] ?? '-'),
              pw.SizedBox(height: 20),

              // Incident Details Section
              _buildSectionHeader('INCIDENT DETAILS'),
              pw.SizedBox(height: 12),
              _buildInfoRow('Incident Summary', formData['incidentSummary'] ?? '-', isMultiline: true),
              pw.SizedBox(height: 8),
              _buildInfoRow('Damage Caused', formData['damageCaused'] ?? '-', isMultiline: true),
              pw.SizedBox(height: 8),
              _buildInfoRow('Incident Detail', formData['incidentDetail'] ?? '-', isMultiline: true),
              pw.SizedBox(height: 30),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'Please accept the responsibility for supplying, checking, and verifying the accuracy and correctness of the information provided.',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                    fontStyle: pw.FontStyle.italic,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'Generated on: ${DateTime.now().toString().split('.')[0]}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Build section header
  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey900,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  /// Build info row
  static pw.Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey700,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              value.isEmpty ? '-' : value,
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColors.black,
                fontWeight: pw.FontWeight.normal,
              ),
              maxLines: isMultiline ? null : 2,
            ),
          ),
        ],
      ),
    );
  }

  /// Load image from assets
  static Future<pw.MemoryImage?> _loadImage(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      return pw.MemoryImage(bytes);
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }
}
