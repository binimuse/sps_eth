import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VisitorIdController extends GetxController {
  // Form controllers for Personal Information
  final clearanceForController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final maritalStatusController = TextEditingController();

  // Keyboard state
  final selectedLanguage = 'English'.obs;
  final TextEditingController keyboardController = TextEditingController();
  TextEditingController? focusedController;
  FocusNode? focusedField = FocusNode();

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
    clearanceForController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    maritalStatusController.dispose();
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

  void onKeyboardKeyPressed(String key) {
    if (focusedController == null) return;

    final text = focusedController!.text;
    final selection = focusedController!.selection;
    
    if (key == 'backspace') {
      if (selection.start > 0) {
        final newText = text.substring(0, selection.start - 1) + text.substring(selection.end);
        focusedController!.text = newText;
        focusedController!.selection = TextSelection.collapsed(offset: selection.start - 1);
      }
    } else if (key == 'space') {
      final newText = text.substring(0, selection.start) + ' ' + text.substring(selection.end);
      focusedController!.text = newText;
      focusedController!.selection = TextSelection.collapsed(offset: selection.start + 1);
    } else if (key == 'left') {
      if (selection.start > 0) {
        focusedController!.selection = TextSelection.collapsed(offset: selection.start - 1);
      }
    } else if (key == 'right') {
      if (selection.end < text.length) {
        focusedController!.selection = TextSelection.collapsed(offset: selection.end + 1);
      }
    } else if (key == 'enter') {
      final newText = text.substring(0, selection.start) + '\n' + text.substring(selection.end);
      focusedController!.text = newText;
      focusedController!.selection = TextSelection.collapsed(offset: selection.start + 1);
    } else if (key == '123') {
      // Switch to number/symbol mode (would need to implement this)
    } else {
      final newText = text.substring(0, selection.start) + key + text.substring(selection.end);
      focusedController!.text = newText;
      focusedController!.selection = TextSelection.collapsed(offset: selection.start + key.length);
    }
    
    keyboardController.text = focusedController!.text;
    keyboardController.selection = focusedController!.selection;
  }
}

