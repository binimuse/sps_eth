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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Nearby Police Stations',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(() {
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
      ),
    );
  }
}
