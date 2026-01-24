import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart' hide ChatMessage;
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/app/utils/enums.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';

import '../controllers/call_class_controller.dart';
import 'package:sps_eth_app/app/common/widgets/pulsing_logo_loader.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';

/// Helper class for safe navigation
class _NavigationHelper {
  /// Safely navigate back by going directly to home route
  /// This avoids Get.back() which tries to close snackbars
  static void safeNavigateBack() {
    try {
      // Use offAllNamed to navigate directly to home without going through back stack
      // This avoids the snackbar cleanup issue in Get.back()
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      print('⚠️ [NAVIGATION] Error navigating to home: $e');
      // Last resort: try using Navigator directly
      try {
        final context = Get.context;
        if (context != null) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.HOME,
            (route) => false,
          );
        }
      } catch (e2) {
        print('❌ [NAVIGATION] All navigation methods failed: $e2');
      }
    }
  }
}

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
            _NavigationHelper.safeNavigateBack();
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
                                                  ? 'Waiting for participant...'.tr 
                                                  : 'Not connected'.tr),
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
                                    _NavigationHelper.safeNavigateBack();
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
                                          _NavigationHelper.safeNavigateBack();
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
                                        _NavigationHelper.safeNavigateBack();
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
                                    Obx(() {
                                      final isEnding = controller.isEndingCall.value;
                                      return GestureDetector(
                                        onTap: isEnding ? null : () => controller.endCall(),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            _roundCtrl(
                                              Icons.call_end, 
                                              color: isEnding 
                                                  ? AppColors.grayDark 
                                                  : AppColors.danger,
                                            ),
                                            if (isEnding)
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    AppColors.danger,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }),
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
                                    // Show camera selector only if multiple cameras are available
                                    Obx(() {
                                      if (controller.hasMultipleCameras.value) {
                                        return Row(
                                          children: [
                                            const SizedBox(width: 12),
                                            GestureDetector(
                                              onTap: () => controller.switchCamera(),
                                              child: _roundCtrl(
                                                Icons.cameraswitch,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    }),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar
                      _buildProgressBar(),
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
                            // Show Fayda user data if available
                            Obx(() {
                              final faydaData = controller.faydaData.value;
                              if (faydaData.isNotEmpty) {
                                final rows = <InfoRow>[];
                                if (faydaData['name'] != null) {
                                  rows.add(InfoRow('Name', faydaData['name'].toString()));
                                }
                                if (faydaData['individualId'] != null) {
                                  rows.add(InfoRow('FAN/FIN Number', faydaData['individualId'].toString()));
                                }
                                if (faydaData['dateOfBirth'] != null) {
                                  rows.add(InfoRow('Date of Birth', faydaData['dateOfBirth'].toString()));
                                }
                                if (faydaData['gender'] != null) {
                                  rows.add(InfoRow('Gender', faydaData['gender'].toString()));
                                }
                                if (faydaData['nationality'] != null) {
                                  rows.add(InfoRow('Nationality', faydaData['nationality'].toString()));
                                }
                                if (faydaData['phoneNumber'] != null) {
                                  rows.add(InfoRow('Phone Number', faydaData['phoneNumber'].toString()));
                                }
                                if (faydaData['status'] != null) {
                                  rows.add(InfoRow('Status', faydaData['status'].toString()));
                                }
                                
                                if (rows.isNotEmpty) {
                                  return _InfoCard(
                                    title: 'User Information',
                                    rows: rows,
                                  );
                                }
                              }
                              return const SizedBox.shrink();
                            }),
                            const SizedBox(height: 12),
                            Obx(() {
                              if (controller.idInformation.isEmpty) {
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
                                      Text(
                                        'Report Info',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No information available yet',
                                        style: TextStyle(
                                          color: AppColors.grayDark,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              return _InfoCard(
                                title: 'Report Info',
                                rows: controller.idInformation.toList(),
                              );
                            }),
                            const SizedBox(height: 12),
                         
                            Obx(() {
                              if (controller.supportingDocuments.isEmpty) {
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
                                      Text(
                                        'Supporting Document',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No documents available',
                                        style: TextStyle(
                                          color: AppColors.grayDark,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              return _DocumentsCard(
                                documents: controller.supportingDocuments.toList(),
                              );
                            }),
                            const SizedBox(height: 12),
                            // Statement Details View - Show during active calls
                            Obx(() {
                              final isCallActive = controller.callStatus.value == 'active' || 
                                                   controller.callStatus.value == 'connecting';
                              if (!isCallActive) {
                                return const SizedBox.shrink();
                              }
                              return _StatementDetailsView(controller: controller);
                            }),
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
                          PulsingLogoLoader(
                            logoPath: Assets.images.efpLogo.path,
                            logoSize: 160.0,
                            waveColor: AppColors.primary,
                            logoBackgroundColor: AppColors.whiteOff,
                            logoBorderColor: AppColors.primary,
                            waveCount: 3,
                            baseRadius: 100.0,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Authenticating...'.tr,
                            style: TextStyle(
                              color: AppColors.whiteOff,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please wait while we set up your connection'.tr,
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
            // Full-page loading overlay - shown during call connecting/pending
            Obx(() {
              final callStatus = controller.callStatus.value;
              final isConnecting = callStatus == 'connecting' || callStatus == 'pending';
              
              if (!isConnecting) {
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
                          PulsingLogoLoader(
                            logoPath: Assets.images.efpLogo.path,
                            logoSize: 160.0,
                            waveColor: AppColors.primary,
                            logoBackgroundColor: AppColors.whiteOff,
                            logoBorderColor: AppColors.primary,
                            waveCount: 3,
                            baseRadius: 100.0,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            callStatus == 'connecting' ? 'Connecting...'.tr : 'Waiting for agent...'.tr,
                            style: TextStyle(
                              color: AppColors.whiteOff,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please wait while we connect your call'.tr,
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
            // Offline indicator - shown at the top when offline
            Obx(() {
              final isOnline = controller.connectivityUtil.isOnline.value;
              if (isOnline) {
                return const SizedBox.shrink();
              }
              
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: AppColors.danger,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          color: AppColors.whiteOff,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No Internet Connection'.tr,
                          style: TextStyle(
                            color: AppColors.whiteOff,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildProgressBar() {
    return Obx(() {
      final currentStep = controller.currentProgressStep.value;
      final isConnecting = controller.isConnectingToOfficer.value;
      final isReportInit = controller.isReportInitiated.value;
      final isUploading = controller.isAttachmentUploading.value;

      return Container(
        padding: const EdgeInsets.all(20),
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
            // Title
            Text(
              'Call Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontFamily: 'DMSans',
              ),
            ),
            const SizedBox(height: 20),
            // Progress Steps
            Row(
              children: [
                // Step 1: Connect to Police Officer
                Expanded(
                  child: _buildProgressStep(
                    stepNumber: 1,
                    title: 'Connect to\nPolice Officer',
                    isActive: currentStep >= 1,
                    isCurrent: currentStep == 1,
                    isLoading: isConnecting && currentStep == 1,
                  ),
                ),
                // Connector Line
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: currentStep >= 2 
                          ? AppColors.success 
                          : AppColors.grayLighter,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Step 2: Report Initiated
                Expanded(
                  child: _buildProgressStep(
                    stepNumber: 2,
                    title: 'Report\nInitiated',
                    isActive: currentStep >= 2,
                    isCurrent: currentStep == 2,
                    isLoading: isReportInit && currentStep == 2,
                  ),
                ),
                // Connector Line
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: currentStep >= 3 
                          ? AppColors.success 
                          : AppColors.grayLighter,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Step 3: Attachment Upload
                Expanded(
                  child: _buildProgressStep(
                    stepNumber: 3,
                    title: 'Attachment\nUpload',
                    isActive: currentStep >= 3,
                    isCurrent: currentStep == 3,
                    isLoading: isUploading && currentStep == 3,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProgressStep({
    required int stepNumber,
    required String title,
    required bool isActive,
    required bool isCurrent,
    required bool isLoading,
  }) {
    final stepColor = isActive ? AppColors.success : AppColors.grayLighter;
    final textColor = isActive ? AppColors.successDark : AppColors.grayDefault;
    final bgColor = isActive 
        ? AppColors.successLight 
        : AppColors.whiteOff;

    return Column(
      children: [
        // Step Circle
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: stepColor,
              width: 3,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(stepColor),
                  ),
                )
              else if (isActive)
                Icon(
                  Icons.check,
                  color: stepColor,
                  size: 24,
                )
              else
                Text(
                  '$stepNumber',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'DMSans',
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Step Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            color: textColor,
            fontFamily: 'DMSans',
            height: 1.2,
          ),
        ),
      ],
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
              Text('Terms and Condition'.tr,style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary), ),
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
                      'Connection Error'.tr,
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to connect. Please try again later.'.tr,
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
                        _NavigationHelper.safeNavigateBack();
                      },
                      child: Text(
                        'Close'.tr,
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
            
            // Show loading if auto-starting without error AND call is not yet active
            if (isAutoStarting && !isCallActive) {
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
                        'Connecting...'.tr,
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
            
            if (callStatus == 'ended') {
              // Show "Go Back" button when call is ended
              print('🔘 [BUTTONS] Showing Go Back button (call ended)');
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(double.infinity, 0),
                ),
                onPressed: () async {
                  print('🔘 [BUTTONS] Go Back button pressed (call ended)');
                  await controller.onWillPop();
                  _NavigationHelper.safeNavigateBack();
                },
                child: Text(
                  'Go Back to Home'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteOff,
                  ),
                ),
              );
            }
            
            // No buttons shown when call is not active (user already used slide button to get here)
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

/// Widget to display statement details from call details
class _StatementDetailsView extends StatelessWidget {
  const _StatementDetailsView({required this.controller});

  final CallClassController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final statement = controller.statementInfo.value;
      final report = controller.reportInfo.value;
      
      // Show message if no statement yet
      if (statement == null && report == null) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grayLight, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined,
                color: AppColors.grayDefault,
                size: 24,
              ),
              const SizedBox(height: 12),
              Text(
                'Report and statement will appear here once created',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grayDark,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      
      return Container(
        decoration: BoxDecoration(
          color: AppColors.whiteOff,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grayLight, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.description, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (report?.reportType != null) ...[
                          Text(
                            report!.reportType!.name ?? 'Report',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          if (report.reportType!.nameAmharic != null && report.reportType!.nameAmharic!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              report.reportType!.nameAmharic!,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grayDark,
                              ),
                            ),
                          ],
                        ] else
                          Text(
                            'Statement Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        if (report?.caseNumber != null && report!.caseNumber!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Case: ${report.caseNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grayDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Person Information
                  if (statement?.person != null) ...[
                    Text(
                      'Person Information',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Full Name', statement!.person!.fullName ?? 'N/A'),
                    if (statement.person!.age != null)
                      _buildInfoRow('Age', '${statement.person!.age}'),
                    if (statement.person!.sex != null)
                      _buildInfoRow('Gender', statement.person!.sex!),
                    if (statement.person!.phoneMobile != null && statement.person!.phoneMobile!.isNotEmpty)
                      _buildInfoRow('Phone', statement.person!.phoneMobile!),
                    if (statement.person!.nationality != null && statement.person!.nationality!.isNotEmpty)
                      _buildInfoRow('Nationality', statement.person!.nationality!),
                    const SizedBox(height: 16),
                  ],
                  
                  // Statement Details
                  if (statement?.statement != null && statement!.statement!.isNotEmpty) ...[
                    Text(
                      'Statement',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.grayLight, width: 1),
                      ),
                      child: Text(
                        statement.statement!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.black,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Statement Metadata
                  if (statement != null) ...[
                    Text(
                      'Statement Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (statement.statementTakerName != null && statement.statementTakerName!.isNotEmpty)
                      _buildInfoRow('Statement Taker', statement.statementTakerName!),
                    if (statement.applicantType != null)
                      _buildInfoRow('Applicant Type', statement.applicantType!),
                    if (statement.statementDate != null)
                      _buildInfoRow('Statement Date', '${statement.statementDate!.day}/${statement.statementDate!.month}/${statement.statementDate!.year}'),
                    if (statement.statementTime != null && statement.statementTime!.isNotEmpty)
                      _buildInfoRow('Statement Time', statement.statementTime!),
                    if (statement.status != null)
                      _buildInfoRow('Status', statement.status!),
                  ],
                  
                  // Report Submission Status (no buttons, just show status)
                  if (report?.submitted == true) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Report Submitted',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.successDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grayDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

