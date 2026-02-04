import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:sps_eth_app/app/common/widgets/side_info_panel.dart';

import '../controllers/language_controller.dart';

class LanguageView extends GetView<LanguageController> {
  const LanguageView({super.key});

  // All languages listed together
  static final List<Map<String, dynamic>> allLanguages = [
    // English first
    {'name': 'English', 'icon': Icons.language},
    // Local languages
    {'name': 'አማርኛ', 'icon': Icons.translate}, // Amharic
    {'name': 'Afaan Oromoo', 'icon': Icons.translate},
    {'name': 'ትግርኛ', 'icon': Icons.translate}, // Tigrigna
    {'name': 'Afi Somali', 'icon': Icons.translate},
    // Other languages
    {'name': 'Arabic', 'icon': Icons.translate},
  ];

  @override
  Widget build(BuildContext context) {

    final double viewportHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical - 32;

    return Scaffold(
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
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT PANEL
              Flexible(
                flex: 3,
                fit: FlexFit.loose,
                child: SizedBox(
                  height: viewportHeight,
                  child: SideInfoPanel(
                    title: 'SMART POLICE\nSTATION'.tr,
                    description: 'A technology-driven, modern police service outlet where users can serve themselves without human intervention. Designed to make police services more accessible, efficient, and convenient for the community.'.tr,
                    logoAsset: Assets.images.efpLogo.path,
                    illustrationAsset: Assets.images.law.path,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // RIGHT CONTENT
              Flexible(
                flex: 7,
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Top info box
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Select Language'.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F3955),
                                    )),
                                SizedBox(height: 4),
                                Text(
                                  'A technology-driven, modern police service outlet where users can serve themselves without human intervention. Designed to make police services more accessible, efficient, and convenient for the community.'.tr,
                                  style: TextStyle(color: Color(0xFF4F6B7E), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        side: const BorderSide(color: Color(0xFFCBDCE7)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0F3955)),
                      label: Text('Back'.tr, style: TextStyle(color: Color(0xFF0F3955))),
                    ),
                    const SizedBox(height: 16),
                    // Language grid - Show all languages
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: allLanguages.length,
                        itemBuilder: (context, index) {
                          final language = allLanguages[index];
                          return Obx(() {
                            final isSelected = controller.selectedLanguageIndex.value == index;
                            return GestureDetector(
                              onTap: () {
                                controller.selectLanguage(index);
                                Get.toNamed(Routes.FIILING_CLASS);
                              },
                              child: Card(
                                elevation: 2,
                                color: Colors.white.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: isSelected
                                      ? const BorderSide(color: Color(0xFF0F3955), width: 2)
                                      : BorderSide.none,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        language['icon'] as IconData,
                                        size: 32,
                                        color: const Color(0xFF0F3955),
                                      ),
                                      const SizedBox(height: 6),
                                      Flexible(
                                        child: Text(
                                          language['name'] as String,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    ),
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
}
