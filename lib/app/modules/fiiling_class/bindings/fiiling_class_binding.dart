import 'package:get/get.dart';

import '../controllers/fiiling_class_controller.dart';

class FiilingClassBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FiilingClassController>(
      () => FiilingClassController(),
    );
  }
}
