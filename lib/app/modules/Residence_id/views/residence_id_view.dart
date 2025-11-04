import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:sps_eth_app/gen/assets.gen.dart';

import '../controllers/residence_id_controller.dart';
import 'package:sps_eth_app/app/common/widgets/promo_card.dart';
import 'id_information_view.dart';

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
        backgroundColor: Colors.white.withOpacity(0.9),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LEFT PROMO CARD
                SizedBox(
                  width: 300,
                  child: PromoCard(
                  ),
                ),

                const SizedBox(width: 24),

                // CENTER CONTENT
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 70.h,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Top Section: ID Scanning Icon and Text
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: Image.asset(
                            Assets.images.scanid.path,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Scanning For ID ....',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Middle Section: Input Field and Find Button in Row
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Fayda ID / Phone / Residence',
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
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                // Show ID Information popup
                                IdInformationView.show(
                                  context,
                                  {
                                    'id': '1231235163',
                                    'name': 'Abeba Shimeles Adera',
                                    'birthDate': 'Aug 12, 2024',
                                    'email': 'abeba@gmail.com',
                                    'phoneNumber': '0913427553',
                                    'residenceAddress': '-',
                                  },
                                );
                              },
                              child: const Text(
                                'Find',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Separator: "or" text
                        const Text(
                          'or',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Bottom Section: Guest Option Card
                        GestureDetector(
                          onTap: () {
                            // Handle guest continuation
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 50,
                            ),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(Assets.images.background.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 32,
                                  color: const Color(0xFF1976D2),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Continue as a Guest',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4A4A4A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // RIGHT SIDEBAR
                Image.asset(
                  Assets.images.machine.path,
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
