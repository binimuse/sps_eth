import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';
import 'package:sps_eth_app/app/utils/dio_util.dart';
import 'package:sps_eth_app/app/common/app_toasts.dart';
import 'package:sps_eth_app/app/modules/nearby_police/services/nearby_police_service.dart';
import 'package:sps_eth_app/app/modules/nearby_police/models/branch_location_model.dart';
import 'package:sps_eth_app/app/utils/enums.dart';

class NearbyPoliceController extends GetxController {
  // Observable set of markers for the map
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<NetworkStatus> networkStatus = NetworkStatus.IDLE.obs;

  // Current device location
  final Rx<LatLng?> currentLocation = Rx<LatLng?>(null);

  // Camera position - will be updated based on device location
  final Rx<CameraPosition> cameraPosition = Rx<CameraPosition>(
    const CameraPosition(
      target: LatLng(9.03, 38.74),
      zoom: 15.5, // Increased zoom level for closer view
    ),
  );

  BitmapDescriptor? _pinIcon;
  GoogleMapController? _mapController;
  
  // Service
  late final NearbyPoliceService _nearbyPoliceService;
  
  // Getter for map controller (for overlay widget)
  GoogleMapController? get mapController => _mapController;

  @override
  void onInit() {
    super.onInit();
    // Initialize service (public endpoint, no auth token needed)
    final dio = DioUtil().getDio(useAccessToken: false);
    _nearbyPoliceService = NearbyPoliceService(dio);
  }

  @override
  void onReady() {
    super.onReady();
    loadNearbyStations();
  }

  @override
  void onClose() {
    _mapController?.dispose();
    super.onClose();
  }

