import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';

class IdInformationView extends StatelessWidget {
  final Map<String, String> idInfo;

  const IdInformationView({super.key, required this.idInfo});

  Widget _buildTableRow(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label column
              SizedBox(
                width: 35.w,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Value column
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
     
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 5.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 50.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image at the top
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Image.asset(
                  Assets.images.popupimage.path,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
       

            // Content Section with Table Layout
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table Rows
                  _buildTableRow(
                    'ID Information'.tr,
                    idInfo['id'] ?? '1231235163',
                  ),
                  _buildTableRow(
                    'Name Information'.tr,
                    idInfo['name'] ?? 'Abeba Shimeles Adera',
                  ),
                  _buildTableRow(
                    'Birth Date'.tr,
                    idInfo['birthDate'] ?? 'Aug 12, 2024',
                  ),
                  _buildTableRow(
                    'Email'.tr,
                    idInfo['email'] ?? 'abeba@gmail.com',
                  ),
                  _buildTableRow(
                    'Phone Number'.tr,
                    idInfo['phoneNumber'] ?? '0913427553',
                  ),
                  _buildTableRow(
                    'Residence Address'.tr,
                    idInfo['residenceAddress'] ?? '-',
                  ),
                  
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cancel Button - White with Blue Border
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1976D2),
                          side: const BorderSide(
                            color: Color(0xFF1976D2),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          'Cancel'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Confirm Button - Dark Blue with Arrow Icon
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                       Get.toNamed(Routes.CALL_CLASS);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children:  [
                            Text(
                              'Confirm'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, Map<String, String> idInfo) {
    showDialog(
      context: context,
      builder: (context) => IdInformationView(idInfo: idInfo),
    );
  }
}