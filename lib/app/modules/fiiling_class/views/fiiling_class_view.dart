import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/app/theme/app_sizes.dart';
import 'package:sps_eth_app/app/theme/app_text_styles.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';

import '../controllers/fiiling_class_controller.dart';

class FiilingClassView extends GetView<FiilingClassController> {
  const FiilingClassView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // LEFT PANEL
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo placeholder
                 
                      const SizedBox(height: 12),
                  
                        const SizedBox(height: 12),
     Image.asset(
                            Assets.images.efpLogo.path,
                          width: 72,
                          height: 56,
                          fit: BoxFit.cover,
                        ), 
                        const SizedBox(height: 12),
                            Text(
                        'Smart Police \n Station',
                
                        textAlign: TextAlign.center,
         style: AppTextStyles.menuBold.copyWith( color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Loreim re in charge of planning and managing marketing\n'
                        'campaigns that promote a company\'s brand. marketing\n'
                        'campaigns that promote a company\'s brand.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF5E7586)),
                      ),
                      const SizedBox(height: 24),
                      // Large illustration placeholder
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                          Assets.images.law.path,
                                                    width: double.infinity,
                                                    height: double.infinity,
                          fit: BoxFit.fitWidth,
                                                  
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // RIGHT CONTENT
              Expanded(
                flex: 7,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('List of Provided Services',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F3955),
                                    )),
                                SizedBox(height: 4),
                                Text(
                                  'Loreim re in charge of planning and managing marketing\n'
                                  'campaigns that promote a company\'s brand.',
                                  style: TextStyle(color: Color(0xFF4F6B7E), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                  
                      ],
                    ),
                    const SizedBox(height: 16),
                          OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            side: const BorderSide(color: Color(0xFFCBDCE7)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F3955)),
                          label: const Text('Back', style: TextStyle(color: Color(0xFF0F3955))),
                        ),
                         const SizedBox(height: 16),
                    // Two selection cards
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: const SizedBox(
                                height: 420,
                                width: double.infinity,
                                child: _ServiceCard(
                                  title: 'Residence ID',
                                  subtitle: 'Please Start your process using your\nResidence id / National id',
                                  icon: Icons.badge,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: const SizedBox(
                                height: 420,
                                width: double.infinity,
                                child: _ServiceCard(
                                  title: 'Visitor ID / Passport',
                                  subtitle: 'If you are foreigner you can start your process\nusing your passport id',
                                  icon: Icons.travel_explore,
                                ),
                              ),
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
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _ServiceCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            width: 220,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F3FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 120, color: const Color(0xFF2D6E91)),
          ),
          const SizedBox(height: 24),
          Text(title,
              style:  TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.font_12,
                color: Color(0xFF0A5B95),
                fontFamily: 'DMSans',
              )),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF4F6B7E), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
