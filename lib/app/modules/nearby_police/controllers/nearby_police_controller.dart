import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';

class NearbyPoliceController extends GetxController {
  // Observable set of markers for the map
  final RxSet<Marker> markers = <Marker>{}.obs;

  // Default camera position (Addis Ababa approx)
  final CameraPosition initialCamera = const CameraPosition(
    target: LatLng(9.03, 38.74),
    zoom: 13,
  );

  BitmapDescriptor? _pinIcon;

  @override
  void onReady() {
    super.onReady();
    _loadMarkerIconAndMarkers();
  }

  Future<void> _loadMarkerIconAndMarkers() async {
    try {
      _pinIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.0),
        Assets.images.efpLogo.path,
      );
    } catch (_) {
      _pinIcon = BitmapDescriptor.defaultMarker;
    }

    final List<LatLng> positions = [
      const LatLng(9.0308, 38.7469),
      const LatLng(9.0320, 38.7510),
      const LatLng(9.0285, 38.7430),
      const LatLng(9.0250, 38.7500),
      const LatLng(9.0350, 38.7400),
    ];

    final Set<Marker> newMarkers = {};
    for (var i = 0; i < positions.length; i++) {
      newMarkers.add(Marker(
        markerId: MarkerId('efp_$i'),
        position: positions[i],
        icon: _pinIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: 'EFP Station ${i + 1}'),
      ));
    }

    markers.addAll(newMarkers);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
