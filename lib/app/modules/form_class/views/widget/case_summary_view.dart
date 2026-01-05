import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:sps_eth_app/app/common/widgets/side_info_panel.dart';
import 'confirmation_page_view.dart';

class CaseSummaryView extends StatelessWidget {
  final Map<String, String> formData;

  const CaseSummaryView({super.key, required this.formData});

  static void show(BuildContext context, Map<String, String> formData) {
    Get.to(() => CaseSummaryView(formData: formData));
  }

  @override
  Widget build(BuildContext context) {
    final double viewportHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.vertical - 32;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT PANEL - Branding with Current Case Status
              Flexible(
                flex: 3,
                fit: FlexFit.loose,
                child: SizedBox(
                  height: viewportHeight,
                  child: Stack(
                    children: [
                      SideInfoPanel(
                        title: 'SMART POLICE\nSTATION',
                        description:
                            'A technology-driven, modern police service outlet where users can serve themselves without human intervention. Designed to make police services more accessible, efficient, and convenient for the community.',
                        logoAsset: Assets.images.efpLogo.path,
                        illustrationAsset: Assets.images.law.path,
                      ),
                      // Current Case Status Banner
                  
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // MAIN CONTENT AREA
              Flexible(
                flex: 7,
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT COLUMN - Wider for ID and Incident Information
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildIdInformationCard(),
                            const SizedBox(height: 16),
                            _buildIncidentInformationCard(),
                            const SizedBox(height: 16),
                            _buildFootagesCard(),
                            const SizedBox(height: 16),
                            _buildSupportingDocumentCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // RIGHT COLUMN - Narrower
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTermsAndConditionCard(),
                            const SizedBox(height: 16),
                            _buildCaseTrackingCard(),
                            const SizedBox(height: 16),
                            _buildActivitiesCard(),
                          ],
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
    );
  }

  Widget _buildTermsAndConditionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6F3FB), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terms and Condition',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F3955),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: false,
                onChanged: (value) {},
                activeColor: const Color(0xFF1976D2),
              ),
              Expanded(
                child: Text(
                  'A technology-driven, modern police service outlet where users can serve themselves without human intervention. Designed to make police services more accessible, efficient, and convenient for the community.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4F6B7E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  // Navigate to confirmation page
                  ConfirmationPageView.show(Get.context!, formData);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Confirm / Agree'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdInformationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ID Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F3955),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('ID Information', formData['id'] ?? '1231235163'),
          _buildInfoRow('Name Information', formData['name'] ?? 'Abeba Shimeles Adera'),
          _buildInfoRow('Birth Date', formData['birthDate'] ?? 'Aug 12, 2024'),
          _buildInfoRow('Email', formData['email'] ?? 'abeba@gmail.com'),
          _buildInfoRow('Phone Number', formData['phoneNumber'] ?? '0913427553'),
          _buildInfoRow('Residence Address', formData['address'] ?? '-'),
        ],
      ),
    );
  }

  Widget _buildIncidentInformationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Incident Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F3955),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Type', formData['incidentType'] ?? 'Type 1'),
          _buildInfoRow('Category', formData['category'] ?? 'Economic'),
          _buildInfoRow('Status', formData['status'] ?? 'Begin'),
          _buildInfoRow('Address', formData['address'] ?? 'Addis Ababa'),
        ],
      ),
    );
  }

  Widget _buildCaseTrackingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Case Tracking',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F3955),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Report Number', '123154125'),
          _buildInfoRow('Submit Time', '22 Oct, 2023'),
          _buildInfoRow('Waiting time', ''),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: const Text(
                  'Current Status',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4F6B7E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Referred',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: const Text(
                  'Assignee',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4F6B7E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Spacer(),
              Row(
                children: [
                            
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Belete Alem',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F3955),
                        ),
                      ),
                      Text(
                        'Updated By',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4F6B7E),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8),
                        CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF1976D2),
                    child: const Text(
                      'BA',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFootagesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Footages',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F3955),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: index == 4
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              color: Colors.grey[300],
                            ),
                            const Icon(
                              Icons.play_circle_filled,
                              size: 40,
                              color: Colors.white,
                            ),
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportingDocumentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supporting Document',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F3955),
            ),
          ),
          const SizedBox(height: 16),
          _buildDocumentItem('Clearance Doc', '254kb'),
          const SizedBox(height: 12),
          _buildDocumentItem('Clearance Doc', '254kb'),
          const SizedBox(height: 12),
          _buildDocumentItem('Clearance Doc', '254kb'),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String name, String size) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'PDF',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F3955),
                ),
              ),
              Text(
                size,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4F6B7E),
                ),
              ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text(
            'View',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F3955),
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityItem('Report Updated', '12 mins Ago', '23/12/2024'),
          const SizedBox(height: 12),
          _buildActivityItem('Report Updated', '24 mins Ago', '23/12/2024'),
          const SizedBox(height: 12),
          _buildActivityItem('Report Updated', '1hr Ago', '23/12/2024'),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, String date) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.amber[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.description,
            size: 18,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F3955),
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4F6B7E),
                ),
              ),
              Text(
                'Date: $date',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF4F6B7E),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFF1976D2),
              child: const Text(
                'BA',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belete Alem',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F3955),
                  ),
                ),
                Text(
                  'Updated By',
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF4F6B7E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4F6B7E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Spacer(),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF0F3955),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

