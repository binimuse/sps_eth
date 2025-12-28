import 'package:get/get.dart';
import 'package:sps_eth_app/app/utils/prefrence_utility.dart';

class LanguageController extends GetxController {
  static const String _selectedLanguageIndexKey = 'selected_language_index';
  
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

  /// Load previously selected language index from storage
  void _loadSelectedLanguage() {
    try {
      final savedIndex = PreferenceUtils.getInt(_selectedLanguageIndexKey, -1);
      if (savedIndex >= 0) {
        selectedLanguageIndex.value = savedIndex;
        print('📝 [LANGUAGE] Loaded previously selected language index: $savedIndex');
      }
    } catch (e) {
      print('⚠️ [LANGUAGE] Error loading selected language: $e');
    }
  }

  /// Save selected language index to storage
  Future<void> _saveSelectedLanguage(int index) async {
    try {
      await PreferenceUtils.setInt(_selectedLanguageIndexKey, index);
      print('💾 [LANGUAGE] Saved selected language index: $index');
    } catch (e) {
      print('⚠️ [LANGUAGE] Error saving selected language: $e');
    }
  }

  // Updates the selected language index
  void selectLanguage(int index) {
    selectedLanguageIndex.value = index;
    _saveSelectedLanguage(index);
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
