import 'dart:async';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sps_eth_app/app/modules/form_class/views/widget/scanning_document_view.dart';
import 'package:sps_eth_app/app/modules/call_class/services/direct_call_service.dart';
import 'package:sps_eth_app/app/modules/call_class/services/direct_call_websocket_service.dart';
import 'package:sps_eth_app/app/modules/call_class/models/direct_call_model.dart';
import 'package:sps_eth_app/app/modules/Residence_id/services/auth_service.dart';
import 'package:dio/dio.dart' as dio;
import 'package:sps_eth_app/app/utils/dio_util.dart';
import 'package:sps_eth_app/app/utils/enums.dart';
import 'package:sps_eth_app/app/utils/auth_util.dart';
import 'package:sps_eth_app/app/utils/jwt_util.dart';
import 'package:sps_eth_app/app/utils/device_id_util.dart';
import 'package:sps_eth_app/app/utils/connectivity_util.dart';
import 'package:sps_eth_app/app/common/app_toasts.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';

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
      'A technology-driven, modern police service outlet where users can serve themselves without human intervention. Designed to make police services more accessible, efficient, and convenient for the community.'
          .obs;
  final RxString discussionDate = 'June 12, 2024'.obs;
  
  // Call details from backend
  final Rx<CallDetailsResponse?> callDetails = Rx<CallDetailsResponse?>(null);

  // Direct Call services
  final DirectCallService _directCallService = DirectCallService(
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
  
  // Camera selection
  final RxList<CameraPosition> availableCameraPositions = <CameraPosition>[].obs;
  final RxInt currentCameraIndex = 0.obs;
  final RxBool hasMultipleCameras = false.obs;
  
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
  
  // Report and statement data from call details
  final Rx<ReportInfo?> reportInfo = Rx<ReportInfo?>(null);
  final Rx<StatementInfo?> statementInfo = Rx<StatementInfo?>(null);
  
  // Call details polling
  Timer? _callDetailsPollingTimer;
  static const int _callDetailsPollInterval = 3; // seconds (reduced for faster updates)
  bool _isLoadingCallDetails = false; // Prevent overlapping requests

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
          // Start polling for call details when call is accepted (this includes report and statement)
          if (event.sessionId != null && event.sessionId!.isNotEmpty) {
            _startCallDetailsPolling();
          }
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
          // Navigate back to home after a short delay to allow cleanup
          Future.delayed(const Duration(milliseconds: 500), () {
            try {
              Get.offAllNamed(Routes.HOME); // Navigate to home when admin ends call
              print('🏠 [NAVIGATION] Navigated to home after call ended by admin');
            } catch (e) {
              print('❌ [NAVIGATION] Error navigating to home: $e');
            }
          });
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
    _stopCallDetailsPolling();
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
      
      // Start polling for call details when call becomes active (this includes report and statement)
      final sessionId = currentSessionId.value;
      if (sessionId != null && sessionId.isNotEmpty) {
        _startCallDetailsPolling();
      }

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
        print('📷 [CAMERA] Multiple cameras detected, camera switching enabled');
      }
    } catch (e, stackTrace) {
      print('❌ [CAMERA ERROR] Error enumerating cameras: $e');
      print('❌ [CAMERA ERROR] Stack trace: $stackTrace');
      // Continue without camera enumeration - single camera assumed
      availableCameraPositions.clear();
      hasMultipleCameras.value = false;
    }
  }

  /// Enable video
  Future<void> enableVideo() async {
    print('🎥 [VIDEO] Enabling video...');
    try {
      if (_localParticipant != null) {
        // Enumerate cameras first if not already done
        if (availableCameraPositions.isEmpty) {
          await _enumerateCameras();
        }
        
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

  /// Switch to next available camera
  Future<void> switchCamera() async {
    try {
      if (!hasMultipleCameras.value || availableCameraPositions.isEmpty) {
        print('📷 [CAMERA] No multiple cameras available, skipping switch');
        return;
      }
      
      if (_localParticipant == null) {
        print('❌ [CAMERA] Local participant is null, cannot switch camera');
        return;
      }
      
      // Get current camera track
      final cameraTrack = _localParticipant!.videoTrackPublications
          .where((pub) => pub.source == TrackSource.camera)
          .map((pub) => pub.track)
          .whereType<LocalVideoTrack>()
          .firstOrNull;
      
      if (cameraTrack == null) {
        print('❌ [CAMERA] No camera track found, cannot switch');
        return;
      }
      
      // Calculate next camera index
      currentCameraIndex.value = (currentCameraIndex.value + 1) % availableCameraPositions.length;
      final nextPosition = availableCameraPositions[currentCameraIndex.value];
      
      print('📷 [CAMERA] Switching to camera ${currentCameraIndex.value}: ${nextPosition}');
      
      // Switch camera by using setCameraPosition on the track
      try {
        // Try to set camera position directly on the track
        await cameraTrack.setCameraPosition(nextPosition);
        print('✅ [CAMERA] Camera switched successfully to ${nextPosition}');
        _updateLocalVideoTrack();
      } catch (e) {
        print('❌ [CAMERA ERROR] Error using setCameraPosition: $e');
        // Fallback: Disable and re-enable with new position
        try {
          // Disable current camera
          await _localParticipant!.setCameraEnabled(false);
          await Future.delayed(const Duration(milliseconds: 200));
          
          // Create new capture options with the next camera position
          final newOptions = CameraCaptureOptions(
            cameraPosition: nextPosition,
          );
          
          // Create new track with new camera position
          final newTrack = await LocalVideoTrack.createCameraTrack(newOptions);
          
          // Stop old track if it exists
          final oldTrackPub = _localParticipant!.videoTrackPublications
              .where((pub) => pub.source == TrackSource.camera)
              .firstOrNull;
          
          if (oldTrackPub != null && oldTrackPub.track != null) {
            final oldTrack = oldTrackPub.track;
            if (oldTrack is LocalVideoTrack) {
              await oldTrack.stop();
            }
          }
          
          // Publish new track
          await _localParticipant!.publishVideoTrack(newTrack);
          
          print('✅ [CAMERA] Camera switched using createCameraTrack method');
          
          // Wait a bit for track to update
          await Future.delayed(const Duration(milliseconds: 200));
          _updateLocalVideoTrack();
        } catch (e2) {
          print('❌ [CAMERA ERROR] All camera switch methods failed: $e2');
        }
      }
    } catch (e, stackTrace) {
      print('❌ [CAMERA ERROR] Error switching camera: $e');
      print('❌ [CAMERA ERROR] Stack trace: $stackTrace');
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
      // Start polling for call details if we have a session ID
      final sessionId = currentSessionId.value;
      if (sessionId != null && sessionId.isNotEmpty && callDetails.value == null) {
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
          print('⚠️ [ROOM EVENT] Could not show toast (overlay not available): $e');
        }
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
      // Only show toast if we have a valid context (avoid overlay errors)
      try {
        AppToasts.showError('Failed to connect. Please check your internet and try again.');
      } catch (e) {
        print('⚠️ [ROOM EVENT] Could not show toast (overlay not available): $e');
      }
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
      final response = await _directCallService.getCallDetails(sessionId, timestamp);
      
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
          
          if (oldStatementText != newStatementText || oldStatementId != newStatementId) {
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
        }
        
        if (newReport != null) {
          print('✅ [CALL DETAILS] Report found: ${newReport.caseNumber ?? "No case number"}');
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
      // Don't show error toast - this is a background operation
    } finally {
      _isLoadingCallDetails = false;
    }
  }
  
  /// Start polling for call details updates
  void _startCallDetailsPolling() {
    final sessionId = currentSessionId.value;
    if (sessionId == null || sessionId.isEmpty) {
      print('⚠️ [CALL DETAILS POLLING] Cannot start polling: sessionId is empty');
      return;
    }
    
    // Stop any existing polling
    _stopCallDetailsPolling();
    
    print('📋 [CALL DETAILS POLLING] Starting call details polling for session: $sessionId');
    
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
      final dateStr = '${details.createdAt!.day}/${details.createdAt!.month}/${details.createdAt!.year}';
      infoRows.add(InfoRow('Call Date', dateStr));
    }
    
    idInformation.assignAll(infoRows);
    print('✅ [CALL DETAILS] Updated ID Information with ${infoRows.length} rows');
  }

  /// Handle call ended (cleanup)
  Future<void> _handleCallEnded() async {
    // Stop polling when call ends
    _stopCallDetailsPolling();
    
    await disconnectFromRoom();
    callStatus.value = 'ended';
    currentSessionId.value = '';
    currentRoomName.value = '';
    currentWsUrl.value = '';
    
    // Clear call details
    callDetails.value = null;
    reportInfo.value = null;
    statementInfo.value = null;
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
