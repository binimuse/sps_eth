import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/routes/app_pages.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SplashView'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          // Detect swipe gesture
           Get.toNamed(Routes.HOME); // Navigate to the home screen
        },
        child: const Center(
          child: Text(
            'Swipe anywhere to continue',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
