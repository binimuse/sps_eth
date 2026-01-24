import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:sps_eth_app/app/common/widgets/side_info_panel.dart';
import '../../controllers/residence_id_controller.dart';

class ResidenceServiceListView extends GetView<ResidenceIdController> {
  const ResidenceServiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    final double viewportHeight = MediaQuery.of(context).size.height - 
        MediaQuery.of(context).padding.vertical - 32;
    
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
                    title: 'SMART POLICE\nSTATION',
                    description: 'A technology-driven, modern police service outlet where users can serve themselves without human intervention. Designed to make police services more accessible, efficient, and convenient for the community.'
                       ,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top info box
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
                                Text(
                                  'List of Provided Services',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: Color(0xFF0F3955),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Service List of planning and managing that promote a company\'s brand.',
                                  style: TextStyle(color: Color(0xFF4F6B7E), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Language selector button
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            side: const BorderSide(color: Color(0xFFCBDCE7)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Get.toNamed(Routes.LANGUAGE);
                          },
                          icon: const Icon(Icons.language, color: Color(0xFF0F3955), size: 20),
                          label: const Text('Language', style: TextStyle(color: Color(0xFF0F3955))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 24),
                    // Scrollable service cards list in a row
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ServiceCard(
                              title: 'Crime Report',
                              description: 'Report crimes promptly and help maintain public safety.',
                              image: Assets.images.crime.path,
                              onTap: () {
                                controller.selectService('Crime Report');
                              },
                            ),
                            const SizedBox(width: 16),
                            _ServiceCard(
                              title: 'Traffic Incident Report',
                              description: 'Official platform for monitoring and managing traffic incidents.',
                              image: Assets.images.traffic.path,
                              onTap: () {
                                controller.selectService('Traffic Incident Report');
                              },
                            ),
                            const SizedBox(width: 16),
                            _ServiceCard(
                              title: 'Incident Report',
                              description: 'Ensuring accountability through proper incident documentation.',
                              image: Assets.images.incident.path,
                              onTap: () {
                                controller.selectService('Incident Report');
                              },
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
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.description,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
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
        padding: const EdgeInsets.all(20),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top section with icon and navigation arrow
          Row(
            children: [
              // Image - will be replaced with actual image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F3FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Spacer(),
              // Navigation arrow
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF0F3955)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF0A5B95),
            ),
          ),
          const SizedBox(height: 6),
          // Description
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF4F6B7E),
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
    );
  }
}
