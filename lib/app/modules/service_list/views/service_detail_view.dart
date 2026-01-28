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
                    description: 'A technology-driven, modern police service outlet where users can serve themselves without human intervention. Designed to make police services more accessible, efficient, and convenient for the community.',
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
                    // Top info box
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2F0F8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${controller.selectedService.value} Registration',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: Color(0xFF0F3955),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(() => Text(
                                  _getServiceDescription(controller.selectedService.value),
                                  style: const TextStyle(color: Color(0xFF4F6B7E), fontSize: 12),
                                )),
                              ],
                            ),
                          )),
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
                                  Obx(() => _buildServiceCard(
                                    title: 'Crime Report',
                                    description: 'Report crimes promptly and help maintain public safety.',
                                    image: Assets.images.crime.path,
                                    onTap: () => controller.selectService('Crime Report'),
                                    isSelected: controller.selectedService.value == 'Crime Report',
                                  )),
                                  const SizedBox(height: 16),
                                  Obx(() => _buildServiceCard(
                                    title: 'Traffic Incident Report',
                                    description: 'Official platform for monitoring and managing traffic incidents.',
                                    image: Assets.images.traffic.path,
                                    onTap: () => controller.selectService('Traffic Incident Report'),
                                    isSelected: controller.selectedService.value == 'Traffic Incident Report',
                                  )),
                                  const SizedBox(height: 16),
                                  Obx(() => _buildServiceCard(
                                    title: 'Incident Report',
                                    description: 'Ensuring accountability through proper incident documentation.',
                                    image: Assets.images.incident.path,
                                    onTap: () => controller.selectService('Incident Report'),
                                    isSelected: controller.selectedService.value == 'Incident Report',
                                  )),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right column - Detail card and action cards
                          Flexible(
                            flex: 2,
                            child: Obx(() => Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF0F3955).withOpacity(0.2),
                                  width: 1,
                                ),
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
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: _buildDetailCardContent(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Fill out Form and Call for Assistance cards side by side
                                  Row(
                                    children: [
                                      Flexible(
                                        child: _buildActionCard(
                                          title: 'Fill out Form',
                                          description: 'Complete the digital form to submit your report. Provide all required information and supporting documents.',
                                          image: Assets.images.fill.path,
                                          onTap: () {
                                            Get.toNamed(Routes.FORM_CLASS);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Flexible(
                                        child: _buildActionCard(
                                          title: 'Call for Assistance',
                                          description: 'Connect with a police officer via video call for real-time assistance and guidance.',
                                          image: Assets.images.callA.path,
                                          onTap: () {
                                         Get.toNamed(Routes.CALL_CLASS, arguments: {'isVisitor': false});
                                        },
                                      ),
                                    ),
                                  ],
                                  ),
                                ],
                              ),
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
          ],
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
        width: 280,
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F3FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    image,
                    width: 60,
                    height: 60,
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

  Widget _buildDetailCardContent() {
    final serviceTitle = controller.selectedService.value;
    
    return Column(
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
          Text(
            _getServiceDescription(serviceTitle),
            style: const TextStyle(
              color: Color(0xFF4F6B7E),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          // Read me button
          SizedBox(
            width: 10.w,
            height: 5.h,
            child: ElevatedButton(
              onPressed: () {
                // Handle read me action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAA232F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
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
          const SizedBox(height: 8),
          // Requirements section
          Text(
            'Requirements for $serviceTitle Registration form.',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF0F3955),
            ),
          ),
          const SizedBox(height: 8),
          // Requirements list
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: _getServiceRequirements(serviceTitle).asMap().entries.map((entry) {
                final index = entry.key;
                final requirement = entry.value;
                final isLast = index == _getServiceRequirements(serviceTitle).length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              requirement,
                              style: const TextStyle(
                                color: Color(0xFF4F6B7E),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey[400],
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
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
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F3FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    image,
                    width: 60,
                    height: 60,
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

  String _getServiceDescription(String serviceTitle) {
    switch (serviceTitle) {
      case 'Crime Report':
        return 'Report criminal activities, incidents, or suspicious behavior to help maintain public safety and assist law enforcement in their investigations.';
      case 'Traffic Incident Report':
        return 'Report traffic accidents, violations, or road incidents to help improve road safety and traffic management in your area.';
      case 'Incident Report':
        return 'Document any incident, complaint, or event that requires police attention. Ensure proper documentation for official records.';
      default:
        return 'Access police services and submit reports through our digital platform.';
    }
  }

  List<String> _getServiceRequirements(String serviceTitle) {
    switch (serviceTitle) {
      case 'Crime Report':
        return [
          'Valid identification document (ID card, passport, or driver\'s license)',
          'Detailed description of the crime or incident including date, time, and location',
          'Contact information for follow-up communication',
          'Any supporting evidence or documents related to the incident',
        ];
      case 'Traffic Incident Report':
        return [
          'Vehicle registration documents and driver\'s license',
          'Details of the traffic incident including date, time, and exact location',
          'Information about involved parties and vehicles',
          'Photos or evidence of the incident if available',
        ];
      case 'Incident Report':
        return [
          'Personal identification document',
          'Complete description of the incident with all relevant details',
          'Date, time, and location of the incident',
          'Contact information and any witness details if applicable',
        ];
      default:
        return [
          'Valid identification document',
          'Complete information about the incident',
          'Contact details for communication',
          'Supporting documents or evidence',
        ];
    }
  }
}

