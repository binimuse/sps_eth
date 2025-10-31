// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// mixin FormControllerMixin on GetxController {
//   // Form key
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();

//   // Loading state
//   final RxBool isLoading = false.obs;

//   // Form validation
//   bool validateForm() {
//     return formKey.currentState?.validate() ?? false;
//   }

//   // Clear form
//   void clearForm(List<TextEditingController> controllers) {
//     for (var controller in controllers) {
//       controller.clear();
//     }
//   }

//   // Reset form
//   void resetForm(List<TextEditingController> controllers) {
//     clearForm(controllers);
//     formKey.currentState?.reset();
//   }

//   // Check if form is dirty (has changes)
//   bool isFormDirty(List<TextEditingController> controllers) {
//     return controllers.any((controller) => controller.text.isNotEmpty);
//   }

//   // Get form data as map
//   Map<String, String> getFormData(
//     List<TextEditingController> controllers,
//     List<String> fieldNames,
//   ) {
//     Map<String, String> data = {};
//     for (int i = 0; i < controllers.length && i < fieldNames.length; i++) {
//       data[fieldNames[i]] = controllers[i].text.trim();
//     }
//     return data;
//   }

//   // Set form data from map
//   void setFormData(
//     Map<String, String> data,
//     List<TextEditingController> controllers,
//     List<String> fieldNames,
//   ) {
//     for (int i = 0; i < controllers.length && i < fieldNames.length; i++) {
//       String fieldName = fieldNames[i];
//       if (data.containsKey(fieldName)) {
//         controllers[i].text = data[fieldName]!;
//       }
//     }
//   }

//   // Start loading
//   void startLoading() {
//     isLoading.value = true;
//   }

//   // Stop loading
//   void stopLoading() {
//     isLoading.value = false;
//   }

//   // Dispose controllers
//   void disposeControllers(List<TextEditingController> controllers) {
//     for (var controller in controllers) {
//       controller.dispose();
//     }
//   }

//   // Dispose focus nodes
//   void disposeFocusNodes(List<FocusNode> focusNodes) {
//     for (var focusNode in focusNodes) {
//       focusNode.dispose();
//     }
//   }

//   // Check if any field is focused
//   bool isAnyFieldFocused(List<FocusNode> focusNodes) {
//     return focusNodes.any((focusNode) => focusNode.hasFocus);
//   }

//   // Unfocus all fields
//   void unfocusAllFields(List<FocusNode> focusNodes) {
//     for (var focusNode in focusNodes) {
//       focusNode.unfocus();
//     }
//   }

//   // Focus next field
//   void focusNextField(List<FocusNode> focusNodes, int currentIndex) {
//     if (currentIndex < focusNodes.length - 1) {
//       focusNodes[currentIndex + 1].requestFocus();
//     }
//   }

//   // Focus previous field
//   void focusPreviousField(List<FocusNode> focusNodes, int currentIndex) {
//     if (currentIndex > 0) {
//       focusNodes[currentIndex - 1].requestFocus();
//     }
//   }
// }
