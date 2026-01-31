import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configures the app for full-screen, edge-to-edge use (e.g. kiosk).
/// Hides status and navigation bars and uses the whole screen.
class FullScreenUtil {
  /// Enables full-screen immersive mode: content uses the whole screen,
  /// status and navigation bars are hidden. Bars reappear on swipe and
  /// hide again (immersive sticky).
  static Future<void> enableFullScreen() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  /// Call from a [WidgetsBindingObserver] to re-apply full screen when
  /// the app resumes (e.g. after keyboard or other overlay).
  static void reapplyFullScreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }
}
