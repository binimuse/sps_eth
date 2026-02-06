import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sps_eth_app/app/modules/call_class/services/direct_call_service.dart';
import 'package:sps_eth_app/app/modules/call_class/services/direct_call_websocket_service.dart';
import 'package:sps_eth_app/app/modules/call_class/models/direct_call_model.dart';
import 'package:sps_eth_app/app/modules/call_class/models/report_response_model.dart';
import 'package:sps_eth_app/app/modules/call_class/views/widgets/confirmation_page_view.dart';
import 'package:sps_eth_app/app/modules/call_class/views/widgets/attachment_upload_popup.dart';
import 'package:sps_eth_app/app/modules/Residence_id/services/auth_service.dart';
import 'package:dio/dio.dart' as dio;
import 'package:sps_eth_app/app/utils/dio_util.dart';
import 'package:sps_eth_app/app/utils/enums.dart';
import 'package:sps_eth_app/app/utils/auth_util.dart';
import 'package:sps_eth_app/app/utils/jwt_util.dart';
import 'package:sps_eth_app/app/utils/device_id_util.dart';
import 'package:sps_eth_app/app/utils/connectivity_util.dart';
import 'package:sps_eth_app/app/utils/constants.dart';
import 'package:sps_eth_app/app/common/app_toasts.dart';
import 'package:sps_eth_app/app/common/widgets/line_busy_dialog.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/app/modules/language/controllers/language_controller.dart';
import 'package:sps_eth_app/app/modules/language/views/language_view.dart';

class ChatMessage {
  ChatMessage({required this.text, required this.isFromOP, required this.time});

  final bool
  isFromOP; // true if from OP (Officer/Operator), false if from other party
  final String text;
  final String time;
}

class InfoRow {
  const InfoRow(this.label, this.value);

  final String label;
  final String value;
}

class DocumentItem {
  const DocumentItem({required this.label, required this.fileName});

  final String fileName;
  final String label;
}

class CallClassController extends GetxController {
  // Auto-start flag for home swipe
  final RxBool autoStartCall = false.obs;

  // Camera selection
  final RxList<CameraPosition> availableCameraPositions =
      <CameraPosition>[].obs;

  // Media devices enumeration for debugging
  final RxList<MediaDevice> availableCameras = <MediaDevice>[].obs;

  final RxList<MediaDevice> availableMicrophones = <MediaDevice>[].obs;
  // Call details from backend
  final Rx<CallDetailsResponse?> callDetails = Rx<CallDetailsResponse?>(null);

  final Rx<NetworkStatus> callNetworkStatus = NetworkStatus.IDLE.obs;
  // Direct Call state
  final RxString callStatus =
      'idle'.obs; // idle, pending, connecting, active, ended

  final RxString connectionStatus = 'Disconnected'.obs;
  // Connectivity monitoring
  final ConnectivityUtil connectivityUtil = ConnectivityUtil();

  final RxString currentCameraDeviceId = ''.obs;
  final RxInt currentCameraIndex = 0.obs;
  final RxString currentMicrophoneDeviceId = ''.obs;
  // Progress tracking for call process
  final RxInt currentProgressStep = 0
      .obs; // 0: not started, 1: connecting, 2: report initiated, 3: attachment upload

  final Rx<String?> currentRoomName = Rx<String?>('');
  final Rx<String?> currentSessionId = Rx<String?>('');
  // Attachment upload state
  final Rx<AttachmentUploadLinkEvent?> currentUploadRequest =
      Rx<AttachmentUploadLinkEvent?>(null);

  final Rx<String?> currentWsUrl = Rx<String?>('');
  final RxString discussionDate = 'June 12, 2024'.obs;
  final Rx<Map<String, dynamic>> faydaData = Rx<Map<String, dynamic>>(
    <String, dynamic>{},
  );
  // Fayda ID verification data
  final RxString faydaTransactionID = ''.obs;

  TextEditingController? focusedController;
  FocusNode? focusedField = FocusNode();
  final RxBool hasMultipleCameras = false.obs;
  final RxList<InfoRow> idInformation = <InfoRow>[].obs;
  final Rx<IncomingCallEvent?> incomingCall = Rx<IncomingCallEvent?>(null);
  // Anonymous login state
  final RxBool isAnonymousLoginLoading = false.obs;

  final RxBool isAttachmentUploading = false.obs;
  final RxBool isAudioEnabled = true.obs;
  final RxBool isConnected = false.obs;

  // Codec switching state
  final RxString currentVideoCodec =
      'VP9'.obs; // Default codec: 'VP9'; also 'H264', 'VP8'
  final RxBool isSwitchingCodec = false.obs;
  final RxBool isSwitchingCamera = false.obs;
  final RxBool isConnectingToOfficer = false.obs;
  final RxBool isEndingCall = false.obs; // Loading state for ending call
  final RxBool isReportInitiated = false.obs;
  final RxBool isUploadDialogOpen = false.obs;
  final RxBool isVideoEnabled = true.obs;
  final TextEditingController keyboardController = TextEditingController();
  final Rx<VideoTrack?> localVideoTrack = Rx<VideoTrack?>(null);
  final messageController = TextEditingController();
  final messages = <ChatMessage>[].obs;
  // For employee side
  final RxList<PendingCall> pendingCalls = <PendingCall>[].obs;

  final RxList<RemoteParticipant> remoteParticipants =
      <RemoteParticipant>[].obs;

  /// Reactive remote video track so admin UI rebuilds when track becomes subscribed (fixes black screen)
  final Rx<VideoTrack?> remoteVideoTrack = Rx<VideoTrack?>(null);

  // Report and statement data from call details
  final Rx<ReportInfo?> reportInfo = Rx<ReportInfo?>(null);

  // Residence ID verification data
  final Rx<Map<String, dynamic>> residenceData = Rx<Map<String, dynamic>>(
    <String, dynamic>{},
  );

  final selectedLanguage = 'English'.obs;
  final Rx<StatementInfo?> statementInfo = Rx<StatementInfo?>(null);
  final RxList<DocumentItem> supportingDocuments = <DocumentItem>[].obs;
  final RxString termsAndConditions =
      'A technology-driven, modern police service outlet where users can serve themselves without human intervention. Designed to make police services more accessible, efficient, and convenient for the community.'
          .obs;

  // TIN verification data
  final Rx<Map<String, dynamic>> tinData = Rx<Map<String, dynamic>>(
    <String, dynamic>{},
  );

  static const int _callDetailsPollInterval =
      3; // seconds (reduced for faster updates)
  static const Duration _remoteVideoTrackRetryInterval = Duration(
    milliseconds: 200,
  );
  static const int _remoteVideoTrackRetryMax = 20; // 200ms * 20 = 4s

  // Call details polling
  Timer? _callDetailsPollingTimer;

  // Connection timeout monitor
  Timer? _connectionTimeoutTimer;

  // Direct Call services
  final DirectCallService _directCallService = DirectCallService(
    DioUtil().getDio(useAccessToken: true),
  );

  bool _isLoadingCallDetails = false; // Prevent overlapping requests
  // Call request parameters
  bool _isVisitor = false; // Default to false (residence/home)

  LocalParticipant? _localParticipant;
  String? _preferredLanguage; // Will be set if language was selected
  final Map<RemoteParticipant, void Function()> _remoteParticipantListeners =
      {};
  int _remoteVideoTrackRetryCount = 0;

  /// Workaround for LiveKit Flutter #919: on Android, publication.track can be null after subscribe.
  /// We retry _updateRemoteVideoTrack periodically until track appears or timeout.
  Timer? _remoteVideoTrackRetryTimer;

  /// Delayed sync of remote participants after connect (fixes admin black screen when admin joins after kiosk).
  Timer? _remoteVideoTrackSyncTimer;

  /// Audio health check timer (for VP9 codec debugging)
  Timer? _audioHealthCheckTimer;
  
  /// Track previous remote audio muting states to detect changes
  final Map<String, bool> _previousRemoteAudioMutedStates = {};

  // LiveKit related
  Room? _room;

  // Passport/ID photo from scanner (base64)
  String? _scannedIdPhoto;

  DirectCallWebSocketService? _webSocketService;

