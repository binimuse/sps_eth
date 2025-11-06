import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/modules/form_class/views/widget/case_summary_view.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';

import '../controllers/form_class_controller.dart';
import 'widget/scanning_document_view.dart';

class FormClassView extends GetView<FormClassController> {
  const FormClassView({super.key});

  @override
  Widget build(BuildContext context) {
    // Hide keyboard when scaffold builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      FocusScope.of(context).unfocus();
    });
    
    return GestureDetector(
      onTap: () {
        // Hide keyboard when tapping outside
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FAFD),
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP BRANDING SECTION
              Row(
                children: [
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
                          // Form Section
                          Expanded(
                            flex: 5,
                            child: _buildFormContent(),
                          ),
                          const SizedBox(width: 16),
                          // Progress and Keyboard Section
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                _buildProgressIndicator(),
                                const SizedBox(height: 16),
                                Expanded(child: _buildCustomKeyboard()),
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
        padding: const EdgeInsets.all(12),
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

  Widget _buildFormContent() {
    return Obx(() {
      final step = controller.currentStep.value;
      switch (step) {
        case 1:
          return _buildPersonalInfoForm();
        case 2:
          return _buildResidenceInfoForm();
        case 3:
          return _buildIncidentDetailsForm();
        default:
          return _buildPersonalInfoForm();
      }
    });
  }

  Widget _buildPersonalInfoForm() {
    return Container(
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF0F3955),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'here you should insert the personal information',
            style: TextStyle(
              color: Color(0xFF4F6B7E),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          _buildDropdownField('Clearance For', controller.clearanceForController),
          const SizedBox(height: 16),
          _buildTextField('Insert Your Email', controller.emailController),
          const SizedBox(height: 16),
          _buildTextField('Phone number', controller.phoneController),
          const SizedBox(height: 16),
          _buildTextField('Current Address', controller.addressController, maxLines: 2),
          const SizedBox(height: 16),
          _buildDropdownField('Marital Status', controller.maritalStatusController),
          const SizedBox(height: 24),
          _buildActionButtons(showSubmit: false),
          ],
        ),
      ),
    );
  }

  Widget _buildResidenceInfoForm() {
    return Container(
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          const Text(
            'Residence Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF0F3955),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'here you should insert the residence information',
            style: TextStyle(
              color: Color(0xFF4F6B7E),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
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
          _buildActionButtons(showSubmit: false),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentDetailsForm() {
    return Container(
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          const Text(
            'Incident Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF0F3955),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'here you should insert the Incident information',
            style: TextStyle(
              color: Color(0xFF4F6B7E),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
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
          _buildActionButtons(showSubmit: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController textController, {int maxLines = 1}) {
    final focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        // Hide system keyboard when field is focused
        Future.microtask(() {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          FocusScope.of(Get.context!).unfocus();
          focusNode.requestFocus();
        });
        controller.setFocusedField(focusNode, textController);
      }
    });
    return TextField(
      controller: textController,
      focusNode: focusNode,
      maxLines: maxLines,
      readOnly: true,
      enableInteractiveSelection: true,
      showCursor: true,
      keyboardType: TextInputType.none,
      onTap: () {
        // Hide system keyboard immediately
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        FocusScope.of(Get.context!).unfocus();
        controller.setFocusedField(focusNode, textController);
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
    final focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        // Hide system keyboard when field is focused
        Future.microtask(() {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          FocusScope.of(Get.context!).unfocus();
          focusNode.requestFocus();
        });
        controller.setFocusedField(focusNode, textController);
      }
    });
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
          focusNode: focusNode,
          maxLines: 3,
          readOnly: true,
          enableInteractiveSelection: true,
          showCursor: true,
          keyboardType: TextInputType.none,
          onTap: () {
            // Hide system keyboard immediately
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            FocusScope.of(Get.context!).unfocus();
            controller.setFocusedField(focusNode, textController);
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
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

  Widget _buildActionButtons({required bool showSubmit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () => Get.back(),
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
                  Get.to(CaseSummaryView(formData: {},));
                }
              : () => controller.nextStep(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F3955),
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

  Widget _buildCustomKeyboard() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            
              DropdownButton<String>(
                value: controller.selectedLanguage.value,
                items: ['English', 'Amharic', 'Tigrinya'].map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Text(lang),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedLanguage.value = value;
                  }
                },
                underline: Container(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _VirtualKeyboard(
              onKeyPressed: (key) => controller.onKeyboardKeyPressed(key),
            ),
          ),
        ],
      ),
    ));
  }
}

class _VirtualKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;

  const _VirtualKeyboard({required this.onKeyPressed});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // First row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rows[0].map((key) => _buildKey(key)).toList(),
          ),
          const SizedBox(height: 4),
          // Second row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              ...rows[1].map((key) => _buildKey(key)),
            ],
          ),
          const SizedBox(height: 4),
          // Third row with special keys
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSpecialKey('123?', () => onKeyPressed('123')),
              ...rows[2].map((key) => _buildKey(key)),
              _buildSpecialKey('⌫', () => onKeyPressed('backspace')),
            ],
          ),
          const SizedBox(height: 4),
          // Bottom row with space and enter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSpecialKey('←', () => onKeyPressed('left'), width: 60),
              _buildSpecialKey('Space', () => onKeyPressed('space'), width: 200),
              _buildSpecialKey('→', () => onKeyPressed('right'), width: 60),
              _buildSpecialKey('↵', () => onKeyPressed('enter'), width: 80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    return GestureDetector(
      onTap: () => onKeyPressed(key),
      child: Container(
        width: 35,
        height: 35,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            key.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String label, VoidCallback onTap, {double? width}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 60,
        height: 35,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
