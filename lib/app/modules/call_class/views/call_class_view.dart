import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart' hide ChatMessage;
import 'package:sps_eth_app/app/common/widgets/side_info_panel.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';

import '../controllers/call_class_controller.dart';

class CallClassView extends GetView<CallClassController> {
  const CallClassView({super.key});
  @override
  Widget build(BuildContext context) {
    // Only hide keyboard when this view is actually visible and user taps outside
    // Don't hide on every build as it interferes with other screens

    final double viewportHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical - 32;
    return GestureDetector(
      onTap: () {
        // Hide keyboard when tapping outside (only when this view is active)
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Chat Panel
                // Flexible(
                //   flex: 4,
                //   fit: FlexFit.loose,
                //   child: SizedBox(
                //     height: viewportHeight,
                //     child: _ChatWidget(),
                //   ),
                // ),
                    Flexible(
                flex: 4,
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
                            // Main video (remote participant or placeholder)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Obx(() {
                                final remoteParticipants = controller.remoteParticipants;
                                if (remoteParticipants.isNotEmpty) {
                                  final remoteVideoTrack = controller.getRemoteVideoTrack(remoteParticipants.first);
                                  if (remoteVideoTrack != null) {
                                    return VideoTrackRenderer(
                                      remoteVideoTrack,
                                    );
                                  }
                                }
                                // Placeholder when no remote video
                                return Container(
                                  color: AppColors.black,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.videocam_off, size: 48, color: AppColors.white70),
                                        const SizedBox(height: 8),
                                        Obx(() => Text(
                                          controller.connectionStatus.value.isNotEmpty
                                              ? controller.connectionStatus.value
                                              : (controller.isConnected.value 
                                                  ? 'Waiting for participant...' 
                                                  : 'Not connected'),
                                          style: TextStyle(color: AppColors.white70),
                                        )),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                            // PIP (local video)
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Obx(() {
                                  final localVideoTrack = controller.localVideoTrack.value;
                                  if (localVideoTrack != null && controller.isVideoEnabled.value) {
                                    return Container(
                                      width: 140,
                                      height: 100,
                                      color: AppColors.black,
                                      child: VideoTrackRenderer(
                                        localVideoTrack,
                                      ),
                                    );
                                  }
                                  // Placeholder when local video is off
                                  return Container(
                                    width: 140,
                                    height: 100,
                                    color: AppColors.backgroundLight,
                                    child: Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 40,
                                        color: AppColors.grayDark,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            // Start Call buttons - Show when call is not active
                            Obx(() {
                              final callStatus = controller.callStatus.value;
                              final isCallActive = callStatus == 'active' || callStatus == 'connecting' || callStatus == 'pending';
                              
                              if (isCallActive) return const SizedBox.shrink();
                              
                              return Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        print('🔘 [BUTTONS] Cancel button pressed');
                                        Get.back();
                                      },
                                      child: _roundCtrl(Icons.close, color: AppColors.danger),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () {
                                        print('🔘 [BUTTONS] Confirm / Agree button pressed');
                                        controller.confirmTerms();
                                      },
                                      child: _roundCtrl(Icons.check, color: AppColors.success),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            // Call controls - Only show when call is active
                            Obx(() {
                              final isCallActive = controller.callStatus.value == 'active' || 
                                                   controller.callStatus.value == 'connecting';
                              if (!isCallActive) return const SizedBox.shrink();
                              
                              return Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // GestureDetector(
                                    //   onTap: () => Get.back(),
                                    //   child: _roundCtrl(Icons.home),
                                    // ),
                                    // const SizedBox(width: 12),
                                    // GestureDetector(
                                    //   onTap: () {
                                    //     // Scroll to bottom of chat or focus on message input
                                    //     // This can be enhanced with a scroll controller if needed
                                    //     FocusScope.of(context).requestFocus(controller.focusedField);
                                    //   },
                                    //   child: _roundCtrl(Icons.message),
                                    // ),
                                    // const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () => controller.endCall(),
                                      child: _roundCtrl(Icons.call_end, color: AppColors.danger),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () => controller.toggleVideo(),
                                      child: _roundCtrl(
                                        controller.isVideoEnabled.value 
                                            ? Icons.videocam 
                                            : Icons.videocam_off,
                                        color: controller.isVideoEnabled.value 
                                            ? null 
                                            : AppColors.grayDark,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () => controller.toggleAudio(),
                                      child: _roundCtrl(
                                        controller.isAudioEnabled.value 
                                            ? Icons.mic 
                                            : Icons.mic_off,
                                        color: controller.isAudioEnabled.value 
                                            ? null 
                                            : AppColors.grayDark,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () => controller.switchCamera(),
                                      child: _roundCtrl(Icons.flip_camera_ios),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Action tiles
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              final tiles = controller.actionTiles;
                              return Row(
                                children: [
                                  for (var i = 0; i < tiles.length; i++) ...[
                                    Expanded(
                                      child: _ActionTile(
                                        config: tiles[i],
                                      ),
                                    ),
                                    if (i != tiles.length - 1)
                                      const SizedBox(width: 16),
                                  ],
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Keyboard Section
                      Expanded(
                        child: _buildCustomKeyboard(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right info sidebar
                Flexible(
                  flex: 4,
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Obx(() {
                              return _InfoCard(
                                title: 'ID Information',
                                rows: controller.idInformation.toList(),
                              );
                            }),
                            const SizedBox(height: 12),
                         
                            Obx(() => _DocumentsCard(
                                  documents: controller.supportingDocuments.toList(),
                                )),
                            const SizedBox(height: 8),
                            _TermsAndActions(controller: controller),
                            const Spacer(), // Push buttons to top if needed
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomKeyboard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.whiteOff,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _VirtualKeyboard(
              onKeyPressed: (key) => controller.onKeyboardKeyPressed(key),
            ),
          ),
        ],
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
  const _ActionTile({required this.config});

  final ActionTileConfig config;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => config.onPressed(context),
      child: Container(
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
              child: Icon(config.icon, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              config.label,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<InfoRow> rows;
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
                    Expanded(child: Text(r.label, )),
                    Text(r.value, ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard({required this.documents});

  final List<DocumentItem> documents;

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
          ...documents.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(item.label, )),
                    Row(children: [
                      _docChip(item.fileName),
                      const SizedBox(width: 6),
                      
                    ])
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _docChip(String fileName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(fileName, ),
    );
  }
}

class _TermsAndActions extends StatelessWidget {
  const _TermsAndActions({required this.controller});

  final CallClassController controller;

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
          Obx(() {
            return Text(
              controller.termsAndConditions.value,
              style: TextStyle(color: AppColors.grayDark),
            );
          }),
          const SizedBox(height: 8),
          Obx(() {
            final callStatus = controller.callStatus.value;
            print('🔘 [BUTTONS] Current call status: $callStatus');
            final isCallActive = callStatus == 'active' || callStatus == 'connecting' || callStatus == 'pending';
            print('🔘 [BUTTONS] Is call active: $isCallActive');
            
            if (isCallActive) {
              // Show end call button when call is active
              print('🔘 [BUTTONS] Showing End Call button');
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(double.infinity, 0),
                ),
                onPressed: () {
                  print('🔘 [BUTTONS] End Call button pressed');
                  controller.endCall();
                },
                child: Text(
                  callStatus == 'connecting' 
                      ? 'Connecting...' 
                      : callStatus == 'pending'
                          ? 'Waiting for agent...'
                          : 'End Call',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.whiteOff),
                ),
              );
            } else {
              // Show start call buttons when call is not active
              print('🔘 [BUTTONS] Showing Start Call buttons');
              return Container(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Make buttons more visible with a border
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.danger,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 4,
                              ),
                              onPressed: () {
                                print('🔘 [BUTTONS] Cancel button pressed');
                                Get.back();
                              },
                              child: Text(
                                'Cancel', 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  color: AppColors.whiteOff,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        print('🔘 [BUTTONS] Confirm / Agree button pressed');
                        controller.confirmTerms();
                      },
                      child: Text(
                        'Confirm / Agree', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: AppColors.whiteOff,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Status indicator
                    Obx(() => Text(
                      'Status: ${controller.connectionStatus.value.isEmpty ? "Ready to call" : controller.connectionStatus.value}',
                      style: TextStyle(
                        color: AppColors.grayDark,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    )),
                  ],
                ),
              );
            }
          }),
        ],
      ),
    );
  }
}

// Chat Widget
class _ChatWidget extends GetView<CallClassController> {
  const _ChatWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteOff,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Image.asset(
                  Assets.images.efpLogo.path,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                const Text(
                  'SMART POLICE STATION',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0F3955),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Discussion Date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                const Text(
                  'Discussion Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4F6B7E),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  return Text(
                    controller.discussionDate.value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),
          // Chat Messages
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.messages.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                return _ChatMessageBubble(message: message);
              },
            )),
          ),
          // Input Area
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              border: Border(
                top: BorderSide(color: AppColors.grayLighter, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.whiteOff,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: controller.messageController,
                      focusNode: controller.focusedField,
                      readOnly: true,
                      enableInteractiveSelection: true,
                      showCursor: true,
                      keyboardType: TextInputType.none,
                      onTap: () {
                        // Hide system keyboard immediately
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        FocusScope.of(Get.context!).unfocus();
                        controller.setFocusedField(controller.focusedField, controller.messageController);
                      },
                      onSubmitted: (_) => controller.sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Send Message Details',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4F6B7E),
                        ),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => controller.sendMessage(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3955),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isFromOP = message.isFromOP;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isFromOP ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isFromOP) ...[
            // Avatar for OP
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF0F3955),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'OP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.25,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isFromOP ? Colors.grey[300] : const Color(0xFF0F3955),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 12,
                      color: isFromOP ? Colors.black87 : Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.time,
                    style: TextStyle(
                      fontSize: 10,
                      color: isFromOP ? Colors.grey[600] : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isFromOP) ...[
            const SizedBox(width: 8),
            // Avatar for other party
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 18,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Virtual Keyboard
class _VirtualKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;

  const _VirtualKeyboard({required this.onKeyPressed});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // First row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rows[0].map((key) => _buildKey(key)).toList(),
          ),
          const SizedBox(height: 4),
          // Second row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              ...rows[1].map((key) => _buildKey(key)),
            ],
          ),
          const SizedBox(height: 4),
          // Third row with special keys
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSpecialKey('123?', () => onKeyPressed('123')),
              ...rows[2].map((key) => _buildKey(key)),
              _buildSpecialKey('⌫', () => onKeyPressed('backspace')),
            ],
          ),
          const SizedBox(height: 4),
          // Bottom row with space and enter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSpecialKey('←', () => onKeyPressed('left'), width: 60),
              _buildSpecialKey('Space', () => onKeyPressed('space'), width: 200),
              _buildSpecialKey('→', () => onKeyPressed('right'), width: 60),
              _buildSpecialKey('↵', () => onKeyPressed('enter'), width: 80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    return GestureDetector(
      onTap: () => onKeyPressed(key),
      child: Container(
        width: 35,
        height: 35,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            key.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String label, VoidCallback onTap, {double? width}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 60,
        height: 35,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
