import 'package:get/get.dart';

class LanguageController extends GetxController {
  //TODO: Implement LanguageController

  final count = 0.obs;

  // Tracks the selected language index
  final RxInt selectedLanguageIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  // Updates the selected language index
  void selectLanguage(int index) {
    selectedLanguageIndex.value = index;
  }
}
