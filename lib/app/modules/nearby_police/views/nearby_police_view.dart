import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';

import '../controllers/nearby_police_controller.dart';

class NearbyPoliceView extends GetView<NearbyPoliceController> {
  const NearbyPoliceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6FF),
      body: SafeArea(
        child: Stack(
          children: [
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.loadNearbyStations(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return GoogleMap(
                initialCameraPosition: controller.cameraPosition.value,
                onMapCreated: controller.onMapCreated,
                markers: controller.markers,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                mapType: MapType.normal,
              );
            }),
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
                  onPressed: () {
                    // Use Navigator directly to avoid GetX overlay controller issues
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      // Fallback: navigate to home if can't pop
                      try {
                        Get.offAllNamed(Routes.HOME);
                      } catch (e) {
                        print('⚠️ [NAVIGATION] Error navigating back: $e');
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
