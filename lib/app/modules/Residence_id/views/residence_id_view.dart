import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:sps_eth_app/app/common/widgets/promo_card.dart';
import '../controllers/residence_id_controller.dart';

class ResidenceIdView extends GetView<ResidenceIdController> {
  const ResidenceIdView({super.key});
  
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top info box + back button
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2F0F8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Select ID Type',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F3955),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'A technology-driven, modern police service outlet where users can serve themselves without human intervention. Designed to make police services more accessible, efficient, and convenient for the community.',
                                      style: TextStyle(color: Color(0xFF4F6B7E), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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

                               OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            side: const BorderSide(color: Color(0xFFCBDCE7)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Get.toNamed(Routes.CALL_CLASS);
                          },
                          icon: const Icon(Icons.person_outline, color: Color(0xFF0F3955)),
                          label: const Text('Continue as guest', style: TextStyle(color: Color(0xFF0F3955))),
                        ),
                        ],),
                      
                        
                        const SizedBox(height: 16),
                        
                        // Single Card with Three ID Type Buttons or Input Field
                        Obx(() {
                          final selectedType = controller.selectedIdType.value;
                          
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with back button if selected
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedType.isEmpty
                                          ? 'Select Your ID Type'
                                          : selectedType == 'fayda'
                                              ? 'Enter Phone Number'
                                              : selectedType == 'residence'
                                                  ? 'Enter Residence ID'
                                                  : 'Enter TIN Number',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F3955),
                                      ),
                                    ),
                                    if (selectedType.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Color(0xFF0F3955)),
                                        onPressed: () => controller.clearSelection(),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                
                                // Show buttons if nothing selected
                                if (selectedType.isEmpty) ...[
                                  // Fayda ID Button
                                  _IdTypeButton(
                                    title: 'Fayda ID',
                                    subtitle: 'Use your Fayda ID to continue with the process',
                                    icon: Icons.credit_card,
                                    onTap: () {
                                      controller.selectIdType('fayda');
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Residence ID Button
                                  _IdTypeButton(
                                    title: 'Residence ID',
                                    subtitle: 'Use your Residence ID or National ID to continue',
                                    icon: Icons.badge,
                                    onTap: () {
                                      controller.selectIdType('residence');
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // TIN Number Button
                                  _IdTypeButton(
                                    title: 'TIN Number',
                                    subtitle: 'Use your Tax Identification Number to continue',
                                    icon: Icons.numbers,
                                    onTap: () {
                                      controller.selectIdType('tin');
                                    },
                                  ),
                                ],
                                
                                // Show input field based on selection
                                if (selectedType == 'fayda') ...[
                                  TextField(
                                    controller: controller.phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      hintText: 'Phone Number',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
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
                                      onPressed: () => controller.submit(),
                                      child: const Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                
                                if (selectedType == 'residence') ...[
                                  TextField(
                                    controller: controller.idController,
                                    decoration: InputDecoration(
                                      hintText: 'Residence ID / National ID',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
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
                                      onPressed: () => controller.submit(),
                                      child: const Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                
                                if (selectedType == 'tin') ...[
                                  TextField(
                                    controller: controller.tinController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'TIN Number',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
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
                                      onPressed: () => controller.submit(),
                                      child: const Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        
                        // Guest Option Card
                        // GestureDetector(
                        //   onTap: () {
                        //     Get.toNamed(Routes.CALL_CLASS);
                        //   },
                        //   child: Container(
                        //     width: double.infinity,
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 24,
                        //       vertical: 35,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       image: DecorationImage(
                        //         image: AssetImage(Assets.images.background.path),
                        //         fit: BoxFit.cover,
                        //       ),
                        //       borderRadius: BorderRadius.circular(16),
                        //     ),
                        //     child: Column(
                        //       children: [
                        //         Icon(
                        //           Icons.person_outline,
                        //           size: 32,
                        //           color: const Color(0xFF1976D2),
                        //         ),
                        //         const SizedBox(height: 12),
                        //         const Text(
                        //           'Continue as a Guest',
                        //           style: TextStyle(
                        //             fontSize: 15,
                        //             fontWeight: FontWeight.w600,
                        //             color: Color(0xFF4A4A4A),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // RIGHT SIDEBAR
                Image.asset(
                  Assets.images.machineGif.path,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IdTypeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _IdTypeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F9FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFCBDCE7),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F3FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: const Color(0xFF0A5B95),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0A5B95),
                      fontFamily: 'DMSans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF4F6B7E),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Color(0xFF0A5B95),
            ),
          ],
        ),
      ),
    );
  }
}
