import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VisitorIdController extends GetxController {
  // Passport ID controller
  final passportIdController = TextEditingController();

  // Keyboard state
  final selectedLanguage = 'English'.obs;
  final TextEditingController keyboardController = TextEditingController();
  TextEditingController? focusedController;
  FocusNode? focusedField = FocusNode();



  @override
  void onClose() {
    passportIdController.dispose();
    keyboardController.dispose();
    focusedField?.dispose();
    super.onClose();
  }

  void setFocusedField(FocusNode? focusNode, TextEditingController textController) {
    focusedField = focusNode;
    focusedController = textController;
    keyboardController.text = textController.text;
    keyboardController.selection = textController.selection;
  }
}