  Future<void> loadNearbyStations() async {
    isLoading.value = true;
    errorMessage.value = '';
    networkStatus.value = NetworkStatus.LOADING;
    
    try {
      // Request location permission
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        errorMessage.value = 'Location permission is required to find nearby police stations';
        networkStatus.value = NetworkStatus.ERROR;
        isLoading.value = false;
        _showToastSafely(() => AppToasts.showError('Location permission denied'));
        return;
      }

      // Get device location
      final position = await _getCurrentLocation();
      if (position == null) {
        errorMessage.value = 'Unable to get your current location';
        networkStatus.value = NetworkStatus.ERROR;
        isLoading.value = false;
        _showToastSafely(() => AppToasts.showError('Unable to get your current location'));
        return;
      }

      final deviceLat = position.latitude;
      final deviceLng = position.longitude;
      currentLocation.value = LatLng(deviceLat, deviceLng);

      // Prepare marker icon
      await _prepareMarkerIcon();

      // Fetch nearby branches from API
      final branches = await _fetchNearbyBranches(deviceLat, deviceLng);
      
      // Create markers from branches
      final Set<Marker> newMarkers = {};
      LatLng? firstStationLocation;
      
      // Add user location marker
      final userLocation = LatLng(deviceLat, deviceLng);
      newMarkers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: userLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          anchor: const Offset(0.5, 0.5),
          infoWindow: const InfoWindow(
            title: 'Your Location',
          ),
        ),
      );
      
      for (var i = 0; i < branches.length; i++) {
        final branch = branches[i];
        if (branch.lat != null && branch.lng != null) {
          // Store the first station location for camera positioning
          if (i == 0) {
            firstStationLocation = LatLng(branch.lat!, branch.lng!);
          }
          
          // Get branch name (prefer English, fallback to Amharic or default name)
          String branchName = branch.nameJson?.en ?? 
                             branch.nameJson?.am ?? 
                             branch.name ?? 
                             'Police Station ${i + 1}';
          
          // Build info window snippet
          String snippet = '';
          if (branch.distance != null) {
            snippet = 'Distance: ${branch.distance!.toStringAsFixed(2)} km';
          }
          if (branch.code != null && branch.code!.isNotEmpty) {
            if (snippet.isNotEmpty) snippet += '\n';
            snippet += 'Code: ${branch.code}';
          }

          // Create marker with custom icon
          newMarkers.add(
            Marker(
              markerId: MarkerId(branch.id ?? 'branch_$i'),
              position: LatLng(branch.lat!, branch.lng!),
              icon: _pinIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              anchor: const Offset(0.5, 0.5), // Center the marker
              infoWindow: InfoWindow(
                title: branchName,
                snippet: snippet.isNotEmpty ? snippet : null,
              ),
            ),
          );
        }
      }
      
      markers
        ..clear()
        ..addAll(newMarkers);
      
      // Update camera to first nearby police station if available, otherwise use device location
      final targetLocation = firstStationLocation ?? LatLng(deviceLat, deviceLng);
      cameraPosition.value = CameraPosition(
        target: targetLocation,
        zoom: 15.5, // Increased zoom level for closer view
      );

      // Move map camera to the first police station (or device location if no stations found)
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            targetLocation,
            15.5, // Increased zoom level for closer view
          ),
        );
      }
      
      networkStatus.value = NetworkStatus.SUCCESS;
      
      if (branches.isEmpty) {
        _showToastSafely(() => AppToasts.showWarning('No nearby police stations found'));
      } else {
        _showToastSafely(() => AppToasts.showSuccess('Found ${branches.length} nearby police station(s)'));
      }
    } catch (e) {
      print('❌ [NEARBY POLICE] Error loading nearby stations: $e');
      errorMessage.value = 'Failed to load nearby police stations: ${e.toString()}';
      networkStatus.value = NetworkStatus.ERROR;
      _showToastSafely(() => AppToasts.showError('Failed to load nearby police stations'));
    } finally {
      isLoading.value = false;
    }
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
        print('⚠️ [NEARBY POLICE] Error showing toast: $e');
        // Silently fail - error message is already shown in UI
      }
    });
  }

  /// Request location permission
  Future<bool> _requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // Show dialog to open app settings
        _showToastSafely(() => AppToasts.showError('Location permission is permanently denied. Please enable it in app settings.'));
        return false;
      }
      return false;
    } catch (e) {
      print('❌ [NEARBY POLICE] Error requesting location permission: $e');
      return false;
    }
  }

  /// Get current device location
  Future<Position?> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled;
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } catch (e) {
        // Handle MissingPluginException - plugin might not be initialized
        print('⚠️ [NEARBY POLICE] Geolocator plugin not available: $e');
        print('⚠️ [NEARBY POLICE] Please rebuild the app after adding geolocator dependency');
        // Assume location services are enabled and continue
        serviceEnabled = true;
      }
      
      if (!serviceEnabled) {
        _showToastSafely(() => AppToasts.showError('Location services are disabled. Please enable location services.'));
        return null;
      }

      // Check location permission
      LocationPermission permission;
      try {
        permission = await Geolocator.checkPermission();
      } catch (e) {
        print('⚠️ [NEARBY POLICE] Error checking permission: $e');
        return null;
      }
      
      if (permission == LocationPermission.denied) {
        try {
          permission = await Geolocator.requestPermission();
        } catch (e) {
          print('⚠️ [NEARBY POLICE] Error requesting permission: $e');
          return null;
        }
        if (permission == LocationPermission.denied) {
          _showToastSafely(() => AppToasts.showError('Location permissions are denied'));
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showToastSafely(() => AppToasts.showError('Location permissions are permanently denied. Please enable them in app settings.'));
        return null;
      }

      // Get current position
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        print('❌ [NEARBY POLICE] Error getting position: $e');
        return null;
      }
    } catch (e) {
      print('❌ [NEARBY POLICE] Error getting current location: $e');
      return null;
    }
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _prepareMarkerIcon() async {
    try {
      // Create bigger icon with better visibility
      _pinIcon = await _createResizedMarkerIcon(
        Assets.images.efpLogo.path,
        width: 90, // Increased size even more for better visibility
        height: 90,
      );
    } catch (e) {
      print('⚠️ [NEARBY POLICE] Error creating marker icon: $e');
      _pinIcon = BitmapDescriptor.defaultMarker;
    }
  }

  /// Create a resized marker icon from an asset image
  Future<BitmapDescriptor> _createResizedMarkerIcon(
    String assetPath, {
    int width = 40,
    int height = 40,
  }) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    
    // Decode the image
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: width,
      targetHeight: height,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    // Convert to byte data
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List resizedBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(resizedBytes);
  }

  /// Fetch nearby branches from API
  Future<List<BranchLocation>> _fetchNearbyBranches(double lat, double lng) async {
    try {
      print('📍 [NEARBY POLICE] Fetching branches for location: lat=$lat, lng=$lng');
      
      final response = await _nearbyPoliceService.getNearbyBranches(lat, lng);
      
      if (response.success == true && response.data != null) {
        print('✅ [NEARBY POLICE] Found ${response.data!.length} branches');
        return response.data!;
      } else {
        print('⚠️ [NEARBY POLICE] API returned success=false or data is null');
        return [];
      }
    } catch (e) {
      print('❌ [NEARBY POLICE] Error fetching branches: $e');
      rethrow;
    }
  }
}
