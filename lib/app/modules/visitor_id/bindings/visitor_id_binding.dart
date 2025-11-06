import 'package:get/get.dart';

import '../controllers/visitor_id_controller.dart';

class VisitorIdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VisitorIdController>(
      () => VisitorIdController(),
    );
  }
}

