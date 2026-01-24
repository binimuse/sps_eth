import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Utility class for monitoring network connectivity
/// 
/// Provides real-time connectivity status and allows listening to connectivity changes
class ConnectivityUtil {
  static final ConnectivityUtil _instance = ConnectivityUtil._internal();
  factory ConnectivityUtil() => _instance;
  ConnectivityUtil._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  // Observable connectivity status
  final RxBool isOnline = true.obs;
  final RxString connectivityStatus = 'Unknown'.obs;

  /// Initialize connectivity monitoring
  /// Call this once when app starts
  Future<void> initialize() async {
    try {
      // Check initial connectivity status
      await checkConnectivity();
      
      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          _updateConnectivityStatus(results);
        },
        onError: (error) {
          print('❌ [CONNECTIVITY] Error listening to connectivity changes: $error');
          // Assume offline on error
          isOnline.value = false;
          connectivityStatus.value = 'Error';
        },
      );
      
      print('✅ [CONNECTIVITY] Connectivity monitoring initialized');
    } catch (e) {
      print('❌ [CONNECTIVITY] Error initializing connectivity: $e');
      // Assume offline on error
      isOnline.value = false;
      connectivityStatus.value = 'Error';
    }
  }

  /// Check current connectivity status
  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(results);
    } catch (e) {
      print('❌ [CONNECTIVITY] Error checking connectivity: $e');
      // Assume offline on error
      isOnline.value = false;
      connectivityStatus.value = 'Error';
    }
  }

  /// Update connectivity status based on results
  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    // Check if any connection type is available
    final hasConnection = results.any((result) => 
      result != ConnectivityResult.none
    );
    
    isOnline.value = hasConnection;
    
    if (hasConnection) {
      // Determine connection type
      if (results.contains(ConnectivityResult.wifi)) {
        connectivityStatus.value = 'WiFi';
      } else if (results.contains(ConnectivityResult.mobile)) {
        connectivityStatus.value = 'Mobile Data';
      } else if (results.contains(ConnectivityResult.ethernet)) {
        connectivityStatus.value = 'Ethernet';
      } else {
        connectivityStatus.value = 'Connected';
      }
      print('✅ [CONNECTIVITY] Online via: ${connectivityStatus.value}');
    } else {
      connectivityStatus.value = 'Offline';
      print('❌ [CONNECTIVITY] Offline - No internet connection');
    }
  }

  /// Wait for internet connection to come back
  /// Returns true if internet comes back within timeout, false otherwise
  /// 
  /// [timeout] Maximum time to wait (default: 60 seconds)
  Future<bool> waitForInternet({Duration timeout = const Duration(seconds: 60)}) async {
    print('⏳ [CONNECTIVITY] Waiting for internet connection (timeout: ${timeout.inSeconds}s)...');
    
    // If already online, return immediately
    if (isOnline.value) {
      print('✅ [CONNECTIVITY] Already online, no need to wait');
      return true;
    }
    
    try {
      // Wait for isOnline to become true
      await isOnline.stream
          .where((online) => online == true)
          .first
          .timeout(
            timeout,
            onTimeout: () {
              print('⏰ [CONNECTIVITY] Timeout waiting for internet connection');
              return false;
            },
          );
      
      print('✅ [CONNECTIVITY] Internet connection restored');
      return true;
    } catch (e) {
      print('❌ [CONNECTIVITY] Error waiting for internet: $e');
      return false;
    }
  }

  /// Dispose connectivity monitoring
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    print('🔌 [CONNECTIVITY] Connectivity monitoring disposed');
  }
}

