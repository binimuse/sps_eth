// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';

import 'package:flutter/material.dart';

import 'package:sps_eth_app/app/utils/constants.dart';
import 'package:sps_eth_app/app/utils/prefrence_utility.dart';


class LanUtil {
  ///SAVE SELECTED LANGUAGE
  static saveLanguage(String lan) async {
    await PreferenceUtils.setString(Constants.selectedLanguage, lan);

    String selectedLan = getSelecctedLanguage();

    var locale = Locale(selectedLan);
    Get.updateLocale(locale);
  }

  ///GET SELECTED LANGUAGE
  static String getSelecctedLanguage() {
    String lan = PreferenceUtils.getString(
      Constants.selectedLanguage,
      Constants.lanAm,
    );

    return lan;
  }
}
