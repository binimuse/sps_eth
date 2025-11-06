import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';

import 'package:sps_eth_app/gen/assets.gen.dart';

import '../controllers/visitor_id_controller.dart';
import 'package:sps_eth_app/app/common/widgets/promo_card.dart';

class VisitorIdView extends GetView<VisitorIdController> {
  const VisitorIdView({super.key});
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
      child: Container( 
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          label: const Text('Back', style: TextStyle(color: Color(0xFF0F3955))),
                        ),
                        const SizedBox(height: 16),
                        // Main Card with Personal Info Form
                        Expanded(
                          child: _buildPersonalInfoForm(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),
 const SizedBox(width: 70),
                  // RIGHT SIDEBAR
                 
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
            _buildActionButtons(),
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

  Widget _buildActionButtons() {
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
          onPressed: () {
            // Handle submit
            Get.toNamed(Routes.SERVICE_LIST);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F3955),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }

}

