import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart' hide ChatMessage;
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/app/utils/enums.dart';

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
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (!didPop) {
            // Clear tokens and navigate back
            await controller.onWillPop();
            Get.back();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Stack(
          children: [
            // Main content - always visible
            SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Middle video + actions
                Flexible(
                  flex: 8,
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
                            // Back button
                            Positioned(
                              top: 16,
                              left: 16,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  tooltip: 'Back',
                                  onPressed: () async {
                                    await controller.onWillPop();
                                    Get.back();
                                  },
                                ),
                              ),
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
                            // Start Call buttons - Show when call is not active and NOT auto-starting
                            // OR show close button when auto-starting but there's an error
                            Obx(() {
                              final callStatus = controller.callStatus.value;
                              final isCallActive = callStatus == 'active' || callStatus == 'connecting' || callStatus == 'pending';
                              final isAutoStarting = controller.autoStartCall.value;
                              final hasError = controller.callNetworkStatus.value == NetworkStatus.ERROR;
                              
                              // Show close button if auto-starting and there's an error
                              if (isAutoStarting && hasError && !isCallActive) {
                                return Positioned(
                                  bottom: 10,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          print('🔘 [BUTTONS] Close button pressed (error state)');
                                          await controller.onWillPop();
                                          Get.back();
                                        },
                                        child: _roundCtrl(Icons.close, color: AppColors.danger),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              // Hide buttons if call is active or if auto-starting (without error)
                              if (isCallActive || (isAutoStarting && !hasError)) return const SizedBox.shrink();
                              
                              return Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        print('🔘 [BUTTONS] Cancel button pressed');
                                        await controller.onWillPop();
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
            // Blurred loading overlay - shown during anonymous login
            Obx(() {
              if (!controller.isAnonymousLoginLoading.value) {
                return const SizedBox.shrink();
              }
              
              return Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: AppColors.black.withOpacity(0.3),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Authenticating...',
                            style: TextStyle(
                              color: AppColors.whiteOff,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please wait while we set up your connection',
                            style: TextStyle(
                              color: AppColors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
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
            final isAutoStarting = controller.autoStartCall.value;
            print('🔘 [BUTTONS] Current call status: $callStatus');
            print('🔘 [BUTTONS] Auto-starting: $isAutoStarting');
            final isCallActive = callStatus == 'active' || callStatus == 'connecting' || callStatus == 'pending';
            print('🔘 [BUTTONS] Is call active: $isCallActive');
            
            // Show error message with close button if auto-starting and there's an error
            if (isAutoStarting && controller.callNetworkStatus.value == NetworkStatus.ERROR) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.danger,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Connection Error',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to connect. Please try again later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.grayDark,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        print('🔘 [BUTTONS] Close button pressed (error in terms card)');
                        await controller.onWillPop();
                        Get.back();
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: AppColors.whiteOff,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            // Show loading if auto-starting without error
            if (isAutoStarting) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 12),
                      Text(
                        'Connecting...',
                        style: TextStyle(
                          color: AppColors.grayDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            if (isCallActive) {
              // Show end call button when call is active
              print('🔘 [BUTTONS] Showing End Call button');
              return Obx(() {
                final isEnding = controller.isEndingCall.value;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  onPressed: isEnding ? null : () {
                    print('🔘 [BUTTONS] End Call button pressed');
                    controller.endCall();
                  },
                  child: isEnding
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteOff),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ending call...',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.whiteOff),
                            ),
                          ],
                        )
                      : Text(
                          callStatus == 'connecting' 
                              ? 'Connecting...' 
                              : callStatus == 'pending'
                                  ? 'Waiting for agent...'
                                  : 'End Call',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.whiteOff),
                        ),
                );
              });
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
                              onPressed: () async {
                                print('🔘 [BUTTONS] Cancel button pressed');
                                await controller.onWillPop();
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
                    child: Obx(() {
                      final isLoading = controller.callNetworkStatus.value == NetworkStatus.LOADING;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 4,
                        ),
                        onPressed: isLoading ? null : () {
                          print('🔘 [BUTTONS] Confirm / Agree button pressed');
                          controller.confirmTerms();
                        },
                        child: isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteOff),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Connecting...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      color: AppColors.whiteOff,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Confirm / Agree', 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  color: AppColors.whiteOff,
                                  fontSize: 16,
                                ),
                              ),
                      );
                    }),
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
