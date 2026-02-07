import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/modules/call_class/views/widgets/confirmation_page_view.dart';

import 'package:sps_eth_app/gen/assets.gen.dart';

import '../controllers/form_class_controller.dart';
import '../services/pdf_service.dart';
import 'widget/scanning_document_view.dart';

class FormClassView extends GetView<FormClassController> {
  const FormClassView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              Assets.images.logoBackground.path,
              fit: BoxFit.fitWidth,
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP BRANDING SECTION
                  Row(
                    children: [
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
                        label: const Text('Back', style: TextStyle(color: Color(0xFF0F3955))),
                      ),
                      const SizedBox(width: 16),
                      Image.asset(
                    Assets.images.efpLogo.path,
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ethiopian Federal Police',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF0F3955),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ethiopian Federal Police',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4F6B7E),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '(SPS)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          'SMART POLICE STATION FORM',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      side: const BorderSide(color: Color(0xFF0F3955)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final formData = controller.getAllFormData();
                        // Show dialog with print and share options
                        _showPrintOptionsDialog(Get.context!, formData);
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to generate PDF: ${e.toString()}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    icon: const Icon(Icons.print, color: Color(0xFF0F3955)),
                    label: const Text('Print', style: TextStyle(color: Color(0xFF0F3955))),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // MAIN CONTENT AREA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Navigation and Progress
                    _buildStepNavigation(),
                    const SizedBox(height: 16),
                    // Main Content Area
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Form Section - takes more space now
                          Expanded(
                            flex: 7,
                            child: _buildFormContent(context),
                          ),
                          const SizedBox(width: 24),
                          // Progress Section only
                          Expanded(
                            flex: 3,
                            child: _buildProgressIndicator(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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

  Widget _buildStepNavigation() {
    return Obx(() {
      final step = controller.currentStep.value;
      final stepNames = ['Personal Info', 'Residence Information', 'Incident Detail'];
      final stepTitle = step == 1 
          ? 'Personal Information' 
          : step == 2 
              ? 'Residence Information' 
              : 'Incident Details';
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Step $step',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0F3955),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                stepTitle,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF0F3955),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (index) {
              final isActive = (index + 1) == step;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.goToStep(index + 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF0F3955) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        stepNames[index],
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey[700],
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      );
    });
  }

  Widget _buildProgressIndicator() {
    return Obx(() {
      final progress = controller.progress.value;
      final step = controller.currentStep.value;
      final stepText = step == 1 
          ? 'Step 1 Personal Information Filling'
          : step == 2
              ? 'Step 2 Residence Information'
              : 'Step 3 Incident Details';
      
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress Indicator',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF0F3955),
                  ),
                ),
                Text(
                  '${progress.toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF0F3955),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      Text(
                        '${progress.toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF0F3955),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stepText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFF0F3955),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Please Users accept the responsibility for supplying, checking, and verifying the accuracy and correctness of the information they provide.',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF4F6B7E),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFormContent(BuildContext context) {
    return Obx(() {
      final step = controller.currentStep.value;
      switch (step) {
        case 1:
          return _buildPersonalInfoForm(context);
        case 2:
          return _buildResidenceInfoForm(context);
        case 3:
          return _buildIncidentDetailsForm(context);
        default:
          return _buildPersonalInfoForm(context);
      }
    });
  }

  Widget _buildPersonalInfoForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
         
          const SizedBox(height: 12),
          _buildDropdownField('Clearance For', controller.clearanceForController),
          const SizedBox(height: 16),
          _buildTextField('Insert Your Email', controller.emailController, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildTextField('Phone number', controller.phoneController, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _buildTextField('Current Address', controller.addressController, maxLines: 2),
          const SizedBox(height: 16),
          _buildDropdownField('Marital Status', controller.maritalStatusController),
          const SizedBox(height: 24),
          _buildActionButtons(showSubmit: false, context: context),
          ],
        ),
      ),
    );
  }

  Widget _buildResidenceInfoForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
        
