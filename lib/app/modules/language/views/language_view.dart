import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:sps_eth_app/app/common/widgets/side_info_panel.dart';

import '../controllers/language_controller.dart';

class LanguageView extends GetView<LanguageController> {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = [
      {'name': 'English', 'image': Assets.images.english.path},
      {'name': 'French', 'image': Assets.images.french.path},
      {'name': 'Spanish', 'image': Assets.images.spanish.path},
      {'name': 'Arabic', 'image': Assets.images.arabic.path},
      {'name': 'አማርኛ', 'image': Assets.images.amhric.path},
      {'name': 'Afaan Oromoo', 'image': Assets.images.oromoo.path},
      {'name': 'ነጋሪት', 'image': Assets.images.tigregna.path},
      {'name': 'Afar', 'image': Assets.images.afar.path},
    ];

    final double viewportHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical - 32;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Padding(
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
                    title: 'SMART POLICE\nSTATION',
                    description: 'Loreim re in charge of planning and managing marketing\n'
                        'campaigns that promote a company\'s brand. marketing\n'
                        'campaigns that promote a company\'s brand.',
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
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    final isSelected = controller.selectedLanguageIndex == index;
                    return GestureDetector(
                      onTap: () {
                        controller.selectLanguage(index);
                        Get.toNamed(Routes.FIILING_CLASS);
                      },
                      child: Card(
                        color: Colors.white.withOpacity(0.8), // Added white color with opacity
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSelected
                              ? BorderSide(color: Colors.blue, width: 2)
                              : BorderSide.none,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                language['image']!,
                                width: 180, // Increased size
                                height: 180, // Increased size
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(language['name']!,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
