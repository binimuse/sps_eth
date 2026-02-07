import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';

/// Method channel for direct USB print (Android only).
const String _kDirectPrintChannel = 'com.sps.eth.sps_eth_app/direct_print';

class PdfService {
  /// Direct print PDF to USB-connected printer (Android only). No system dialog.
  /// Builds PDF from form data and sends bytes to native; native finds first USB printer and sends raw PDF.
  static Future<void> directPrintPdf(Map<String, String> formData) async {
    if (!Platform.isAndroid) {
      throw PlatformException(
        code: 'UNSUPPORTED',
        message: 'Direct USB print is supported on Android only',
      );
    }
    try {
      final pdfBytes = await _createPdf(formData);
      const channel = MethodChannel(_kDirectPrintChannel);
      await channel.invokeMethod<void>('printPdf', {'pdfBytes': pdfBytes});
    } catch (e) {
      print('Error printing PDF: $e');
      rethrow;
    }
  }

  /// Share PDF (e.g. save or share via system share sheet).
  /// Generates PDF and opens share dialog; on non-Android or when share not available, throws.
  static Future<void> generateAndPrintPdf(Map<String, String> formData) async {
    try {
      final pdfBytes = await _createPdf(formData);
      await _sharePdfBytes(pdfBytes);
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow;
    }
  }

  /// Share PDF bytes using platform share (e.g. share_plus or file + share intent).
  static Future<void> _sharePdfBytes(Uint8List pdfBytes) async {
    // Use share_plus if available; otherwise defer to platform or show message.
    try {
      final tempDir = await _tempDir;
      final file = await _writePdfToTemp(tempDir, pdfBytes);
      await _invokeShare(file.path);
    } catch (e) {
      print('Error sharing PDF: $e');
      rethrow;
    }
  }

  static Future<String> get _tempDir async {
    // path_provider is in pubspec
    final p = await getApplicationDocumentsDirectory();
    return p.path;
  }

  static Future<File> _writePdfToTemp(String dir, Uint8List bytes) async {
    final path = '$dir/form_submission_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<void> _invokeShare(String path) async {
    await Share.shareXFiles([XFile(path)]);
  }

  /// Get PDF bytes for saving/sharing
  static Future<Uint8List> getPdfBytes(Map<String, String> formData) async {
    return await _createPdf(formData);
  }

  /// Generate PDF document
  /// Supports both report confirmation format (id, caseNumber, category, etc.)
  /// and form submission format (clearanceFor, email, etc.)
  static Future<Uint8List> _createPdf(Map<String, String> formData) async {
    final pdf = pw.Document();

    // Detect format: report confirmation vs form submission
    final isReportFormat = _isReportFormData(formData);

    if (isReportFormat) {
      return _createReportConfirmationPdf(pdf, formData);
    } else {
      return _createFormSubmissionPdf(pdf, formData);
    }
  }

  /// Check if formData is in report confirmation format
  static bool _isReportFormData(Map<String, String> formData) {
    return (formData['id'] != null && formData['id']!.isNotEmpty) ||
        (formData['caseNumber'] != null && formData['caseNumber']!.isNotEmpty) ||
        (formData['category'] != null && formData['category']!.isNotEmpty);
  }

  /// Create report confirmation PDF (from call flow)
  static Future<Uint8List> _createReportConfirmationPdf(
    pw.Document pdf,
    Map<String, String> formData,
  ) async {
    final logoImage = await _loadImage(Assets.images.efpLogo.path);

    final v = (String key) => _getValue(formData, key);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildReportPdfHeader(logoImage),
              pw.SizedBox(height: 24),

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
              pw.SizedBox(height: 24),

              // Report Information Section
              _buildSectionHeader('REPORT INFORMATION'),
              pw.SizedBox(height: 12),
              _buildInfoRow('Case Number', (v('id') ?? v('caseNumber')) ?? 'N/A'),
              _buildInfoRow('Category', v('category') ?? 'N/A'),
              _buildInfoRow('Type', (v('incidentType') ?? v('type')) ?? 'N/A'),
              _buildInfoRow('Full Name', v('fullName') ?? 'N/A'),
              _buildInfoRow('Phone Number', v('phoneNumber') ?? 'N/A'),
              _buildInfoRow('Age', v('age') ?? 'N/A'),
              _buildInfoRow('Sex', v('sex') ?? 'N/A'),
              _buildInfoRow('Nationality', v('nationality') ?? 'N/A'),
              _buildInfoRow('Date of Birth', v('dateOfBirth') ?? 'N/A'),
              _buildInfoRow('Address', (v('address') ?? v('location')) ?? 'N/A'),
              _buildInfoRow('Schedule Time', (v('scheduleTime') ?? v('submitTime')) ?? 'N/A'),
              pw.SizedBox(height: 24),

              _buildPdfFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Create form submission PDF (from form_class flow)
  static Future<Uint8List> _createFormSubmissionPdf(
    pw.Document pdf,
    Map<String, String> formData,
  ) async {
    final logoImage = await _loadImage(Assets.images.efpLogo.path);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildReportPdfHeader(logoImage),
              pw.SizedBox(height: 24),

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
              pw.SizedBox(height: 24),

              _buildSectionHeader('PERSONAL INFORMATION'),
              pw.SizedBox(height: 12),
              _buildInfoRow('Clearance For', _getValue(formData, 'clearanceFor') ?? 'N/A'),
              _buildInfoRow('Email', _getValue(formData, 'email') ?? 'N/A'),
              _buildInfoRow('Phone Number', _getValue(formData, 'phone') ?? 'N/A'),
              _buildInfoRow('Current Address', _getValue(formData, 'address') ?? 'N/A'),
              _buildInfoRow('Marital Status', _getValue(formData, 'maritalStatus') ?? 'N/A'),
              pw.SizedBox(height: 20),

              _buildSectionHeader('RESIDENCE INFORMATION'),
              pw.SizedBox(height: 12),
              _buildInfoRow('Ethiopian / Foreigner', _getValue(formData, 'ethiopianOrForeigner') ?? 'N/A'),
              _buildInfoRow('Region', _getValue(formData, 'region') ?? 'N/A'),
              _buildInfoRow('Subcity', _getValue(formData, 'subcity') ?? 'N/A'),
              _buildInfoRow('Woreda', _getValue(formData, 'woreda') ?? 'N/A'),
              _buildInfoRow('Kebele', _getValue(formData, 'kebele') ?? 'N/A'),
              _buildInfoRow('House Number', _getValue(formData, 'houseNumber') ?? 'N/A'),
              pw.SizedBox(height: 20),

              _buildSectionHeader('INCIDENT DETAILS'),
              pw.SizedBox(height: 12),
              _buildInfoRow('Incident Summary', _getValue(formData, 'incidentSummary') ?? 'N/A', isMultiline: true),
              pw.SizedBox(height: 8),
              _buildInfoRow('Damage Caused', _getValue(formData, 'damageCaused') ?? 'N/A', isMultiline: true),
              pw.SizedBox(height: 8),
              _buildInfoRow('Incident Detail', _getValue(formData, 'incidentDetail') ?? 'N/A', isMultiline: true),
              pw.SizedBox(height: 24),

              _buildPdfFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Get non-empty value or fallback
  static String? _getValue(Map<String, String> formData, String key) {
    final v = formData[key];
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  /// Build shared PDF header
  static pw.Widget _buildReportPdfHeader(pw.MemoryImage? logoImage) {
    return pw.Row(
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
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }

  /// Build shared PDF footer
  static pw.Widget _buildPdfFooter() {
    return pw.Column(
      children: [
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
