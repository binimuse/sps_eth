import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sps_eth_app/app/app_language/translations.dart';
import 'package:sps_eth_app/app/utils/constants.dart';
import 'package:sps_eth_app/app/utils/prefrence_utility.dart';
import 'package:sps_eth_app/app/utils/kiosk_machine_id_util.dart';
import 'package:sps_eth_app/app/utils/full_screen_util.dart';
import 'package:upgrader/upgrader.dart';
import 'app/routes/app_pages.dart';

final botToastBuilder = BotToastInit();
late String selectedLocale;

void main() async {
  print('=== APP STARTING ===');

  WidgetsFlutterBinding.ensureInitialized();

  // Full screen: use whole screen, hide status/nav bars (immersive sticky)
  await FullScreenUtil.enableFullScreen();

  // Allow all orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await PreferenceUtils.init();

  // Initialize and store Android ID and Serial Number for kiosk machine identification
  await KioskMachineIdUtil.initializeAndStoreDeviceInfo();

  // Set default language to English if no language preference exists
  final String savedLanguage = PreferenceUtils.getString(
    Constants.selectedLanguage,
    '',
  );
  if (savedLanguage.isEmpty) {
    await PreferenceUtils.setString(
      Constants.selectedLanguage,
      Constants.lanEn,
    );
    selectedLocale = 'en_US'; // Map 'en' to 'en_US' for translations
  } else {
    // Map language codes to translation keys
    if (savedLanguage == Constants.lanEn) {
      selectedLocale = 'en_US';
    } else {
      selectedLocale =
          savedLanguage; // 'am', 'or', 'ti', 'so' match translation keys
    }
  }

  await Future<void>.delayed(const Duration(milliseconds: 5000));

  runApp(const _FullScreenApp());
}

/// Wraps the app and reapplies full screen when the app resumes.
class _FullScreenApp extends StatefulWidget {
  const _FullScreenApp();

  @override
  State<_FullScreenApp> createState() => _FullScreenAppState();
}

class _FullScreenAppState extends State<_FullScreenApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FullScreenUtil.reapplyFullScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
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
    );
  }
}