  @override
  void onClose() {
    _connectionTimeoutTimer?.cancel();
    _remoteVideoTrackRetryTimer?.cancel();
    _remoteVideoTrackRetryTimer = null;
    _remoteVideoTrackSyncTimer?.cancel();
    _remoteVideoTrackSyncTimer = null;
    _audioHealthCheckTimer?.cancel();
    _audioHealthCheckTimer = null;
    _previousRemoteAudioMutedStates.clear();
    _stopCallDetailsPolling();
    for (var entry in _remoteParticipantListeners.entries.toList()) {
      try {
        entry.key.removeListener(entry.value);
      } catch (_) {}
    }
    _remoteParticipantListeners.clear();
    remoteVideoTrack.value = null;
    disconnectFromRoom();
    _webSocketService?.disconnect();
    messageController.dispose();
    keyboardController.dispose();
    focusedField?.dispose();
    // Dispose connectivity monitoring
    connectivityUtil.dispose();
    // Clear tokens when controller is closed
    clearTokensOnExit();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    try {
      // Initialize connectivity monitoring
      connectivityUtil.initialize();

      // Listen to connectivity changes to auto-retry when internet comes back
      ever(connectivityUtil.isOnline, (bool isOnline) {
        if (isOnline) {
          print(
            '🌐 [CONNECTIVITY] Internet restored, checking if retry is needed...',
          );
          // If WebSocket is not connected, try to reconnect
          if (_webSocketService != null && !_webSocketService!.isConnected) {
            print(
              '🔄 [CONNECTIVITY] WebSocket disconnected, attempting to reconnect...',
            );
            _connectWebSocket().catchError((e) {
              print('❌ [CONNECTIVITY] Failed to reconnect WebSocket: $e');
            });
          }
        } else {
          print('🌐 [CONNECTIVITY] Internet disconnected');
        }
      });

      // Read arguments to determine call source and get preferred language
      final args = Get.arguments;
      if (args != null && args is Map) {
        // Check if auto-start is requested
        if (args['autoStart'] == true) {
          autoStartCall.value = true;
          print('📞 [AUTO START] Auto-start call requested from home swipe');
        }

        // Get isVisitor flag (default to false if not provided)
        _isVisitor = args['isVisitor'] == true;
        print('📞 [INIT] isVisitor: $_isVisitor');

        // Get transactionID from Fayda verification (if available)
        if (args['transactionID'] != null) {
          faydaTransactionID.value = args['transactionID'].toString();
          print('📞 [INIT] Fayda Transaction ID: ${faydaTransactionID.value}');

          // Auto-start call when coming from Fayda verification
          autoStartCall.value = true;
          print('📞 [INIT] Auto-starting call for Fayda verification');
        }

        // Get Fayda data (if available)
        if (args['faydaData'] != null && args['faydaData'] is Map) {
          final faydaDataMap = Map<String, dynamic>.from(
            args['faydaData'] as Map,
          );
          faydaData.value = faydaDataMap;
          print('📞 [INIT] Fayda Data received:');
          print('  - Name: ${faydaDataMap['name']}');
          print('  - Individual ID: ${faydaDataMap['individualId']}');
          print('  - Status: ${faydaDataMap['status']}');
        }

        // Get Residence ID data (if available)
        if (args['residenceData'] != null && args['residenceData'] is Map) {
          final residenceDataMap = Map<String, dynamic>.from(
            args['residenceData'] as Map,
          );
          residenceData.value = residenceDataMap;
          print('📞 [INIT] Residence Data received:');
          print('  - Full Name: ${residenceDataMap['fullName']}');
          print('  - Residence ID: ${args['residenceId']}');
          print('  - Gender: ${residenceDataMap['gender']}');
          print('  - Nationality: ${residenceDataMap['nationality']}');
        }

        // Get TIN data (if available)
        if (args['tinData'] != null && args['tinData'] is Map) {
          final tinDataMap = Map<String, dynamic>.from(args['tinData'] as Map);
          tinData.value = tinDataMap;
          print('📞 [INIT] TIN Data received:');
          print('  - Full Name: ${tinDataMap['fullName']}');
          print('  - TIN Number: ${args['tinNumber']}');
          print('  - Type: ${tinDataMap['tpTypeDesc']}');
          print('  - Region: ${tinDataMap['region']}');
        }

        // Get scanned ID photo (base64) from passport scanner (if available)
        if (args['idPhoto'] != null && args['idPhoto'].toString().isNotEmpty) {
          _scannedIdPhoto = args['idPhoto'].toString();
          print(
            '📞 [INIT] Scanned ID Photo received: ${_scannedIdPhoto!.length} characters (base64)',
          );
        } else {
          print('📞 [INIT] No scanned ID photo provided');
        }

        // Get preferred language from LanguageController if available
        _preferredLanguage = _getPreferredLanguage();
        if (_preferredLanguage != null) {
          print('📞 [INIT] preferredLanguage: $_preferredLanguage');
        } else {
          print('📞 [INIT] preferredLanguage: null (no language selected)');
        }
      } else {
        // No arguments, default values
        _isVisitor = false;
        _preferredLanguage = _getPreferredLanguage();
        print(
          '📞 [INIT] No arguments provided, using defaults - isVisitor: $_isVisitor',
        );
      }

      _loadInitialData();
    } catch (e, stackTrace) {
      print('❌ [INIT ERROR] Error in onInit: $e');
      print('❌ [INIT ERROR] Stack trace: $stackTrace');
      AppToasts.showError('Failed to initialize call class: ${e.toString()}');
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Check authentication first before allowing access
    // Using onReady ensures the view is fully built before navigation
    _checkAuthBeforeAccess().catchError((error, stackTrace) {
      print('❌ [INIT ERROR] Error in onReady: $error');
      print('❌ [INIT ERROR] Stack trace: $stackTrace');
      AppToasts.showError(
        'Failed to initialize call class: ${error.toString()}',
      );
    });
  }

  /// Public method to load pending calls (can be called from UI)
  Future<void> loadPendingCalls() async {
    await _loadPendingCalls();
  }

  /// Clear authentication tokens when leaving the call class view
  Future<void> clearTokensOnExit() async {
    try {
      print('🔐 [CLEAR TOKENS] Clearing authentication tokens on exit...');
      await AuthUtil().logOut();
      print('✅ [CLEAR TOKENS] Tokens cleared successfully');
    } catch (e) {
      print('❌ [CLEAR TOKENS] Error clearing tokens: $e');
    }
  }

  /// Handle back button press - clear tokens and navigate back
  Future<bool> onWillPop() async {
    print('🔙 [BACK BUTTON] Back button pressed, clearing tokens...');
    await clearTokensOnExit();
    return true; // Allow navigation
  }

  /// Request a call (Client/User role)
  /// This is the new Direct Call flow
  Future<void> requestCall() async {
    print('📞 [REQUEST CALL] Starting call request...');

    // Check authentication first
    final isAuthenticated = await _checkAuthentication();
    if (!isAuthenticated) {
      print('❌ [REQUEST CALL] Authentication check failed');
      return;
    }

    print('✅ [REQUEST CALL] Authentication passed');

    try {
      callNetworkStatus.value = NetworkStatus.LOADING;
      callStatus.value = 'pending';
      print('📞 [REQUEST CALL] Status set to pending');

      // Request permissions first
      print('📞 [REQUEST CALL] Requesting camera permission...');
      final cameraStatus = await Permission.camera.request();
      print('📞 [REQUEST CALL] Camera permission: ${cameraStatus.toString()}');

      print('📞 [REQUEST CALL] Requesting microphone permission...');
      final microphoneStatus = await Permission.microphone.request();
      print(
        '📞 [REQUEST CALL] Microphone permission: ${microphoneStatus.toString()}',
      );

      if (!cameraStatus.isGranted || !microphoneStatus.isGranted) {
        callNetworkStatus.value = NetworkStatus.ERROR;
        callStatus.value = 'idle';
        print(
          '❌ [REQUEST CALL] Permissions denied - Camera: ${cameraStatus.isGranted}, Microphone: ${microphoneStatus.isGranted}',
        );
        AppToasts.showError('Camera and microphone permissions are required');
        return;
      }

      print('✅ [REQUEST CALL] Permissions granted');
      print('📞 [REQUEST CALL] Calling Direct Call API...');

      // Get device serial number
      final deviceSerial = await DeviceIdUtil.getDeviceSerialNumber();
      print('📱 [REQUEST CALL] Device Serial Number: $deviceSerial');

      // Extract Fayda data if available
      final faydaDataMap = faydaData.value;
      String? idNumber;
      String? photoUrl;
      String? fullname;
      String? fullnameAm;
      String? nationality;
      String? phoneNumber;
      String? address;
      String? idType;

      if (faydaDataMap.isNotEmpty && faydaTransactionID.value.isNotEmpty) {
        idNumber = faydaDataMap['individualId']?.toString();
        photoUrl = faydaDataMap['photo']?.toString();
        fullname = faydaDataMap['name']?.toString();
        fullnameAm = faydaDataMap['nameAm']?.toString();
        nationality = faydaDataMap['nationality']?.toString();
        phoneNumber = faydaDataMap['phoneNumber']?.toString();
        address = faydaDataMap['address']?.toString();
        idType = 'fayda';

        print('📤 [REQUEST CALL] Fayda data extracted:');
        print('  - ID Number: $idNumber');
        print('  - Full Name: $fullname');
        print('  - Full Name (Am): $fullnameAm');
        print('  - Nationality: $nationality');
        print('  - Phone: $phoneNumber');
        print('  - Address: $address');
        print(
          '  - Photo URL: ${photoUrl != null ? "${photoUrl.substring(0, 20)}..." : "null"}',
        );
      } else {
        // Extract Residence ID data if available
        final residenceDataMap = residenceData.value;
        final args = Get.arguments;
        if (residenceDataMap.isNotEmpty &&
            args != null &&
            args['residenceId'] != null) {
          idNumber = args['residenceId']?.toString();
          fullname = residenceDataMap['fullName']?.toString();
          fullnameAm = residenceDataMap['fullNameAmh']?.toString();
          nationality = residenceDataMap['nationality']?.toString();
          phoneNumber = residenceDataMap['phoneNo']?.toString();
          idType = 'residence';

          // Build address from residence data
          final addressParts = <String>[];
          if (residenceDataMap['houseNo'] != null &&
              residenceDataMap['houseNo'].toString().isNotEmpty) {
            addressParts.add(residenceDataMap['houseNo'].toString());
          }
          if (residenceDataMap['ppaCity'] != null &&
              residenceDataMap['ppaCity'].toString().isNotEmpty) {
            addressParts.add(residenceDataMap['ppaCity'].toString());
          }
          if (residenceDataMap['ppaCityAmh'] != null &&
              residenceDataMap['ppaCityAmh'].toString().isNotEmpty) {
            addressParts.add(residenceDataMap['ppaCityAmh'].toString());
          }
          if (addressParts.isNotEmpty) {
            address = addressParts.join(', ');
          }

          print('📤 [REQUEST CALL] Residence data extracted:');
          print('  - ID Number: $idNumber');
          print('  - Full Name: $fullname');
          print('  - Full Name (Am): $fullnameAm');
          print('  - Nationality: $nationality');
          print('  - Phone: $phoneNumber');
          print('  - Address: $address');
        } else {
          // Extract TIN data if available
          final tinDataMap = tinData.value;
          if (tinDataMap.isNotEmpty &&
              args != null &&
              args['tinNumber'] != null) {
            idNumber = args['tinNumber']?.toString();
            fullname = tinDataMap['fullName']?.toString();
            fullnameAm = tinDataMap['fullNameF']?.toString();
            phoneNumber = tinDataMap['phoneNumber']?.toString();
            idType = 'tin';

            // Build address from TIN data
            final addressParts = <String>[];
            if (tinDataMap['cityName'] != null &&
                tinDataMap['cityName'].toString().isNotEmpty) {
              addressParts.add(tinDataMap['cityName'].toString());
            }
            if (tinDataMap['localityDesc'] != null &&
                tinDataMap['localityDesc'].toString().isNotEmpty) {
              addressParts.add(tinDataMap['localityDesc'].toString());
            }
            if (tinDataMap['kebeleDesc'] != null &&
                tinDataMap['kebeleDesc'].toString().isNotEmpty) {
              addressParts.add(tinDataMap['kebeleDesc'].toString());
            }
            if (addressParts.isNotEmpty) {
              address = addressParts.join(', ');
            }

            print('📤 [REQUEST CALL] TIN data extracted:');
            print('  - ID Number: $idNumber');
            print('  - Full Name: $fullname');
            print('  - Full Name (Am): $fullnameAm');
            print('  - Phone: $phoneNumber');
            print('  - Address: $address');
          }
        }
      }

      // Create request payload with isVisitor, preferredLanguage, ID data, scanned ID photo, and device serial
      final requestPayload = RequestCallRequest(
        isVisitor: _isVisitor,
        preferredLanguage: _preferredLanguage,
        idNumber: idNumber,
        idType: idType,
        photoUrl: photoUrl,
        fullname: fullname,
        fullnameAm: fullnameAm,
        nationality: nationality,
        phoneNumber: phoneNumber,
        address: address,
        idPhoto: _scannedIdPhoto, // Add scanned ID photo (base64)
        deviceSerialNumber: deviceSerial, // Add device serial number
      );

      // Print request payload details
      final accessToken = await AuthUtil().getAccessToken();
      final baseUrl = 'https://sps-api-test.aii.et/api/v1';
      final endpoint = '/direct-call/request';
      final fullUrl = '$baseUrl$endpoint';

      print('📤 [REQUEST CALL] ========== REQUEST PAYLOAD ==========');
      print('📤 [REQUEST CALL] Method: POST');
      print('📤 [REQUEST CALL] URL: $fullUrl');
      print('📤 [REQUEST CALL] Headers:');
      print('📤 [REQUEST CALL]   - Content-Type: application/json');
      if (accessToken != null) {
        print('📤 [REQUEST CALL]   - Authorization: Bearer $accessToken');
      } else {
        print('📤 [REQUEST CALL]   - Authorization: null');
      }
      print('📤 [REQUEST CALL] Body:');
      print('📤 [REQUEST CALL] {');
      print('📤 [REQUEST CALL]   "isVisitor": ${requestPayload.isVisitor}');
      print(
        '📤 [REQUEST CALL]   "preferredLanguage": ${requestPayload.preferredLanguage != null ? "\"${requestPayload.preferredLanguage}\"" : "null"}',
      );
      if (requestPayload.idNumber != null) {
        print('📤 [REQUEST CALL]   "idNumber": "${requestPayload.idNumber}"');
        print('📤 [REQUEST CALL]   "idType": "${requestPayload.idType}"');
        print('📤 [REQUEST CALL]   "fullname": "${requestPayload.fullname}"');
        if (requestPayload.fullnameAm != null) {
          print(
            '📤 [REQUEST CALL]   "fullnameAm": "${requestPayload.fullnameAm}"',
          );
        }
        if (requestPayload.nationality != null) {
          print(
            '📤 [REQUEST CALL]   "nationality": "${requestPayload.nationality}"',
          );
        }
        if (requestPayload.phoneNumber != null) {
          print(
            '📤 [REQUEST CALL]   "phoneNumber": "${requestPayload.phoneNumber}"',
          );
        }
        if (requestPayload.address != null) {
          print('📤 [REQUEST CALL]   "address": "${requestPayload.address}"');
        }
        if (requestPayload.photoUrl != null) {
          print(
            '📤 [REQUEST CALL]   "photoUrl": "${requestPayload.photoUrl!.substring(0, requestPayload.photoUrl!.length > 50 ? 50 : requestPayload.photoUrl!.length)}..."',
          );
        }
      }
      if (requestPayload.idPhoto != null &&
          requestPayload.idPhoto!.isNotEmpty) {
        print(
          '📤 [REQUEST CALL]   "idPhoto": "<base64 image ${requestPayload.idPhoto!.length} chars>"',
        );
      }
      if (requestPayload.deviceSerialNumber != null &&
          requestPayload.deviceSerialNumber!.isNotEmpty) {
        print(
          '📤 [REQUEST CALL]   "deviceSerialNumber": "${requestPayload.deviceSerialNumber}"',
        );
      }
      print('📤 [REQUEST CALL] }');
      print('📤 [REQUEST CALL] ======================================');

      // Request call via Direct Call API
      final responseWrapper = await _directCallService.requestCall(
        requestPayload,
      );

      // Extract data from wrapper
      if (responseWrapper.success != true || responseWrapper.data == null) {
        callNetworkStatus.value = NetworkStatus.ERROR;
        callStatus.value = 'idle';
        print(
          '❌ [REQUEST CALL] API response indicates failure or missing data',
        );
        print('  - success: ${responseWrapper.success}');
        print('  - data: ${responseWrapper.data}');
        AppToasts.showError('Failed to request call');
        return;
      }

      final response = responseWrapper.data!;

      print('📥 [REQUEST CALL] ========== RESPONSE PAYLOAD ==========');
      print('📥 [REQUEST CALL] Status: Success');
      print('📥 [REQUEST CALL] Response Body:');
      print('📥 [REQUEST CALL] {');
      print('📥 [REQUEST CALL]   "success": ${responseWrapper.success}');
      print('📥 [REQUEST CALL]   "data": {');
      print(
        '📥 [REQUEST CALL]     "token": "${response.token != null ? "${response.token!.substring(0, 20)}..." : "null"}"',
      );
      print(
        '📥 [REQUEST CALL]     "roomName": "${response.roomName ?? "null"}"',
      );
      print(
        '📥 [REQUEST CALL]     "sessionId": "${response.sessionId ?? "null"}"',
      );
      print('📥 [REQUEST CALL]     "wsUrl": "${response.wsUrl ?? "null"}"');
      print('📥 [REQUEST CALL]   }');
      if (responseWrapper.meta != null) {
        print('📥 [REQUEST CALL]   "meta": {');
        print(
          '📥 [REQUEST CALL]     "timestamp": "${responseWrapper.meta!.timestamp ?? "null"}"',
        );
        print(
          '📥 [REQUEST CALL]     "requestId": "${responseWrapper.meta!.requestId ?? "null"}"',
        );
        print('📥 [REQUEST CALL]   }');
      }
      print('📥 [REQUEST CALL] }');
      print('📥 [REQUEST CALL] ======================================');

      if (response.token == null ||
          response.roomName == null ||
          response.sessionId == null ||
          response.wsUrl == null) {
        callNetworkStatus.value = NetworkStatus.ERROR;
        callStatus.value = 'idle';
        print('❌ [REQUEST CALL] Missing required fields in response data');
        AppToasts.showError('Failed to request call');
        return;
      }

      // Store session info
      currentSessionId.value = response.sessionId;
      currentRoomName.value = response.roomName;
      currentWsUrl.value = response.wsUrl;
      print('💾 [REQUEST CALL] Session info stored:');
      print('  - sessionId: ${currentSessionId.value}');
      print('  - roomName: ${currentRoomName.value}');
      print('  - wsUrl: ${currentWsUrl.value}');

      callNetworkStatus.value = NetworkStatus.SUCCESS;
      callStatus.value = 'connecting';
      connectionStatus.value = 'Connecting...';
      print('📞 [REQUEST CALL] Status set to connecting');

      // Connect to LiveKit room
      print('🎥 [LIVEKIT] Starting LiveKit room connection...');
      await _connectToLiveKitRoom(
        wsUrl: response.wsUrl!,
        token: response.token!,
        roomName: response.roomName!,
      );
    } on dio.DioException catch (e) {
      print('❌ [REQUEST CALL] DioException: ${e.type}');
      print('❌ [REQUEST CALL] Status Code: ${e.response?.statusCode}');
      print('❌ [REQUEST CALL] Response: ${e.response?.data}');
      print('❌ [REQUEST CALL] Error: ${e.error}');
      print('❌ [REQUEST CALL] Message: ${e.message}');

      callNetworkStatus.value = NetworkStatus.ERROR;
      callStatus.value = 'idle';

      String errorMessage = 'Failed to request call';

      // Handle network/connection errors
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout ||
          e.type == dio.DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection and try again.';
      } else if (e.type == dio.DioExceptionType.connectionError ||
          e.error?.toString().toLowerCase().contains('connection closed') ==
              true ||
          e.error?.toString().toLowerCase().contains('connection refused') ==
              true ||
          e.error?.toString().toLowerCase().contains('failed host lookup') ==
              true ||
          e.error?.toString().toLowerCase().contains('no address associated') ==
              true ||
          e.error?.toString().toLowerCase().contains(
                'network is unreachable',
              ) ==
              true ||
          e.message?.toLowerCase().contains('connection closed') == true ||
          e.message?.toLowerCase().contains('failed host lookup') == true) {
        // Check if it's an internet connectivity issue
        if (!connectivityUtil.isOnline.value) {
          print(
            '🌐 [REQUEST CALL] Internet disconnected, waiting for connection to restore...',
          );
          // Wait for internet and retry
          await _waitForInternetAndRetryCall();
          return; // Exit early, retry will happen in _waitForInternetAndRetryCall
        }
        errorMessage =
            'Connection error. The server may be temporarily unavailable. Please try again in a moment.';
        print(
          '⚠️ [REQUEST CALL] This appears to be a backend/network issue. The server closed the connection unexpectedly.',
        );
      } else if (e.response?.statusCode == 403) {
        // Parse error message from response
        try {
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            final error = responseData['error'];
            if (error is Map && error.containsKey('message')) {
              errorMessage =
                  error['message'] ??
                  'Access forbidden. This action requires USER role.';
            } else {
              errorMessage =
                  'Access forbidden. This action requires USER role.';
            }
          }
        } catch (_) {
          errorMessage = 'Access forbidden. This action requires USER role.';
        }

        // Get user role for debugging
        final userInfo = await AuthUtil().getUserData();
        if (userInfo.isNotEmpty && userInfo.containsKey('role')) {
          final role = userInfo['role'];
          if (role is Map && role.containsKey('name')) {
            print('❌ [REQUEST CALL] Current user role: ${role['name']}');
            errorMessage += '\nYour current role: ${role['name']}';
          }
        }
      } else if (e.response?.statusCode == 503) {
        // Check if it's a "no agents available" error
        bool isNoAgentsError = false;
        try {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic>) {
            final error = responseData['error'];
            if (error is Map && error.containsKey('message')) {
              final errorMsg = error['message']?.toString().toLowerCase() ?? '';
              if (errorMsg.contains('no connected call center agents') ||
                  errorMsg.contains('no agents available')) {
                isNoAgentsError = true;
              }
            }
          }
        } catch (_) {}

        if (isNoAgentsError) {
          // Show line busy dialog instead of snackbar
          final context = Get.context;
          if (context != null) {
            LineBusyDialogHelper.show(
              context: context,
              onTryAgain: () {
                // Retry the call request
                requestCall();
              },
            );
          } else {
            // Fallback to snackbar if context is not available
            errorMessage = 'No agents available. Please try again later.';
            AppToasts.showError(errorMessage);
          }
          return; // Don't show snackbar for this error
        } else {
          errorMessage = 'Service unavailable. Please try again later.';
        }
      } else if (e.response != null) {
        try {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic>) {
            final error = responseData['error'];
            if (error is Map && error.containsKey('message')) {
              errorMessage = error['message'] ?? errorMessage;
            } else if (responseData.containsKey('message')) {
              errorMessage = responseData['message'] ?? errorMessage;
            }
          }
        } catch (_) {}
      }

      print('❌ [REQUEST CALL] Error message: $errorMessage');
      print('❌ [REQUEST CALL] Error type: ${e.type}');

      // Show user-friendly error message (only if not already shown via dialog)
      if (errorMessage.isNotEmpty) {
        AppToasts.showError(errorMessage);
      }
    } catch (e, stackTrace) {
      print('❌ [REQUEST CALL] Exception: $e');
      print('❌ [REQUEST CALL] Stack trace: $stackTrace');
      callNetworkStatus.value = NetworkStatus.ERROR;
      callStatus.value = 'idle';
      AppToasts.showError(
        'An unexpected error occurred while requesting the call. Please try again.',
      );
    }
  }

  /// Accept a call (Employee role)
  Future<void> acceptCall(String sessionId) async {
    // Check authentication first
    final isAuthenticated = await _checkAuthentication();
    if (!isAuthenticated) {
      return;
    }

    try {
      callNetworkStatus.value = NetworkStatus.LOADING;

      // Request permissions
      final cameraStatus = await Permission.camera.request();
      final microphoneStatus = await Permission.microphone.request();

      if (!cameraStatus.isGranted || !microphoneStatus.isGranted) {
        callNetworkStatus.value = NetworkStatus.ERROR;
        AppToasts.showError('Camera and microphone permissions are required');
        return;
      }

      // Accept call via API
      final responseWrapper = await _directCallService.acceptCall(sessionId);

      // Extract data from wrapper
      if (responseWrapper.success != true || responseWrapper.data == null) {
        callNetworkStatus.value = NetworkStatus.ERROR;
        AppToasts.showError('Failed to accept call');
        return;
      }

      final response = responseWrapper.data!;

      if (response.token == null ||
          response.roomName == null ||
          response.sessionId == null ||
          response.wsUrl == null) {
        callNetworkStatus.value = NetworkStatus.ERROR;
        AppToasts.showError('Failed to accept call');
        return;
      }

      // Store session info
      currentSessionId.value = response.sessionId;
      currentRoomName.value = response.roomName;
      currentWsUrl.value = response.wsUrl;

      callNetworkStatus.value = NetworkStatus.SUCCESS;
      callStatus.value = 'connecting';
      connectionStatus.value = 'Connecting...';

      // Connect to LiveKit room
      await _connectToLiveKitRoom(
        wsUrl: response.wsUrl!,
        token: response.token!,
        roomName: response.roomName!,
      );

      // Remove from pending calls
      pendingCalls.removeWhere((call) => call.id == sessionId);
      incomingCall.value = null;
    } catch (e) {
      callNetworkStatus.value = NetworkStatus.ERROR;
      AppToasts.showError('Failed to accept call: $e');
    }
  }

  /// Reject a call (Employee role)
  Future<void> rejectCall(String sessionId) async {
    // Check authentication first
    final isAuthenticated = await _checkAuthentication();
    if (!isAuthenticated) {
      return;
    }

    try {
      await _directCallService.rejectCall(sessionId);

      // Remove from pending calls
      pendingCalls.removeWhere((call) => call.id == sessionId);
      incomingCall.value = null;
    } catch (e) {
      AppToasts.showError('Failed to reject call: $e');
    }
  }

  /// Disconnect from room
  Future<void> disconnectFromRoom() async {
    print('🔌 [DISCONNECT] Disconnecting from LiveKit room...');
    try {
      if (_room != null) {
        // Stop and cleanup tracks before disconnecting
        if (_localParticipant != null) {
          print('🔌 [DISCONNECT] Cleaning up local tracks...');

          // Get and stop local video track
          try {
            final videoTrackPub = _localParticipant!.videoTrackPublications
                .where((pub) => pub.track != null)
                .map((pub) => pub.track)
                .whereType<LocalVideoTrack>()
                .firstOrNull;

            if (videoTrackPub != null) {
              print('🔌 [DISCONNECT] Stopping local video track...');
              await videoTrackPub.stop();
              print('✅ [DISCONNECT] Local video track stopped');
            }
          } catch (e) {
            print('⚠️ [DISCONNECT] Error stopping video track: $e');
          }

          // Get and stop local audio track
          try {
            final audioTrackPub = _localParticipant!.audioTrackPublications
                .where((pub) => pub.track != null)
                .map((pub) => pub.track)
                .whereType<LocalAudioTrack>()
                .firstOrNull;

            if (audioTrackPub != null) {
              print('🔌 [DISCONNECT] Stopping local audio track...');
              await audioTrackPub.stop();
              print('✅ [DISCONNECT] Local audio track stopped');
            }
          } catch (e) {
            print('⚠️ [DISCONNECT] Error stopping audio track: $e');
          }
        }

        print('🔌 [DISCONNECT] Room exists, calling disconnect()...');
        await _room!.disconnect();
        print('🔌 [DISCONNECT] Room disconnected');
        _room = null;
        _localParticipant = null;
        isConnected.value = false;
        connectionStatus.value = 'Disconnected';
        localVideoTrack.value = null;
        for (var entry in _remoteParticipantListeners.entries.toList()) {
          try {
            entry.key.removeListener(entry.value);
          } catch (_) {}
        }
        _remoteParticipantListeners.clear();
        _remoteVideoTrackRetryTimer?.cancel();
        _remoteVideoTrackRetryTimer = null;
        _remoteVideoTrackSyncTimer?.cancel();
        _remoteVideoTrackSyncTimer = null;
        remoteVideoTrack.value = null;
        remoteParticipants.clear();
        print('🔌 [DISCONNECT] Cleanup completed');
      } else {
        print('⚠️ [DISCONNECT] Room is already null');
      }
    } catch (e, stackTrace) {
      print('❌ [DISCONNECT ERROR] Error disconnecting from room: $e');
      print('❌ [DISCONNECT ERROR] Stack trace: $stackTrace');
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
  /// On kiosks with two front cameras, we prefer the second front camera by deviceId
  /// (typically the user-facing one; the first may be document/scanner).
  Future<void> enableVideo() async {
    print(
      '🎥 [VIDEO] ========== ENABLE VIDEO (admin sees this stream) ==========',
    );
    try {
      if (_localParticipant != null) {
        // Enumerate cameras first if not already done
        if (availableCameraPositions.isEmpty) {
          await _enumerateCameras();
        }

        // Enumerate actual devices BEFORE creating track for kiosk debug (multiple front cameras)
        print(
          '🎥 [VIDEO] Enumerating cameras before creating track (kiosk debug)...',
        );
        List<MediaDevice> allCameras = [];
        try {
          final devices = await Hardware.instance.enumerateDevices();
          allCameras = devices.where((d) => d.kind == 'videoinput').toList();
          // Update availableCameras immediately so it's available for switching
          availableCameras.assignAll(allCameras);
          hasMultipleCameras.value = allCameras.length > 1;
          print(
            '🎥 [VIDEO] ========== CAMERA ENUMERATION (KIOSK DEBUG) ==========',
          );
          print('🎥 [VIDEO] Total videoinput devices: ${allCameras.length}');
          for (var i = 0; i < allCameras.length; i++) {
            final c = allCameras[i];
            final labelLower = c.label.toLowerCase();
            final isFront =
                labelLower.contains('front') ||
                labelLower.contains('user') ||
                labelLower.contains('face');
            print(
              '🎥 [VIDEO] Camera[$i] deviceId=${c.deviceId} label="${c.label}" kind=${c.kind} isFrontLike=$isFront',
            );
          }
          final frontCameras = allCameras.where((c) {
            final l = c.label.toLowerCase();
            return l.contains('front') ||
                l.contains('user') ||
                l.contains('face');
          }).toList();
          if (frontCameras.isEmpty) {
            print(
              '🎥 [VIDEO] No cameras with front/user/face in label; using CameraPosition.front (SDK default)',
            );
          } else {
            print(
              '🎥 [VIDEO] Front-like cameras count: ${frontCameras.length}',
            );
            for (var i = 0; i < frontCameras.length; i++) {
              print(
                '🎥 [VIDEO]   Front[$i]: deviceId=${frontCameras[i].deviceId} label="${frontCameras[i].label}"',
              );
            }
          }
          print(
            '🎥 [VIDEO] =========================================================',
          );
        } catch (e) {
          print('⚠️ [VIDEO] Could not enumerate devices before track: $e');
        }

        print('🎥 [VIDEO] Local participant exists');
        print(
          '🎥 [VIDEO] Current video publications BEFORE: ${_localParticipant!.videoTrackPublications.length}',
        );

        // On kiosks with 2+ front cameras, prefer second front camera by deviceId (usually user-facing)
        String? preferredDeviceId;
        if (allCameras.isNotEmpty) {
          final frontLike = allCameras.where((c) {
            final l = c.label.toLowerCase();
            return l.contains('front') ||
                l.contains('user') ||
                l.contains('face');
          }).toList();
          if (frontLike.length >= 2) {
            preferredDeviceId = frontLike[1].deviceId;
            print(
              '🎥 [VIDEO] KIOSK: 2+ front cameras detected, using SECOND front camera by deviceId: $preferredDeviceId (label: "${frontLike[1].label}")',
            );
          } else if (frontLike.length == 1) {
            preferredDeviceId = frontLike[0].deviceId;
            print(
              '🎥 [VIDEO] Single front camera, using deviceId: $preferredDeviceId',
            );
          }
        }

        // Create and publish camera track (with optional deviceId for kiosk)
        final captureOptions = CameraCaptureOptions(
          cameraPosition: CameraPosition.front,
          deviceId: preferredDeviceId,
          params: VideoParametersPresets.h720_169,
        );
        print(
          '🎥 [VIDEO] Creating camera track: position=front deviceId=${preferredDeviceId ?? "null (SDK default)"}',
        );
        final cameraTrack = await LocalVideoTrack.createCameraTrack(
          captureOptions,
        );
        print(
          '✅ [VIDEO] Camera track created: trackId=${cameraTrack.mediaStreamTrack.id}',
        );

        // Log which camera the track is actually using (getSettings)
        try {
          final settings = cameraTrack.mediaStreamTrack.getSettings();
          final actualDeviceId = settings['deviceId']?.toString();
          final facingMode = settings['facingMode']?.toString();
          final trackLabel = cameraTrack.mediaStreamTrack.label;
          print(
            '🎥 [VIDEO] ========== ACTIVE CAMERA FOR STREAM (what admin sees) ==========',
          );
          print('🎥 [VIDEO] deviceId: $actualDeviceId');
          print('🎥 [VIDEO] label: $trackLabel');
          print('🎥 [VIDEO] facingMode: $facingMode');
          print(
            '🎥 [VIDEO] =================================================================',
          );
          if (actualDeviceId != null) {
            currentCameraDeviceId.value = actualDeviceId;
          }
        } catch (e) {
          print('⚠️ [VIDEO] Could not read track getSettings(): $e');
        }

        // Explicitly publish the track to ensure it's sent to LiveKit server
        // Use current codec (defaults to H.264)
        print('🎥 [VIDEO] Publishing camera track to LiveKit server...');
        print('🎥 [VIDEO] Using codec: ${currentVideoCodec.value}');
        await _localParticipant!.publishVideoTrack(
          cameraTrack,
          publishOptions: VideoPublishOptions(
            videoCodec: currentVideoCodec.value, // Use current codec setting
          ),
        );
        print(
          '✅ [VIDEO] Camera track PUBLISHED to server with ${currentVideoCodec.value} codec',
        );

        // Small delay to let publication complete
        await Future.delayed(const Duration(milliseconds: 800));

        isVideoEnabled.value = true;

        // Verify publication
        final publications = _localParticipant!.videoTrackPublications
            .where((pub) => pub.source == TrackSource.camera)
            .toList();

        print('🎥 [VIDEO] ========== VIDEO PUBLICATION STATUS ==========');
        print('🎥 [VIDEO] Total camera publications: ${publications.length}');

        for (var pub in publications) {
          print('🎥 [VIDEO] Publication ${pub.sid}:');
          print('🎥 [VIDEO]   - Source: ${pub.source}');
          print('🎥 [VIDEO]   - Subscribed: ${pub.subscribed}');
          print('🎥 [VIDEO]   - Muted: ${pub.muted}');
          print('🎥 [VIDEO]   - Has track: ${pub.track != null}');

          if (pub.track != null) {
            final track = pub.track as LocalVideoTrack;
            print('🎥 [VIDEO]   - Track ID: ${track.mediaStreamTrack.id}');
            print(
              '🎥 [VIDEO]   - Track enabled: ${track.mediaStreamTrack.enabled}',
            );
            print(
              '🎥 [VIDEO]   - Track label: ${track.mediaStreamTrack.label}',
            );
            try {
              final s = track.mediaStreamTrack.getSettings();
              print('🎥 [VIDEO]   - Track deviceId (stream): ${s['deviceId']}');
              print('🎥 [VIDEO]   - Track facingMode: ${s['facingMode']}');
            } catch (_) {}
          }
        }
        print('🎥 [VIDEO] ================================================');

        _updateLocalVideoTrack();

        // Enumerate actual media devices for debugging (this will also update currentCameraDeviceId from track)
        await _enumerateMediaDevices();
        
        // Ensure currentCameraDeviceId is set if not already set
        if (currentCameraDeviceId.value.isEmpty && localVideoTrack.value != null) {
          try {
            final track = localVideoTrack.value as LocalVideoTrack;
            final settings = track.mediaStreamTrack.getSettings();
            final deviceId = settings['deviceId']?.toString();
            if (deviceId != null && deviceId.isNotEmpty) {
              currentCameraDeviceId.value = deviceId;
              print('✅ [VIDEO] Set currentCameraDeviceId from track: $deviceId');
            }
          } catch (e) {
            print('⚠️ [VIDEO] Could not set currentCameraDeviceId from track: $e');
          }
        }

        print('✅ [VIDEO] Video enabled and published successfully');
        print('📷 [VIDEO] Current camera deviceId: ${currentCameraDeviceId.value}');
        print('📷 [VIDEO] Available cameras: ${availableCameras.length}');
      } else {
        print('❌ [VIDEO] Local participant is null, cannot enable video');
        throw Exception('Local participant is null');
      }
    } catch (e, stackTrace) {
      print('❌ [VIDEO ERROR] Error enabling video: $e');
      print('❌ [VIDEO ERROR] Stack trace: $stackTrace');
      isVideoEnabled.value = false;
      // Only show error if it's a permission issue, not connection issues
      if (e.toString().contains('permission') ||
          e.toString().contains('Permission')) {
        AppToasts.showError(
          'Camera permission denied. Please grant permission and try again.',
        );
      }
      rethrow;
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
  /// For VP9 codec on Android, we need to ensure audio track is properly created and published
  /// This method uses explicit track creation and comprehensive error logging
  Future<void> enableAudio() async {
    print('🎤 [AUDIO] ========== STARTING AUDIO ENABLEMENT ==========');
    print('🎤 [AUDIO] Current video codec: ${currentVideoCodec.value}');
    print('🎤 [AUDIO] Room state: ${_room?.connectionState}');
    print('🎤 [AUDIO] Local participant: ${_localParticipant != null ? "exists" : "null"}');
    
    try {
      // Step 0: Check microphone permission
      print('🎤 [AUDIO] Checking microphone permission...');
      try {
        final micPermission = await Permission.microphone.status;
        print('🎤 [AUDIO] Microphone permission status: $micPermission');
        
        if (!micPermission.isGranted) {
          print('⚠️ [AUDIO] Microphone permission not granted, requesting...');
          final requestResult = await Permission.microphone.request();
          print('🎤 [AUDIO] Permission request result: $requestResult');
          
          if (!requestResult.isGranted) {
            print('❌ [AUDIO ERROR] Microphone permission denied');
            throw Exception('Microphone permission denied: $requestResult');
          }
        }
        print('✅ [AUDIO] Microphone permission granted');
      } catch (permError, permStack) {
        print('❌ [AUDIO ERROR] Permission check failed: $permError');
        print('❌ [AUDIO ERROR] Stack trace: $permStack');
        throw Exception('Microphone permission error: $permError');
      }

      // Step 1: Validate prerequisites
      if (_localParticipant == null) {
        print('❌ [AUDIO ERROR] Local participant is null, cannot enable audio');
        throw Exception('Local participant is null');
      }

      if (_room == null) {
        print('❌ [AUDIO ERROR] Room is null, cannot enable audio');
        throw Exception('Room is null');
      }

      if (_room!.connectionState != ConnectionState.connected) {
        print('❌ [AUDIO ERROR] Room not connected: ${_room!.connectionState}');
        throw Exception('Room not connected: ${_room!.connectionState}');
      }

      print('✅ [AUDIO] Prerequisites validated');

      // Step 2: Check for existing audio tracks
      print('🎤 [AUDIO] Checking for existing audio tracks...');
      final existingPublications = _localParticipant!.audioTrackPublications
          .where((pub) => pub.source == TrackSource.microphone)
          .toList();
      
      print('🎤 [AUDIO] Found ${existingPublications.length} existing microphone publication(s)');
      for (var pub in existingPublications) {
        print('🎤 [AUDIO]   Publication ${pub.sid}: track=${pub.track != null}, muted=${pub.muted}, subscribed=${pub.subscribed}');
      }

      final existingAudioTrack = existingPublications
          .where((pub) => pub.track != null)
          .map((pub) => pub.track)
          .whereType<LocalAudioTrack>()
          .firstOrNull;

      if (existingAudioTrack != null) {
        print('🎤 [AUDIO] Existing audio track found, verifying and enabling...');
        try {
          // Log track details
          final settings = existingAudioTrack.mediaStreamTrack.getSettings();
          print('🎤 [AUDIO] Track settings: $settings');
          print('🎤 [AUDIO] Track enabled: ${existingAudioTrack.mediaStreamTrack.enabled}');
          print('🎤 [AUDIO] Track muted: ${existingAudioTrack.muted}');
          print('🎤 [AUDIO] Track ID: ${existingAudioTrack.mediaStreamTrack.id}');
          print('🎤 [AUDIO] Track label: ${existingAudioTrack.mediaStreamTrack.label}');
          
          // Ensure track is enabled
          if (!existingAudioTrack.mediaStreamTrack.enabled) {
            print('🎤 [AUDIO] Enabling existing audio track...');
            existingAudioTrack.mediaStreamTrack.enabled = true;
            await Future.delayed(const Duration(milliseconds: 200));
          }

          // Ensure microphone is enabled
          await _localParticipant!.setMicrophoneEnabled(true);
          await Future.delayed(const Duration(milliseconds: 300));
          
          // Verify track is still enabled after setMicrophoneEnabled
          if (!existingAudioTrack.mediaStreamTrack.enabled) {
            print('⚠️ [AUDIO] Track disabled after setMicrophoneEnabled, re-enabling...');
            existingAudioTrack.mediaStreamTrack.enabled = true;
          }

          isAudioEnabled.value = true;
          print('✅ [AUDIO] Existing track enabled successfully');
          
          // Log device ID
          try {
            final deviceId = settings['deviceId']?.toString();
            if (deviceId != null) {
              currentMicrophoneDeviceId.value = deviceId;
              print('🎤 [AUDIO] Microphone device ID: $deviceId');
            }
          } catch (e) {
            print('⚠️ [AUDIO] Could not read device ID: $e');
          }
        } catch (e, stackTrace) {
          print('❌ [AUDIO ERROR] Error enabling existing track: $e');
          print('❌ [AUDIO ERROR] Stack trace: $stackTrace');
          // Continue to try creating new track
        }
      }

      // Step 3: If no track exists or existing track failed, create new one
      if (existingAudioTrack == null || !isAudioEnabled.value) {
        print('🎤 [AUDIO] No valid audio track found, creating new microphone track...');
        
        // For VP9 codec, use longer delays
        final isVP9 = currentVideoCodec.value == 'VP9';
        final delayMs = isVP9 ? 1000 : 500;
        print('🎤 [AUDIO] Using ${isVP9 ? "VP9" : "non-VP9"} delay: ${delayMs}ms');

        // Strategy: Use setMicrophoneEnabled with retry logic
        print('🎤 [AUDIO] Using setMicrophoneEnabled with VP9-aware delays...');
        
        // Disable first to reset state
        print('🎤 [AUDIO] Step 1: Disabling microphone to reset state...');
        try {
          await _localParticipant!.setMicrophoneEnabled(false);
          await Future.delayed(const Duration(milliseconds: 300));
          print('✅ [AUDIO] Microphone disabled');
        } catch (disableError) {
          print('⚠️ [AUDIO] Error disabling microphone (may already be disabled): $disableError');
        }
        
        // Enable microphone
        print('🎤 [AUDIO] Step 2: Calling setMicrophoneEnabled(true)...');
        try {
          await _localParticipant!.setMicrophoneEnabled(true);
          print('✅ [AUDIO] setMicrophoneEnabled(true) completed');
        } catch (enableError, enableStack) {
          print('❌ [AUDIO ERROR] setMicrophoneEnabled failed: $enableError');
          print('❌ [AUDIO ERROR] Stack trace: $enableStack');
          throw enableError;
        }
        
        // Wait longer for VP9 codec
        print('🎤 [AUDIO] Step 3: Waiting ${delayMs * 2}ms for track creation (VP9-aware delay)...');
        await Future.delayed(Duration(milliseconds: delayMs * 2));
        
        // Check for track
        print('🎤 [AUDIO] Step 4: Checking for audio track...');
        final audioTrack = _localParticipant!.audioTrackPublications
            .where((pub) => pub.source == TrackSource.microphone && pub.track != null)
            .map((pub) => pub.track)
            .whereType<LocalAudioTrack>()
            .firstOrNull;
        
        if (audioTrack != null) {
          print('✅ [AUDIO] Audio track created successfully');
          isAudioEnabled.value = true;
          
          // Ensure track is enabled
          if (!audioTrack.mediaStreamTrack.enabled) {
            print('🎤 [AUDIO] Enabling audio track media stream...');
            audioTrack.mediaStreamTrack.enabled = true;
            await Future.delayed(const Duration(milliseconds: 200));
          }
          
          // Log track details
          try {
            final settings = audioTrack.mediaStreamTrack.getSettings();
            print('🎤 [AUDIO] Audio track settings: $settings');
            final deviceId = settings['deviceId']?.toString();
            if (deviceId != null) {
              currentMicrophoneDeviceId.value = deviceId;
              print('🎤 [AUDIO] Microphone device ID: $deviceId');
            }
            
            // Log track state
            print('🎤 [AUDIO] Track enabled: ${audioTrack.mediaStreamTrack.enabled}');
            print('🎤 [AUDIO] Track muted: ${audioTrack.muted}');
            print('🎤 [AUDIO] Track ID: ${audioTrack.mediaStreamTrack.id}');
            print('🎤 [AUDIO] Track label: ${audioTrack.mediaStreamTrack.label}');
          } catch (e) {
            print('⚠️ [AUDIO] Could not read track details: $e');
          }
        } else {
          print('⚠️ [AUDIO] Audio track not found after setMicrophoneEnabled');
          print('⚠️ [AUDIO] This may be normal - track might appear later');
          // Still mark as enabled - track might appear later
          isAudioEnabled.value = true;
        }
      }

      // Step 4: Enumerate media devices
      print('🎤 [AUDIO] Enumerating media devices...');
      try {
        if (availableMicrophones.isEmpty) {
          await _enumerateMediaDevices();
        }
        print('🎤 [AUDIO] Available microphones: ${availableMicrophones.length}');
      } catch (e) {
        print('⚠️ [AUDIO] Error enumerating devices: $e');
      }

      // Step 5: Final verification and logging
      print('🎤 [AUDIO] Performing final verification...');
      final finalPublications = _localParticipant!.audioTrackPublications
          .where((pub) => pub.source == TrackSource.microphone)
          .toList();
      
      print('🎤 [AUDIO] ========== FINAL AUDIO PUBLICATION STATUS ==========');
      print('🎤 [AUDIO] Total microphone publications: ${finalPublications.length}');
      print('🎤 [AUDIO] isAudioEnabled state: ${isAudioEnabled.value}');
      print('🎤 [AUDIO] Video codec: ${currentVideoCodec.value}');
      
      for (var pub in finalPublications) {
        print('🎤 [AUDIO] Publication ${pub.sid}:');
        print('🎤 [AUDIO]   - Source: ${pub.source}');
        print('🎤 [AUDIO]   - Subscribed: ${pub.subscribed}');
        print('🎤 [AUDIO]   - Muted: ${pub.muted}');
        print('🎤 [AUDIO]   - Has track: ${pub.track != null}');
        
        if (pub.track != null) {
          final track = pub.track as LocalAudioTrack;
          try {
            print('🎤 [AUDIO]   - Track enabled: ${track.mediaStreamTrack.enabled}');
            print('🎤 [AUDIO]   - Track muted: ${track.muted}');
            print('🎤 [AUDIO]   - Track ID: ${track.mediaStreamTrack.id}');
            print('🎤 [AUDIO]   - Track label: ${track.mediaStreamTrack.label}');
            
            final settings = track.mediaStreamTrack.getSettings();
            print('🎤 [AUDIO]   - Track settings: $settings');
            
            // Check for audio constraints
            final constraints = track.mediaStreamTrack.getConstraints();
            print('🎤 [AUDIO]   - Track constraints: $constraints');
          } catch (e) {
            print('⚠️ [AUDIO]   - Error reading track properties: $e');
          }
        }
      }
      print('🎤 [AUDIO] ====================================================');
      
      if (finalPublications.isEmpty || finalPublications.every((p) => p.track == null)) {
        print('⚠️ [AUDIO WARNING] No audio tracks found after enablement!');
        print('⚠️ [AUDIO WARNING] Audio may not work properly');
      } else {
        final hasEnabledTrack = finalPublications.any((p) => 
          p.track != null && 
          (p.track as LocalAudioTrack).mediaStreamTrack.enabled &&
          !p.muted
        );
        if (!hasEnabledTrack) {
          print('⚠️ [AUDIO WARNING] Audio tracks exist but none are enabled/unmuted!');
        } else {
          print('✅ [AUDIO] Audio track is enabled and ready');
          
          // Start periodic audio health check for VP9 codec
          if (currentVideoCodec.value == 'VP9') {
            print('🎤 [AUDIO] Starting periodic audio health check for VP9...');
            _startAudioHealthCheck();
          }
        }
      }
      
    } catch (e, stackTrace) {
      print('❌ [AUDIO ERROR] ========== FATAL ERROR ==========');
      print('❌ [AUDIO ERROR] Error: $e');
      print('❌ [AUDIO ERROR] Type: ${e.runtimeType}');
      print('❌ [AUDIO ERROR] Stack trace: $stackTrace');
      print('❌ [AUDIO ERROR] Video codec: ${currentVideoCodec.value}');
      print('❌ [AUDIO ERROR] Room state: ${_room?.connectionState}');
      print('❌ [AUDIO ERROR] Local participant: ${_localParticipant != null}');
      print('❌ [AUDIO ERROR] ==================================');
      
      isAudioEnabled.value = false;
      
      // Show user-friendly error
      String errorMessage = 'Failed to enable microphone';
      if (e.toString().contains('permission') || e.toString().contains('Permission')) {
        errorMessage = 'Microphone permission denied. Please grant permission and try again.';
      } else if (e.toString().contains('not connected') || e.toString().contains('null')) {
        errorMessage = 'Cannot enable microphone: connection issue';
      }
      
      AppToasts.showError(errorMessage);
      rethrow;
    }
  }

  /// Disable audio
  Future<void> disableAudio() async {
    try {
      _stopAudioHealthCheck();
      if (_localParticipant != null) {
        await _localParticipant!.setMicrophoneEnabled(false);
        isAudioEnabled.value = false;
      }
    } catch (e) {
      print('Error disabling audio: $e');
    }
  }

  /// Start periodic audio health check (for VP9 codec debugging)
  void _startAudioHealthCheck() {
    _stopAudioHealthCheck(); // Stop any existing check
    
    print('🎤 [AUDIO HEALTH] Starting periodic audio health check...');
    _audioHealthCheckTimer = Timer.periodic(
      const Duration(seconds: 5), // Check every 5 seconds
      (timer) {
        _performAudioHealthCheck();
      },
    );
  }

  /// Stop audio health check
  void _stopAudioHealthCheck() {
    if (_audioHealthCheckTimer != null) {
      _audioHealthCheckTimer!.cancel();
      _audioHealthCheckTimer = null;
      print('🎤 [AUDIO HEALTH] Stopped audio health check');
    }
  }

  /// Perform audio health check
  void _performAudioHealthCheck() {
    try {
      if (_localParticipant == null || _room == null) {
        return;
      }

      print('🎤 [AUDIO HEALTH] ========== AUDIO HEALTH CHECK ==========');
      print('🎤 [AUDIO HEALTH] Video codec: ${currentVideoCodec.value}');
      print('🎤 [AUDIO HEALTH] Room connected: ${_room!.connectionState == ConnectionState.connected}');
      print('🎤 [AUDIO HEALTH] isAudioEnabled state: ${isAudioEnabled.value}');
      
      // Check local audio
      final localAudioPubs = _localParticipant!.audioTrackPublications
          .where((pub) => pub.source == TrackSource.microphone)
          .toList();
      
      print('🎤 [AUDIO HEALTH] Local audio publications: ${localAudioPubs.length}');
      bool localAudioNeedsRecovery = false;
      
      for (var pub in localAudioPubs) {
        if (pub.track != null) {
          final track = pub.track as LocalAudioTrack;
          final isEnabled = track.mediaStreamTrack.enabled;
          final isMuted = pub.muted || track.muted;
          final isSubscribed = pub.subscribed;
          
          print('🎤 [AUDIO HEALTH]   Local Publication ${pub.sid}:');
          print('🎤 [AUDIO HEALTH]     - Subscribed: $isSubscribed');
          print('🎤 [AUDIO HEALTH]     - Publication muted: ${pub.muted}');
          print('🎤 [AUDIO HEALTH]     - Track muted: ${track.muted}');
          print('🎤 [AUDIO HEALTH]     - Track enabled: $isEnabled');
          print('🎤 [AUDIO HEALTH]     - Track ID: ${track.mediaStreamTrack.id}');
          print('🎤 [AUDIO HEALTH]     - Track label: ${track.mediaStreamTrack.label}');
          
          // Check if local audio needs recovery
          if (!isEnabled || isMuted || !isSubscribed) {
            print('⚠️ [AUDIO HEALTH]     ⚠️ LOCAL AUDIO ISSUE DETECTED!');
            if (!isEnabled) print('⚠️ [AUDIO HEALTH]       - Track is disabled');
            if (isMuted) print('⚠️ [AUDIO HEALTH]       - Track is muted');
            if (!isSubscribed) print('⚠️ [AUDIO HEALTH]       - Publication not subscribed');
            localAudioNeedsRecovery = true;
          }
          
          // Try to read track settings
          try {
            final settings = track.mediaStreamTrack.getSettings();
            print('🎤 [AUDIO HEALTH]     - Track settings: $settings');
          } catch (e) {
            print('⚠️ [AUDIO HEALTH]     - Could not read settings: $e');
          }
        } else {
          print('⚠️ [AUDIO HEALTH]   Local Publication ${pub.sid}: track is null!');
          localAudioNeedsRecovery = true;
        }
      }
      
      // Attempt to recover local audio if needed
      if (localAudioNeedsRecovery && isAudioEnabled.value) {
        print('🔧 [AUDIO HEALTH] Attempting to recover local audio...');
        _recoverLocalAudio();
      }
      
      // Check remote audio
      final remoteParts = _room!.remoteParticipants.values.toList();
      print('🎤 [AUDIO HEALTH] Remote participants: ${remoteParts.length}');
      
      for (var participant in remoteParts) {
        final remoteAudioPubs = participant.audioTrackPublications;
        print('🎤 [AUDIO HEALTH]   Participant ${participant.identity}: ${remoteAudioPubs.length} audio publication(s)');
        
        for (var pub in remoteAudioPubs) {
          if (pub.track != null) {
            final track = pub.track as RemoteAudioTrack;
            final isEnabled = track.mediaStreamTrack.enabled;
            final isMuted = pub.muted || track.muted;
            final isSubscribed = pub.subscribed;
            
            print('🎤 [AUDIO HEALTH]     Remote Publication ${pub.sid}:');
            print('🎤 [AUDIO HEALTH]       - Subscribed: $isSubscribed');
            print('🎤 [AUDIO HEALTH]       - Publication muted: ${pub.muted}');
            print('🎤 [AUDIO HEALTH]       - Track muted: ${track.muted}');
            print('🎤 [AUDIO HEALTH]       - Track enabled: $isEnabled');
            print('🎤 [AUDIO HEALTH]       - Track ID: ${track.mediaStreamTrack.id}');
            print('🎤 [AUDIO HEALTH]       - Track label: ${track.mediaStreamTrack.label}');
            
            if (!isSubscribed) {
              print('⚠️ [AUDIO HEALTH]       ⚠️ WARNING: Remote audio not subscribed!');
              print('⚠️ [AUDIO HEALTH]       This means we cannot hear the remote participant');
            }
            if (isMuted) {
              print('⚠️ [AUDIO HEALTH]       ⚠️ WARNING: Remote audio is muted!');
              print('⚠️ [AUDIO HEALTH]       The remote participant has muted their microphone');
            }
            if (!isEnabled) {
              print('⚠️ [AUDIO HEALTH]       ⚠️ WARNING: Remote audio track is disabled!');
            }
          } else {
            print('⚠️ [AUDIO HEALTH]     Remote Publication ${pub.sid}: track is null!');
          }
        }
      }
      
      print('🎤 [AUDIO HEALTH] =========================================');
    } catch (e, stackTrace) {
      print('⚠️ [AUDIO HEALTH] Error performing health check: $e');
      print('⚠️ [AUDIO HEALTH] Stack trace: $stackTrace');
    }
  }
  
  /// Attempt to recover local audio if it becomes disabled or muted
  Future<void> _recoverLocalAudio() async {
    try {
      print('🔧 [AUDIO RECOVERY] ========== ATTEMPTING LOCAL AUDIO RECOVERY ==========');
      
      if (_localParticipant == null || _room == null) {
        print('❌ [AUDIO RECOVERY] Cannot recover: room or participant is null');
        return;
      }
      
      if (_room!.connectionState != ConnectionState.connected) {
        print('❌ [AUDIO RECOVERY] Cannot recover: room not connected');
        return;
      }
      
      final localAudioPubs = _localParticipant!.audioTrackPublications
          .where((pub) => pub.source == TrackSource.microphone)
          .toList();
      
      bool recovered = false;
      
      for (var pub in localAudioPubs) {
        if (pub.track != null) {
          final track = pub.track as LocalAudioTrack;
          
          // Re-enable track if disabled
          if (!track.mediaStreamTrack.enabled) {
            print('🔧 [AUDIO RECOVERY] Re-enabling disabled audio track...');
            track.mediaStreamTrack.enabled = true;
            await Future.delayed(const Duration(milliseconds: 200));
            recovered = true;
          }
          
          // Unmute if muted
          if (pub.muted || track.muted) {
            print('🔧 [AUDIO RECOVERY] Unmuting audio track...');
            await _localParticipant!.setMicrophoneEnabled(true);
            await Future.delayed(const Duration(milliseconds: 300));
            recovered = true;
          }
        } else {
          // Track is null, need to recreate
          print('🔧 [AUDIO RECOVERY] Audio track is null, recreating...');
          await enableAudio();
          recovered = true;
        }
      }
      
      if (recovered) {
        print('✅ [AUDIO RECOVERY] Audio recovery completed');
        // Verify recovery
        await Future.delayed(const Duration(milliseconds: 500));
        final verifyPubs = _localParticipant!.audioTrackPublications
            .where((pub) => pub.source == TrackSource.microphone && pub.track != null)
            .toList();
        
        if (verifyPubs.isNotEmpty) {
          final verifyTrack = verifyPubs.first.track as LocalAudioTrack;
          if (verifyTrack.mediaStreamTrack.enabled && !verifyPubs.first.muted) {
            print('✅ [AUDIO RECOVERY] Verification: Audio track is now enabled and unmuted');
          } else {
            print('⚠️ [AUDIO RECOVERY] Verification: Audio track still has issues');
          }
        }
      } else {
        print('ℹ️ [AUDIO RECOVERY] No recovery needed or recovery not possible');
      }
      
      print('🔧 [AUDIO RECOVERY] ================================================');
    } catch (e, stackTrace) {
      print('❌ [AUDIO RECOVERY] Error during recovery: $e');
      print('❌ [AUDIO RECOVERY] Stack trace: $stackTrace');
    }
  }

  /// Check if device is ZC-3588A tablet (uses lower quality preset for compatibility)
  Future<bool> _isZC3588ATablet() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final model = androidInfo.model.toUpperCase();
        print('📱 [DEVICE] Device model: $model');
        // Check if it's ZC-3588A tablet
        if (model.contains('ZC-3588A') || model.contains('ZC3588A')) {
          print(
            '📱 [DEVICE] ZC-3588A tablet detected - will use lower quality preset',
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      print('⚠️ [DEVICE] Error detecting device model: $e');
      return false;
    }
  }

  /// Get video publish options helper (matches web client pattern)
  VideoPublishOptions _getVideoPublishOptions(String codec) {
    return VideoPublishOptions(
      videoCodec: codec,
      // Simulcast disabled for simplicity (can be enabled if needed)
      simulcast: false,
    );
  }

  /// Camera position from device label (back/night/ir/rear → back, else front).
  static CameraPosition _positionFromLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('back') ||
        l.contains('night') ||
        l.contains('ir') ||
        l.contains('rear') ||
        l.contains('environment')) {
      return CameraPosition.back;
    }
    return CameraPosition.front;
  }

  /// Switch camera using unpublish → stop → create new → publish pattern
  Future<void> switchCamera(String deviceId) async {
    if (_localParticipant == null ||
        isSwitchingCamera.value ||
        isSwitchingCodec.value) {
      print('⚠️ [CAMERA] Switch skipped: participant=${_localParticipant != null}, switching=${isSwitchingCamera.value}, codecSwitching=${isSwitchingCodec.value}');
      return;
    }
    
    if (deviceId == currentCameraDeviceId.value) {
      print('⚠️ [CAMERA] Switch skipped: same deviceId=$deviceId');
      return;
    }

    final oldTrack = _localParticipant!.videoTrackPublications
        .where((pub) => pub.source == TrackSource.camera && pub.track != null)
        .map((pub) => pub.track)
        .whereType<LocalVideoTrack>()
        .firstOrNull;

    if (oldTrack == null) {
      print('❌ [CAMERA] Switch failed: no existing video track');
      return;
    }

    // Save previous device ID for error recovery
    final previousDeviceId = currentCameraDeviceId.value;
    
    print('🔄 [CAMERA] Switching camera from $previousDeviceId to $deviceId');
    isSwitchingCamera.value = true;
    
    // Clear local video track reference immediately to prevent UI from rendering stopped track
    localVideoTrack.value = null;
    localVideoTrack.refresh(); // Force UI to update immediately
    print('🔄 [CAMERA] Cleared local video track reference');
    
    try {
      // Refresh camera list so we have the latest devices and labels
      await _enumerateMediaDevices();
      
      // Verify the target device exists
      final targetDevice = availableCameras
          .where((c) => c.deviceId == deviceId)
          .firstOrNull;
      
      if (targetDevice == null) {
        print('❌ [CAMERA] Switch failed: target deviceId $deviceId not found in available cameras');
        print('📷 [CAMERA] Available cameras: ${availableCameras.map((c) => '${c.deviceId} (${c.label})').join(', ')}');
        return;
      }
      
      print('✅ [CAMERA] Target device found: ${targetDevice.deviceId} (${targetDevice.label})');

      // Step 1: Get all camera tracks and publications before cleanup
      final allCameraPublications = _localParticipant!.videoTrackPublications
          .where((pub) => pub.source == TrackSource.camera)
          .toList();
      final allCameraTracks = allCameraPublications
          .where((pub) => pub.track != null)
          .map((pub) => pub.track as LocalVideoTrack)
          .toList();
      
      print('🔄 [CAMERA] Found ${allCameraTracks.length} camera track(s) to cleanup');

      // Step 2: Unpublish all camera tracks by disabling camera
      print('🔄 [CAMERA] Disabling camera to unpublish all tracks...');
      try {
        await _localParticipant!.setCameraEnabled(false);
        print('✅ [CAMERA] Camera disabled (all tracks unpublished)');
      } catch (e) {
        print('⚠️ [CAMERA] Error disabling camera: $e');
      }
      
      // Wait for unpublish to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: Stop all camera tracks explicitly
      print('🔄 [CAMERA] Stopping all camera tracks...');
      for (var track in allCameraTracks) {
        try {
          await track.stop();
          print('✅ [CAMERA] Track stopped: ${track.mediaStreamTrack.label}');
        } catch (e) {
          print('⚠️ [CAMERA] Error stopping track (may already be stopped): $e');
        }
      }
      
      // Step 4: Wait longer for Android camera system to fully release the camera
      // Android requires cameras to be fully closed before opening a new one
      print('🔄 [CAMERA] Waiting for camera system to release cameras...');
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Step 5: Verify no active camera tracks exist
      final remainingPublications = _localParticipant!.videoTrackPublications
          .where((pub) => pub.source == TrackSource.camera && pub.track != null)
          .toList();
      
      if (remainingPublications.isNotEmpty) {
        print('⚠️ [CAMERA] Warning: ${remainingPublications.length} camera track(s) still exist after cleanup');
        // Try stopping any remaining tracks one more time
        for (var pub in remainingPublications) {
          try {
            if (pub.track != null) {
              final track = pub.track as LocalVideoTrack;
              await track.stop();
              print('✅ [CAMERA] Stopped remaining track: ${track.mediaStreamTrack.label}');
            }
          } catch (e) {
            print('⚠️ [CAMERA] Error stopping remaining track: $e');
          }
        }
        // Wait again after stopping remaining tracks
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        print('✅ [CAMERA] All camera tracks cleaned up successfully');
      }

      final isZC3588A = await _isZC3588ATablet();
      final videoParams = isZC3588A
          ? VideoParametersPresets.h360_169
          : VideoParametersPresets.h720_169;

      // Determine camera position from device label
      final position = _positionFromLabel(targetDevice.label);
      print('📷 [CAMERA] Using camera position: $position for device: ${targetDevice.label}');

      // Create new track with target device
      final captureOptions = CameraCaptureOptions(
        cameraPosition: position,
        deviceId: deviceId,
        params: videoParams,
      );
      
      print('🔄 [CAMERA] Creating new track with deviceId: $deviceId');
      LocalVideoTrack? newTrack;
      
      // Retry logic: Android camera system sometimes needs extra time to release
      int maxRetries = 3;
      int retryDelay = 500; // Start with 500ms delay
      
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          newTrack = await LocalVideoTrack.createCameraTrack(captureOptions);
          print('✅ [CAMERA] New track created successfully on attempt $attempt');
          break; // Success, exit retry loop
        } catch (e) {
          print('❌ [CAMERA] Failed to create new track (attempt $attempt/$maxRetries): $e');
          
          if (attempt < maxRetries) {
            // Wait longer before retrying (exponential backoff)
            print('🔄 [CAMERA] Waiting ${retryDelay}ms before retry...');
            await Future.delayed(Duration(milliseconds: retryDelay));
            retryDelay *= 2; // Double the delay for next retry
          } else {
            // Last attempt failed, rethrow the error
            print('❌ [CAMERA] All retry attempts failed');
            rethrow;
          }
        }
      }
      
      if (newTrack == null) {
        throw Exception('Failed to create camera track after $maxRetries attempts');
      }

      // Ensure the track is enabled (should be by default, but verify)
      try {
        if (!newTrack.mediaStreamTrack.enabled) {
          newTrack.mediaStreamTrack.enabled = true;
          print('✅ [CAMERA] Enabled new track');
        }
        print('📷 [CAMERA] Track enabled state: ${newTrack.mediaStreamTrack.enabled}');
      } catch (e) {
        print('⚠️ [CAMERA] Could not check/enable track: $e');
      }

      // Verify the new track is using the correct device
      String actualDeviceId = deviceId;
      try {
        final settings = newTrack.mediaStreamTrack.getSettings();
        final deviceIdFromSettings = settings['deviceId']?.toString();
        if (deviceIdFromSettings != null && deviceIdFromSettings.isNotEmpty) {
          actualDeviceId = deviceIdFromSettings;
          print('📷 [CAMERA] New track actual deviceId: $actualDeviceId');
          if (actualDeviceId != deviceId) {
            print('⚠️ [CAMERA] Warning: Track deviceId ($actualDeviceId) differs from requested ($deviceId)');
          }
        }
      } catch (e) {
        print('⚠️ [CAMERA] Could not verify track deviceId: $e');
      }
      
      // Wait a bit for the track to start producing frames before updating UI
      print('🔄 [CAMERA] Waiting for track to start producing frames...');
      await Future.delayed(const Duration(milliseconds: 400));

      // Publish new track
      print('🔄 [CAMERA] Publishing new track...');
      try {
        await _localParticipant!.publishVideoTrack(
          newTrack,
          publishOptions: _getVideoPublishOptions(currentVideoCodec.value),
        );
        print('✅ [CAMERA] New track published successfully');
        
        // Update current camera device ID
        currentCameraDeviceId.value = actualDeviceId;
        print('✅ [CAMERA] Current camera device ID updated to: $actualDeviceId');
        
        // Small delay to let publication complete
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Verify track is enabled
        try {
          if (!newTrack.mediaStreamTrack.enabled) {
            newTrack.mediaStreamTrack.enabled = true;
            print('✅ [CAMERA] Re-enabled track after publishing');
          }
        } catch (e) {
          print('⚠️ [CAMERA] Could not verify track enabled state: $e');
        }
        
        // Wait for the track to be fully ready and producing frames
        // Android cameras need time to initialize and start producing frames
        print('🔄 [CAMERA] Waiting for track to be ready and producing frames...');
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Update local video track reference with the new track we just created
        // Use the newTrack directly since we know it's the active one we just published
        print('🔄 [CAMERA] Updating local video track reference...');
        print('📷 [CAMERA] New track label: ${newTrack.mediaStreamTrack.label}');
        print('📷 [CAMERA] New track ID: ${newTrack.mediaStreamTrack.id}');
        print('📷 [CAMERA] Track enabled: ${newTrack.mediaStreamTrack.enabled}');
        
        // Clear the track value first to force widget disposal
        localVideoTrack.value = null;
        localVideoTrack.refresh();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Now set the new track - this will force VideoTrackRenderer to rebuild
        localVideoTrack.value = newTrack;
        localVideoTrack.refresh(); // Force GetX to notify listeners
        print('✅ [CAMERA] Local video track reference updated with new track');
        
        // Wait for the UI to rebuild with the new track
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Also call _updateLocalVideoTrack() to ensure consistency
        _updateLocalVideoTrack();
        
        // Force another refresh to ensure UI updates
        localVideoTrack.refresh();
        print('✅ [CAMERA] UI refresh completed');
        
        // Verify the track is actually in publications (double-check)
        final publishedTrack = _localParticipant!.videoTrackPublications
            .where((pub) => pub.source == TrackSource.camera && pub.track != null)
            .map((pub) => pub.track)
            .whereType<LocalVideoTrack>()
            .firstOrNull;
        
        if (publishedTrack != null) {
          // Ensure we're using the published track (should be the same as newTrack)
          if (publishedTrack.mediaStreamTrack.id != newTrack.mediaStreamTrack.id) {
            print('⚠️ [CAMERA] Warning: Published track differs from new track, using published track');
            localVideoTrack.value = publishedTrack;
            localVideoTrack.refresh();
          }
          print('✅ [CAMERA] Verified track is published and active');
        } else {
          print('⚠️ [CAMERA] Warning: Track not found in publications, but using newTrack directly');
        }
        
        // Ensure video is still enabled
        isVideoEnabled.value = true;
        
        // Wait one more time to ensure the track is rendering before marking switch as complete
        await Future.delayed(const Duration(milliseconds: 200));
        
        print('✅ [CAMERA] Camera switch completed successfully');
      } catch (e) {
        print('❌ [CAMERA] Failed to publish new track: $e');
        // Clean up the track if publish failed
        try {
          await newTrack.stop();
        } catch (_) {}
        rethrow;
      }
    } catch (e, stackTrace) {
      print('❌ [CAMERA] Switch failed: $e');
      print('❌ [CAMERA] Stack trace: $stackTrace');
      
      // Try to restore camera state on error
      try {
        // Check if we still have a valid video track
        final existingTrack = _localParticipant!.videoTrackPublications
            .where((pub) => pub.source == TrackSource.camera && pub.track != null)
            .map((pub) => pub.track)
            .whereType<LocalVideoTrack>()
            .firstOrNull;
        
        if (existingTrack == null) {
          print('⚠️ [CAMERA] No active track after error, attempting to restore...');
          // Try to re-enable video with the previous camera
          if (previousDeviceId.isNotEmpty) {
            print('🔄 [CAMERA] Attempting to restore previous camera: $previousDeviceId');
            // Restore the previous device ID
            currentCameraDeviceId.value = previousDeviceId;
            // Don't recursively call switchCamera, just try to enable video again
            await enableVideo();
            // Update local video track after restoring
            _updateLocalVideoTrack();
            localVideoTrack.refresh();
          } else {
            print('⚠️ [CAMERA] No previous camera device ID to restore');
          }
        } else {
          print('✅ [CAMERA] Existing track still active, no restoration needed');
          _updateLocalVideoTrack();
          localVideoTrack.refresh();
        }
      } catch (restoreError) {
        print('❌ [CAMERA] Failed to restore camera state: $restoreError');
      }
      
      AppToasts.showError('Failed to switch camera: ${e.toString()}');
    } finally {
      isSwitchingCamera.value = false;
      // Ensure video enabled state is correct and local track is updated
      final hasActiveTrack = _localParticipant?.videoTrackPublications
          .any((pub) => pub.source == TrackSource.camera && pub.track != null) ?? false;
      if (hasActiveTrack) {
        isVideoEnabled.value = true;
        // Ensure local video track reference is up to date
        _updateLocalVideoTrack();
        localVideoTrack.refresh();
      } else {
        // No active track, clear the reference
        localVideoTrack.value = null;
      }
    }
  }

  /// Get next camera deviceId for cycling through ALL cameras (so normal ↔ night/back works).
  String? getNextCameraDeviceId() {
    final cameras = availableCameras;
    print('📷 [CAMERA] Getting next camera deviceId');
    print('📷 [CAMERA] Available cameras count: ${cameras.length}');
    print('📷 [CAMERA] Current camera deviceId: ${currentCameraDeviceId.value}');
    
    if (cameras.isEmpty) {
      print('⚠️ [CAMERA] No cameras available');
      return null;
    }
    
    if (cameras.length == 1) {
      print('📷 [CAMERA] Only one camera available, returning: ${cameras.first.deviceId}');
      return cameras.first.deviceId;
    }

    final currentId = currentCameraDeviceId.value;
    final idx = cameras.indexWhere((c) => c.deviceId == currentId);
    
    print('📷 [CAMERA] Current camera index: $idx');
    
    // If current camera not found, start from first camera
    final nextIdx = (idx < 0 ? 0 : idx + 1) % cameras.length;
    final nextDeviceId = cameras[nextIdx].deviceId;
    
    print('📷 [CAMERA] Next camera index: $nextIdx, deviceId: $nextDeviceId (${cameras[nextIdx].label})');
    
    return nextDeviceId;
  }

  /// Switch codec using unpublish → stop → create new → publish pattern (matches web client)
  Future<void> switchCodec(String newCodec) async {
    try {
      // Guard: Room and current video track must exist, not already switching, and new codec must be different
      if (_localParticipant == null ||
          localVideoTrack.value == null ||
          isSwitchingCodec.value ||
          isSwitchingCamera.value ||
          newCodec == currentVideoCodec.value) {
        print(
          '🎬 [CODEC] Switch codec skipped: room=${_localParticipant != null}, track=${localVideoTrack.value != null}, switching=${isSwitchingCodec.value}, sameCodec=${newCodec == currentVideoCodec.value}',
        );
        return;
      }

      // Get current camera deviceId so the new track uses the same camera
      String? deviceId = currentCameraDeviceId.value;
      if (deviceId.isEmpty) {
        // Try to get deviceId from current track
        try {
          final currentTrack = localVideoTrack.value as LocalVideoTrack?;
          if (currentTrack != null) {
            final settings = currentTrack.mediaStreamTrack.getSettings();
            deviceId = settings['deviceId']?.toString();
          }
        } catch (e) {
          print('⚠️ [CODEC] Could not get deviceId from current track: $e');
        }
      }

      if (deviceId == null || deviceId.isEmpty) {
        print('❌ [CODEC] Cannot switch codec: deviceId not available');
        return;
      }

      isSwitchingCodec.value = true;
      print(
        '🎬 [CODEC] Switching codec from ${currentVideoCodec.value} to $newCodec',
      );

      try {
        final oldTrack = localVideoTrack.value as LocalVideoTrack?;
        if (oldTrack == null) {
          print('❌ [CODEC] No current video track found');
          return;
        }

        // Step 1: Unpublish old track by disabling camera (this unpublishes the track)
        print('🎬 [CODEC] Unpublishing old track...');
        await _localParticipant!.setCameraEnabled(false);
        await Future.delayed(const Duration(milliseconds: 200));

        // Step 2: Stop old track
        print('🎬 [CODEC] Stopping old track...');
        await oldTrack.stop();

        // Step 3: Create new track from the same camera (same deviceId)
        print(
          '🎬 [CODEC] Creating new track from same camera (deviceId: $deviceId)',
        );
        final isZC3588A = await _isZC3588ATablet();
        final videoParams = isZC3588A
            ? VideoParametersPresets.h360_169
            : VideoParametersPresets.h720_169;

        final captureOptions = CameraCaptureOptions(
          cameraPosition: CameraPosition.front,
          deviceId: deviceId,
          params: videoParams,
        );
        final newTrack = await LocalVideoTrack.createCameraTrack(
          captureOptions,
        );

        // Step 4: Publish new track with new codec (this is the only place the codec changes)
        print('🎬 [CODEC] Publishing new track with codec: $newCodec');
        await _localParticipant!.publishVideoTrack(
          newTrack,
          publishOptions: _getVideoPublishOptions(newCodec),
        );

        // Step 5: Update state
        final oldCodec = currentVideoCodec.value;
        final wasAudioEnabled = isAudioEnabled.value;
        currentVideoCodec.value = newCodec;
        _updateLocalVideoTrack();

        // Step 6: Ensure audio remains enabled after codec switch (important for VP9)
        // Wait a bit for video track to stabilize
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (wasAudioEnabled) {
          // Verify audio is still enabled and re-enable if needed
          final audioPublications = _localParticipant!.audioTrackPublications
              .where((pub) => pub.source == TrackSource.microphone && pub.track != null)
              .toList();
          
          if (audioPublications.isEmpty || !isAudioEnabled.value) {
            print('🎤 [CODEC] Audio track missing after codec switch, re-enabling...');
            try {
              await enableAudio();
            } catch (e) {
              print('⚠️ [CODEC] Failed to re-enable audio after codec switch: $e');
            }
          } else {
            // Verify audio track is enabled
            final audioPub = audioPublications.first;
            if (audioPub.track != null) {
              final audioTrack = audioPub.track as LocalAudioTrack;
              if (!audioTrack.mediaStreamTrack.enabled) {
                print('🎤 [CODEC] Audio track disabled, re-enabling...');
                audioTrack.mediaStreamTrack.enabled = true;
              }
            }
          }
        }

        print(
          '✅ [CODEC] Codec switched successfully from $oldCodec to $newCodec',
        );
      } catch (e, stackTrace) {
        print('❌ [CODEC ERROR] Error switching codec: $e');
        print('❌ [CODEC ERROR] Stack trace: $stackTrace');
        rethrow;
      } finally {
        isSwitchingCodec.value = false;
      }
    } catch (e, stackTrace) {
      print('❌ [CODEC ERROR] Error in switchCodec: $e');
      print('❌ [CODEC ERROR] Stack trace: $stackTrace');
      isSwitchingCodec.value = false;
    }
  }

  /// Get remote video track for a participant
  VideoTrack? getRemoteVideoTrack(RemoteParticipant participant) {
    print(
      '🎥 [REMOTE TRACK] Getting remote video track for participant: ${participant.identity}',
    );
    print(
      '🎥 [REMOTE TRACK] Video publications: ${participant.videoTrackPublications.length}',
    );

    for (var pub in participant.videoTrackPublications) {
      print(
        '🎥 [REMOTE TRACK] - Publication: subscribed=${pub.subscribed}, muted=${pub.muted}, track=${pub.track != null}',
      );
    }

    final videoTrack = participant.videoTrackPublications
        .where((pub) => pub.subscribed)
        .map((pub) => pub.track)
        .whereType<RemoteVideoTrack>()
        .firstOrNull;

    print('🎥 [REMOTE TRACK] Found remote video track: ${videoTrack != null}');

    return videoTrack;
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final hour = now.hour == 0
        ? 12
        : now.hour > 12
        ? now.hour - 12
        : now.hour;
    final timeString =
        '$hour:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    messages.add(ChatMessage(text: text, isFromOP: true, time: timeString));

    messageController.clear();
  }

  void cancelCall() async {
    await endCall();
    Get.back();
  }

  /// End the current call
  Future<void> endCall() async {
    // Prevent multiple simultaneous end calls
    if (isEndingCall.value) {
      print(
        '⚠️ [END CALL] Call ending already in progress, ignoring duplicate request',
      );
      return;
    }

    final sessionId = currentSessionId.value;
    if (sessionId == null || sessionId.isEmpty) {
      await disconnectFromRoom();
      return;
    }

    // Set loading state - will be cleared when WebSocket confirms call ended
    isEndingCall.value = true;
    print('📞 [END CALL] Ending call, showing loading indicator...');

    try {
      await _directCallService.endCall(sessionId);
      // Don't clear loading state here - wait for WebSocket confirmation
      // The loading state will be cleared when onCallEnded WebSocket event is received
      // or when navigation happens in _handleCallEnded
    } catch (e) {
      // Check if it's a DioException with 400 status about PENDING call
      bool isPendingCallError = false;
      if (e is dio.DioException) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        if (statusCode == 400) {
          // Check if error message mentions PENDING status
          final errorMessage = responseData?.toString() ?? '';
          if (errorMessage.contains('PENDING') ||
              errorMessage.contains('not active') ||
              errorMessage.contains('Call session is not active')) {
            isPendingCallError = true;
          }
        }
      }

      // Even if API call fails, disconnect from LiveKit and handle call ended
      // Don't clear loading state yet - wait for WebSocket or navigation
      await _handleCallEnded(shouldNavigate: true);

      // Only show error if it's not a PENDING call error (which is expected)
      if (!isPendingCallError) {
        AppToasts.showError('Error ending call. Please try again.');
      }
      // For pending calls, just clean up silently

      // If navigation happens immediately (no report), clear loading state
      // Otherwise it will be cleared when WebSocket receives callEnded event
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (isEndingCall.value) {
          isEndingCall.value = false;
        }
      });
    }
  }

  /// Confirm report submission - navigate to confirmation page and end call
  Future<void> confirmReportSubmission() async {
    try {
      final reportId = reportInfo.value?.id;
      if (reportId == null || reportId.isEmpty) {
        AppToasts.showError('Report ID not found');
        return;
      }

      print('✅ [REPORT CONFIRM] Confirming report submission: $reportId');

      // Fetch and show report in confirmation page
      await _fetchAndShowReport(reportId);

      // End the call after showing confirmation page (without navigation since we're already showing confirmation page)
      await disconnectFromRoom();
      callStatus.value = 'ended';

      // Clear call details
      callDetails.value = null;
      reportInfo.value = null;
      statementInfo.value = null;

      currentSessionId.value = '';
      currentRoomName.value = '';
      currentWsUrl.value = '';

      // Stop polling
      _stopCallDetailsPolling();

      print('✅ [REPORT CONFIRM] Call ended and confirmation page shown');
    } catch (e, stackTrace) {
      print('❌ [REPORT CONFIRM] Error confirming report: $e');
      print('❌ [REPORT CONFIRM] Stack trace: $stackTrace');
      AppToasts.showError('Failed to confirm report: ${e.toString()}');
    }
  }

  /// Reject report submission - stay on page (API integration to be added later)
  Future<void> rejectReportSubmission() async {
    try {
      final reportId = reportInfo.value?.id;
      if (reportId == null || reportId.isEmpty) {
        AppToasts.showError('Report ID not found');
        return;
      }

      print('❌ [REPORT REJECT] Rejecting report submission: $reportId');

      // TODO: Integrate API call to reject report
      // For now, just show a message and stay on the page
      AppToasts.showWarning(
        'Report rejection will be processed. API integration pending.',
      );

      // Stay on the page - no navigation
    } catch (e, stackTrace) {
      print('❌ [REPORT REJECT] Error rejecting report: $e');
      print('❌ [REPORT REJECT] Stack trace: $stackTrace');
      AppToasts.showError('Failed to reject report: ${e.toString()}');
    }
  }

  // Removed draft polling - now using call details endpoint which includes report and statement
  // Old draft polling methods removed - data comes from call details every 10 seconds

  // Removed: _startDraftPolling, _stopDraftPolling, _scheduleNextPoll, _pollDraft methods
  // These are no longer needed as we get report and statement data from call details endpoint

  void confirmTerms() async {
    // Check authentication before confirming terms
    final isAuthenticated = await _checkAuthentication();
    if (!isAuthenticated) {
      return;
    }

    // After confirming terms, request a call (Client role)
    // The system will automatically assign an employee
    await requestCall();
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
            text.substring(0, selection.start - 1) +
            text.substring(selection.end);
        controller
          ..text = newText
          ..selection = TextSelection.collapsed(offset: selection.start - 1);
      }
    } else if (key == 'space') {
      final newText =
          '${text.substring(0, selection.start)} ${text.substring(selection.end)}';
      controller
        ..text = newText
        ..selection = TextSelection.collapsed(offset: selection.start + 1);
    } else if (key == 'left') {
      if (selection.start > 0) {
        controller.selection = TextSelection.collapsed(
          offset: selection.start - 1,
        );
      }
    } else if (key == 'right') {
      if (selection.end < text.length) {
        controller.selection = TextSelection.collapsed(
          offset: selection.end + 1,
        );
      }
    } else if (key == 'enter') {
      final newText =
          '${text.substring(0, selection.start)}\n${text.substring(selection.end)}';
      controller
        ..text = newText
        ..selection = TextSelection.collapsed(offset: selection.start + 1);
    } else if (key == '123') {
      // Future enhancement: switch keyboard layout
    } else {
      final newText =
          text.substring(0, selection.start) +
          key +
          text.substring(selection.end);
      controller
        ..text = newText
        ..selection = TextSelection.collapsed(
          offset: selection.start + key.length,
        );
    }

    keyboardController
      ..text = controller.text
      ..selection = controller.selection;
  }

  void clearMessage() {
    messageController.clear();
  }

  /// Check authentication before allowing access to video call
  /// Uses anonymous login if not authenticated
  Future<void> _checkAuthBeforeAccess() async {
    try {
      print('🔐 [AUTH CHECK] Starting authentication check...');

      // First check if user is already authenticated
      final isAuthenticated = await AuthUtil().isFullyAuthenticated();
      print('🔐 [AUTH CHECK] isFullyAuthenticated: $isAuthenticated');

      if (isAuthenticated) {
        // Check if token is not expired
        final token = await AuthUtil().getAccessToken();
        if (token != null && !JwtUtil.isTokenExpired(token)) {
          print('✅ [AUTH CHECK] User already authenticated with valid token');
          print('✅ [AUTH CHECK] Token is valid, connecting WebSocket...');
          // User is authenticated, connect WebSocket
          await _checkAuthAndConnectWebSocket();

          // If auto-start is requested, automatically start the call
          if (autoStartCall.value) {
            print('📞 [AUTO START] Auto-starting call after authentication...');
            try {
              // Small delay to ensure WebSocket is connected
              await Future.delayed(const Duration(milliseconds: 500));
              await requestCall();
            } catch (e, stackTrace) {
              print('❌ [AUTO START] Error auto-starting call: $e');
              print('❌ [AUTO START] Stack trace: $stackTrace');
              AppToasts.showError('Failed to auto-start call: ${e.toString()}');
            }
          }
          return;
        }
      }

      // User is not authenticated or token is expired, perform anonymous login
      print(
        '🔐 [ANONYMOUS LOGIN] User not authenticated, performing anonymous login...',
      );
      await _performAnonymousLogin();
    } catch (e, stackTrace) {
      print('❌ [AUTH CHECK] Fatal error in _checkAuthBeforeAccess: $e');
      print('❌ [AUTH CHECK] Stack trace: $stackTrace');
      isAnonymousLoginLoading.value = false;
      AppToasts.showError(
        'Failed to initialize authentication: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Perform anonymous login using device ID
  Future<void> _performAnonymousLogin() async {
    try {
      isAnonymousLoginLoading.value = true;

      // Get device ID from utility (for now returns common static ID)
      final deviceId = await DeviceIdUtil.getDeviceId();
      print(
        '🔐 [ANONYMOUS LOGIN] Starting anonymous login with device ID: $deviceId',
      );

      // Create Dio instance without access token (since we don't have one yet)
      final dio = DioUtil().getDio(useAccessToken: false);
      final authService = AuthService(dio);

      // Call anonymous login API
      final response = await authService.anonymousLogin({'deviceId': deviceId});

      print('🔐 [ANONYMOUS LOGIN] API response received');
      print('  - success: ${response.success}');
      print(
        '  - accessToken: ${response.data?.accessToken != null ? "${response.data!.accessToken!.substring(0, 20)}..." : "null"}',
      );
      print('  - user: ${response.data?.user != null ? "exists" : "null"}');

      if (response.success != true || response.data == null) {
        throw Exception('Anonymous login failed: Invalid response from server');
      }

      final loginData = response.data!;

      if (loginData.accessToken == null || loginData.accessToken!.isEmpty) {
        throw Exception('Anonymous login failed: Access token is missing');
      }

      if (loginData.user == null) {
        throw Exception('Anonymous login failed: User data is missing');
      }

      // Convert user to Map for storage
      final userMap = loginData.user!.toJson();

      // Save tokens and user info
      print('💾 [ANONYMOUS LOGIN] Saving tokens and user data...');
      await AuthUtil().saveTokenAndUserInfo(
        accessToken: loginData.accessToken!,
        refreshToken:
            loginData.refreshToken ??
            '', // Anonymous login might not provide refresh token
        user: userMap,
      );

      // Verify token was saved
      final savedToken = await AuthUtil().getAccessToken();
      if (savedToken == null || savedToken != loginData.accessToken) {
        throw Exception('Failed to save authentication token');
      }

      print('✅ [ANONYMOUS LOGIN] Anonymous login successful');
      print('✅ [ANONYMOUS LOGIN] Token saved, connecting WebSocket...');

      // Connect WebSocket
      await _checkAuthAndConnectWebSocket();

      // If auto-start is requested, automatically start the call
      if (autoStartCall.value) {
        print('📞 [AUTO START] Auto-starting call after anonymous login...');
        try {
          // Small delay to ensure WebSocket is connected
          await Future.delayed(const Duration(milliseconds: 500));
          await requestCall();
        } catch (e, stackTrace) {
          print('❌ [AUTO START] Error auto-starting call: $e');
          print('❌ [AUTO START] Stack trace: $stackTrace');
          AppToasts.showError('Failed to auto-start call: ${e.toString()}');
        }
      }
    } on dio.DioException catch (e) {
      print('❌ [ANONYMOUS LOGIN] DioException: ${e.type}');
      print('❌ [ANONYMOUS LOGIN] Status Code: ${e.response?.statusCode}');
      print('❌ [ANONYMOUS LOGIN] Response: ${e.response?.data}');
      print('❌ [ANONYMOUS LOGIN] Error: ${e.error}');
      print('❌ [ANONYMOUS LOGIN] Message: ${e.message}');

      String errorMessage = 'Failed to authenticate. Please try again.';

      // Detect network connectivity errors
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout ||
          e.type == dio.DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection and try again.';
      } else if (e.type == dio.DioExceptionType.connectionError) {
        // Check for specific network unreachable errors
        final errorString = e.error?.toString().toLowerCase() ?? '';
        final messageString = e.message?.toLowerCase() ?? '';

        if (errorString.contains('network is unreachable') ||
            errorString.contains('connection failed') ||
            errorString.contains('socketexception') ||
            messageString.contains('network is unreachable') ||
            messageString.contains('connection failed')) {
          errorMessage =
              'No internet connection. Please check your network settings and try again.';
          print(
            '⚠️ [ANONYMOUS LOGIN] Network connectivity issue detected - device cannot reach the server',
          );
        } else {
          errorMessage =
              'Connection error. The server may be temporarily unavailable. Please try again in a moment.';
        }
      } else if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 500) {
        // Backend validation errors
        try {
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            final error = responseData['error'];
            if (error is Map && error.containsKey('message')) {
              errorMessage = error['message'] ?? errorMessage;
            } else if (responseData.containsKey('message')) {
              errorMessage = responseData['message'] ?? errorMessage;
            }
          }
        } catch (_) {}
      }

      // Show user-friendly error message
      AppToasts.showError(errorMessage);
      rethrow;
    } catch (e, stackTrace) {
      print('❌ [ANONYMOUS LOGIN] Exception: $e');
      print('❌ [ANONYMOUS LOGIN] Stack trace: $stackTrace');
      AppToasts.showError(
        'An unexpected error occurred during authentication. Please try again.',
      );
      rethrow;
    } finally {
      isAnonymousLoginLoading.value = false;
    }
  }

  /// Check authentication and connect WebSocket if authenticated
  Future<void> _checkAuthAndConnectWebSocket() async {
    try {
      print(
        '🔌 [WEBSOCKET] Checking authentication for WebSocket connection...',
      );
      final isAuthenticated = await AuthUtil().isFullyAuthenticated();
      print('🔌 [WEBSOCKET] isAuthenticated: $isAuthenticated');

      if (isAuthenticated) {
        // Also check if token is not expired
        final token = await AuthUtil().getAccessToken();
        print('🔌 [WEBSOCKET] Token exists: ${token != null}');

        if (token != null && !JwtUtil.isTokenExpired(token)) {
          print('✅ [WEBSOCKET] Token valid, connecting WebSocket...');
          await _connectWebSocket();
        } else {
          print(
            '❌ [WEBSOCKET] Token expired or null, performing anonymous login...',
          );
          if (token != null) {
            print(
              '🔌 [WEBSOCKET] Token expired: ${JwtUtil.isTokenExpired(token)}',
            );
          }
          // Perform anonymous login instead of showing login dialog
          await _performAnonymousLogin();
        }
      } else {
        print(
          '❌ [WEBSOCKET] User not authenticated, WebSocket connection skipped',
        );
      }
    } catch (e, stackTrace) {
      print('❌ [WEBSOCKET] Error in _checkAuthAndConnectWebSocket: $e');
      print('❌ [WEBSOCKET] Stack trace: $stackTrace');
      AppToasts.showError('Failed to connect WebSocket: ${e.toString()}');
      rethrow;
    }
  }

  /// Connect to Direct Call WebSocket
  Future<void> _connectWebSocket() async {
    print('🔌 [WEBSOCKET] Starting WebSocket connection...');
    try {
      _webSocketService = DirectCallWebSocketService();
      print('🔌 [WEBSOCKET] WebSocket service created');

      // Set up event handlers
      _webSocketService!.onIncomingCall = (event) {
        print(
          '📞 [WEBSOCKET EVENT] incomingCall: sessionId=${event.sessionId}, roomName=${event.roomName}, callerId=${event.callerId}',
        );
        incomingCall.value = event;
        // Optionally refresh pending calls
        _loadPendingCalls();
      };

      _webSocketService!.onCallAccepted = (event) {
        print(
          '✅ [WEBSOCKET EVENT] callAccepted: sessionId=${event.sessionId}, roomName=${event.roomName}',
        );
        print(
          '📊 [WEBSOCKET EVENT] Current sessionId: ${currentSessionId.value}',
        );
        if (event.sessionId == currentSessionId.value) {
          print(
            '✅ [WEBSOCKET EVENT] Session IDs match, updating call status to active',
          );
          callStatus.value = 'active';
          connectionStatus.value = 'Connected';
          // Start polling for call details when call is accepted (this includes report and statement)
          if (event.sessionId != null && event.sessionId!.isNotEmpty) {
            _startCallDetailsPolling();
          }
        } else {
          print(
            '⚠️ [WEBSOCKET EVENT] Session IDs do not match! Event: ${event.sessionId}, Current: ${currentSessionId.value}',
          );
        }
      };

      _webSocketService!.onCallRejected = (event) {
        print(
          '❌ [WEBSOCKET EVENT] callRejected: sessionId=${event.sessionId}, message=${event.message}',
        );
        if (event.sessionId == currentSessionId.value) {
          callStatus.value = 'ended';
          _handleCallEnded(shouldNavigate: false);
          AppToasts.showError(event.message ?? 'Call rejected');
        }
      };

      _webSocketService!.onCallEnded = (event) {
        print(
          '🔚 [WEBSOCKET EVENT] callEnded: sessionId=${event.sessionId}, duration=${event.duration}, message=${event.message}',
        );
        if (event.sessionId == currentSessionId.value) {
          callStatus.value = 'ended';
          // Clear ending call loading state when WebSocket confirms call ended
          isEndingCall.value = false;
          // Clear upload request when call ends
          currentUploadRequest.value = null;
          // _handleCallEnded will handle navigation based on whether report exists
          _handleCallEnded(shouldNavigate: true);
        }
      };

      _webSocketService!.onAttachmentUploadLink = (event) {
        print(
          '📎 [WEBSOCKET EVENT] ATTACHMENT_UPLOAD_LINK: reportId=${event.reportId}, url=${event.url?.substring(0, 50)}...',
        );
        print('📎 [WEBSOCKET EVENT] Description: ${event.description}');
        print('📎 [WEBSOCKET EVENT] Attachment Type: ${event.attachmentType}');
        print('📎 [WEBSOCKET EVENT] Expires At: ${event.expiresAt}');

        // Show upload popup
        currentUploadRequest.value = event;
        isUploadDialogOpen.value = true;

        // Show dialog
        final context = Get.context;
        if (context != null && !Get.isDialogOpen!) {
          Get.dialog(
            AttachmentUploadPopup(uploadLinkEvent: event),
            barrierDismissible: true, // Allow closing by tapping outside
          ).then((_) {
            // Update state when dialog is closed (either manually or automatically)
            isUploadDialogOpen.value = false;
            // Optionally clear the upload request when manually closed
            // currentUploadRequest.value = null; // Uncomment if you want to clear on manual close
          });
        }

        // Show toast notification
        if (context != null) {
          AppToasts.showSuccess(
            event.description ?? 'Please upload the requested file',
          );
        }
      };

      _webSocketService!.onAttachmentUploaded = (event) {
        print(
          '✅ [WEBSOCKET EVENT] ATTACHMENT_UPLOADED: reportId=${event.reportId}, fileName=${event.fileName}',
        );

        // Close upload popup safely
        _closeUploadDialogSafely();
        currentUploadRequest.value = null;
        isUploadDialogOpen.value = false;

        // Show success message
        final context = Get.context;
        if (context != null) {
          _showToastSafely(
            () => AppToasts.showSuccess(
              'File uploaded successfully: ${event.fileName ?? "File"}',
            ),
          );
        }
      };

      _webSocketService!.onAttachmentUploadFailed = (event) {
        print(
          '❌ [WEBSOCKET EVENT] ATTACHMENT_UPLOAD_FAILED: reportId=${event.reportId}, reason=${event.reason}',
        );

        // Close upload popup safely
        _closeUploadDialogSafely();
        currentUploadRequest.value = null;
        isUploadDialogOpen.value = false;

        // Show error message
        final context = Get.context;
        if (context != null) {
          _showToastSafely(
            () => AppToasts.showError(
              'Upload failed: ${event.reason ?? "Unknown error"}',
            ),
          );
        }
      };

      _webSocketService!.onConnected = () {
        print('✅ [WEBSOCKET] Direct Call WebSocket connected successfully');
        print('🔌 [WEBSOCKET] Socket ID: ${_webSocketService?.socketId}');
      };

      _webSocketService!.onDisconnected = () {
        print('❌ [WEBSOCKET] Direct Call WebSocket disconnected');
      };

      _webSocketService!.onError = (error) {
        print('❌ [WEBSOCKET ERROR] Error: $error');

        // Check if it's a network/internet error
        final errorString = error.toString().toLowerCase();
        final isNetworkError =
            errorString.contains('socketexception') ||
            errorString.contains('failed host lookup') ||
            errorString.contains('no address associated') ||
            errorString.contains('network is unreachable') ||
            errorString.contains('connection failed');

        if (isNetworkError && !connectivityUtil.isOnline.value) {
          print(
            '🌐 [WEBSOCKET ERROR] Network error detected, waiting for internet to come back...',
          );
          // Wait for internet and retry connection
          _waitForInternetAndRetryWebSocket();
          return;
        }

        // Don't show error toast for auth errors, perform anonymous login instead
        if (errorString.contains('auth') ||
            errorString.contains('unauthorized')) {
          print(
            '🔐 [WEBSOCKET ERROR] Auth error detected, performing anonymous login',
          );
          // Perform anonymous login
          _performAnonymousLogin().catchError((authError) {
            print('❌ [WEBSOCKET ERROR] Anonymous login failed: $authError');
          });
        }
        // Only show critical WebSocket errors that affect functionality
        // Non-critical errors are logged but not shown to user
      };

      // Connect
      print('🔌 [WEBSOCKET] Calling connect()...');
      await _webSocketService!.connect();
      print(
        '🔌 [WEBSOCKET] connect() completed, isConnected: ${_webSocketService?.isConnected}',
      );
    } catch (e, stackTrace) {
      print('❌ [WEBSOCKET ERROR] Exception connecting WebSocket: $e');
      print('❌ [WEBSOCKET ERROR] Stack trace: $stackTrace');
      final errorMessage = e.toString();

      // Check if it's a network/internet error
      final errorString = errorMessage.toLowerCase();
      final isNetworkError =
          errorString.contains('socketexception') ||
          errorString.contains('failed host lookup') ||
          errorString.contains('no address associated') ||
          errorString.contains('network is unreachable') ||
          errorString.contains('connection failed');

      if (isNetworkError && !connectivityUtil.isOnline.value) {
        print(
          '🌐 [WEBSOCKET ERROR] Network error detected, waiting for internet to come back...',
        );
        // Wait for internet and retry connection
        await _waitForInternetAndRetryWebSocket();
        return;
      }

      AppToasts.showError('WebSocket connection failed: $errorMessage');
      if (errorString.contains('auth') ||
          errorString.contains('token') ||
          errorString.contains('unauthorized')) {
        // Try anonymous login
        try {
          await _performAnonymousLogin();
        } catch (authError) {
          print('❌ [WEBSOCKET] Anonymous login failed: $authError');
        }
      }
      rethrow;
    }
  }

  /// Wait for internet connection and retry WebSocket connection
  Future<void> _waitForInternetAndRetryWebSocket() async {
    try {
      print('⏳ [WEBSOCKET RETRY] Waiting for internet connection...');
      final internetRestored = await connectivityUtil.waitForInternet(
        timeout: const Duration(seconds: 60),
      );

      if (internetRestored) {
        print(
          '✅ [WEBSOCKET RETRY] Internet restored, retrying WebSocket connection...',
        );
        // Small delay to ensure connection is stable
        await Future.delayed(const Duration(seconds: 2));
        // Retry WebSocket connection
        await _connectWebSocket();
      } else {
        print('⏰ [WEBSOCKET RETRY] Timeout waiting for internet, giving up');
        AppToasts.showError(
          'No internet connection. Please check your network and try again.',
        );
      }
    } catch (e, stackTrace) {
      print('❌ [WEBSOCKET RETRY] Error waiting for internet: $e');
      print('❌ [WEBSOCKET RETRY] Stack trace: $stackTrace');
      AppToasts.showError(
        'Failed to reconnect. Please check your internet connection.',
      );
    }
  }

  /// Wait for internet connection and retry call request
  Future<void> _waitForInternetAndRetryCall() async {
    try {
      print('⏳ [REQUEST CALL RETRY] Waiting for internet connection...');
      final internetRestored = await connectivityUtil.waitForInternet(
        timeout: const Duration(seconds: 60),
      );

      if (internetRestored) {
        print(
          '✅ [REQUEST CALL RETRY] Internet restored, retrying call request...',
        );
        // Small delay to ensure connection is stable
        await Future.delayed(const Duration(seconds: 2));
        // Retry call request
        await requestCall();
      } else {
        print('⏰ [REQUEST CALL RETRY] Timeout waiting for internet, giving up');
        callNetworkStatus.value = NetworkStatus.ERROR;
        callStatus.value = 'idle';
        AppToasts.showError(
          'No internet connection. Please check your network and try again.',
        );
      }
    } catch (e, stackTrace) {
      print('❌ [REQUEST CALL RETRY] Error waiting for internet: $e');
      print('❌ [REQUEST CALL RETRY] Stack trace: $stackTrace');
      callNetworkStatus.value = NetworkStatus.ERROR;
      callStatus.value = 'idle';
      AppToasts.showError(
        'Failed to reconnect. Please check your internet connection.',
      );
    }
  }

  /// Check if user is authenticated before performing call operations
  /// Performs anonymous login if not authenticated
  Future<bool> _checkAuthentication() async {
    final isAuthenticated = await AuthUtil().isFullyAuthenticated();
    if (!isAuthenticated) {
      // Perform anonymous login
      try {
        await _performAnonymousLogin();
        return true;
      } catch (e) {
        print('❌ [AUTH] Anonymous login failed: $e');
        return false;
      }
    }

    // Check if token is expired
    final token = await AuthUtil().getAccessToken();
    if (token == null || JwtUtil.isTokenExpired(token)) {
      // Perform anonymous login
      try {
        await _performAnonymousLogin();
        return true;
      } catch (e) {
        print('❌ [AUTH] Anonymous login failed: $e');
        return false;
      }
    }

    return true;
  }

  /// Load pending calls (Employee only)
  Future<void> _loadPendingCalls() async {
    // Check authentication first
    final isAuthenticated = await _checkAuthentication();
    if (!isAuthenticated) {
      return;
    }

    try {
      final calls = await _directCallService.getPendingCalls();
      pendingCalls.assignAll(calls);
    } catch (e) {
      print('Error loading pending calls: $e');
      // If it's an auth error, perform anonymous login
      if (e.toString().toLowerCase().contains('401') ||
          e.toString().toLowerCase().contains('unauthorized')) {
        try {
          await _performAnonymousLogin();
          // Retry loading pending calls after anonymous login
          await _loadPendingCalls();
        } catch (authError) {
          print('❌ [PENDING CALLS] Anonymous login failed: $authError');
        }
      }
    }
  }

  void _loadInitialData() {
    try {
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

      // Progress will be updated via WebSocket integration later
      // For now, initialize to step 0 (not started)
      currentProgressStep.value = 0;
      isConnectingToOfficer.value = false;
      isReportInitiated.value = false;
      isAttachmentUploading.value = false;

      // ID Information and documents will be loaded from call details when call is active
      // Keep empty initially, will be populated when call details are fetched
      idInformation.clear();
      supportingDocuments.clear();
    } catch (e, stackTrace) {
      print('❌ [INIT ERROR] Error loading initial data: $e');
      print('❌ [INIT ERROR] Stack trace: $stackTrace');
      AppToasts.showError('Failed to load initial data: ${e.toString()}');
    }
  }

  /// Connect to LiveKit room (internal helper)
  Future<void> _connectToLiveKitRoom({
    required String wsUrl,
    required String token,
    required String roomName,
  }) async {
    print('🎥 [LIVEKIT] ========== Starting LiveKit Connection ==========');
    print('🎥 [LIVEKIT] wsUrl: $wsUrl');
    print('🎥 [LIVEKIT] roomName: $roomName');
    print('🎥 [LIVEKIT] token: ${token.substring(0, 20)}...');

    try {
      // Create room
      print('🎥 [LIVEKIT] Creating Room instance...');
      _room = Room();
      print('🎥 [LIVEKIT] Room instance created');

      // Set up event listeners BEFORE connecting to catch connection errors
      print('🎥 [LIVEKIT] Setting up event listeners...');
      _room!.addListener(_onRoomChanged);
      _room!.addListener(() {
        _onRemoteParticipantsChanged();
      });
      print('🎥 [LIVEKIT] Event listeners set up');

      // Connect to room with timeout
      print('🎥 [LIVEKIT] Calling room.connect()...');
      connectionStatus.value = 'Connecting...';
      callStatus.value = 'connecting';

      // Start connection timeout monitor
      _startConnectionTimeoutMonitor();

      // Add connection timeout (30 seconds)
      // Configure audio capture options with enhanced noise cancellation
      // These settings improve audio quality by reducing background noise,
      // echo from speakers, and automatically adjusting microphone gain
      await _room!
          .connect(
            wsUrl,
            token,
            roomOptions: const RoomOptions(
              adaptiveStream: true,
              dynacast: true,
              defaultAudioCaptureOptions: AudioCaptureOptions(
                // Echo cancellation: Prevents microphone from picking up audio from speakers
                // This eliminates echo/feedback in video calls
                echoCancellation: true,

                // Noise suppression: Reduces background noise (traffic, music, voices, etc.)
                // This improves audio clarity for other participants
                noiseSuppression: true,

                // Auto gain control: Automatically adjusts microphone sensitivity
                // This ensures consistent audio levels regardless of distance from mic
                autoGainControl: true,
              ),
            ),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('❌ [LIVEKIT] Connection timeout after 30 seconds');
              throw TimeoutException(
                'Connection timeout: Failed to connect to video call server within 30 seconds. Please check your internet connection and try again.',
              );
            },
          );

      print('🎥 [LIVEKIT] room.connect() completed');

      // Wait a bit for connection state to stabilize
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if connection actually succeeded
      if (_room!.connectionState != ConnectionState.connected) {
        print(
          '❌ [LIVEKIT] Connection state is not connected: ${_room!.connectionState}',
        );
        throw Exception(
          'Connection failed: Room state is ${_room!.connectionState}',
        );
      }

      _localParticipant = _room!.localParticipant;
      print(
        '🎥 [LIVEKIT] Local participant: ${_localParticipant != null ? "exists" : "null"}',
      );

      if (_localParticipant == null) {
        print('❌ [LIVEKIT] Local participant is null after connection');
        throw Exception('Connection failed: Local participant is null');
      }

      print(
        '🎥 [LIVEKIT] Local participant identity: ${_localParticipant!.identity}',
      );
      print('🎥 [LIVEKIT] Local participant sid: ${_localParticipant!.sid}');

      isConnected.value = true;
      connectionStatus.value = 'Connected';
      callStatus.value = 'active';

      print(
        '🎥 [LIVEKIT] Connection state updated - isConnected: ${isConnected.value}',
      );
      print('🎥 [LIVEKIT] Room connection state: ${_room!.connectionState}');

      // Start polling for call details when call becomes active (this includes report and statement)
      final sessionId = currentSessionId.value;
      if (sessionId != null && sessionId.isNotEmpty) {
        _startCallDetailsPolling();
      }

      // Enable camera and microphone (this stream is what admin/officer sees)
      print(
        '🎥 [LIVEKIT] Enabling video (kiosk: use second front camera if 2 front cameras)...',
      );
      try {
        await enableVideo();
        print('🎥 [LIVEKIT] Video enabled: ${isVideoEnabled.value}');
        
        // For VP9 codec on Android, wait a bit longer before enabling audio
        // This ensures the video track is fully published and stable
        final codec = currentVideoCodec.value;
        if (codec == 'VP9') {
          print('🎤 [LIVEKIT] VP9 codec detected, waiting extra time before enabling audio...');
          await Future.delayed(const Duration(milliseconds: 1500));
        } else {
          // For other codecs, shorter delay
          await Future.delayed(const Duration(milliseconds: 800));
        }
      } catch (e) {
        print('⚠️ [LIVEKIT] Warning: Failed to enable video: $e');
        // Error toast already shown in enableVideo()
      }

      print('🎥 [LIVEKIT] ========== ENABLING AUDIO ==========');
      print('🎥 [LIVEKIT] Video codec: ${currentVideoCodec.value}');
      print('🎥 [LIVEKIT] Video enabled: ${isVideoEnabled.value}');
      print('🎥 [LIVEKIT] Room connected: ${_room!.connectionState == ConnectionState.connected}');
      print('🎥 [LIVEKIT] Local participant exists: ${_localParticipant != null}');
      
      try {
        await enableAudio();
        print('🎥 [LIVEKIT] enableAudio() completed, isAudioEnabled: ${isAudioEnabled.value}');
        
        // Verify audio is actually working after a short delay
        print('🎥 [LIVEKIT] Verifying audio track after enablement...');
        await Future.delayed(const Duration(milliseconds: 500));
        
        final audioPublications = _localParticipant!.audioTrackPublications
            .where((pub) => pub.source == TrackSource.microphone)
            .toList();
        
        print('🎥 [LIVEKIT] Found ${audioPublications.length} audio publication(s) after enable');
        
        final audioTracks = audioPublications
            .where((pub) => pub.track != null)
            .map((pub) => pub.track)
            .whereType<LocalAudioTrack>()
            .toList();
        
        print('🎥 [LIVEKIT] Found ${audioTracks.length} audio track(s)');
        
        for (var track in audioTracks) {
          print('🎥 [LIVEKIT] Track enabled: ${track.mediaStreamTrack.enabled}');
          print('🎥 [LIVEKIT] Track muted: ${track.muted}');
          print('🎥 [LIVEKIT] Track ID: ${track.mediaStreamTrack.id}');
          print('🎥 [LIVEKIT] Track label: ${track.mediaStreamTrack.label}');
        }
        
        if (audioTracks.isEmpty) {
          print('⚠️ [LIVEKIT] No audio track found after enable, retrying...');
          print('⚠️ [LIVEKIT] Retry attempt 1...');
          
          // Retry once with longer delay for VP9
          final retryDelay = currentVideoCodec.value == 'VP9' ? 1000 : 500;
          await Future.delayed(Duration(milliseconds: retryDelay));
          
          try {
            await enableAudio();
            print('🎥 [LIVEKIT] Retry enableAudio() completed');
            
            // Verify again
            await Future.delayed(const Duration(milliseconds: 500));
            final retryAudioTracks = _localParticipant!.audioTrackPublications
                .where((pub) => pub.source == TrackSource.microphone && pub.track != null)
                .map((pub) => pub.track)
                .whereType<LocalAudioTrack>()
                .toList();
            
            if (retryAudioTracks.isEmpty) {
              print('❌ [LIVEKIT] ERROR: Still no audio tracks after retry!');
              print('❌ [LIVEKIT] Audio may not work properly');
            } else {
              print('✅ [LIVEKIT] Audio track found after retry');
            }
          } catch (retryError, retryStack) {
            print('❌ [LIVEKIT] ERROR: Retry enableAudio() failed: $retryError');
            print('❌ [LIVEKIT] Stack trace: $retryStack');
          }
        } else {
          // Verify tracks are enabled and unmuted
          final enabledTracks = audioTracks.where((t) => 
            t.mediaStreamTrack.enabled && !t.muted
          ).toList();
          
          if (enabledTracks.isEmpty) {
            print('⚠️ [LIVEKIT] WARNING: Audio tracks exist but none are enabled/unmuted!');
            print('⚠️ [LIVEKIT] Attempting to enable tracks...');
            
            for (var track in audioTracks) {
              if (!track.mediaStreamTrack.enabled) {
                track.mediaStreamTrack.enabled = true;
                print('🎤 [LIVEKIT] Enabled track: ${track.mediaStreamTrack.id}');
              }
              if (track.muted) {
                // Note: LiveKit tracks don't have direct unmute, need to use participant
                print('⚠️ [LIVEKIT] Track is muted, may need to unmute via participant');
              }
            }
          } else {
            print('✅ [LIVEKIT] Audio track is enabled and ready');
          }
        }
        
        print('🎥 [LIVEKIT] ====================================');
      } catch (e, stackTrace) {
        print('❌ [LIVEKIT] ========== AUDIO ENABLEMENT ERROR ==========');
        print('❌ [LIVEKIT] Error: $e');
        print('❌ [LIVEKIT] Type: ${e.runtimeType}');
        print('❌ [LIVEKIT] Stack trace: $stackTrace');
        print('❌ [LIVEKIT] Video codec: ${currentVideoCodec.value}');
        print('❌ [LIVEKIT] Room state: ${_room?.connectionState}');
        print('❌ [LIVEKIT] =============================================');
        // Error toast already shown in enableAudio()
      }

      // Get local video track
      print('🎥 [LIVEKIT] Updating local video track...');
      _updateLocalVideoTrack();
      print(
        '🎥 [LIVEKIT] Local video track: ${localVideoTrack.value != null ? "exists" : "null"}',
      );

      // Log room participants
      print(
        '🎥 [LIVEKIT] Remote participants count: ${_room!.remoteParticipants.length}',
      );
      print('🎥 [LIVEKIT] ========== LiveKit Connection Complete ==========');

      // Cancel timeout monitor since connection succeeded
      _connectionTimeoutTimer?.cancel();
      _connectionTimeoutTimer = null;
    } on TimeoutException catch (e) {
      print('❌ [LIVEKIT ERROR] Connection timeout: $e');
      _connectionTimeoutTimer?.cancel();
      _connectionTimeoutTimer = null;
      connectionStatus.value = 'Connection timeout';
      isConnected.value = false;
      callStatus.value = 'idle';
      callNetworkStatus.value = NetworkStatus.ERROR;
      AppToasts.showError(
        'Failed to connect to video call server. This may be due to slow internet connection or server issues.',
      );
      await _handleCallEnded(shouldNavigate: false);
    } catch (e, stackTrace) {
      print('❌ [LIVEKIT ERROR] Exception connecting to LiveKit: $e');
      print('❌ [LIVEKIT ERROR] Stack trace: $stackTrace');
      connectionStatus.value = 'Connection failed';
      isConnected.value = false;
      callStatus.value = 'idle';

      // Show user-friendly error message
      String errorMessage = 'Failed to connect to video call';
      if (e.toString().contains('timeout')) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('socket')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('permission') ||
          e.toString().contains('camera') ||
          e.toString().contains('microphone')) {
        errorMessage =
            'Camera or microphone permission error. Please grant permissions and try again.';
      } else if (e.toString().contains('token') ||
          e.toString().contains('auth')) {
        errorMessage = 'Authentication error. Please try logging in again.';
      }

      AppToasts.showError(errorMessage);
      _connectionTimeoutTimer?.cancel();
      _connectionTimeoutTimer = null;
      await _handleCallEnded(shouldNavigate: false);
    }
  }

  /// Start connection timeout monitor
  /// This will show an error if connection is stuck in "connecting" state for too long
  void _startConnectionTimeoutMonitor() {
    _connectionTimeoutTimer?.cancel();

    _connectionTimeoutTimer = Timer(const Duration(seconds: 35), () {
      // Check if still connecting after timeout
      if (callStatus.value == 'connecting' &&
          (connectionStatus.value == 'Connecting...' ||
              connectionStatus.value == 'Reconnecting...')) {
        print(
          '❌ [CONNECTION TIMEOUT] Connection stuck in connecting state for 35 seconds',
        );
        AppToasts.showError(
          'Connection is taking too long. Please check your internet and try again.',
        );
        callNetworkStatus.value = NetworkStatus.ERROR;
        callStatus.value = 'idle';
        connectionStatus.value = 'Connection timeout';
        _handleCallEnded(shouldNavigate: false);
      }
    });
  }

  /// Enumerate available cameras by testing different positions
  /// For multiple front cameras, we'll add front position multiple times
  /// and cycle through them using device switching
  Future<void> _enumerateCameras() async {
    try {
      print('📷 [CAMERA] Enumerating available cameras...');

      // Test which camera positions are available
      final positions = <CameraPosition>[];

      // Add front camera (may have multiple front cameras on some devices)
      positions.add(CameraPosition.front);

      // Try to add back camera if available
      // Note: On devices with only front cameras, back might not be available
      // but we'll add it anyway and handle errors gracefully
      positions.add(CameraPosition.back);

      // For devices with multiple front cameras (like smart police station machines),
      // we'll add front position again to allow cycling through front cameras
      // The actual device switching will be handled in switchCamera()
      positions.add(CameraPosition.front); // Second front camera option

      availableCameraPositions.assignAll(positions);
      hasMultipleCameras.value = positions.length > 1;
      currentCameraIndex.value = 0;

      print('📷 [CAMERA] Available camera positions: ${positions.length}');
      for (var i = 0; i < positions.length; i++) {
        print('📷 [CAMERA] Position $i: ${positions[i]}');
      }

      if (hasMultipleCameras.value) {
        print(
          '📷 [CAMERA] Multiple cameras detected, camera switching enabled',
        );
      }
    } catch (e, stackTrace) {
      print('❌ [CAMERA ERROR] Error enumerating cameras: $e');
      print('❌ [CAMERA ERROR] Stack trace: $stackTrace');
      // Continue without camera enumeration - single camera assumed
      availableCameraPositions.clear();
      hasMultipleCameras.value = false;
    }
  }

  /// Enumerate actual media devices (cameras and microphones) for debugging
  Future<void> _enumerateMediaDevices() async {
    try {
      print('🎬 [MEDIA DEVICES] Enumerating media devices...');

      // Get all media devices using LiveKit's Hardware class
      final devices = await Hardware.instance.enumerateDevices();

      print('🎬 [MEDIA DEVICES] Total devices found: ${devices.length}');

      // Filter cameras
      final cameras = devices.where((d) => d.kind == 'videoinput').toList();
      availableCameras.assignAll(cameras);
      hasMultipleCameras.value = cameras.length > 1;

      print('📷 [MEDIA DEVICES] Cameras found: ${cameras.length}');
      for (var i = 0; i < cameras.length; i++) {
        print('📷 [MEDIA DEVICES] Camera $i:');
        print('   - Device ID: ${cameras[i].deviceId}');
        print('   - Label: ${cameras[i].label}');
        print('   - Kind: ${cameras[i].kind}');
      }

      // Filter microphones
      final microphones = devices.where((d) => d.kind == 'audioinput').toList();
      availableMicrophones.assignAll(microphones);

      print('🎤 [MEDIA DEVICES] Microphones found: ${microphones.length}');
      for (var i = 0; i < microphones.length; i++) {
        print('🎤 [MEDIA DEVICES] Microphone $i:');
        print('   - Device ID: ${microphones[i].deviceId}');
        print('   - Label: ${microphones[i].label}');
        print('   - Kind: ${microphones[i].kind}');
      }

      // Try to detect current camera device ID
      if (_localParticipant != null) {
        final videoTrack = _localParticipant!.videoTrackPublications
            .where((pub) => pub.source == TrackSource.camera)
            .map((pub) => pub.track)
            .whereType<LocalVideoTrack>()
            .firstOrNull;

        if (videoTrack != null) {
          // Get device ID from track settings
          final settings = videoTrack.mediaStreamTrack.getSettings();
          final deviceId = settings['deviceId'];
          final facingMode = settings['facingMode'];

          print('📷 [MEDIA DEVICES] Track settings:');
          print('   - deviceId: $deviceId');
          print('   - facingMode: $facingMode');

          if (deviceId != null) {
            currentCameraDeviceId.value = deviceId.toString();
            print(
              '📷 [MEDIA DEVICES] Current camera device ID (from track): ${currentCameraDeviceId.value}',
            );
          }

          // Try to match by label if device IDs don't match
          // Look for camera with matching facing mode or position
          if (facingMode != null && cameras.isNotEmpty) {
            final isFrontCamera =
                facingMode.toString().toLowerCase().contains('user') ||
                facingMode.toString().toLowerCase().contains('front');
            final matchingCamera = cameras.firstWhere(
              (cam) => isFrontCamera
                  ? cam.label.toLowerCase().contains('front')
                  : cam.label.toLowerCase().contains('back'),
              orElse: () => cameras.first,
            );

            if (matchingCamera.deviceId != currentCameraDeviceId.value) {
              print(
                '📷 [MEDIA DEVICES] Using label-based match: ${matchingCamera.deviceId} (${matchingCamera.label})',
              );
              currentCameraDeviceId.value = matchingCamera.deviceId;
            }
          }
        }
      }

      print('✅ [MEDIA DEVICES] Media device enumeration complete');
    } catch (e, stackTrace) {
      print('❌ [MEDIA DEVICES ERROR] Error enumerating media devices: $e');
      print('❌ [MEDIA DEVICES ERROR] Stack trace: $stackTrace');
    }
  }

  /// Update local video track (local participant: use source == camera, not subscribed)
  void _updateLocalVideoTrack() {
    if (_localParticipant == null) {
      localVideoTrack.value = null;
      return;
    }

    // For local participant, get camera track by source (subscribed is for remote)
    final videoTrack = _localParticipant!.videoTrackPublications
        .where((pub) => pub.source == TrackSource.camera && pub.track != null)
        .map((pub) => pub.track)
        .whereType<LocalVideoTrack>()
        .firstOrNull;

    localVideoTrack.value = videoTrack;
  }

  /// Room event handler
  void _onRoomChanged() {
    if (_room == null) {
      print('⚠️ [ROOM EVENT] Room is null');
      return;
    }

    print(
      '🔄 [ROOM EVENT] Room changed - ConnectionState: ${_room!.connectionState}',
    );

    final previousState = connectionStatus.value;

    // Update connection status
    if (_room!.connectionState == ConnectionState.connected) {
      print('✅ [ROOM EVENT] Room connected');
      connectionStatus.value = 'Connected';
      isConnected.value = true;
      callStatus.value = 'active';
      // Sync remote participants immediately (fixes admin black screen when admin joins after kiosk)
      _onRemoteParticipantsChanged();
      // Delayed sync to catch late-arriving participant/track updates (LiveKit can notify track after connect)
      _remoteVideoTrackSyncTimer?.cancel();
      _remoteVideoTrackSyncTimer = Timer(const Duration(milliseconds: 500), () {
        _remoteVideoTrackSyncTimer = null;
        if (_room != null &&
            _room!.connectionState == ConnectionState.connected) {
          _onRemoteParticipantsChanged();
          print(
            '🎥 [REMOTE TRACK] Delayed sync after connect (admin black screen fix)',
          );
        }
      });
      // Start polling for call details if we have a session ID
      final sessionId = currentSessionId.value;
      if (sessionId != null &&
          sessionId.isNotEmpty &&
          callDetails.value == null) {
        _startCallDetailsPolling();
      }
    } else if (_room!.connectionState == ConnectionState.disconnected) {
      print('❌ [ROOM EVENT] Room disconnected');
      connectionStatus.value = 'Disconnected';
      isConnected.value = false;
      // Only show error if we were previously connected (not if we're just starting)
      if (previousState == 'Connected') {
        // Only show toast if we have a valid context (avoid overlay errors)
        try {
          AppToasts.showError('Connection lost. Please try again.');
        } catch (e) {
          print(
            '⚠️ [ROOM EVENT] Could not show toast (overlay not available): $e',
          );
        }
        callStatus.value = 'idle';
        _handleCallEnded(shouldNavigate: false);
      }
    } else if (_room!.connectionState == ConnectionState.connecting) {
      print('🔄 [ROOM EVENT] Room connecting...');
      connectionStatus.value = 'Connecting...';
      callStatus.value = 'connecting';
    } else if (_room!.connectionState == ConnectionState.reconnecting) {
      print('🔄 [ROOM EVENT] Room reconnecting...');
      connectionStatus.value = 'Reconnecting...';
    }

    // Check for connection errors
    if (_room!.connectionState == ConnectionState.disconnected &&
        (previousState == 'Connecting...' ||
            previousState == 'Reconnecting...')) {
      print('❌ [ROOM EVENT] Connection failed during connect/reconnect');
      // Only show toast if we have a valid context (avoid overlay errors)
      try {
        AppToasts.showError(
          'Failed to connect. Please check your internet and try again.',
        );
      } catch (e) {
        print(
          '⚠️ [ROOM EVENT] Could not show toast (overlay not available): $e',
        );
      }
      callStatus.value = 'idle';
      callNetworkStatus.value = NetworkStatus.ERROR;
    }

    print(
      '🔄 [ROOM EVENT] Remote participants: ${_room!.remoteParticipants.length}',
    );
    print(
      '🔄 [ROOM EVENT] Local participant: ${_room!.localParticipant != null ? "exists" : "null"}',
    );

    // Update local video track
    _updateLocalVideoTrack();
  }

  /// Update reactive remote video track (so admin UI rebuilds when track becomes available).
  /// Workaround for LiveKit Flutter #919 (Android): publication.track can be null after subscribe;
  /// we retry periodically until the SDK sets it.
  void _updateRemoteVideoTrack() {
    if (remoteParticipants.isEmpty) {
      _remoteVideoTrackRetryTimer?.cancel();
      _remoteVideoTrackRetryTimer = null;
      _remoteVideoTrackRetryCount = 0;
      remoteVideoTrack.value = null;
      return;
    }
    final track = getRemoteVideoTrack(remoteParticipants.first);
    if (track != null) {
      _remoteVideoTrackRetryTimer?.cancel();
      _remoteVideoTrackRetryTimer = null;
      _remoteVideoTrackRetryCount = 0;
      if (track != remoteVideoTrack.value) {
        remoteVideoTrack.value = track;
        print('🎥 [REMOTE TRACK] Updated remoteVideoTrack: true');
      }
      return;
    }
    // Track is null but we may have a subscribed video publication (SDK sets track async on Android)
    final hasSubscribedVideo = remoteParticipants.any(
      (p) => p.videoTrackPublications.any((pub) => pub.subscribed),
    );
    if (hasSubscribedVideo && _remoteVideoTrackRetryTimer == null) {
      _remoteVideoTrackRetryCount = 0;
      _remoteVideoTrackRetryTimer = Timer.periodic(
        _remoteVideoTrackRetryInterval,
        (_) {
          _remoteVideoTrackRetryCount++;
          if (_remoteVideoTrackRetryCount > _remoteVideoTrackRetryMax) {
            _remoteVideoTrackRetryTimer?.cancel();
            _remoteVideoTrackRetryTimer = null;
            _remoteVideoTrackRetryCount = 0;
            print(
              '🎥 [REMOTE TRACK] Retry timeout waiting for remote video track',
            );
            return;
          }
          _updateRemoteVideoTrack();
        },
      );
      print(
        '🎥 [REMOTE TRACK] Started retry polling for remote video track (LiveKit #919 workaround)',
      );
    }
  }

  /// Remote participants event handler
  void _onRemoteParticipantsChanged() {
    if (_room == null) {
      print('⚠️ [PARTICIPANTS] Room is null');
      return;
    }

    final participants = _room!.remoteParticipants.values.toList();
    print(
      '👥 [PARTICIPANTS] Remote participants changed: ${participants.length}',
    );

    // Remove listeners from participants no longer in the room
    for (var entry in _remoteParticipantListeners.entries.toList()) {
      if (!participants.contains(entry.key)) {
        try {
          entry.key.removeListener(entry.value);
        } catch (_) {}
        _remoteParticipantListeners.remove(entry.key);
      }
    }

    for (var participant in participants) {
      print(
        '👥 [PARTICIPANTS] - Identity: ${participant.identity}, SID: ${participant.sid}',
      );
      print(
        '👥 [PARTICIPANTS] - Video tracks: ${participant.videoTrackPublications.length}',
      );
      print(
        '👥 [PARTICIPANTS] - Audio tracks: ${participant.audioTrackPublications.length}',
      );

      for (var videoPub in participant.videoTrackPublications) {
        print(
          '👥 [PARTICIPANTS]   Video track: subscribed=${videoPub.subscribed}, muted=${videoPub.muted}, track=${videoPub.track != null}',
        );
      }

      // Log audio track details for remote participants
      print('🎤 [REMOTE AUDIO] ========== REMOTE AUDIO TRACKS ==========');
      print('🎤 [REMOTE AUDIO] Participant: ${participant.identity}');
      print('🎤 [REMOTE AUDIO] Audio publications count: ${participant.audioTrackPublications.length}');
      
      for (var audioPub in participant.audioTrackPublications) {
        print('🎤 [REMOTE AUDIO]   Publication ${audioPub.sid}:');
        print('🎤 [REMOTE AUDIO]     - Source: ${audioPub.source}');
        print('🎤 [REMOTE AUDIO]     - Subscribed: ${audioPub.subscribed}');
        print('🎤 [REMOTE AUDIO]     - Muted: ${audioPub.muted}');
        print('🎤 [REMOTE AUDIO]     - Has track: ${audioPub.track != null}');
        
        if (audioPub.track != null) {
          final audioTrack = audioPub.track as RemoteAudioTrack;
          try {
            print('🎤 [REMOTE AUDIO]     - Track enabled: ${audioTrack.mediaStreamTrack.enabled}');
            print('🎤 [REMOTE AUDIO]     - Track muted: ${audioTrack.muted}');
            print('🎤 [REMOTE AUDIO]     - Track ID: ${audioTrack.mediaStreamTrack.id}');
            print('🎤 [REMOTE AUDIO]     - Track label: ${audioTrack.mediaStreamTrack.label}');
            
            // Try to get track settings
            try {
              final settings = audioTrack.mediaStreamTrack.getSettings();
              print('🎤 [REMOTE AUDIO]     - Track settings: $settings');
            } catch (e) {
              print('⚠️ [REMOTE AUDIO]     - Could not read settings: $e');
            }
          } catch (e) {
            print('⚠️ [REMOTE AUDIO]     - Error reading track properties: $e');
          }
        } else {
          print('⚠️ [REMOTE AUDIO]     - WARNING: Audio track is null!');
        }
      }
      
      // Check if we need to subscribe to audio tracks
      final unsubscribedAudio = participant.audioTrackPublications
          .where((pub) => !pub.subscribed)
          .toList();
      
      if (unsubscribedAudio.isNotEmpty) {
        print('⚠️ [REMOTE AUDIO] Found ${unsubscribedAudio.length} unsubscribed audio publication(s)');
        print('⚠️ [REMOTE AUDIO] Attempting to subscribe to audio tracks...');
        
        for (var pub in unsubscribedAudio) {
          try {
            print('🎤 [REMOTE AUDIO] Subscribing to audio publication ${pub.sid}...');
            // Note: LiveKit SDK should auto-subscribe, but we log if it doesn't
            // The subscription happens automatically when track is available
          } catch (e) {
            print('❌ [REMOTE AUDIO] Error subscribing to audio: $e');
          }
        }
      } else {
        print('✅ [REMOTE AUDIO] All audio publications are subscribed');
      }
      
      print('🎤 [REMOTE AUDIO] =========================================');

      // Listen to participant so we update when track gets subscribed (fixes admin black screen)
      if (!_remoteParticipantListeners.containsKey(participant)) {
        void onParticipantChanged() {
          _updateRemoteVideoTrack();
          // Also log audio tracks when participant changes
          _logRemoteAudioTracks(participant);
        }

        participant.addListener(onParticipantChanged);
        _remoteParticipantListeners[participant] = onParticipantChanged;
      }
    }

    remoteParticipants.assignAll(participants);
    _updateRemoteVideoTrack();
    print(
      '👥 [PARTICIPANTS] Updated remoteParticipants list: ${remoteParticipants.length}',
    );
  }

  /// Helper method to log remote audio track details
  void _logRemoteAudioTracks(RemoteParticipant participant) {
    try {
      print('🎤 [REMOTE AUDIO UPDATE] Participant: ${participant.identity}');
      final audioPubs = participant.audioTrackPublications;
      print('🎤 [REMOTE AUDIO UPDATE] Audio publications: ${audioPubs.length}');
      
      for (var pub in audioPubs) {
        final trackKey = '${participant.identity}_${pub.sid}';
        final previousMuted = _previousRemoteAudioMutedStates[trackKey];
        final currentMuted = pub.muted;
        
        if (pub.track != null) {
          final track = pub.track as RemoteAudioTrack;
          final trackMuted = track.muted;
          final isEnabled = track.mediaStreamTrack.enabled;
          final isSubscribed = pub.subscribed;
          
          print('🎤 [REMOTE AUDIO UPDATE] Track ${pub.sid}:');
          print('🎤 [REMOTE AUDIO UPDATE]   - Subscribed: $isSubscribed');
          print('🎤 [REMOTE AUDIO UPDATE]   - Publication muted: $currentMuted');
          print('🎤 [REMOTE AUDIO UPDATE]   - Track muted: $trackMuted');
          print('🎤 [REMOTE AUDIO UPDATE]   - Track enabled: $isEnabled');
          print('🎤 [REMOTE AUDIO UPDATE]   - Track ID: ${track.mediaStreamTrack.id}');
          print('🎤 [REMOTE AUDIO UPDATE]   - Track label: ${track.mediaStreamTrack.label}');
          
          // Detect muting state changes
          if (previousMuted != null && previousMuted != currentMuted) {
            if (currentMuted) {
              print('🔇 [REMOTE AUDIO UPDATE] ⚠️ REMOTE AUDIO MUTED! (was unmuted)');
              print('🔇 [REMOTE AUDIO UPDATE] The remote participant has muted their microphone');
              print('🔇 [REMOTE AUDIO UPDATE] You will not be able to hear them until they unmute');
            } else {
              print('🔊 [REMOTE AUDIO UPDATE] ✅ REMOTE AUDIO UNMUTED! (was muted)');
              print('🔊 [REMOTE AUDIO UPDATE] The remote participant has unmuted their microphone');
            }
          } else if (previousMuted == null && currentMuted) {
            print('🔇 [REMOTE AUDIO UPDATE] ⚠️ REMOTE AUDIO IS MUTED');
            print('🔇 [REMOTE AUDIO UPDATE] The remote participant has their microphone muted');
          }
          
          // Update previous state
          _previousRemoteAudioMutedStates[trackKey] = currentMuted;
          
          // Warn about issues
          if (!isSubscribed) {
            print('⚠️ [REMOTE AUDIO UPDATE] ⚠️ WARNING: Not subscribed to remote audio!');
            print('⚠️ [REMOTE AUDIO UPDATE] This means audio is not being received');
          }
          if (currentMuted || trackMuted) {
            print('⚠️ [REMOTE AUDIO UPDATE] ⚠️ WARNING: Remote audio is muted');
          }
          if (!isEnabled) {
            print('⚠️ [REMOTE AUDIO UPDATE] ⚠️ WARNING: Remote audio track is disabled');
          }
        } else {
          print('⚠️ [REMOTE AUDIO UPDATE] Publication ${pub.sid}: track is null');
          // Clear previous state if track is null
          _previousRemoteAudioMutedStates.remove(trackKey);
        }
      }
    } catch (e, stackTrace) {
      print('⚠️ [REMOTE AUDIO UPDATE] Error logging audio tracks: $e');
      print('⚠️ [REMOTE AUDIO UPDATE] Stack trace: $stackTrace');
    }
  }

  /// Get preferred language from LanguageController if available
  String? _getPreferredLanguage() {
    try {
      // Try to get LanguageController instance
      if (Get.isRegistered<LanguageController>()) {
        final languageController = Get.find<LanguageController>();
        final selectedIndex = languageController.selectedLanguageIndex.value;

        // Check if a language was actually selected (index >= 0)
        if (selectedIndex >= 0 &&
            selectedIndex < LanguageView.allLanguages.length) {
          final languageName =
              LanguageView.allLanguages[selectedIndex]['name'] as String;
          print(
            '🌐 [LANGUAGE] Found selected language: $languageName (index: $selectedIndex)',
          );
          return languageName;
        } else {
          print('🌐 [LANGUAGE] No language selected (index: $selectedIndex)');
          return null;
        }
      } else {
        print('🌐 [LANGUAGE] LanguageController not registered');
        return null;
      }
    } catch (e) {
      print('⚠️ [LANGUAGE] Error getting preferred language: $e');
      return null;
    }
  }

  /// Load call details from backend
  Future<void> _loadCallDetails(String sessionId) async {
    if (sessionId.isEmpty) {
      print('⚠️ [CALL DETAILS] Cannot load call details: sessionId is empty');
      return;
    }

    // Prevent overlapping requests
    if (_isLoadingCallDetails) {
      print('⏳ [CALL DETAILS] Request already in progress, skipping...');
      return;
    }

    _isLoadingCallDetails = true;

    try {
      print('📋 [CALL DETAILS] Loading call details for session: $sessionId');

      // Add timestamp for cache-busting to ensure fresh data in release mode
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await _directCallService.getCallDetails(
        sessionId,
        timestamp,
      );

      if (response.success == true && response.data != null) {
        callDetails.value = response.data;
        print('✅ [CALL DETAILS] Call details loaded successfully');
        print('  - Caller: ${response.data!.caller?.name ?? "Unknown"}');
        print('  - Receiver: ${response.data!.receiver?.name ?? "Unknown"}');
        print('  - Status: ${response.data!.status}');

        // Extract report and statement info
        final newReport = response.data!.report;
        final newStatement = response.data!.statement;

        // Check if statement text changed to detect updates
        bool statementChanged = false;
        bool reportChanged = false;

        if (newStatement != null && statementInfo.value != null) {
          final oldStatementText = statementInfo.value!.statement ?? '';
          final newStatementText = newStatement.statement ?? '';
          final oldStatementId = statementInfo.value!.id ?? '';
          final newStatementId = newStatement.id ?? '';

          if (oldStatementText != newStatementText ||
              oldStatementId != newStatementId) {
            statementChanged = true;
            print('🔄 [CALL DETAILS] Statement changed detected');
            print('  - Old length: ${oldStatementText.length}');
            print('  - New length: ${newStatementText.length}');
            if (oldStatementText != newStatementText) {
              print('  - Text changed!');
            }
            if (oldStatementId != newStatementId) {
              print('  - ID changed: $oldStatementId -> $newStatementId');
            }
          }
        } else if (newStatement != null && statementInfo.value == null) {
          // First time statement appears
          statementChanged = true;
          print('🔄 [CALL DETAILS] Statement appeared for the first time');
        }

        if (newReport != null && reportInfo.value != null) {
          final oldReportId = reportInfo.value!.id ?? '';
          final newReportId = newReport.id ?? '';
          if (oldReportId != newReportId) {
            reportChanged = true;
            print('🔄 [CALL DETAILS] Report changed detected');
          }
        } else if (newReport != null && reportInfo.value == null) {
          reportChanged = true;
          print('🔄 [CALL DETAILS] Report appeared for the first time');
        }

        // Always update values - create new references to ensure GetX detects changes
        // This is important in release mode where object references might be optimized
        final oldReportSubmitted = reportInfo.value?.submitted ?? false;
        reportInfo.value = newReport;
        statementInfo.value = newStatement;

        // Force refresh to ensure UI updates immediately
        // Use update() method which is more reliable in release mode
        if (statementChanged || newStatement != null) {
          statementInfo.refresh();
          // Also trigger update on the observable
          statementInfo.value = newStatement; // Re-assign to trigger change
          print('🔄 [CALL DETAILS] Forced statementInfo refresh and update');
        }

        if (reportChanged || newReport != null) {
          reportInfo.refresh();
          reportInfo.value = newReport; // Re-assign to trigger change

          // Auto-confirm when report is submitted (only if coming from Fayda verification)
          final newReportSubmitted = newReport?.submitted ?? false;
          if (!oldReportSubmitted &&
              newReportSubmitted &&
              faydaTransactionID.value.isNotEmpty) {
            print(
              '✅ [AUTO CONFIRM] Report submitted, auto-confirming for Fayda user...',
            );
            // Auto-confirm after a short delay to allow UI to update
            Future.delayed(const Duration(milliseconds: 1000), () {
              confirmReportSubmission();
            });
          }
        }

        if (newReport != null) {
          print(
            '✅ [CALL DETAILS] Report found: ${newReport.caseNumber ?? "No case number"}',
          );
          print('  - Report Type: ${newReport.reportType?.name ?? "Unknown"}');
        }

        if (newStatement != null) {
          print('✅ [CALL DETAILS] Statement found: ${newStatement.id}');
          print('  - Person: ${newStatement.person?.fullName ?? "Unknown"}');
          print('  - Statement length: ${newStatement.statement?.length ?? 0}');
        }

        // Update ID Information from call details
        _updateIdInformationFromCallDetails(response.data!);
      } else {
        print('⚠️ [CALL DETAILS] API returned success=false or data is null');
      }
    } catch (e, stackTrace) {
      print('❌ [CALL DETAILS] Error loading call details: $e');
      print('❌ [CALL DETAILS] Stack trace: $stackTrace');

      // Check if it's a network/internet error
      final errorString = e.toString().toLowerCase();
      final isNetworkError =
          errorString.contains('socketexception') ||
          errorString.contains('failed host lookup') ||
          errorString.contains('no address associated') ||
          errorString.contains('network is unreachable') ||
          errorString.contains('connection failed') ||
          (e is dio.DioException &&
              (e.type == dio.DioExceptionType.connectionError ||
                  e.type == dio.DioExceptionType.connectionTimeout));

      if (isNetworkError && !connectivityUtil.isOnline.value) {
        print(
          '🌐 [CALL DETAILS] Network error detected, will retry when internet comes back',
        );
        // Don't retry immediately - the polling will retry automatically when internet comes back
        // The connectivity listener will trigger a retry
      }
      // Don't show error toast - this is a background operation
    } finally {
      _isLoadingCallDetails = false;
    }
  }

  /// Start polling for call details updates
  void _startCallDetailsPolling() {
    final sessionId = currentSessionId.value;
    if (sessionId == null || sessionId.isEmpty) {
      print(
        '⚠️ [CALL DETAILS POLLING] Cannot start polling: sessionId is empty',
      );
      return;
    }

    // Stop any existing polling
    _stopCallDetailsPolling();

    print(
      '📋 [CALL DETAILS POLLING] Starting call details polling for session: $sessionId',
    );

    // Load immediately first time
    _loadCallDetails(sessionId);

    // Schedule periodic polling every 10 seconds
    _callDetailsPollingTimer = Timer.periodic(
      const Duration(seconds: _callDetailsPollInterval),
      (timer) {
        final currentSessionId = this.currentSessionId.value;
        if (currentSessionId == null || currentSessionId.isEmpty) {
          _stopCallDetailsPolling();
          return;
        }

        // Stop polling if call is not active
        if (callStatus.value != 'active' && callStatus.value != 'connecting') {
          _stopCallDetailsPolling();
          return;
        }

        // Poll for call details
        _loadCallDetails(currentSessionId);
      },
    );
  }

  /// Stop polling for call details updates
  void _stopCallDetailsPolling() {
    if (_callDetailsPollingTimer != null) {
      _callDetailsPollingTimer!.cancel();
      _callDetailsPollingTimer = null;
      print('📋 [CALL DETAILS POLLING] Stopped call details polling');
    }
  }

  /// Update ID Information from call details
  void _updateIdInformationFromCallDetails(CallDetailsResponse details) {
    final infoRows = <InfoRow>[];

    // Determine which user info to show (caller or receiver)
    // For USER role, show receiver (employee/officer) info
    // For EMPLOYEE role, show caller (user) info
    final userInfo = details.receiver ?? details.caller;

    // Only add officer name
    if (userInfo != null) {
      if (userInfo.name != null && userInfo.name!.isNotEmpty) {
        infoRows.add(InfoRow('Officer Name', userInfo.name!));
      }
    }

    // Add call status
    if (details.status != null) {
      infoRows.add(InfoRow('Call Status', details.status!));
    }

    // Add call date
    if (details.createdAt != null) {
      final dateStr =
          '${details.createdAt!.day}/${details.createdAt!.month}/${details.createdAt!.year}';
      infoRows.add(InfoRow('Call Date', dateStr));
    }

    idInformation.assignAll(infoRows);
    print(
      '✅ [CALL DETAILS] Updated ID Information with ${infoRows.length} rows',
    );
  }

  /// Handle call ended (cleanup)
  Future<void> _handleCallEnded({bool shouldNavigate = true}) async {
    // Stop polling when call ends
    _stopCallDetailsPolling();

    // Save report ID before clearing call details
    final reportId = reportInfo.value?.id;
    print('📋 [CALL ENDED] Report ID: ${reportId ?? "null"}');

    await disconnectFromRoom();
    callStatus.value = 'ended';

    // Clear call details (but keep reportId for fetching)
    final savedReportId = reportId;
    callDetails.value = null;
    reportInfo.value = null;
    statementInfo.value = null;

    currentSessionId.value = '';
    currentRoomName.value = '';
    currentWsUrl.value = '';

    // If there's a report ID and we should navigate, fetch and show report
    if (shouldNavigate && savedReportId != null && savedReportId.isNotEmpty) {
      try {
        print('📋 [CALL ENDED] Fetching report with ID: $savedReportId');
        // Clear loading state when navigation happens
        isEndingCall.value = false;
        await _fetchAndShowReport(savedReportId);
      } catch (e, stackTrace) {
        print('❌ [CALL ENDED] Error fetching report: $e');
        print('❌ [CALL ENDED] Stack trace: $stackTrace');
        // Clear loading state when navigation happens
        isEndingCall.value = false;
        // If report fetch fails, just navigate to home
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed(Routes.HOME);
        });
      }
    } else if (shouldNavigate) {
      // No report, just navigate to home
      print('📋 [CALL ENDED] No report found, navigating to home');
      // Clear loading state when navigation happens
      isEndingCall.value = false;
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offAllNamed(Routes.HOME);
      });
    }
  }

  /// Fetch report by ID and show in confirmation page view
  Future<void> _fetchAndShowReport(String reportId) async {
    try {
      print('📋 [REPORT FETCH] Fetching report from admin API...');
      // Use Dio directly for admin API since it has a different base URL
      final dio = DioUtil().getDio(useAccessToken: true);

      // Remove leading slash since baseUrl already ends with /
      final response = await dio.get('${Constants.baseUrl}reports/$reportId');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};
        print('✅ [REPORT FETCH] Report fetched successfully');

        // Parse response using model
        final reportWrapper = ReportResponseWrapper.fromJson(responseData);

        if (reportWrapper.data == null) {
          print('⚠️ [REPORT FETCH] Report data is null');
          Future.delayed(const Duration(milliseconds: 500), () {
            Get.offAllNamed(Routes.HOME);
          });
          return;
        }

        final reportData = reportWrapper.data!;
        print('📋 [REPORT FETCH] Report ID: ${reportData.id}');
        print('📋 [REPORT FETCH] Case Number: ${reportData.caseNumber}');
        print('📋 [REPORT FETCH] Report Type: ${reportData.reportType?.name}');
        print(
          '📋 [REPORT FETCH] Statements count: ${reportData.statements?.length ?? 0}',
        );

        // Convert report data to formData format for ConfirmationPageView
        final formData = _convertReportToFormData(reportData);

        // Navigate directly to confirmation page view
        print('📋 [REPORT FETCH] Navigating to confirmation page view');
        Future.delayed(const Duration(milliseconds: 500), () {
          ConfirmationPageView.show(Get.context!, formData);
        });
      } else {
        print('⚠️ [REPORT FETCH] Invalid response from report API');
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed(Routes.HOME);
        });
      }
    } catch (e, stackTrace) {
      print('❌ [REPORT FETCH] Error fetching report: $e');
      print('❌ [REPORT FETCH] Stack trace: $stackTrace');
      // If report fetch fails, navigate to home
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offAllNamed(Routes.HOME);
      });
    }
  }

  /// Convert report data from API to formData format for ConfirmationPageView
  /// Only extracts necessary fields for the confirmation page
  Map<String, String> _convertReportToFormData(ReportData reportData) {
    final formData = <String, String>{};

    try {
      print('📋 [REPORT CONVERT] Converting report data...');

      // Extract ID - use caseNumber if available, otherwise use id
      if (reportData.caseNumber != null && reportData.caseNumber!.isNotEmpty) {
        formData['id'] = reportData.caseNumber!;
        formData['caseNumber'] = reportData.caseNumber!;
      } else if (reportData.id != null) {
        formData['id'] = reportData.id!;
      }

      // Extract Category - use reportType.code
      if (reportData.reportType?.code != null &&
          reportData.reportType!.code!.isNotEmpty) {
        formData['category'] = reportData.reportType!.code!;
      }

      // Extract Type - use reportType.name
      if (reportData.reportType?.name != null &&
          reportData.reportType!.name!.isNotEmpty) {
        formData['incidentType'] = reportData.reportType!.name!;
      }

      // Extract information from first statement
      if (reportData.statements != null && reportData.statements!.isNotEmpty) {
        final statement = reportData.statements!.first;

        // Extract full name
        if (statement.fullName != null &&
            statement.fullName!.trim().isNotEmpty) {
          formData['fullName'] = statement.fullName!.trim();
        }

        // Extract phone number
        if (statement.phoneMobile != null &&
            statement.phoneMobile!.trim().isNotEmpty) {
          formData['phoneNumber'] = statement.phoneMobile!.trim();
        }

        // Extract age
        if (statement.age != null) {
          formData['age'] = statement.age.toString();
        }

        // Extract sex
        if (statement.sex != null && statement.sex!.trim().isNotEmpty) {
          formData['sex'] = statement.sex!.trim();
        }

        // Extract nationality
        if (statement.nationality != null &&
            statement.nationality!.trim().isNotEmpty) {
          formData['nationality'] = statement.nationality!.trim();
        }

        // Extract date of birth
        if (statement.dateOfBirth != null) {
          try {
            final dob = statement.dateOfBirth!;
            formData['dateOfBirth'] =
                '${dob.day} ${_getMonthName(dob.month)}, ${dob.year}';
          } catch (e) {
            print('⚠️ [REPORT CONVERT] Error formatting date of birth: $e');
          }
        }

        // Extract statement text
        if (statement.statement != null &&
            statement.statement!.trim().isNotEmpty) {
          formData['statement'] = statement.statement!.trim();
        }

        // Extract statement date
        if (statement.statementDate != null) {
          try {
            final stmtDate = statement.statementDate!;
            formData['statementDate'] =
                '${stmtDate.day} ${_getMonthName(stmtDate.month)}, ${stmtDate.year}';
          } catch (e) {
            print('⚠️ [REPORT CONVERT] Error formatting statement date: $e');
          }
        }

        // Extract statement time
        if (statement.statementTime != null &&
            statement.statementTime!.trim().isNotEmpty) {
          formData['statementTime'] = statement.statementTime!.trim();
        }

        // Build address from available fields
        final addressParts = <String>[];

        if (statement.specificAddress != null &&
            statement.specificAddress!.trim().isNotEmpty) {
          addressParts.add(statement.specificAddress!.trim());
        }
        if (statement.currentSubCity != null &&
            statement.currentSubCity!.trim().isNotEmpty) {
          addressParts.add(statement.currentSubCity!.trim());
        }
        if (statement.currentKebele != null &&
            statement.currentKebele!.trim().isNotEmpty) {
          addressParts.add(statement.currentKebele!.trim());
        }
        if (statement.currentHouseNumber != null &&
            statement.currentHouseNumber!.trim().isNotEmpty) {
          addressParts.add('House: ${statement.currentHouseNumber!.trim()}');
        }
        if (statement.otherAddress != null &&
            statement.otherAddress!.trim().isNotEmpty) {
          addressParts.add(statement.otherAddress!.trim());
        }

        if (addressParts.isNotEmpty) {
          formData['address'] = addressParts.join(', ');
        }
      }

      // Extract Schedule Time - use createdAt
      if (reportData.createdAt != null) {
        try {
          final createdAt = reportData.createdAt!;
          formData['submitTime'] =
              '${createdAt.day} ${_getMonthName(createdAt.month)}, ${createdAt.year}';
          formData['scheduleTime'] = formData['submitTime']!;
        } catch (e) {
          print('⚠️ [REPORT CONVERT] Error formatting date: $e');
        }
      }

      print('✅ [REPORT CONVERT] Converted report data:');
      print('  - ID: ${formData['id'] ?? 'N/A'}');
      print('  - Category: ${formData['category'] ?? 'N/A'}');
      print('  - Type: ${formData['incidentType'] ?? 'N/A'}');
      print('  - Full Name: ${formData['fullName'] ?? 'N/A'}');
      print('  - Phone Number: ${formData['phoneNumber'] ?? 'N/A'}');
      print('  - Age: ${formData['age'] ?? 'N/A'}');
      print('  - Sex: ${formData['sex'] ?? 'N/A'}');
      print('  - Nationality: ${formData['nationality'] ?? 'N/A'}');
      print('  - Date of Birth: ${formData['dateOfBirth'] ?? 'N/A'}');
      print('  - Address: ${formData['address'] ?? 'N/A'}');
      print(
        '  - Statement: ${formData['statement'] != null ? "${formData['statement']!.substring(0, formData['statement']!.length > 50 ? 50 : formData['statement']!.length)}..." : 'N/A'}',
      );
      print('  - Statement Date: ${formData['statementDate'] ?? 'N/A'}');
      print('  - Statement Time: ${formData['statementTime'] ?? 'N/A'}');
      print('  - Schedule Time: ${formData['scheduleTime'] ?? 'N/A'}');
    } catch (e, stackTrace) {
      print('⚠️ [REPORT CONVERT] Error converting report data: $e');
      print('⚠️ [REPORT CONVERT] Stack trace: $stackTrace');
    }

    return formData;
  }

  /// Helper to get month name
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Safely close the upload dialog without triggering GetX overlay errors
  void _closeUploadDialogSafely() {
    // Use a delayed call to ensure the widget tree is stable
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        final context = Get.context;
        if (context != null) {
          // Use Navigator directly to avoid GetX overlay controller issues
          // Try rootNavigator first (for dialogs)
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
            print('✅ [UPLOAD POPUP] Dialog closed using rootNavigator');
            return;
          }

          // Try regular navigator
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
            print('✅ [UPLOAD POPUP] Dialog closed using Navigator');
            return;
          }

          print('⚠️ [UPLOAD POPUP] Cannot pop dialog - no routes to pop');
        } else {
          print('⚠️ [UPLOAD POPUP] No context available to close dialog');
        }
      } catch (e) {
        print('⚠️ [UPLOAD POPUP] Error closing dialog: $e');
        // Last resort: try again after a longer delay
        Future.delayed(const Duration(milliseconds: 300), () {
          try {
            final context = Get.context;
            if (context != null) {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              } else if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            }
          } catch (e2) {
            print('⚠️ [UPLOAD POPUP] Retry failed: $e2');
          }
        });
      }
    });
  }

  /// Safely show toast by checking if context is available and delaying if needed
  void _showToastSafely(VoidCallback showToast) {
    // Delay to ensure widget tree is built
    Future.delayed(const Duration(milliseconds: 300), () {
      try {
        if (Get.context != null) {
          showToast();
        } else {
          // If context is still not available, try again after a longer delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (Get.context != null) {
              showToast();
            }
          });
        }
      } catch (e) {
        print('⚠️ [UPLOAD POPUP] Error showing toast: $e');
        // Silently fail - error message is already shown in UI
      }
    });
  }
}