          const SizedBox(height: 12),
          _buildDropdownField('Ethiopian / Foreigner', controller.ethiopianOrForeignerController),
          const SizedBox(height: 16),
          _buildTextField('Region', controller.regionController),
          const SizedBox(height: 16),
          _buildTextField('Subcity', controller.subcityController),
          const SizedBox(height: 16),
          _buildTextField('Woreda', controller.woredaController),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Kebele', controller.kebeleController),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('House Number', controller.houseNumberController),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionButtons(showSubmit: false, context: context),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentDetailsForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
        
          const SizedBox(height: 12),
          _buildFieldWithUpload(
            Get.context!,
            'Incident Summary',
            controller.incidentSummaryController,
            'Incident Summary here...',
          ),
          const SizedBox(height: 16),
          _buildFieldWithUpload(
            Get.context!,
            'Damage Caused by incident',
            controller.damageCausedController,
            'Damage Caused by the incident',
          ),
          const SizedBox(height: 16),
          _buildFieldWithUpload(
            Get.context!,
            'Incident Detail',
            controller.incidentDetailController,
            'Reported Case in Brief',
            showScanOnly: true,
          ),
          const SizedBox(height: 24),
          _buildActionButtons(showSubmit: true, context: context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController textController, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: textController,
      maxLines: maxLines,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F3955), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdownField(String hint, TextEditingController textController) {
    return TextField(
      controller: textController,
      readOnly: true,
      onTap: () {
        // Show dropdown dialog
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0F3955)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildFieldWithUpload(BuildContext context, String label, TextEditingController textController, String hint, {bool showScanOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF0F3955),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: textController,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0F3955), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (!showScanOnly)
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload, size: 16),
                label: const Text('Video / Image Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE6F3FB),
                  foregroundColor: const Color(0xFF0F3955),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            if (!showScanOnly) const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                ScanningDocumentView.show(context);
              },
              icon: const Icon(Icons.document_scanner, size: 16),
              label: const Text('Scan Document'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons({required bool showSubmit, required BuildContext context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0F3955),
            side: const BorderSide(color: Color(0xFF0F3955), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: showSubmit 
              ? () {
                  // Submit form
                  Get.to(ConfirmationPageView(formData: {},));
                }
              : () => controller.nextStep(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 31, 34, 37),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(showSubmit ? 'Submit' : 'Next'),
        ),
      ],
    );
  }

  void _showPrintOptionsDialog(BuildContext context, Map<String, String> formData) {
    int cooldownSeconds = 0;
    Timer? cooldownTimer;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            void startPrintCooldown() {
              cooldownTimer?.cancel();
              cooldownSeconds = 60;
              cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
                if (cooldownSeconds <= 0) {
                  cooldownTimer?.cancel();
                  if (context.mounted) setState(() {});
                  return;
                }
                cooldownSeconds--;
                if (context.mounted) setState(() {});
              });
              setState(() {});
            }

            return AlertDialog(
              title: const Text(
                'Print / Share PDF',
                style: TextStyle(
                  color: Color(0xFF0F3955),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text('Choose an option to print or share the form PDF'),
              actions: [
                TextButton(
                  onPressed: () {
                    cooldownTimer?.cancel();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: cooldownSeconds > 0
                      ? null
                      : () async {
                          startPrintCooldown();
                          try {
                            await PdfService.directPrintPdf(formData);
                            if (dialogContext.mounted) {
                              Get.snackbar(
                                'Print',
                                'Sent to printer',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              Get.snackbar(
                                'Error',
                                'Failed to print: ${e.toString()}',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          }
                        },
                  icon: Icon(Icons.print, size: 18, color: cooldownSeconds > 0 ? Colors.grey : Colors.white),
                  label: Text(
                    cooldownSeconds > 0 ? 'Print again in ${cooldownSeconds}s' : 'Print',
                    style: TextStyle(color: cooldownSeconds > 0 ? Colors.grey : Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cooldownSeconds > 0 ? Colors.grey : const Color(0xFF0F3955),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await PdfService.generateAndPrintPdf(formData);
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Failed to share: ${e.toString()}',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3955),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

}
