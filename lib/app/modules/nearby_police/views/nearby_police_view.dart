import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
              return GoogleMap(
                initialCameraPosition: controller.initialCamera,
                onMapCreated: controller.onMapCreated,
                markers: controller.markers,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
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
                  onPressed: Get.back,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
