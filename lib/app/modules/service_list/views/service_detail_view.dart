import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:sps_eth_app/app/common/widgets/side_info_panel.dart';
import '../controllers/service_detail_controller.dart';

class ServiceDetailView extends GetView<ServiceDetailController> {
  const ServiceDetailView({super.key});

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
                flex: 3,
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
                            Get.toNamed(Routes.LANGUAGE);
                          },
                          icon: const Icon(Icons.language, color: Color(0xFF0F3955), size: 20),
                          label: const Text('Language', style: TextStyle(color: Color(0xFF0F3955))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Main content area with two columns
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column - Service cards
                          Flexible(
                            flex: 1,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildServiceCard(
                                    title: 'Crime Report',
                                    description: 'Report crimes promptly and help maintain public safety.',
                                    image: Assets.images.crime.path,
                                    onTap: () => controller.selectService('Crime Report'),
                                    isSelected: controller.selectedService.value == 'Crime Report',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildServiceCard(
                                    title: 'Traffic Incident Report',
                                    description: 'Official platform for monitoring and managing traffic incidents.',
                                    image: Assets.images.traffic.path,
                                    onTap: () => controller.selectService('Traffic Incident Report'),
                                    isSelected: controller.selectedService.value == 'Traffic Incident Report',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildServiceCard(
                                    title: 'Incident Report',
                                    description: 'Ensuring accountability through proper incident documentation.',
                                    image: Assets.images.incident.path,
                                    onTap: () => controller.selectService('Incident Report'),
                                    isSelected: controller.selectedService.value == 'Incident Report',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right column - Detail card and action cards
                          Flexible(
                            flex: 1,
                            child: Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: _buildDetailCard(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Fill out Form and Call for Assistance cards side by side
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildActionCard(
                                        title: 'Fill out Form',
                                        description: 'Official platform for monitoring and managing traffic incidents.',
                                        image: Assets.images.fill.path,
                                        onTap: () {
                                          Get.toNamed(Routes.FORM_CLASS);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildActionCard(
                                        title: 'Call for Assistance',
                                        description: 'Ensuring accountability through proper incident documentation.',
                                        image: Assets.images.callA.path,
                                        onTap: () {
                                          Get.toNamed(Routes.CALL_CLASS);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
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

  Widget _buildServiceCard({
    required String title,
    required String description,
    required String image,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0xFF1976D2).withOpacity(0.2) : const Color(0x1A000000),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F3FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    image,
                    width: 90,
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF0F3955)),
                    onPressed: onTap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF0A5B95),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFF4F6B7E),
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    final serviceTitle = controller.selectedService.value;
    
    return Container(
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and subtitle
          Text(
            '$serviceTitle Registration',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF0F3955),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Service List of planning and managing that promote a company\'s brand.',
            style: TextStyle(
              color: Color(0xFF4F6B7E),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          // Read me button
          SizedBox(
            width: 10.w,
            child: ElevatedButton(
              onPressed: () {
                // Handle read me action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Read me',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Requirements section
          Text(
            'Requirements for $serviceTitle Registration form.',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF0F3955),
            ),
          ),
          const SizedBox(height: 16),
          // Requirements list
          ...List.generate(4, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Lorem Ipsum is a placeholder text commonly used in the design and publishing industries as a temporary filler.',
                        style: TextStyle(
                          color: Color(0xFF4F6B7E),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required String image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Image.asset(
                  image,
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF0F3955)),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 6),
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
    );
  }
}

