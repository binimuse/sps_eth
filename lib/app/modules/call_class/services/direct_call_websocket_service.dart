import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:sps_eth_app/app/utils/constants.dart';
import 'package:sps_eth_app/app/utils/jwt_util.dart';
import 'package:sps_eth_app/app/utils/auth_util.dart';
import 'package:sps_eth_app/app/modules/call_class/models/direct_call_model.dart';

/// WebSocket service for Direct Call system using Socket.IO
class DirectCallWebSocketService {
  IO.Socket? _socket;
  Timer? _heartbeatTimer;
  final String _baseUrl;

  // Event callbacks
  Function(IncomingCallEvent)? onIncomingCall;
  Function(CallAcceptedEvent)? onCallAccepted;
  Function(CallRejectedEvent)? onCallRejected;
  Function(CallEndedEvent)? onCallEnded;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(String)? onError;

  DirectCallWebSocketService({String? baseUrl})
      : _baseUrl = baseUrl ?? Constants.baseUrl.replaceAll('/api/v1', '');

  /// Connect to WebSocket
  /// Should be called when user logs in
  Future<void> connect() async {
    print('🔌 [WS SERVICE] Starting WebSocket connection...');
    try {
      // Get user ID from token
      final token = await AuthUtil().getAccessToken();
      print('🔌 [WS SERVICE] Token exists: ${token != null}');
      
      if (token == null) {
        print('❌ [WS SERVICE] No access token available');
        onError?.call('No access token available');
        return;
      }

      final userId = JwtUtil.getUserIdFromToken(token);
      print('🔌 [WS SERVICE] User ID extracted: ${userId ?? "null"}');
      
      if (userId == null || userId.isEmpty) {
        print('❌ [WS SERVICE] Could not extract user ID from token');
        onError?.call('Could not extract user ID from token');
        return;
      }

      // Disconnect existing connection if any
      print('🔌 [WS SERVICE] Disconnecting existing connection if any...');
      disconnect();

      // Create Socket.IO connection
      // Ensure baseUrl doesn't end with / and path doesn't start with /
      final cleanBaseUrl = _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
      final wsUrl = '$cleanBaseUrl/direct-call';
      print('🔌 [WS SERVICE] Connecting to: $wsUrl');
      print('🔌 [WS SERVICE] Auth payload: {userId: $userId}');
      
      _socket = IO.io(
        wsUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'userId': userId})
            .enableAutoConnect()
            .build(),
      );
      print('🔌 [WS SERVICE] Socket.IO instance created');

      // Set up event listeners
      print('🔌 [WS SERVICE] Setting up event listeners...');
      _setupEventListeners();

      // Start heartbeat
      print('🔌 [WS SERVICE] Starting heartbeat...');
      _startHeartbeat(userId);
      
