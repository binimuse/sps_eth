import 'package:get/get.dart';

import '../controllers/form_class_controller.dart';

class FormClassBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FormClassController>(
      () => FormClassController(),
    );
  }
}

