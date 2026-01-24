import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/common/widgets/custom_loading_widget.dart';
import 'package:sps_eth_app/app/utils/enums.dart';
import '../../controllers/residence_id_controller.dart';

class OtpVerificationView extends GetView<ResidenceIdController> {
  final String phoneNumber;

  const OtpVerificationView({
    super.key,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Verify OTP'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F3955),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Phone number display
              Text(
                'Enter the OTP sent to'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                phoneNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F3955),
                ),
              ),
              const SizedBox(height: 24),
              
              // OTP Input Field
              TextField(
                controller: controller.otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: TextStyle(
                    fontSize: 24,
                    color: Colors.grey[300],
                    letterSpacing: 8,
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  if (value.length == 6) {
                    // Auto-submit when 6 digits are entered
                //    controller.verifyOtp(phoneNumber);
                  }
                },
              ),
              const SizedBox(height: 24),
              
              // Error message
              Obx(() {
                if (controller.otpError.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      controller.otpError.value,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              
              // Loading or buttons
              Obx(() {
                if (controller.otpNetworkStatus.value == NetworkStatus.LOADING) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomLoadingWidget(),
                  );
                }
                
                return Column(
                  children: [
                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => {
                          // controller.verisfyOtp(phoneNumber)
                        },
                        child: Text(
                          'Verify'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Resend OTP Button
                    Obx(() => TextButton(
                      onPressed: controller.otpNetworkStatus.value == NetworkStatus.LOADING
                          ? null
                          : () => {
                            // controller.requestOtp(phoneNumber)
                          },
                      child: Text(
                        'Resend OTP'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, String phoneNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OtpVerificationView(phoneNumber: phoneNumber),
    );
  }
}