      print('🔌 [WS SERVICE] Connection process completed');
      print('🔌 [WS SERVICE] Socket state after setup:');
      print('  - Socket exists: ${_socket != null}');
      print('  - Socket connected: ${_socket?.connected ?? false}');
      print('  - Socket ID: ${_socket?.id ?? "null"}');
      print('🔌 [WS SERVICE] Waiting for connection... (this is async)');
    } catch (e, stackTrace) {
      print('❌ [WS SERVICE ERROR] Error connecting to WebSocket: $e');
      print('❌ [WS SERVICE ERROR] Stack trace: $stackTrace');
      onError?.call('Failed to connect: $e');
    }
  }

  /// Set up Socket.IO event listeners
  void _setupEventListeners() {
    if (_socket == null) {
      print('⚠️ [WS SERVICE] Socket is null, cannot set up listeners');
      return;
    }

    print('🔌 [WS SERVICE] Setting up Socket.IO event listeners...');

    _socket!.onConnect((_) {
      print('✅ [WS SERVICE] ========== Socket.IO CONNECTED ==========');
      print('✅ [WS SERVICE] Socket ID: ${_socket!.id}');
      print('✅ [WS SERVICE] Socket connected: ${_socket!.connected}');
      print('✅ [WS SERVICE] Socket transport: ${_socket!.io.engine?.transport?.name ?? "unknown"}');
      print('✅ [WS SERVICE] ==========================================');
      onConnected?.call();
    });

    _socket!.onDisconnect((reason) {
      print('❌ [WS SERVICE] ========== Socket.IO DISCONNECTED ==========');
      print('❌ [WS SERVICE] Reason: $reason');
      print('❌ [WS SERVICE] Socket connected: ${_socket?.connected ?? false}');
      print('❌ [WS SERVICE] ==============================================');
      onDisconnected?.call();
    });

    _socket!.onError((error) {
      print('❌ [WS SERVICE ERROR] ========== Socket.IO ERROR ==========');
      print('❌ [WS SERVICE ERROR] Error: $error');
      print('❌ [WS SERVICE ERROR] Error type: ${error.runtimeType}');
      print('❌ [WS SERVICE ERROR] Socket connected: ${_socket?.connected ?? false}');
      print('❌ [WS SERVICE ERROR] ======================================');
      onError?.call(error.toString());
    });
    
    // Also listen for connection errors
    _socket!.onConnectError((error) {
      print('❌ [WS SERVICE ERROR] ========== CONNECTION ERROR ==========');
      print('❌ [WS SERVICE ERROR] Connection error: $error');
      print('❌ [WS SERVICE ERROR] Error type: ${error.runtimeType}');
      print('❌ [WS SERVICE ERROR] =======================================');
      onError?.call('Connection error: $error');
    });

    // Listen for incoming call (Employee only)
    _socket!.on('incomingCall', (data) {
      print('📞 [WS SERVICE EVENT] Received incomingCall event');
      print('📞 [WS SERVICE EVENT] Data: $data');
      try {
        Map<String, dynamic> jsonData;
        if (data is Map<String, dynamic>) {
          jsonData = data;
        } else {
          // Try to convert to Map
          jsonData = Map<String, dynamic>.from(data as Map);
        }
        final event = IncomingCallEvent.fromJson(jsonData);
        print('📞 [WS SERVICE EVENT] Parsed incomingCall: sessionId=${event.sessionId}, roomName=${event.roomName}');
        onIncomingCall?.call(event);
      } catch (e, stackTrace) {
        print('❌ [WS SERVICE ERROR] Error parsing incomingCall event: $e');
        print('❌ [WS SERVICE ERROR] Stack trace: $stackTrace');
        print('❌ [WS SERVICE ERROR] Data: $data');
      }
    });

    // Listen for call accepted (Caller only)
    _socket!.on('callAccepted', (data) {
      print('✅ [WS SERVICE EVENT] Received callAccepted event');
      print('✅ [WS SERVICE EVENT] Data: $data');
      try {
        Map<String, dynamic> jsonData;
        if (data is Map<String, dynamic>) {
          jsonData = data;
        } else {
          jsonData = Map<String, dynamic>.from(data as Map);
        }
        final event = CallAcceptedEvent.fromJson(jsonData);
        print('✅ [WS SERVICE EVENT] Parsed callAccepted: sessionId=${event.sessionId}, roomName=${event.roomName}');
        onCallAccepted?.call(event);
      } catch (e, stackTrace) {
        print('❌ [WS SERVICE ERROR] Error parsing callAccepted event: $e');
        print('❌ [WS SERVICE ERROR] Stack trace: $stackTrace');
        print('❌ [WS SERVICE ERROR] Data: $data');
      }
    });

    // Listen for call rejected (Caller only)
    _socket!.on('callRejected', (data) {
      try {
        Map<String, dynamic> jsonData;
        if (data is Map<String, dynamic>) {
          jsonData = data;
        } else {
          jsonData = Map<String, dynamic>.from(data as Map);
        }
        final event = CallRejectedEvent.fromJson(jsonData);
        onCallRejected?.call(event);
      } catch (e) {
        print('Error parsing callRejected event: $e, data: $data');
      }
    });

    // Listen for call ended (Both)
    _socket!.on('callEnded', (data) {
      try {
        Map<String, dynamic> jsonData;
        if (data is Map<String, dynamic>) {
          jsonData = data;
        } else {
          jsonData = Map<String, dynamic>.from(data as Map);
        }
        final event = CallEndedEvent.fromJson(jsonData);
        onCallEnded?.call(event);
      } catch (e) {
        print('Error parsing callEnded event: $e, data: $data');
      }
    });
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat(String userId) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_socket != null && _socket!.connected) {
        _socket!.emit('heartbeat', {'userId': userId});
      }
    });
  }

  /// Disconnect from WebSocket
  /// Should be called when user logs out or component unmounts
  void disconnect() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  /// Check if socket is connected
  bool get isConnected => _socket?.connected ?? false;

  /// Get socket ID
  String? get socketId => _socket?.id;
}

