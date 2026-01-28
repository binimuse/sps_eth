import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/app/modules/call_class/models/direct_call_model.dart';

class AttachmentUploadPopup extends StatelessWidget {
  final AttachmentUploadLinkEvent uploadLinkEvent;

  const AttachmentUploadPopup({
    super.key,
    required this.uploadLinkEvent,
  });

  static void show(BuildContext context, AttachmentUploadLinkEvent event) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AttachmentUploadPopup(uploadLinkEvent: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Requested'.tr,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (uploadLinkEvent.description != null && uploadLinkEvent.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          uploadLinkEvent.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grayDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // Don't allow closing manually - only close on upload success/failure
                  },
                  color: AppColors.grayDark,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Two sections side by side
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left section - QR Code
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.whiteOff,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grayLight, width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Scan QR Code'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (uploadLinkEvent.url != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.grayLight, width: 1),
                              ),
                              child: QrImageView(
                                data: uploadLinkEvent.url!,
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white,
                                errorCorrectionLevel: QrErrorCorrectLevel.M,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Use the document scanner to scan this QR code'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grayDark,
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(40),
                              child: Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.danger,
                              ),
                            ),
                            Text(
                              'Upload URL not available'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Right section - How to instructions
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'How to Upload'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInstructionStep(
                            stepNumber: 1,
                            text: 'Use the document scanner on the machine to scan the QR code'.tr,
                          ),
                          const SizedBox(height: 12),
                          _buildInstructionStep(
                            stepNumber: 2,
                            text: 'The scanner will open the upload page automatically'.tr,
                          ),
                          const SizedBox(height: 12),
                          _buildInstructionStep(
                            stepNumber: 3,
                            text: 'Place your document on the scanner and press scan'.tr,
                          ),
                          const SizedBox(height: 12),
                          _buildInstructionStep(
                            stepNumber: 4,
                            text: 'The file will be uploaded automatically and this popup will close'.tr,
                          ),
                          if (uploadLinkEvent.expiresAt != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.warningLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.warning, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: AppColors.warningDefault,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This link expires at ${_formatExpiryTime(uploadLinkEvent.expiresAt!)}'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.warningDefault,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep({
    required int stepNumber,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grayDark,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  String _formatExpiryTime(String expiresAt) {
    try {
      final dateTime = DateTime.parse(expiresAt);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return expiresAt;
    }
  }
}
