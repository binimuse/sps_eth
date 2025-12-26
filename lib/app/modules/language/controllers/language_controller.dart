import 'package:get/get.dart';

class LanguageController extends GetxController {
  //TODO: Implement LanguageController

  final count = 0.obs;

  // Tracks the selected language index
  final RxInt selectedLanguageIndex = (-1).obs;




  void increment() => count.value++;

  // Updates the selected language index
  void selectLanguage(int index) {
    selectedLanguageIndex.value = index;
  }
}
