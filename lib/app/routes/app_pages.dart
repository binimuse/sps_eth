import 'package:get/get.dart';

import '../modules/Residence_id/bindings/residence_id_binding.dart';
import '../modules/Residence_id/views/residence_id_view.dart';
import '../modules/visitor_id/bindings/visitor_id_binding.dart';
import '../modules/visitor_id/views/visitor_id_view.dart';
import '../modules/call_class/bindings/call_class_binding.dart';
import '../modules/call_class/views/call_class_view.dart';
import '../modules/fiiling_class/bindings/fiiling_class_binding.dart';
import '../modules/fiiling_class/views/fiiling_class_view.dart';
import '../modules/form_class/bindings/form_class_binding.dart';
import '../modules/form_class/views/form_class_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/language/bindings/language_binding.dart';
import '../modules/language/views/language_view.dart';
import '../modules/nearby_police/bindings/nearby_police_binding.dart';
import '../modules/nearby_police/views/nearby_police_view.dart';
import '../modules/recent_alerts/bindings/recent_alerts_binding.dart';
import '../modules/recent_alerts/views/recent_alerts_view.dart';
import '../modules/service_list/bindings/service_list_binding.dart';
import '../modules/service_list/views/service_list_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.CALL_CLASS,
      page: () => const CallClassView(),
      binding: CallClassBinding(),
    ),
    GetPage(
      name: _Paths.FIILING_CLASS,
      page: () => const FiilingClassView(),
      binding: FiilingClassBinding(),
    ),
    GetPage(
      name: _Paths.FORM_CLASS,
      page: () => const FormClassView(),
      binding: FormClassBinding(),
    ),
    GetPage(
      name: _Paths.NEARBY_POLICE,
      page: () => NearbyPoliceView(),
      binding: NearbyPoliceBinding(),
    ),
    GetPage(
      name: _Paths.RECENT_ALERTS,
      page: () => const RecentAlertsView(),
      binding: RecentAlertsBinding(),
    ),
    GetPage(
      name: _Paths.LANGUAGE,
      page: () => const LanguageView(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: _Paths.RESIDENCE_ID,
      page: () => const ResidenceIdView(),
      binding: ResidenceIdBinding(),
    ),
    GetPage(
      name: _Paths.SERVICE_LIST,
      page: () => const ServiceListView(),
      binding: ServiceListBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.VISITOR_ID,
      page: () => const VisitorIdView(),
      binding: VisitorIdBinding(),
    ),
  ];
}
