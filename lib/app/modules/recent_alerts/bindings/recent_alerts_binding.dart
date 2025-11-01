import 'package:get/get.dart';

import '../controllers/recent_alerts_controller.dart';

class RecentAlertsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecentAlertsController>(
      () => RecentAlertsController(),
    );
  }
}
