// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:dio/dio.dart';
// import 'package:ossc_chat_bot/app/common/app_toasts.dart';

// abstract class BaseController extends GetxController {
//   // Common observable variables
//   final RxBool isLoading = false.obs;
//   final RxBool isPasswordVisible = false.obs;
//   final RxBool isConfirmPasswordVisible = false.obs;

//   // Password strength observables
//   final RxString passwordStrength = ''.obs;
//   final RxDouble passwordStrengthValue = 0.0.obs;
//   final Rx<Color> passwordStrengthColor = Colors.grey.obs;

//   // Common form key
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();

//   // Common error handling method
//   void handleApiError(
//     DioException e, {
//     String defaultMessage = 'Operation failed',
//   }) {
//     isLoading.value = false;

//     String errorMessage = defaultMessage;

//     if (e.response != null) {
//       final responseData = e.response!.data;
//       if (responseData is Map<String, dynamic> &&
//           responseData.containsKey('message')) {
//         final message = responseData['message'];
//         if (message is String) {
//           errorMessage = message;
//         } else if (message is List) {
//           // Handle case where message is a list (common in validation errors)
//           errorMessage = message.join(', ');
//         } else {
//           // Handle other data types by converting to string
//           errorMessage = message.toString();
//         }
//       } else {
//         // Handle specific status codes
//         switch (e.response!.statusCode) {
//           case 400:
//             errorMessage = 'Invalid data provided';
//             break;
//           case 401:
//             errorMessage = 'Unauthorized access';
//             break;
//           case 403:
//             errorMessage = 'Access forbidden';
//             break;
//           case 404:
//             errorMessage = 'Resource not found';
//             break;
//           case 409:
//             errorMessage = 'Resource already exists';
//             break;
//           case 500:
//             errorMessage = 'Server error. Please try again later';
//             break;
//           default:
//             errorMessage = defaultMessage;
//         }
//       }
//     } else {
//       // Handle network errors
//       switch (e.type) {
//         case DioExceptionType.connectionTimeout:
//           errorMessage = 'Connection timeout. Please check your internet';
//           break;
//         case DioExceptionType.connectionError:
//           errorMessage = 'No internet connection';
//           break;
//         case DioExceptionType.receiveTimeout:
//           errorMessage = 'Request timeout';
//           break;
//         case DioExceptionType.sendTimeout:
//           errorMessage = 'Send timeout';
//           break;
//         default:
//           errorMessage = 'Network error occurred';
//       }
//     }

//     AppToasts.showError(errorMessage);
//   }

//   // Common success handling method
//   void showSuccessSnackbar(String message) {
//     AppToasts.showSuccess(message);
//   }

//   // Common error snackbar method
//   void showErrorSnackbar(String message) {
//     AppToasts.showError(message);
//   }

//   // Common warning snackbar method
//   void showWarningSnackbar(String message) {
//     AppToasts.showWarning(message);
//   }

//   // Password strength calculation
//   void updatePasswordStrength(String password) {
//     if (password.isEmpty) {
//       passwordStrength.value = '';
//       passwordStrengthValue.value = 0.0;
//       passwordStrengthColor.value = Colors.grey;
//       return;
//     }

//     int strength = 0;
//     String message = '';
//     Color color = Colors.grey;

//     // Check each requirement
//     bool hasLength = password.length >= 8;
//     bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
//     bool hasLowercase = password.contains(RegExp(r'[a-z]'));
//     bool hasNumber = password.contains(RegExp(r'[0-9]'));
//     bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

//     strength = [
//       hasLength,
//       hasUppercase,
//       hasLowercase,
//       hasNumber,
//       hasSpecial,
//     ].where((condition) => condition).length;

//     if (strength <= 2) {
//       message = 'Weak';
//       color = Colors.red;
//     } else if (strength <= 3) {
//       message = 'Fair';
//       color = Colors.orange;
//     } else if (strength <= 4) {
//       message = 'Good';
//       color = const Color(0xFFF57C00); // Orange 700
//     } else {
//       message = 'Strong';
//       color = Colors.green;
//     }

//     passwordStrength.value = message;
//     passwordStrengthValue.value = strength / 5;
//     passwordStrengthColor.value = color;
//   }

//   // Toggle password visibility
//   void togglePasswordVisibility() {
//     isPasswordVisible.value = !isPasswordVisible.value;
//   }

//   // Toggle confirm password visibility
//   void toggleConfirmPasswordVisibility() {
//     isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
//   }

//   // Common validation methods
//   String? validateRequired(String? value, String fieldName) {
//     if (value == null || value.trim().isEmpty) {
//       return '$fieldName is required';
//     }
//     return null;
//   }

//   String? validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Email is required';
//     }
//     if (!GetUtils.isEmail(value)) {
//       return 'Please enter a valid email';
//     }
//     return null;
//   }

//   String? validatePhone(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Phone number is required';
//     }
//     if (value.length < 10) {
//       return 'Please enter a valid phone number';
//     }
//     return null;
//   }

//   String? validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }
//     if (value.length < 8) {
//       return 'Password must be at least 8 characters';
//     }
//     if (!value.contains(RegExp(r'[A-Z]'))) {
//       return 'Password must contain at least one uppercase letter';
//     }
//     if (!value.contains(RegExp(r'[a-z]'))) {
//       return 'Password must contain at least one lowercase letter';
//     }
//     if (!value.contains(RegExp(r'[0-9]'))) {
//       return 'Password must contain at least one number';
//     }
//     if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
//       return 'Password must contain at least one special character';
//     }
//     return null;
//   }

//   String? validateConfirmPassword(String? value, String originalPassword) {
//     if (value == null || value.isEmpty) {
//       return 'Please confirm your password';
//     }
//     if (value != originalPassword) {
//       return 'Passwords do not match';
//     }
//     return null;
//   }

//   // Common navigation methods
//   void navigateTo(String route, {dynamic arguments}) {
//     Get.toNamed(route, arguments: arguments);
//   }

//   void navigateToAndClear(String route, {dynamic arguments}) {
//     Get.offAllNamed(route, arguments: arguments);
//   }

//   void goBack() {
//     Get.back();
//   }

//   // Common loading state management
//   void startLoading() {
//     isLoading.value = true;
//   }

//   void stopLoading() {
//     isLoading.value = false;
//   }

//   // Common form validation
//   bool validateForm() {
//     return formKey.currentState?.validate() ?? false;
//   }
// }
