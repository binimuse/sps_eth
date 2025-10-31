// import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static Future<SharedPreferences> get _instance async => _prefsInstance;

  static late SharedPreferences _prefsInstance;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    _prefsInstance = await SharedPreferences.getInstance();
    return _prefsInstance;
  }

  static String getString(String key, [String? defult]) {
    return _prefsInstance.getString(key) ?? defult ?? '';
  }

  static bool getbool(String key, [bool? defult]) {
    return _prefsInstance.getBool(key) ?? defult ?? false;
  }

  static Future<bool> setString(String key, String value) async {
    var prefs = await _instance;
    return prefs.setString(key, value);
  }

  static List<String> getStringList(String key, [List<String>? defult]) {
    return _prefsInstance.getStringList(key) ?? defult ?? <String>[];
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    var prefs = await _instance;
    return prefs.setStringList(key, value);
  }
}
