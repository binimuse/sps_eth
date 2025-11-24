import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/Residence_id/bindings/residence_id_binding.dart';
import '../modules/Residence_id/views/residence_id_view.dart';
import '../modules/visitor_id/bindings/visitor_id_binding.dart';
import '../modules/visitor_id/views/visitor_id_view.dart';
import '../modules/call_class/bindings/call_class_binding.dart';
import '../modules/call_class/views/call_class_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/residency_type/bindings/fiiling_class_binding.dart';
import '../modules/residency_type/views/residency_type_view.dart';
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
import '../modules/service_list/bindings/service_detail_binding.dart';
import '../modules/service_list/views/service_detail_view.dart';
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
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: _Paths.CALL_CLASS,
      page: () => const CallClassView(),
      binding: CallClassBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: _Paths.FIILING_CLASS,
      page: () => const FiilingClassView(),
      binding: FiilingClassBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: _Paths.FORM_CLASS,
      page: () => const FormClassView(),
      binding: FormClassBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: _Paths.NEARBY_POLICE,
      page: () => NearbyPoliceView(),
      binding: NearbyPoliceBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: _Paths.RECENT_ALERTS,
      page: () => const RecentAlertsView(),
      binding: RecentAlertsBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: _Paths.LANGUAGE,
      page: () => const LanguageView(),
      binding: LanguageBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: _Paths.RESIDENCE_ID,
      page: () => const ResidenceIdView(),
      binding: ResidenceIdBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: _Paths.SERVICE_LIST,
      page: () => const ServiceListView(),
      binding: ServiceListBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: _Paths.SERVICE_DETAIL,
      page: () => const ServiceDetailView(),
      binding: ServiceDetailBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: _Paths.VISITOR_ID,
      page: () => const VisitorIdView(),
      binding: VisitorIdBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ),
  ];
}
