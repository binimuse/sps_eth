import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sps_eth_app/app/app_language/translations.dart';
import 'package:sps_eth_app/app/utils/lang_util.dart';
import 'package:sps_eth_app/app/utils/prefrence_utility.dart';
import 'package:upgrader/upgrader.dart';
import 'app/routes/app_pages.dart';


final botToastBuilder = BotToastInit();
late String selectedLocale;
void main() async {
  print('=== APP STARTING ===');
  print('This is a test print from main.dart');

  WidgetsFlutterBinding.ensureInitialized();
  // Lock orientation to landscape for tablet mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await PreferenceUtils.init();

  selectedLocale = LanUtil.getSelecctedLanguage();



  await Future<void>.delayed(const Duration(milliseconds: 5000));

  runApp(
    ResponsiveSizer(
      builder: (context, orientation, deviceType) {
        return UpgradeAlert(
          barrierDismissible: false,
          dialogStyle: UpgradeDialogStyle.cupertino,
          shouldPopScope: () => false,
          showIgnore: false, // Hides ignore button
          showLater: false, // Hides later button
          onUpdate: () {
            // Optional: Add any action when the update button is pressed
            return true;
          },
          child: GetMaterialApp(
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
            translations: MainTranslations(),
            locale: Locale(selectedLocale),
            navigatorObservers: [BotToastNavigatorObserver()],
         
            title: 'SPS Ethiopia'.tr,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              child = botToastBuilder(context, child);

              //return child;
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  // Increase the text scale factor to 1.5
                  textScaler: const TextScaler.linear(0.8),
                ),
                child: child,
              );
            },
          ),
        );
      },
    ),
  );
}
