import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/app/theme/app_text_styles.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:sps_eth_app/app/common/widgets/side_info_panel.dart';

import '../controllers/call_class_controller.dart';

class CallClassView extends GetView<CallClassController> {
  const CallClassView({super.key});
  @override
  Widget build(BuildContext context) {
    final double viewportHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical - 32;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Left info/illustration panel (match FiilingClassView sizing)
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
              // Middle video + actions
              Flexible(
                flex: 6,
                fit: FlexFit.loose,
                child: Column(
                  children: [
                    // Video area
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteOff,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: AppColors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.asset(
                              Assets.images.person.path,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // PIP
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 140,
                                height: 100,
                                color: AppColors.backgroundLight,
                                child: Image.asset(
                                  Assets.images.person2.path,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // Controls
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _roundCtrl(Icons.home),
                                const SizedBox(width: 12),
                                _roundCtrl(Icons.message),
                                const SizedBox(width: 12),
                                _roundCtrl(Icons.call_end, color: AppColors.danger),
                                const SizedBox(width: 12),
                                _roundCtrl(Icons.videocam),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Action tiles
                    Row(
                      children: const [
                        Expanded(child: _ActionTile(icon: Icons.document_scanner, label: 'Scan Document')),
                        SizedBox(width: 16),
                        Expanded(child: _ActionTile(icon: Icons.person, label: 'Take Photo')),
                        SizedBox(width: 16),
                        Expanded(child: _ActionTile(icon: Icons.usb, label: 'Flash  Documents')),
                        SizedBox(width: 16),
                        Expanded(child: _ActionTile(icon: Icons.receipt_long, label: 'Payment Receipt')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Inputs
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteOff,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: AppColors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 44,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text('Time of Discussion',),
                                ),
                                const SizedBox(width: 12),
                                Text('01:23:45',style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary), ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 100,
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Send Message Details', ),
                          ),
                           const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  side: BorderSide(color: AppColors.grayLighter),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {},
                                icon: Icon(Icons.cleaning_services, color: AppColors.grayDark),
                                label: Text('Clear Text', ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {},
                                icon: Icon(Icons.send, color: AppColors.whiteOff),
                                label: Text('Send Text', style: TextStyle(color: AppColors.whiteOff)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right info sidebar
              Flexible(
                flex: 4,
                fit: FlexFit.loose,
                child: Column(
                  children: [
                    _InfoCard(
                      title: 'ID Information',
                      rows: const [
                        ['Name  Information', 'Abeba Shimeles Adera'],
                        ['Birth Date', 'Aug 12 , 2024'],
                        ['Email', 'abeba@gmail.com'],
                        ['Phone Number', '0913427553'],
                        ['Residence Address', '–'],
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      title: 'Incident Information',
                      rows: const [
                        ['Type', 'Type 1'],
                        ['Category', 'Economic'],
                        ['Status', 'Begin'],
                        ['Address', 'Addis Ababa'],
                      ],
                    ),
                    const SizedBox(height: 8),
                    _DocumentsCard(),
                    const SizedBox(height: 8),
                    _TermsAndActions(),
                  ],
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _roundCtrl(IconData icon, {Color? color}) {
  return Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: (color ?? AppColors.primary).withOpacity(0.1),
      shape: BoxShape.circle,
      border: Border.all(color: color ?? AppColors.whiteOff, width: 2),
    ),
    child: Icon(icon, color: color ?? AppColors.white70),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionTile({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteOff,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: AppColors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary), ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<List<String>> rows;
  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteOff,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary), ),
          const SizedBox(height: 12),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(r.first, )),
                    Text(r.last, ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _DocumentsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteOff,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Supporting Document',style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary), ),
          const SizedBox(height: 12),
          ...[
            'Incident Document',
            'Application',
            'Others',
          ].map((label) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(label, )),
                    Row(children: [
                      _docChip(),
                      const SizedBox(width: 6),
                      
                    ])
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _docChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('Doc name.pdf', ),
    );
  }
}

class _TermsAndActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteOff,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_box, color: AppColors.grayDark),
              const SizedBox(width: 8),
              Text('Terms and Condition',style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary), ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'These are the terms and conditions for Loreim re in charge of planning and managing marketing campaigns that promote a company\'s brand.',
            style: TextStyle(color: AppColors.grayDark),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {},
                  child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.whiteOff), ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {},
                  child: Text('Confirm / Agree', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.whiteOff), ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
