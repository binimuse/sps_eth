import 'package:get/get.dart';
import 'package:sps_eth_app/app/utils/constants.dart';
import 'package:sps_eth_app/app/utils/lang_util.dart';
import 'package:sps_eth_app/app/utils/prefrence_utility.dart';

class LanguageController extends GetxController {
  static const String _selectedLanguageIndexKey = 'selected_language_index';

  /// Map language index to locale code for GetX translations
  /// Index: 0=English, 1=Amharic, 2=Afaan Oromoo, 3=Tigrigna, 4=Somali, 5=Arabic
  static const List<String> _localeCodes = [
    'en_US', // English
    'am',    // Amharic
    'or',    // Afaan Oromoo (fallback to en_US)
    'ti',    // Tigrigna (fallback to en_US)
    'so',    // Somali (fallback to en_US)
    'ar',    // Arabic (fallback to en_US)
  ];

  // Tracks the selected language index
  final RxInt selectedLanguageIndex = (-1).obs;

  // Tracks if we're showing local language sub-options
  final RxBool showLocalLanguages = false.obs;

  // Tracks selected local language index
  final RxInt selectedLocalLanguageIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    _loadSelectedLanguage();
  }

  /// Load previously selected language from storage and sync index
  void _loadSelectedLanguage() {
    try {
      final savedLocale = LanUtil.getSelecctedLanguage();
      // Map "en" to en_US for index lookup
      final localeForLookup = savedLocale == Constants.lanEn ? 'en_US' : savedLocale;
      int index = _localeCodes.indexOf(localeForLookup);
      if (index >= 0) {
        selectedLanguageIndex.value = index;
      }
      // Fallback: legacy index-based storage
      if (selectedLanguageIndex.value < 0) {
        final savedIndex = PreferenceUtils.getInt(_selectedLanguageIndexKey, -1);
        if (savedIndex >= 0 && savedIndex < _localeCodes.length) {
          selectedLanguageIndex.value = savedIndex;
        }
      }
    } catch (e) {
      // ignore
    }
  }

  /// Apply locale and persist - updates app language immediately
  Future<void> _applyLocale(int index) async {
    final localeCode = _localeCodes[index];
    // Map en_US for storage (main.dart expects 'en' or full code)
    final toSave = localeCode == 'en_US' ? Constants.lanEn : localeCode;
    await LanUtil.saveLanguage(toSave);
    await PreferenceUtils.setInt(_selectedLanguageIndexKey, index);
  }

  /// Select language - applies locale immediately, then caller navigates
  Future<void> selectLanguage(int index) async {
    if (index < 0 || index >= _localeCodes.length) return;
    selectedLanguageIndex.value = index;
    await _applyLocale(index);
  }
  
  // Show local language sub-options
  void showLocalLanguageOptions() {
    showLocalLanguages.value = true;
  }
  
  // Select a local language
  void selectLocalLanguage(int index) {
    selectedLocalLanguageIndex.value = index;
    // Navigate after selecting local language
    Get.toNamed('/fiiling-class');
  }
  
  // Go back from local language selection
  void backFromLocalLanguages() {
    showLocalLanguages.value = false;
    selectedLocalLanguageIndex.value = -1;
  }
}
