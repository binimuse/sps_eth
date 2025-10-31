import 'package:flutter/material.dart';

class AppColors {
  ///GRAY SCALE
  static Color black = const Color(0xff171717);
  static Color blackLight = const Color(0xff3a3a3c);
  static Color grayDark = const Color(0xff5d6066);
  static Color grayDefault = const Color(0xff808489);
  static Color grayLight = const Color(0xffbcbec2);
  static Color grayLighter = const Color(0xffd2d2d2);

  //BACKGROUND
  static Color backgroundDark = const Color(0xffe8e8e8);
  static Color backgroundLight = const Color(0xfff6f6f6);

  //ETC
  static Color dim = const Color(0xff222628).withOpacity(0.3);
  static Color toastMessageBackground = const Color(
    0xff32363a,
  ).withOpacity(0.8);

  //WHITE
  static Color whiteOff = const Color(0xffffffff);
  static Color white70 = const Color(0xffffffff).withOpacity(0.7);
  static Color white50 = const Color(0xffffffff).withOpacity(0.5);
  static Color white30 = const Color(0xffffffff).withOpacity(0.3);
  static Color white10 = const Color(0xffffffff).withOpacity(0.1);

  //PRIMARY
  static Color primary = const Color(0xff18304E);
  static Color primaryLighter = const Color(0xff18304E).withOpacity(0.1);
  static Color primaryLight = const Color(0xff18304E).withOpacity(0.3);
  static Color primaryDark = const Color(0xff18304E);

  //PRIMARY
  static Color secondary = const Color(0xffEFD288);
  static Color secondaryDark = const Color(0xffEFD288);
  static Color secondaryLight = const Color(0xffEFD288).withOpacity(0.3);
  static Color secondaryLighter = const Color(0xffEFD288).withOpacity(0.1);

  //ACCENT
  static Color accent = const Color(0xff784cd6);
  static Color accentDark = const Color(0xff4a1a88);
  static Color accentLight = const Color(0xffa48ee4);
  static Color accentLighter = const Color(0xffebe1ff);
  static Color accentGradientStart = const Color(0xff784cd6);
  static Color accentGradientEnd = const Color(0xff332fe3);

  //DANGER
  static Color danger = const Color(0xffe76565);
  static Color dangerDark = const Color(0xffa92e2e);
  static Color dangerLight = const Color(0xffffeaea);

  //WARNING
  static Color warning = const Color(0xffFFD02C);
  static Color warningDefault = Color.fromARGB(255, 250, 217, 97);
  static Color warningLight = const Color(0xffffeaea);

  //SUCCESS
  static Color success = const Color(0xff1fa363);
  static Color successDark = const Color(0xff0e6a3e);
  static Color successLight = const Color(0xffddfbed);
}
