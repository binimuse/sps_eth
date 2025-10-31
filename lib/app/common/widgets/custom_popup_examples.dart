import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'custom_popup_dialog.dart';

// Example usage of CustomPopupDialog
class CustomPopupExamples {
  // Example 1: Success popup with celebration
  static void showSuccessPopup() {
    CustomPopupHelper.show(
      context: Get.context!,
      title: 'Success!',
      message: 'Your action was completed successfully.',
      primaryButtonText: 'Continue',
      icon: Icons.check_circle,
      iconColor: Colors.green,
      showCelebration: true,
      onPrimaryButtonPressed: () {
        Get.back(); // Close dialog
      },
    );
  }

  // Example 2: Error popup
  static void showErrorPopup() {
    CustomPopupHelper.show(
      context: Get.context!,
      title: 'Error',
      message: 'Something went wrong. Please try again.',
      primaryButtonText: 'Try Again',
      secondaryButtonText: 'Cancel',
      icon: Icons.error,
      iconColor: Colors.red,
      primaryButtonColor: Colors.red,
      onPrimaryButtonPressed: () {
        Get.back(); // Close dialog
        // Retry logic here
      },
      onSecondaryButtonPressed: () {
        Get.back(); // Close dialog
      },
    );
  }

  // Example 3: Confirmation popup
  static void showConfirmationPopup() {
    CustomPopupHelper.show(
      context: Get.context!,
      title: 'Confirm Action',
      message: 'Are you sure you want to proceed with this action?',
      primaryButtonText: 'Yes, Proceed',
      secondaryButtonText: 'Cancel',
      icon: Icons.warning,
      iconColor: Colors.orange,
      onPrimaryButtonPressed: () {
        Get.back(); // Close dialog
        // Proceed with action
      },
      onSecondaryButtonPressed: () {
        Get.back(); // Close dialog
      },
    );
  }

  // Example 4: Information popup
  static void showInfoPopup() {
    CustomPopupHelper.show(
      context: Get.context!,
      title: 'Information',
      message: 'This is an informational message for the user.',
      primaryButtonText: 'Got it',
      icon: Icons.info,
      iconColor: Colors.blue,
      onPrimaryButtonPressed: () {
        Get.back(); // Close dialog
      },
    );
  }

  // Example 5: Custom styled popup
  static void showCustomStyledPopup() {
    CustomPopupHelper.show(
      context: Get.context!,
      title: 'Custom Styled',
      message: 'This popup has custom colors and styling.',
      primaryButtonText: 'Primary Action',
      secondaryButtonText: 'Secondary Action',
      icon: Icons.star,
      iconColor: Colors.purple,
      primaryButtonColor: Colors.purple,
      secondaryButtonColor: Colors.purple.withOpacity(0.1),
      onPrimaryButtonPressed: () {
        Get.back(); // Close dialog
      },
      onSecondaryButtonPressed: () {
        Get.back(); // Close dialog
      },
    );
  }
}

/*
USAGE EXAMPLES:

1. Success popup with celebration:
   CustomPopupExamples.showSuccessPopup();

2. Error popup:
   CustomPopupExamples.showErrorPopup();

3. Confirmation popup:
   CustomPopupExamples.showConfirmationPopup();

4. Information popup:
   CustomPopupExamples.showInfoPopup();

5. Custom styled popup:
   CustomPopupExamples.showCustomStyledPopup();

6. Direct usage with CustomPopupHelper:
   CustomPopupHelper.show(
     context: Get.context!,
     title: 'Your Title',
     message: 'Your message here',
     primaryButtonText: 'OK',
     icon: Icons.check,
     onPrimaryButtonPressed: () {
       Get.back();
     },
   );
*/
