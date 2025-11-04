import 'package:get/get.dart';

import '../controllers/service_list_controller.dart';

class ServiceListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceListController>(
      () => ServiceListController(),
    );
  }
}

