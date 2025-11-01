import 'package:get/get.dart';

import '../controllers/residence_id_controller.dart';

class ResidenceIdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResidenceIdController>(
      () => ResidenceIdController(),
    );
  }
}
