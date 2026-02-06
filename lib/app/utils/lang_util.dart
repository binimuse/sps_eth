// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';

import 'package:flutter/material.dart';

import 'package:sps_eth_app/app/utils/constants.dart';
import 'package:sps_eth_app/app/utils/prefrence_utility.dart';


class LanUtil {
  /// Map stored language code to GetX translation locale key
  static String _toLocaleCode(String stored) {
    if (stored == Constants.lanEn || stored.isEmpty) return 'en_US';
    return stored;
  }

  /// SAVE SELECTED LANGUAGE and update GetX locale
  static saveLanguage(String lan) async {
    await PreferenceUtils.setString(Constants.selectedLanguage, lan);
    final localeCode = _toLocaleCode(lan);
    Get.updateLocale(Locale(localeCode));
  }

  /// GET SELECTED LANGUAGE from storage
  static String getSelecctedLanguage() {
    return PreferenceUtils.getString(
      Constants.selectedLanguage,
      Constants.lanEn,
    );
  }

  /// GET locale code for GetX (en -> en_US)
  static String getLocaleForGetX() {
    return _toLocaleCode(getSelecctedLanguage());
  }
}
