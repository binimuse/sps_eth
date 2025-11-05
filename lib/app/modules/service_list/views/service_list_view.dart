import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:sps_eth_app/app/common/widgets/side_info_panel.dart';

import '../controllers/service_list_controller.dart';

class ServiceListView extends GetView<ServiceListController> {
  const ServiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    final double viewportHeight = MediaQuery.of(context).size.height - 
        MediaQuery.of(context).padding.vertical - 32;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT PANEL
              Flexible(
                flex: 2,
                fit: FlexFit.loose,
                child: SizedBox(
                  height: viewportHeight,
                  child: SideInfoPanel(
                    title: 'SMART POLICE\nSTATION',
                    description: 'Loreim re in charge of planning and managing marketing\ncampaigns that promote a company\'s brand. marketing\ncampaigns that promote a company\'s brand.',
                    logoAsset: Assets.images.efpLogo.path,
                    illustrationAsset: Assets.images.law.path,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // RIGHT CONTENT
              Flexible(
                flex: 8,
                fit: FlexFit.loose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar with back button, title, and language selector
                    Row(
                      children: [
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
                        const Spacer(),
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
                            // Navigate to language selection
                            Get.toNamed(Routes.LANGUAGE);
                          },
                          icon: const Icon(Icons.language, color: Color(0xFF0F3955), size: 20),
                          label: const Text('Language', style: TextStyle(color: Color(0xFF0F3955))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Title and subtitle
                    Container(
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
                              image: Assets.images.crime.path, // Replace with crime image
                              onTap: () {},
                              subSections: [
                                _ServiceSubSection(
                                  title: 'Start Filling Crime Form',
                                  description: 'Official platform for monitoring and managing traffic incidents.',
                                  onTap: () {
                                    Get.toNamed(Routes.FORM_CLASS);
                                  },
                                ),
                                _ServiceSubSection(
                                  title: 'Direct Call For Crime',
                                  description: 'Official platform for monitoring and managing traffic incidents.',
                                  isCall: true,
                                  onTap: () {
                                       Get.toNamed(Routes.CALL_CLASS);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            _ServiceCard(
                              title: 'Traffic Incident Report',
                              description: 'Official platform for monitoring and managing traffic incidents.',
                              image: Assets.images.traffic.path,
                              onTap: () {},
                              subSections: [
                                _ServiceSubSection(
                                  title: 'Start Filling Traffic Form',
                                  description: 'Official platform for monitoring and managing traffic incidents.',
                                  onTap: () {
                                    Get.toNamed(Routes.FORM_CLASS);
                                  },
                                ),
                                _ServiceSubSection(
                                  title: 'Direct Call For Traffic',
                                  description: 'Official platform for monitoring and managing traffic incidents.',
                                  isCall: true,
                                  onTap: () {
                                       Get.toNamed(Routes.CALL_CLASS);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            _ServiceCard(
                              title: 'Incident Report',
                              description: 'Ensuring accountability through proper incident documentation.',
                              image: Assets.images.incident.path, // Replace with incident image
                              onTap: () {},
                              subSections: [
                                _ServiceSubSection(
                                  title: 'Start Filling Incident Form',
                                  description: 'Official platform for monitoring and managing traffic incidents.',
                                  onTap: () {
                                    Get.toNamed(Routes.FORM_CLASS);
                                  },
                                ),
                                _ServiceSubSection(
                                  title: 'Direct Call For Incident',
                                  description: 'Official platform for monitoring and managing traffic incidents.',
                                  isCall: true,
                                  onTap: () {
                                    Get.toNamed(Routes.CALL_CLASS);
                                  },
                                ),
                              ],
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
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final VoidCallback onTap;
  final List<_ServiceSubSection> subSections;

  const _ServiceCard({
    required this.title,
    required this.description,
    required this.image,
    required this.onTap,
    required this.subSections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF0F3955)),
                  onPressed: onTap,
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
          const SizedBox(height: 12),
          // Sub-sections
          ...subSections.map((subSection) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: subSection,
              )),
        ],
      ),
    );
  }
}

class _ServiceSubSection extends StatelessWidget {
  final String title;
  final String description;
  final bool isCall;
  final VoidCallback onTap;
  final String? image;

  const _ServiceSubSection({
    required this.title,
    required this.description,
    required this.onTap,
    this.isCall = false,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F3FB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  if (image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        image!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Center(
                      child: Icon(
                        isCall ? Icons.people : Icons.description,
                        size: 24,
                        color: const Color(0xFF2D6E91),
                      ),
                    ),
                  // Badge placeholder
                  Positioned(
                    right: 3,
                    bottom: 3,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCall ? Icons.phone : Icons.star,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF0F3955),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF4F6B7E),
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

