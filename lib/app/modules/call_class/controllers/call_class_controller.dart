import 'dart:async';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sps_eth_app/app/modules/form_class/views/widget/scanning_document_view.dart';
import 'package:sps_eth_app/app/modules/call_class/services/direct_call_service.dart';
import 'package:sps_eth_app/app/modules/call_class/services/direct_call_websocket_service.dart';
import 'package:sps_eth_app/app/modules/call_class/services/report_service.dart';
import 'package:sps_eth_app/app/modules/call_class/models/direct_call_model.dart';
import 'package:sps_eth_app/app/modules/call_class/models/report_draft_model.dart';
import 'package:sps_eth_app/app/modules/Residence_id/services/auth_service.dart';
import 'package:dio/dio.dart' as dio;
import 'package:sps_eth_app/app/utils/dio_util.dart';
import 'package:sps_eth_app/app/utils/enums.dart';
import 'package:sps_eth_app/app/utils/auth_util.dart';
import 'package:sps_eth_app/app/utils/jwt_util.dart';
import 'package:sps_eth_app/app/utils/device_id_util.dart';
import 'package:sps_eth_app/app/utils/connectivity_util.dart';
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

  // Direct Call services
  final DirectCallService _directCallService = DirectCallService(
    DioUtil().getDio(useAccessToken: true),
  );
  final ReportService _reportService = ReportService(
    DioUtil().getDio(useAccessToken: true),
  );
  DirectCallWebSocketService? _webSocketService;

  // LiveKit related
  Room? _room;
  LocalParticipant? _localParticipant;
  final RxBool isConnected = false.obs;
  final RxBool isVideoEnabled = true.obs;
  final RxBool isAudioEnabled = true.obs;
  final Rx<VideoTrack?> localVideoTrack = Rx<VideoTrack?>(null);
  final RxList<RemoteParticipant> remoteParticipants = <RemoteParticipant>[].obs;
  final RxString connectionStatus = 'Disconnected'.obs;
  
  // Direct Call state
  final RxString callStatus = 'idle'.obs; // idle, pending, connecting, active, ended
  final Rx<String?> currentSessionId = Rx<String?>('');
  final Rx<String?> currentRoomName = Rx<String?>('');
  final Rx<String?> currentWsUrl = Rx<String?>('');
  final Rx<NetworkStatus> callNetworkStatus = NetworkStatus.IDLE.obs;
  final RxBool isEndingCall = false.obs; // Loading state for ending call
  
  // For employee side
  final RxList<PendingCall> pendingCalls = <PendingCall>[].obs;
  final Rx<IncomingCallEvent?> incomingCall = Rx<IncomingCallEvent?>(null);
  
  // Auto-start flag for home swipe
  final RxBool autoStartCall = false.obs;
  
  // Connection timeout monitor
  Timer? _connectionTimeoutTimer;
  
  // Anonymous login state
  final RxBool isAnonymousLoginLoading = false.obs;
  
  // Connectivity monitoring
  final ConnectivityUtil connectivityUtil = ConnectivityUtil();
  
  // Report draft polling
  Timer? _draftPollingTimer;
  final Rx<ReportDraftData?> reportDraft = Rx<ReportDraftData?>(null);
  final RxBool isPollingDraft = false.obs;
  final RxString pollingStatus = 'Waiting for officer to start form...'.obs;
  Map<String, dynamic>? _previousFormData; // Track previous form data for highlighting updates
  final RxSet<String> recentlyUpdatedFields = <String>{}.obs; // Track fields that were recently updated
  int _consecutiveNoUpdatesCount = 0; // Track consecutive polls with no updates for adaptive polling
  static const int _normalPollInterval = 3; // seconds
  static const int _slowPollInterval = 5; // seconds (when no updates)
  Timer? _fieldHighlightTimer; // Timer to clear field highlights after animation

  @override
  void onInit() {
    super.onInit();
    try {
      // Initialize connectivity monitoring
      connectivityUtil.initialize();
      
      // Check if auto-start is requested from arguments
      final args = Get.arguments;
      if (args != null && args is Map && args['autoStart'] == true) {
        autoStartCall.value = true;
        print('📞 [AUTO START] Auto-start call requested from home swipe');
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
      AppToasts.showError('Failed to initialize call class: ${error.toString()}');
    });
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
      print('🔐 [ANONYMOUS LOGIN] User not authenticated, performing anonymous login...');
      await _performAnonymousLogin();
      
    } catch (e, stackTrace) {
      print('❌ [AUTH CHECK] Fatal error in _checkAuthBeforeAccess: $e');
      print('❌ [AUTH CHECK] Stack trace: $stackTrace');
      isAnonymousLoginLoading.value = false;
      AppToasts.showError('Failed to initialize authentication: ${e.toString()}');
      rethrow;
    }
  }
  
  /// Perform anonymous login using device ID
  Future<void> _performAnonymousLogin() async {
    try {
      isAnonymousLoginLoading.value = true;
      
      // Get device ID from utility (for now returns common static ID)
      final deviceId = await DeviceIdUtil.getDeviceId();
      print('🔐 [ANONYMOUS LOGIN] Starting anonymous login with device ID: $deviceId');
      
      // Create Dio instance without access token (since we don't have one yet)
      final dio = DioUtil().getDio(useAccessToken: false);
      final authService = AuthService(dio);
      
      // Call anonymous login API
      final response = await authService.anonymousLogin({
        'deviceId': deviceId,
      });
      
      print('🔐 [ANONYMOUS LOGIN] API response received');
      print('  - success: ${response.success}');
      print('  - accessToken: ${response.data?.accessToken != null ? "${response.data!.accessToken!.substring(0, 20)}..." : "null"}');
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
        refreshToken: loginData.refreshToken ?? '', // Anonymous login might not provide refresh token
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
        errorMessage = 'Connection timeout. Please check your internet connection and try again.';
      } else if (e.type == dio.DioExceptionType.connectionError) {
        // Check for specific network unreachable errors
        final errorString = e.error?.toString().toLowerCase() ?? '';
        final messageString = e.message?.toLowerCase() ?? '';
        
        if (errorString.contains('network is unreachable') ||
            errorString.contains('connection failed') ||
            errorString.contains('socketexception') ||
            messageString.contains('network is unreachable') ||
            messageString.contains('connection failed')) {
          errorMessage = 'No internet connection. Please check your network settings and try again.';
          print('⚠️ [ANONYMOUS LOGIN] Network connectivity issue detected - device cannot reach the server');
        } else {
          errorMessage = 'Connection error. The server may be temporarily unavailable. Please try again in a moment.';
        }
      } else if (e.response?.statusCode == 400 || e.response?.statusCode == 500) {
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
      AppToasts.showError('An unexpected error occurred during authentication. Please try again.');
      rethrow;
    } finally {
      isAnonymousLoginLoading.value = false;
    }
  }
  
  /// Check authentication and connect WebSocket if authenticated
  Future<void> _checkAuthAndConnectWebSocket() async {
    try {
      print('🔌 [WEBSOCKET] Checking authentication for WebSocket connection...');
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
          print('❌ [WEBSOCKET] Token expired or null, performing anonymous login...');
          if (token != null) {
            print('🔌 [WEBSOCKET] Token expired: ${JwtUtil.isTokenExpired(token)}');
          }
          // Perform anonymous login instead of showing login dialog
          await _performAnonymousLogin();
        }
      } else {
        print('❌ [WEBSOCKET] User not authenticated, WebSocket connection skipped');
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
        print('📞 [WEBSOCKET EVENT] incomingCall: sessionId=${event.sessionId}, roomName=${event.roomName}, callerId=${event.callerId}');
        incomingCall.value = event;
        // Optionally refresh pending calls
        _loadPendingCalls();
      };
      
      _webSocketService!.onCallAccepted = (event) {
        print('✅ [WEBSOCKET EVENT] callAccepted: sessionId=${event.sessionId}, roomName=${event.roomName}');
        print('📊 [WEBSOCKET EVENT] Current sessionId: ${currentSessionId.value}');
        if (event.sessionId == currentSessionId.value) {
          print('✅ [WEBSOCKET EVENT] Session IDs match, updating call status to active');
          callStatus.value = 'active';
          connectionStatus.value = 'Connected';
          // Start polling for report draft when call is accepted
          _startDraftPolling();
        } else {
          print('⚠️ [WEBSOCKET EVENT] Session IDs do not match! Event: ${event.sessionId}, Current: ${currentSessionId.value}');
        }
      };
      
      _webSocketService!.onCallRejected = (event) {
        print('❌ [WEBSOCKET EVENT] callRejected: sessionId=${event.sessionId}, message=${event.message}');
        if (event.sessionId == currentSessionId.value) {
          callStatus.value = 'ended';
          _handleCallEnded();
          AppToasts.showError(event.message ?? 'Call rejected');
        }
      };
      
      _webSocketService!.onCallEnded = (event) {
        print('🔚 [WEBSOCKET EVENT] callEnded: sessionId=${event.sessionId}, duration=${event.duration}, message=${event.message}');
        if (event.sessionId == currentSessionId.value) {
          callStatus.value = 'ended';
          _handleCallEnded();
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
        // Don't show error toast for auth errors, perform anonymous login instead
        if (error.toString().toLowerCase().contains('auth') || 
            error.toString().toLowerCase().contains('unauthorized')) {
          print('🔐 [WEBSOCKET ERROR] Auth error detected, performing anonymous login');
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
      print('🔌 [WEBSOCKET] connect() completed, isConnected: ${_webSocketService?.isConnected}');
    } catch (e, stackTrace) {
      print('❌ [WEBSOCKET ERROR] Exception connecting WebSocket: $e');
      print('❌ [WEBSOCKET ERROR] Stack trace: $stackTrace');
      final errorMessage = e.toString();
      AppToasts.showError('WebSocket connection failed: $errorMessage');
      if (errorMessage.toLowerCase().contains('auth') || 
          errorMessage.toLowerCase().contains('token') ||
          errorMessage.toLowerCase().contains('unauthorized')) {
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
  
  /// Public method to load pending calls (can be called from UI)
  Future<void> loadPendingCalls() async {
    await _loadPendingCalls();
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
    } catch (e, stackTrace) {
      print('❌ [INIT ERROR] Error loading initial data: $e');
      print('❌ [INIT ERROR] Stack trace: $stackTrace');
      AppToasts.showError('Failed to load initial data: ${e.toString()}');
    }
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

  @override
  void onClose() {
    _connectionTimeoutTimer?.cancel();
    _stopDraftPolling();
    _fieldHighlightTimer?.cancel();
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
      print('📞 [REQUEST CALL] Microphone permission: ${microphoneStatus.toString()}');

      if (!cameraStatus.isGranted || !microphoneStatus.isGranted) {
        callNetworkStatus.value = NetworkStatus.ERROR;
        callStatus.value = 'idle';
        print('❌ [REQUEST CALL] Permissions denied - Camera: ${cameraStatus.isGranted}, Microphone: ${microphoneStatus.isGranted}');
        AppToasts.showError('Camera and microphone permissions are required');
        return;
      }

      print('✅ [REQUEST CALL] Permissions granted');
      print('📞 [REQUEST CALL] Calling Direct Call API...');
      
      // Request call via Direct Call API
      final responseWrapper = await _directCallService.requestCall();
      
      // Extract data from wrapper
      if (responseWrapper.success != true || responseWrapper.data == null) {
        callNetworkStatus.value = NetworkStatus.ERROR;
        callStatus.value = 'idle';
        print('❌ [REQUEST CALL] API response indicates failure or missing data');
        print('  - success: ${responseWrapper.success}');
        print('  - data: ${responseWrapper.data}');
        AppToasts.showError('Failed to request call');
        return;
      }
      
      final response = responseWrapper.data!;
      
      print('📞 [REQUEST CALL] API Response received:');
      print('  - token: ${response.token != null ? "${response.token!.substring(0, 20)}..." : "null"}');
      print('  - roomName: ${response.roomName}');
      print('  - sessionId: ${response.sessionId}');
      print('  - wsUrl: ${response.wsUrl}');

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
        errorMessage = 'Connection timeout. Please check your internet connection and try again.';
      } else if (e.type == dio.DioExceptionType.connectionError ||
                 e.error?.toString().toLowerCase().contains('connection closed') == true ||
                 e.error?.toString().toLowerCase().contains('connection refused') == true ||
                 e.message?.toLowerCase().contains('connection closed') == true) {
        errorMessage = 'Connection error. The server may be temporarily unavailable. Please try again in a moment.';
        print('⚠️ [REQUEST CALL] This appears to be a backend/network issue. The server closed the connection unexpectedly.');
      } else if (e.response?.statusCode == 403) {
        // Parse error message from response
        try {
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            final error = responseData['error'];
            if (error is Map && error.containsKey('message')) {
              errorMessage = error['message'] ?? 'Access forbidden. This action requires USER role.';
            } else {
              errorMessage = 'Access forbidden. This action requires USER role.';
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
        errorMessage = 'No agents available. Please try again later.';
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
      
      // Show user-friendly error message
      AppToasts.showError(errorMessage);
    } catch (e, stackTrace) {
      print('❌ [REQUEST CALL] Exception: $e');
      print('❌ [REQUEST CALL] Stack trace: $stackTrace');
      callNetworkStatus.value = NetworkStatus.ERROR;
      callStatus.value = 'idle';
      AppToasts.showError('An unexpected error occurred while requesting the call. Please try again.');
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
      await _room!.connect(
        wsUrl,
        token,
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioCaptureOptions: AudioCaptureOptions(
            echoCancellation: true,
            noiseSuppression: true,
            autoGainControl: true,
          ),
        ),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ [LIVEKIT] Connection timeout after 30 seconds');
          throw TimeoutException('Connection timeout: Failed to connect to video call server within 30 seconds. Please check your internet connection and try again.');
        },
      );
      
      print('🎥 [LIVEKIT] room.connect() completed');

      // Wait a bit for connection state to stabilize
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if connection actually succeeded
      if (_room!.connectionState != ConnectionState.connected) {
        print('❌ [LIVEKIT] Connection state is not connected: ${_room!.connectionState}');
        throw Exception('Connection failed: Room state is ${_room!.connectionState}');
      }

      _localParticipant = _room!.localParticipant;
      print('🎥 [LIVEKIT] Local participant: ${_localParticipant != null ? "exists" : "null"}');
      
      if (_localParticipant == null) {
        print('❌ [LIVEKIT] Local participant is null after connection');
        throw Exception('Connection failed: Local participant is null');
      }
      
      print('🎥 [LIVEKIT] Local participant identity: ${_localParticipant!.identity}');
      print('🎥 [LIVEKIT] Local participant sid: ${_localParticipant!.sid}');

      isConnected.value = true;
      connectionStatus.value = 'Connected';
      callStatus.value = 'active';
      print('🎥 [LIVEKIT] Connection state updated - isConnected: ${isConnected.value}');
      print('🎥 [LIVEKIT] Room connection state: ${_room!.connectionState}');
      
      // Start polling for report draft when call becomes active
      _startDraftPolling();

      // Enable camera and microphone
      print('🎥 [LIVEKIT] Enabling video...');
      try {
        await enableVideo();
        print('🎥 [LIVEKIT] Video enabled: ${isVideoEnabled.value}');
      } catch (e) {
        print('⚠️ [LIVEKIT] Warning: Failed to enable video: $e');
        // Error toast already shown in enableVideo()
      }
      
      print('🎥 [LIVEKIT] Enabling audio...');
      try {
        await enableAudio();
        print('🎥 [LIVEKIT] Audio enabled: ${isAudioEnabled.value}');
      } catch (e) {
        print('⚠️ [LIVEKIT] Warning: Failed to enable audio: $e');
        // Error toast already shown in enableAudio()
      }

      // Get local video track
      print('🎥 [LIVEKIT] Updating local video track...');
      _updateLocalVideoTrack();
      print('🎥 [LIVEKIT] Local video track: ${localVideoTrack.value != null ? "exists" : "null"}');
      
      // Log room participants
      print('🎥 [LIVEKIT] Remote participants count: ${_room!.remoteParticipants.length}');
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
      AppToasts.showError('Failed to connect to video call server. This may be due to slow internet connection or server issues.');
      await _handleCallEnded();
    } catch (e, stackTrace) {
      print('❌ [LIVEKIT ERROR] Exception connecting to LiveKit: $e');
      print('❌ [LIVEKIT ERROR] Stack trace: $stackTrace');
      connectionStatus.value = 'Connection failed';
      isConnected.value = false;
      callStatus.value = 'idle';
      
      // Show user-friendly error message
      String errorMessage = 'Failed to connect to video call';
      if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.toString().contains('network') || e.toString().contains('socket')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('permission') || e.toString().contains('camera') || e.toString().contains('microphone')) {
        errorMessage = 'Camera or microphone permission error. Please grant permissions and try again.';
      } else if (e.toString().contains('token') || e.toString().contains('auth')) {
        errorMessage = 'Authentication error. Please try logging in again.';
      }
      
      AppToasts.showError(errorMessage);
      _connectionTimeoutTimer?.cancel();
      _connectionTimeoutTimer = null;
      await _handleCallEnded();
    }
  }
  
  /// Start connection timeout monitor
  /// This will show an error if connection is stuck in "connecting" state for too long
  void _startConnectionTimeoutMonitor() {
    _connectionTimeoutTimer?.cancel();
    
    _connectionTimeoutTimer = Timer(const Duration(seconds: 35), () {
      // Check if still connecting after timeout
      if (callStatus.value == 'connecting' && 
          (connectionStatus.value == 'Connecting...' || connectionStatus.value == 'Reconnecting...')) {
        print('❌ [CONNECTION TIMEOUT] Connection stuck in connecting state for 35 seconds');
        AppToasts.showError('Connection is taking too long. Please check your internet and try again.');
        callNetworkStatus.value = NetworkStatus.ERROR;
        callStatus.value = 'idle';
        connectionStatus.value = 'Connection timeout';
        _handleCallEnded();
      }
    });
  }

  /// Disconnect from room
  Future<void> disconnectFromRoom() async {
    print('🔌 [DISCONNECT] Disconnecting from LiveKit room...');
    try {
      if (_room != null) {
        print('🔌 [DISCONNECT] Room exists, calling disconnect()...');
        await _room!.disconnect();
        print('🔌 [DISCONNECT] Room disconnected');
        _room = null;
        _localParticipant = null;
        isConnected.value = false;
        connectionStatus.value = 'Disconnected';
        localVideoTrack.value = null;
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
  Future<void> enableVideo() async {
    print('🎥 [VIDEO] Enabling video...');
    try {
      if (_localParticipant != null) {
        print('🎥 [VIDEO] Local participant exists, calling setCameraEnabled(true)...');
        await _localParticipant!.setCameraEnabled(true);
        isVideoEnabled.value = true;
        print('🎥 [VIDEO] Camera enabled: ${isVideoEnabled.value}');
        _updateLocalVideoTrack();
      } else {
        print('❌ [VIDEO] Local participant is null, cannot enable video');
        throw Exception('Local participant is null');
      }
    } catch (e, stackTrace) {
      print('❌ [VIDEO ERROR] Error enabling video: $e');
      print('❌ [VIDEO ERROR] Stack trace: $stackTrace');
      isVideoEnabled.value = false;
      // Only show error if it's a permission issue, not connection issues
      if (e.toString().contains('permission') || e.toString().contains('Permission')) {
        AppToasts.showError('Camera permission denied. Please grant permission and try again.');
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
  Future<void> enableAudio() async {
    print('🎤 [AUDIO] Enabling audio...');
    try {
      if (_localParticipant != null) {
        print('🎤 [AUDIO] Local participant exists, calling setMicrophoneEnabled(true)...');
        await _localParticipant!.setMicrophoneEnabled(true);
        isAudioEnabled.value = true;
        print('🎤 [AUDIO] Microphone enabled: ${isAudioEnabled.value}');
      } else {
        print('❌ [AUDIO] Local participant is null, cannot enable audio');
        throw Exception('Local participant is null');
      }
    } catch (e, stackTrace) {
      print('❌ [AUDIO ERROR] Error enabling audio: $e');
      print('❌ [AUDIO ERROR] Stack trace: $stackTrace');
      isAudioEnabled.value = false;
      // Only show error if it's a permission issue, not connection issues
      if (e.toString().contains('permission') || e.toString().contains('Permission')) {
        AppToasts.showError('Microphone permission denied. Please grant permission and try again.');
      }
      rethrow;
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
    if (_localParticipant == null) {
      print('⚠️ [LOCAL TRACK] Local participant is null');
      localVideoTrack.value = null;
      return;
    }
    
    print('🎥 [LOCAL TRACK] Updating local video track...');
    print('🎥 [LOCAL TRACK] Video track publications: ${_localParticipant!.videoTrackPublications.length}');
    
    for (var pub in _localParticipant!.videoTrackPublications) {
      print('🎥 [LOCAL TRACK] - Publication: subscribed=${pub.subscribed}, muted=${pub.muted}, track=${pub.track != null}');
    }
    
    final videoTrack = _localParticipant!.videoTrackPublications
        .where((pub) => pub.subscribed)
        .map((pub) => pub.track)
        .whereType<LocalVideoTrack>()
        .firstOrNull;
    
    print('🎥 [LOCAL TRACK] Found local video track: ${videoTrack != null}');
    
    localVideoTrack.value = videoTrack;
  }

  /// Get remote video track for a participant
  VideoTrack? getRemoteVideoTrack(RemoteParticipant participant) {
    print('🎥 [REMOTE TRACK] Getting remote video track for participant: ${participant.identity}');
    print('🎥 [REMOTE TRACK] Video publications: ${participant.videoTrackPublications.length}');
    
    for (var pub in participant.videoTrackPublications) {
      print('🎥 [REMOTE TRACK] - Publication: subscribed=${pub.subscribed}, muted=${pub.muted}, track=${pub.track != null}');
    }
    
    final videoTrack = participant.videoTrackPublications
        .where((pub) => pub.subscribed)
        .map((pub) => pub.track)
        .whereType<RemoteVideoTrack>()
        .firstOrNull;
    
    print('🎥 [REMOTE TRACK] Found remote video track: ${videoTrack != null}');
    
    return videoTrack;
  }

  /// Room event handler
  void _onRoomChanged() {
    if (_room == null) {
      print('⚠️ [ROOM EVENT] Room is null');
      return;
    }

    print('🔄 [ROOM EVENT] Room changed - ConnectionState: ${_room!.connectionState}');
    
    final previousState = connectionStatus.value;
    
    // Update connection status
    if (_room!.connectionState == ConnectionState.connected) {
      print('✅ [ROOM EVENT] Room connected');
      connectionStatus.value = 'Connected';
      isConnected.value = true;
      callStatus.value = 'active';
    } else if (_room!.connectionState == ConnectionState.disconnected) {
      print('❌ [ROOM EVENT] Room disconnected');
      connectionStatus.value = 'Disconnected';
      isConnected.value = false;
      // Only show error if we were previously connected (not if we're just starting)
      if (previousState == 'Connected') {
        AppToasts.showError('Connection lost. Please try again.');
        callStatus.value = 'idle';
        _handleCallEnded();
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
        (previousState == 'Connecting...' || previousState == 'Reconnecting...')) {
      print('❌ [ROOM EVENT] Connection failed during connect/reconnect');
      AppToasts.showError('Failed to connect. Please check your internet and try again.');
      callStatus.value = 'idle';
      callNetworkStatus.value = NetworkStatus.ERROR;
    }

    print('🔄 [ROOM EVENT] Remote participants: ${_room!.remoteParticipants.length}');
    print('🔄 [ROOM EVENT] Local participant: ${_room!.localParticipant != null ? "exists" : "null"}');

    // Update local video track
    _updateLocalVideoTrack();
  }

  /// Remote participants event handler
  void _onRemoteParticipantsChanged() {
    if (_room == null) {
      print('⚠️ [PARTICIPANTS] Room is null');
      return;
    }
    
    final participants = _room!.remoteParticipants.values.toList();
    print('👥 [PARTICIPANTS] Remote participants changed: ${participants.length}');
    
    for (var participant in participants) {
      print('👥 [PARTICIPANTS] - Identity: ${participant.identity}, SID: ${participant.sid}');
      print('👥 [PARTICIPANTS] - Video tracks: ${participant.videoTrackPublications.length}');
      print('👥 [PARTICIPANTS] - Audio tracks: ${participant.audioTrackPublications.length}');
      
      for (var videoPub in participant.videoTrackPublications) {
        print('👥 [PARTICIPANTS]   Video track: subscribed=${videoPub.subscribed}, muted=${videoPub.muted}, track=${videoPub.track != null}');
      }
    }
    
    remoteParticipants.assignAll(participants);
    print('👥 [PARTICIPANTS] Updated remoteParticipants list: ${remoteParticipants.length}');
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
    await endCall();
    Get.back();
  }

  /// End the current call
  Future<void> endCall() async {
    final sessionId = currentSessionId.value;
    if (sessionId == null || sessionId.isEmpty) {
      await disconnectFromRoom();
      return;
    }

    // Set loading state
    isEndingCall.value = true;

    try {
      await _directCallService.endCall(sessionId);
      await _handleCallEnded();
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
      
      // Even if API call fails, disconnect from LiveKit
      await _handleCallEnded();
      
      // Only show error if it's not a PENDING call error (which is expected)
      if (!isPendingCallError) {
        AppToasts.showError('Error ending call. Please try again.');
      }
      // For pending calls, just clean up silently
    } finally {
      // Always clear loading state
      isEndingCall.value = false;
    }
  }

  /// Handle call ended (cleanup)
  Future<void> _handleCallEnded() async {
    // Stop polling when call ends
    _stopDraftPolling();
    
    await disconnectFromRoom();
    callStatus.value = 'ended';
    currentSessionId.value = '';
    currentRoomName.value = '';
    currentWsUrl.value = '';
    
    // Clear report draft data
    reportDraft.value = null;
    _previousFormData = null;
    _consecutiveNoUpdatesCount = 0;
    recentlyUpdatedFields.clear();
    _fieldHighlightTimer?.cancel();
    pollingStatus.value = 'Waiting for officer to start form...';
  }
  
  /// Start polling for report draft updates
  void _startDraftPolling() {
    final sessionId = currentSessionId.value;
    if (sessionId == null || sessionId.isEmpty) {
      print('⚠️ [DRAFT POLLING] Cannot start polling: sessionId is empty');
      return;
    }
    
    // Stop any existing polling
    _stopDraftPolling();
    
    // Reset polling state
    _consecutiveNoUpdatesCount = 0;
    _previousFormData = null;
    
    print('📋 [DRAFT POLLING] Starting draft polling for session: $sessionId');
    isPollingDraft.value = true;
    pollingStatus.value = 'Waiting for officer to start form...';
    
    // Poll immediately first time
    _pollDraft(sessionId);
    
    // Start with normal polling interval (3 seconds)
    _scheduleNextPoll(sessionId, _normalPollInterval);
  }
  
  /// Schedule the next poll with adaptive interval
  void _scheduleNextPoll(String sessionId, int intervalSeconds) {
    _draftPollingTimer?.cancel();
    
    _draftPollingTimer = Timer(Duration(seconds: intervalSeconds), () {
      final currentSessionId = this.currentSessionId.value;
      if (currentSessionId == null || currentSessionId.isEmpty) {
        _stopDraftPolling();
        return;
      }
      
      // Stop polling if call is not active
      if (callStatus.value != 'active') {
        _stopDraftPolling();
        return;
      }
      
      // Stop polling if report is submitted
      if (reportDraft.value?.reportSubmitted == true) {
        _stopDraftPolling();
        pollingStatus.value = 'Report submitted successfully';
        return;
      }
      
      // Poll and schedule next one
      _pollDraft(currentSessionId).then((_) {
        // Determine next interval based on updates
        final nextInterval = _consecutiveNoUpdatesCount >= 2 
            ? _slowPollInterval 
            : _normalPollInterval;
        _scheduleNextPoll(currentSessionId, nextInterval);
      });
    });
  }
  
  /// Stop polling for report draft updates
  void _stopDraftPolling() {
    if (_draftPollingTimer != null) {
      _draftPollingTimer!.cancel();
      _draftPollingTimer = null;
      print('📋 [DRAFT POLLING] Stopped draft polling');
    }
    isPollingDraft.value = false;
    _consecutiveNoUpdatesCount = 0; // Reset counter
  }
  
  /// Poll for draft updates
  Future<void> _pollDraft(String callSessionId) async {
    // Validate sessionId before making request
    if (callSessionId.isEmpty) {
      print('⚠️ [DRAFT POLLING] Invalid callSessionId: empty string');
      return;
    }
    
    try {
      print('📋 [DRAFT POLLING] Polling draft for session: $callSessionId');
      
      final response = await _reportService.getDraft(callSessionId);
      
      // Validate response structure
      if (response.success != true) {
        print('⚠️ [DRAFT POLLING] API returned success=false');
        if (reportDraft.value == null) {
          pollingStatus.value = 'Waiting for officer to start form...';
        }
        _consecutiveNoUpdatesCount++;
        return;
      }
      
      if (response.data == null) {
        print('⚠️ [DRAFT POLLING] No draft data available yet');
        if (reportDraft.value == null) {
          pollingStatus.value = 'Waiting for officer to start form...';
        }
        _consecutiveNoUpdatesCount++;
        return;
      }
      
      final draftData = response.data!;
      
      // Validate that callSessionId matches (security check)
      if (draftData.callSessionId != null && 
          draftData.callSessionId != callSessionId) {
        print('⚠️ [DRAFT POLLING] Session ID mismatch! Expected: $callSessionId, Got: ${draftData.callSessionId}');
        // Continue anyway, but log the issue
      }
      
      // Check if report is submitted
      if (draftData.reportSubmitted == true) {
        print('✅ [DRAFT POLLING] Report submitted!');
        reportDraft.value = draftData;
        _stopDraftPolling();
        
        if (draftData.caseNumber != null && draftData.caseNumber!.isNotEmpty) {
          pollingStatus.value = 'Report submitted - Case: ${draftData.caseNumber}';
          AppToasts.showSuccess('Report submitted successfully. Case number: ${draftData.caseNumber}');
        } else if (draftData.reportId != null && draftData.reportId!.isNotEmpty) {
          pollingStatus.value = 'Report submitted successfully';
          AppToasts.showSuccess('Report submitted successfully');
        } else {
          pollingStatus.value = 'Report submitted successfully';
          AppToasts.showSuccess('Report submitted successfully');
        }
        return;
      }
      
      // Check if form data has updates
      final currentFormData = draftData.formData;
      bool hasNewUpdates = false;
      
      if (currentFormData != null && currentFormData.isNotEmpty) {
        // Compare with previous form data to detect updates
        if (_previousFormData == null) {
          hasNewUpdates = true;
          _consecutiveNoUpdatesCount = 0; // Reset counter on first data
          print('📋 [DRAFT POLLING] First draft data received');
        } else {
          // Track which fields were updated
          final updatedFields = <String>[];
          
          // Check if any field changed
          for (var key in currentFormData.keys) {
            final oldValue = _previousFormData![key];
            final newValue = currentFormData[key];
            
            // Deep comparison for better accuracy
            if (oldValue != newValue) {
              hasNewUpdates = true;
              updatedFields.add(key);
              _consecutiveNoUpdatesCount = 0; // Reset counter on update
              print('📋 [DRAFT POLLING] Field updated: $key ($oldValue -> $newValue)');
            }
          }
          
          // Also check for new fields that weren't in previous data
          for (var key in currentFormData.keys) {
            if (!_previousFormData!.containsKey(key)) {
              hasNewUpdates = true;
              updatedFields.add(key);
              _consecutiveNoUpdatesCount = 0;
              print('📋 [DRAFT POLLING] New field added: $key');
            }
          }
          
          // Update recently updated fields for UI highlighting
          if (updatedFields.isNotEmpty) {
            recentlyUpdatedFields.clear();
            recentlyUpdatedFields.addAll(updatedFields);
            // Clear highlights after 3 seconds
            _fieldHighlightTimer?.cancel();
            _fieldHighlightTimer = Timer(const Duration(seconds: 3), () {
              recentlyUpdatedFields.clear();
            });
          }
          
          // If no updates detected but backend says there are updates, trust the backend
          if (!hasNewUpdates && draftData.hasUpdates == true) {
            hasNewUpdates = true;
            _consecutiveNoUpdatesCount = 0;
            print('📋 [DRAFT POLLING] Backend indicates updates (hasUpdates=true)');
            // Mark all fields as updated if backend says so but we can't detect changes
            recentlyUpdatedFields.clear();
            recentlyUpdatedFields.addAll(currentFormData.keys);
            _fieldHighlightTimer?.cancel();
            _fieldHighlightTimer = Timer(const Duration(seconds: 3), () {
              recentlyUpdatedFields.clear();
            });
          }
        }
        
        // Update previous form data
        _previousFormData = Map<String, dynamic>.from(currentFormData);
      } else {
        // No form data yet
        _consecutiveNoUpdatesCount++;
      }
      
      // If no updates, increment counter for adaptive polling
      if (!hasNewUpdates) {
        _consecutiveNoUpdatesCount++;
      }
      
      // Update draft data
      reportDraft.value = draftData;
      
      // Update status message
      if (hasNewUpdates) {
        print('📋 [DRAFT POLLING] Draft updated with new data');
        pollingStatus.value = 'Form updated - ${draftData.lastUpdated != null ? _formatTimestamp(draftData.lastUpdated!) : "Just now"}';
      } else if (currentFormData != null && currentFormData.isNotEmpty) {
        pollingStatus.value = 'Viewing your report - Last updated: ${draftData.lastUpdated != null ? _formatTimestamp(draftData.lastUpdated!) : "Unknown"}';
      } else {
        pollingStatus.value = 'Waiting for officer to start form...';
      }
      
    } on dio.DioException catch (e) {
      // Handle different HTTP status codes
      final statusCode = e.response?.statusCode;
      
      if (statusCode == 404) {
        // No draft exists yet - this is normal
        print('ℹ️ [DRAFT POLLING] No draft exists yet (404)');
        if (reportDraft.value == null) {
          pollingStatus.value = 'Waiting for officer to start form...';
        }
        _consecutiveNoUpdatesCount++;
        return;
      } else if (statusCode == 401) {
        // Unauthorized - token might be expired
        print('⚠️ [DRAFT POLLING] Unauthorized (401) - token may be expired');
        // Don't stop polling, let it retry (token refresh should handle this)
        _consecutiveNoUpdatesCount++;
        return;
      } else if (statusCode == 403) {
        // Forbidden - user doesn't have permission
        print('❌ [DRAFT POLLING] Forbidden (403) - insufficient permissions');
        _stopDraftPolling();
        pollingStatus.value = 'Unable to view report';
        return;
      } else if (statusCode == 400) {
        // Bad request - invalid sessionId
        print('❌ [DRAFT POLLING] Bad request (400) - invalid callSessionId: $callSessionId');
        _stopDraftPolling();
        pollingStatus.value = 'Invalid call session';
        return;
      } else if (statusCode != null && statusCode >= 500) {
        // Server error - retry on next interval
        print('⚠️ [DRAFT POLLING] Server error ($statusCode): ${e.message}');
        _consecutiveNoUpdatesCount++;
        return;
      } else if (e.type == dio.DioExceptionType.connectionError ||
                 e.type == dio.DioExceptionType.connectionTimeout ||
                 e.type == dio.DioExceptionType.receiveTimeout) {
        // Network errors - retry on next interval
        print('⚠️ [DRAFT POLLING] Network error: ${e.type} - ${e.message}');
        _consecutiveNoUpdatesCount++;
        return;
      } else {
        // Other errors
        print('❌ [DRAFT POLLING] Error polling draft: $statusCode - ${e.message}');
        _consecutiveNoUpdatesCount++;
        return;
      }
    } catch (e, stackTrace) {
      print('❌ [DRAFT POLLING] Exception polling draft: $e');
      print('❌ [DRAFT POLLING] Stack trace: $stackTrace');
      _consecutiveNoUpdatesCount++;
      // Don't show error toast for polling failures - polling will retry
    }
  }
  
  /// Format timestamp for display
  String _formatTimestamp(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

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
            text.substring(0, selection.start - 1) + text.substring(selection.end);
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
          '${text.substring(0, selection.start)}\n${text.substring(selection.end)}';
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
