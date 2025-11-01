import 'package:get/get.dart';

import '../controllers/nearby_police_controller.dart';

class NearbyPoliceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NearbyPoliceController>(
      () => NearbyPoliceController(),
    );
  }
}
