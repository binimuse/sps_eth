import 'dart:async';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sps_eth_app/app/modules/form_class/views/widget/scanning_document_view.dart';
import 'package:sps_eth_app/app/modules/call_class/services/livekit_service.dart';
import 'package:sps_eth_app/app/utils/dio_util.dart';
import 'package:sps_eth_app/app/common/app_toasts.dart';

class ChatMessage {
  final String text;
  final bool isFromOP; // true if from OP (Officer/Operator), false if from other party
  final String time;

  ChatMessage({
    required this.text,
    required this.isFromOP,
    required this.time,
  });
}

typedef ActionCallback = void Function(BuildContext context);

class ActionTileConfig {
  const ActionTileConfig({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final ActionCallback onPressed;
}

class InfoRow {
  const InfoRow(this.label, this.value);

  final String label;
  final String value;
}

class DocumentItem {
  const DocumentItem({
    required this.label,
    required this.fileName,
  });

  final String label;
  final String fileName;
}

class CallClassController extends GetxController {
  final messages = <ChatMessage>[].obs;

  final messageController = TextEditingController();

  final selectedLanguage = 'English'.obs;
  final TextEditingController keyboardController = TextEditingController();
  TextEditingController? focusedController;
  FocusNode? focusedField = FocusNode();

  final RxList<ActionTileConfig> actionTiles = <ActionTileConfig>[].obs;
  final RxList<InfoRow> idInformation = <InfoRow>[].obs;
  final RxList<DocumentItem> supportingDocuments = <DocumentItem>[].obs;
  final RxString termsAndConditions =
      'These are the terms and conditions for Loreim re in charge of planning and managing marketing campaigns that promote a company\'s brand.'
          .obs;
  final RxString discussionDate = 'June 12, 2024'.obs;

  // LiveKit related
  Room? _room;
  LocalParticipant? _localParticipant;
  final RxBool isConnected = false.obs;
  final RxBool isVideoEnabled = true.obs;
  final RxBool isAudioEnabled = true.obs;
  final Rx<VideoTrack?> localVideoTrack = Rx<VideoTrack?>(null);
  final RxList<RemoteParticipant> remoteParticipants = <RemoteParticipant>[].obs;
  final RxString connectionStatus = 'Disconnected'.obs;
  String? _roomName;
  String? _participantName;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    // Initialize LiveKit connection when controller is created
    // You can call connectToRoom() when needed, e.g., after user confirms terms
  }

  void _loadInitialData() {
    messages.assignAll([
      ChatMessage(
        text:
            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
        isFromOP: true,
        time: '8:00 PM',
      ),
      ChatMessage(
        text:
            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
        isFromOP: false,
        time: '8:00 PM',
      ),
      ChatMessage(
        text:
            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
        isFromOP: true,
        time: '8:00 PM',
      ),
      ChatMessage(
        text:
            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
        isFromOP: false,
        time: '8:00 PM',
      ),
    ]);

    actionTiles.assignAll([
      ActionTileConfig(
        icon: Icons.document_scanner,
        label: 'Scan Document',
        onPressed: (context) => ScanningDocumentView.show(context),
      ),
      ActionTileConfig(
        icon: Icons.person,
        label: 'Take Photo',
        onPressed: (_) => onTakePhoto(),
      ),
      ActionTileConfig(
        icon: Icons.usb,
        label: 'Flash  Documents',
        onPressed: (_) => onFlashDocuments(),
      ),
      ActionTileConfig(
        icon: Icons.receipt_long,
        label: 'Payment Receipt',
        onPressed: (_) => onPaymentReceipt(),
      ),
    ]);

    idInformation.assignAll(const [
      InfoRow('ID Information', '1231235163'),
      InfoRow('Name  Information', 'Abeba Shimeles Adera'),
      InfoRow('Birth Date', 'Aug 12 , 2024'),
      InfoRow('Email', 'abeba@gmail.com'),
      InfoRow('Phone Number', '0913427553'),
      InfoRow('Residence Address', '–'),
    ]);

    supportingDocuments.assignAll(const [
      DocumentItem(label: 'Incident Document', fileName: 'Doc name.pdf'),
      DocumentItem(label: 'Application', fileName: 'Doc name.pdf'),
      DocumentItem(label: 'Others', fileName: 'Doc name.pdf'),
    ]);
  }

  @override
  void onClose() {
    disconnectFromRoom();
    messageController.dispose();
    keyboardController.dispose();
    focusedField?.dispose();
    super.onClose();
  }

  /// Connect to LiveKit room
  /// Call this method when you're ready to start the video call
  /// roomName and participantName should be provided from your backend or navigation params
  Future<void> connectToRoom({
    required String roomName,
    required String participantName,
  }) async {
    try {
      _roomName = roomName;
      _participantName = participantName;
      connectionStatus.value = 'Connecting...';

      // Request permissions
      final cameraStatus = await Permission.camera.request();
      final microphoneStatus = await Permission.microphone.request();

      if (!cameraStatus.isGranted || !microphoneStatus.isGranted) {
        connectionStatus.value = 'Permissions denied';
        Get.snackbar(
          'Permissions Required',
          'Camera and microphone permissions are required for video calls',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get access token from backend using Retrofit service
      final tokenResponse = await LiveKitService(
        DioUtil().getDio(useAccessToken: true),
      ).getAccessToken({
        'roomName': roomName,
        'participantName': participantName,
      });

      // Check response status
      if (tokenResponse.status != true || tokenResponse.data == null) {
        connectionStatus.value = 'Token generation failed';
        isConnected.value = false;
        AppToasts.showError(tokenResponse.message ?? 'Failed to get access token');
        return;
      }

      final tokenData = tokenResponse.data!;

      // Create room
      _room = Room();

      // Connect to room
      await _room!.connect(
        tokenData.url,
        tokenData.accessToken,
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioCaptureOptions: AudioCaptureOptions(
            echoCancellation: true,
            noiseSuppression: true,
            autoGainControl: true,
          ),
        ),
      );

      // Set up event listeners
      _room!.addListener(_onRoomChanged);
      
      // Listen to room events for participant changes
      _room!.addListener(() {
        _onRemoteParticipantsChanged();
      });

      _localParticipant = _room!.localParticipant;
      isConnected.value = true;
      connectionStatus.value = 'Connected';

      // Enable camera and microphone
      await enableVideo();
      await enableAudio();

      // Get local video track
      _updateLocalVideoTrack();
    } catch (e) {
      connectionStatus.value = 'Connection failed';
      isConnected.value = false;
      Get.snackbar(
        'Connection Error',
        'Failed to connect to video call: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Disconnect from room
  Future<void> disconnectFromRoom() async {
    try {
      if (_room != null) {
        await _room!.disconnect();
        _room = null;
        _localParticipant = null;
        isConnected.value = false;
        connectionStatus.value = 'Disconnected';
        localVideoTrack.value = null;
        remoteParticipants.clear();
      }
    } catch (e) {
      print('Error disconnecting from room: $e');
    }
  }

  /// Enable/disable video
  Future<void> toggleVideo() async {
    if (isVideoEnabled.value) {
      await disableVideo();
    } else {
      await enableVideo();
    }
  }

  /// Enable video
  Future<void> enableVideo() async {
    try {
      if (_localParticipant != null) {
        await _localParticipant!.setCameraEnabled(true);
        isVideoEnabled.value = true;
        _updateLocalVideoTrack();
      }
    } catch (e) {
      print('Error enabling video: $e');
    }
  }

  /// Disable video
  Future<void> disableVideo() async {
    try {
      if (_localParticipant != null) {
        await _localParticipant!.setCameraEnabled(false);
        isVideoEnabled.value = false;
        localVideoTrack.value = null;
      }
    } catch (e) {
      print('Error disabling video: $e');
    }
  }

  /// Enable/disable audio
  Future<void> toggleAudio() async {
    if (isAudioEnabled.value) {
      await disableAudio();
    } else {
      await enableAudio();
    }
  }

  /// Enable audio
  Future<void> enableAudio() async {
    try {
      if (_localParticipant != null) {
        await _localParticipant!.setMicrophoneEnabled(true);
        isAudioEnabled.value = true;
      }
    } catch (e) {
      print('Error enabling audio: $e');
    }
  }

  /// Disable audio
  Future<void> disableAudio() async {
    try {
      if (_localParticipant != null) {
        await _localParticipant!.setMicrophoneEnabled(false);
        isAudioEnabled.value = false;
      }
    } catch (e) {
      print('Error disabling audio: $e');
    }
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    try {
      if (_localParticipant != null) {
        // Get current camera track and switch
        final cameraTrack = _localParticipant!.videoTrackPublications
            .where((pub) => pub.source == TrackSource.camera)
            .map((pub) => pub.track)
            .whereType<LocalVideoTrack>()
            .firstOrNull;
        
        if (cameraTrack != null) {
          // Switch camera position - toggle between front and back
          // Note: This is a simplified approach. You may need to track current position
          // or use a different API based on your LiveKit version
          await cameraTrack.setCameraPosition(CameraPosition.back);
        }
      }
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  /// Update local video track
  void _updateLocalVideoTrack() {
    if (_localParticipant != null) {
      final videoTrack = _localParticipant!.videoTrackPublications
          .where((pub) => pub.subscribed)
          .map((pub) => pub.track)
          .whereType<LocalVideoTrack>()
          .firstOrNull;
      localVideoTrack.value = videoTrack;
    }
  }

  /// Get remote video track for a participant
  VideoTrack? getRemoteVideoTrack(RemoteParticipant participant) {
    final videoTrack = participant.videoTrackPublications
        .where((pub) => pub.subscribed)
        .map((pub) => pub.track)
        .whereType<RemoteVideoTrack>()
        .firstOrNull;
    return videoTrack;
  }

  /// Room event handler
  void _onRoomChanged() {
    if (_room == null) return;

    // Update connection status
    if (_room!.connectionState == ConnectionState.connected) {
      connectionStatus.value = 'Connected';
      isConnected.value = true;
    } else if (_room!.connectionState == ConnectionState.disconnected) {
      connectionStatus.value = 'Disconnected';
      isConnected.value = false;
    } else if (_room!.connectionState == ConnectionState.connecting) {
      connectionStatus.value = 'Connecting...';
    }

    // Update local video track
    _updateLocalVideoTrack();
  }

  /// Remote participants event handler
  void _onRemoteParticipantsChanged() {
    if (_room == null) return;
    remoteParticipants.assignAll(_room!.remoteParticipants.values.toList());
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final hour = now.hour == 0 ? 12 : now.hour > 12 ? now.hour - 12 : now.hour;
    final timeString =
        '$hour:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    messages.add(
      ChatMessage(
        text: text,
        isFromOP: true,
        time: timeString,
      ),
    );

    messageController.clear();
  }

  void cancelCall() async {
    await disconnectFromRoom();
    Get.back();
  }

  void confirmTerms() async {
    // After confirming terms, connect to the video call
    // You should get roomName and participantName from your backend or navigation params
    // For now, using placeholder values - replace with actual values from your backend
    final roomName = _roomName ?? 'room-${DateTime.now().millisecondsSinceEpoch}';
    final participantName = _participantName ?? 'Participant-${DateTime.now().millisecondsSinceEpoch}';
    
    await connectToRoom(
      roomName: roomName,
      participantName: participantName,
    );
  }

  void onTakePhoto() {
    // Placeholder for future photo capture integration
  }

  void onFlashDocuments() {
    // Placeholder for future flash document handling
  }

  void onPaymentReceipt() {
    // Placeholder for future payment receipt handling
  }

  void setFocusedField(
    FocusNode? focusNode,
    TextEditingController textController,
  ) {
    focusedField = focusNode;
    focusedController = textController;
    keyboardController
      ..text = textController.text
      ..selection = textController.selection;
  }

  void onKeyboardKeyPressed(String key) {
    final controller = focusedController;
    if (controller == null) return;

    final text = controller.text;
    final selection = controller.selection;

    if (key == 'backspace') {
      if (selection.start > 0) {
        final newText =
            text.substring(0, selection.start - 1) + text.substring(selection.end);
        controller
          ..text = newText
          ..selection = TextSelection.collapsed(offset: selection.start - 1);
      }
    } else if (key == 'space') {
      final newText =
          text.substring(0, selection.start) + ' ' + text.substring(selection.end);
      controller
        ..text = newText
        ..selection = TextSelection.collapsed(offset: selection.start + 1);
    } else if (key == 'left') {
      if (selection.start > 0) {
        controller.selection =
            TextSelection.collapsed(offset: selection.start - 1);
      }
    } else if (key == 'right') {
      if (selection.end < text.length) {
        controller.selection =
            TextSelection.collapsed(offset: selection.end + 1);
      }
    } else if (key == 'enter') {
      final newText =
          text.substring(0, selection.start) + '\n' + text.substring(selection.end);
      controller
        ..text = newText
        ..selection = TextSelection.collapsed(offset: selection.start + 1);
    } else if (key == '123') {
      // Future enhancement: switch keyboard layout
    } else {
      final newText =
          text.substring(0, selection.start) + key + text.substring(selection.end);
      controller
        ..text = newText
        ..selection = TextSelection.collapsed(offset: selection.start + key.length);
    }

    keyboardController
      ..text = controller.text
      ..selection = controller.selection;
  }

  void clearMessage() {
    messageController.clear();
  }
}
