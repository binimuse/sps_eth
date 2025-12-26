import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormClassController extends GetxController {
  // Current step (1, 2, or 3)
  final currentStep = 1.obs;
  
  // Progress percentage
  final progress = 10.0.obs;

  // Form controllers for Step 1: Personal Information
  final clearanceForController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final maritalStatusController = TextEditingController();

  // Form controllers for Step 2: Residence Information
  final ethiopianOrForeignerController = TextEditingController();
  final regionController = TextEditingController();
  final subcityController = TextEditingController();
  final woredaController = TextEditingController();
  final kebeleController = TextEditingController();
  final houseNumberController = TextEditingController();

  // Form controllers for Step 3: Incident Details
  final incidentSummaryController = TextEditingController();
  final damageCausedController = TextEditingController();
  final incidentDetailController = TextEditingController();

  // Keyboard state
  final selectedLanguage = 'English'.obs;
  final TextEditingController keyboardController = TextEditingController();
  TextEditingController? focusedController;
  FocusNode? focusedField;

  @override
  void onInit() {
    super.onInit();
    updateProgress();
  }

  @override
  void onClose() {
    clearanceForController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    maritalStatusController.dispose();
    ethiopianOrForeignerController.dispose();
    regionController.dispose();
    subcityController.dispose();
    woredaController.dispose();
    kebeleController.dispose();
    houseNumberController.dispose();
    incidentSummaryController.dispose();
    damageCausedController.dispose();
    incidentDetailController.dispose();
    keyboardController.dispose();
    focusedField?.dispose();
    super.onClose();
  }

  void goToStep(int step) {
    currentStep.value = step;
    updateProgress();
  }

  void nextStep() {
    if (currentStep.value < 3) {
      currentStep.value++;
      updateProgress();
    }
  }

  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
      updateProgress();
    }
  }

  void updateProgress() {
    switch (currentStep.value) {
      case 1:
        progress.value = 10.0;
        break;
      case 2:
        progress.value = 42.0;
        break;
      case 3:
        progress.value = 93.0;
        break;
    }
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
      final newText = '${text.substring(0, selection.start)} ${text.substring(selection.end)}';
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
      // Move to next line or submit
      final newText = '${text.substring(0, selection.start)}\n${text.substring(selection.end)}';
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

  /// Collect all form data into a map for PDF generation
  Map<String, String> getAllFormData() {
    return {
      'clearanceFor': clearanceForController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'maritalStatus': maritalStatusController.text,
      'ethiopianOrForeigner': ethiopianOrForeignerController.text,
      'region': regionController.text,
      'subcity': subcityController.text,
      'woreda': woredaController.text,
      'kebele': kebeleController.text,
      'houseNumber': houseNumberController.text,
      'incidentSummary': incidentSummaryController.text,
      'damageCaused': damageCausedController.text,
      'incidentDetail': incidentDetailController.text,
    };
  }
}

