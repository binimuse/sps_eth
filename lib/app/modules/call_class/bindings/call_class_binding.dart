import 'package:get/get.dart';

import '../controllers/call_class_controller.dart';

class CallClassBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallClassController>(
      () => CallClassController(),
    );
  }
}
