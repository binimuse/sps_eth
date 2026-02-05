import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';
import 'package:sps_eth_app/gen/assets.gen.dart';

import '../controllers/nearby_police_controller.dart';

class NearbyPoliceView extends GetView<NearbyPoliceController> {
  const NearbyPoliceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6FF),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image (same as residency_type, language, etc.)
            Image.asset(
              Assets.images.logoBackground.path,
              fit: BoxFit.fitWidth,
            ),
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
                          child: Text('Retry'.tr),
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
            // Back button (same as residence_service_detail_view)
            Positioned(
              top: 16,
              left: 16,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  side: const BorderSide(color: Color(0xFFCBDCE7)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    try {
                      Get.offAllNamed(Routes.HOME);
                    } catch (e) {
                      print('⚠️ [NAVIGATION] Error navigating back: $e');
                    }
                  }
                },
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F3955)),
                label: Text('Back'.tr, style: TextStyle(color: Color(0xFF0F3955))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
