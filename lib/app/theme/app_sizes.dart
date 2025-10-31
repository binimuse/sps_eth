// ignore_for_file: non_constant_identifier_names

import 'package:responsive_sizer/responsive_sizer.dart';

class AppSizes {
  ///for padding and margin sizes
  ///horizontal sizes
  static final double mp_w_1 =
      Device.screenType == ScreenType.mobile ? 1.w : 1.w * 0.7;
  static final double mp_w_2 =
      Device.screenType == ScreenType.mobile ? 2.w : 2.w * 0.7;
  static final double mp_w_3 =
      Device.screenType == ScreenType.mobile ? 3.w : 3.w * 0.7;
  static final double mp_w_4 =
      Device.screenType == ScreenType.mobile ? 4.w : 4.w * 0.7;
  static final double mp_w_6 =
      Device.screenType == ScreenType.mobile ? 6.w : 6.w * 0.7;
  static final double mp_w_8 =
      Device.screenType == ScreenType.mobile ? 8.w : 8.w * 0.7;
  static final double mp_w_10 =
      Device.screenType == ScreenType.mobile ? 10.w : 10.w * 0.7;
  static final double mp_w_12 =
      Device.screenType == ScreenType.mobile ? 12.w : 12.w * 0.7;
  static final double mp_w_14 =
      Device.screenType == ScreenType.mobile ? 14.w : 14.w * 0.7;
  static final double mp_w_16 =
      Device.screenType == ScreenType.mobile ? 16.w : 16.w * 0.7;

  ///for padding and margin sizes
  ///vertical sizes
  static final double mp_v_1 =
      Device.screenType == ScreenType.mobile ? 1.h : 1.h * 0.7;
  static final double mp_v_2 =
      Device.screenType == ScreenType.mobile ? 2.h : 2.h * 0.7;
  static final double mp_v_4 =
      Device.screenType == ScreenType.mobile ? 4.h : 4.h * 0.7;
  static final double mp_v_6 =
      Device.screenType == ScreenType.mobile ? 6.h : 6.h * 0.7;
  static final double mp_v_8 =
      Device.screenType == ScreenType.mobile ? 8.h : 8.h * 0.7;
  static final double mp_v_10 =
      Device.screenType == ScreenType.mobile ? 10.h : 10.h * 0.7;
  static final double mp_v_12 =
      Device.screenType == ScreenType.mobile ? 12.h : 12.h * 0.7;
  static final double mp_v_14 =
      Device.screenType == ScreenType.mobile ? 14.h : 14.h * 0.7;
  static final double mp_v_16 =
      Device.screenType == ScreenType.mobile ? 16.h : 16.h * 0.7;

  ///for font sizes
  static final double font_10 =
      Device.screenType == ScreenType.mobile ? 14.sp : 14.sp * 1.4;
  static final double font_12 =
      Device.screenType == ScreenType.mobile ? 16.sp : 16.sp * 1.4;
  static final double font_14 =
      Device.screenType == ScreenType.mobile ? 19.sp : 19.sp * 1.4;
  static final double font_16 =
      Device.screenType == ScreenType.mobile ? 20.sp : 20.sp * 1.4;
  static final double font_18 =
      Device.screenType == ScreenType.mobile ? 22.sp : 22.sp * 1.4;
  static final double font_20 =
      Device.screenType == ScreenType.mobile ? 24.sp : 24.sp * 1.4;
  static final double font_22 =
      Device.screenType == ScreenType.mobile ? 26.sp : 26.sp * 1.4;
  static final double font_24 =
      Device.screenType == ScreenType.mobile ? 28.sp : 28.sp * 1.4;
  static final double font_28 =
      Device.screenType == ScreenType.mobile ? 30.sp : 32.sp * 1.4;
  static final double font_32 =
      Device.screenType == ScreenType.mobile ? 34.sp : 34.sp * 1.4;
  static final double font_64 =
      Device.screenType == ScreenType.mobile ? 66.sp : 66.sp * 1.4;

  ///for icon sizes
  static final double icon_size_2 =
      Device.screenType == ScreenType.mobile ? 2.w : 2.w * 0.7;
  static final double icon_size_4 =
      Device.screenType == ScreenType.mobile ? 4.w : 4.w * 0.7;
  static final double icon_size_6 =
      Device.screenType == ScreenType.mobile ? 6.w : 6.w * 0.7;
  static final double icon_size_7 =
      Device.screenType == ScreenType.mobile ? 7.w : 7.w * 0.7;
  static final double icon_size_8 =
      Device.screenType == ScreenType.mobile ? 8.w : 8.w * 0.7;
  static final double icon_size_10 =
      Device.screenType == ScreenType.mobile ? 10.w : 10.w * 0.7;
  static final double icon_size_12 =
      Device.screenType == ScreenType.mobile ? 12.w : 12.w * 0.7;
  static final double icon_size_14 =
      Device.screenType == ScreenType.mobile ? 14.w : 14.w * 0.7;
  static final double icon_size_16 =
      Device.screenType == ScreenType.mobile ? 16.w : 16.w * 0.7;
  static final double icon_size_18 =
      Device.screenType == ScreenType.mobile ? 18.w : 18.w * 0.7;
  static final double icon_size_20 =
      Device.screenType == ScreenType.mobile ? 20.w : 20.w * 0.7;
  static final double icon_size_22 =
      Device.screenType == ScreenType.mobile ? 22.w : 22.w * 0.7;
  static final double icon_size_24 =
      Device.screenType == ScreenType.mobile ? 24.w : 24.w * 0.7;
  static final double icon_size_26 =
      Device.screenType == ScreenType.mobile ? 26.w : 26.w * 0.7;
  static final double icon_size_28 =
      Device.screenType == ScreenType.mobile ? 28.w : 28.w * 0.7;
  static final double icon_size_30 =
      Device.screenType == ScreenType.mobile ? 30.w : 30.w * 0.7;
  static final double icon_size_32 =
      Device.screenType == ScreenType.mobile ? 32.w : 32.w * 0.7;

  ///for shape radius
  static final double radius_4 =
      Device.screenType == ScreenType.mobile ? 4 : 4 * 1.2;
  static final double radius_8 =
      Device.screenType == ScreenType.mobile ? 8 : 8 * 1.2;
  static final double radius_12 =
      Device.screenType == ScreenType.mobile ? 12 : 12 * 1.2;
  static final double radius_16 =
      Device.screenType == ScreenType.mobile ? 16 : 16 * 1.2;
  static final double radius_20 =
      Device.screenType == ScreenType.mobile ? 20 : 20 * 1.2;
}
