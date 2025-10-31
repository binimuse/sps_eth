import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/common/app_toasts.dart';


class ValidatorUtil {
  static bool isPhoneValidEthiopian(String text) {
    bool isPhoneValidEthiopian = true;

    if (text.length == 13) {
      if (!text.startsWith("+251")) {
        isPhoneValidEthiopian = false;
      }
    }

    if (text.length == 12) {
      if (!text.startsWith("251")) {
        isPhoneValidEthiopian = false;
      }
    }

    if (text.length == 10) {
      if (!text.startsWith("0")) {
        isPhoneValidEthiopian = false;
      }
    }

    if (text.length == 9) {
      if (!text.startsWith("9")) {
        isPhoneValidEthiopian = false;
      }
    }

    if (text.length < 9 || text.length == 11 || text.length > 13) {
      isPhoneValidEthiopian = false;
    }
    return isPhoneValidEthiopian;
  }

  static bool validatPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone);
  }

  static String formatPhoneNumber(String text, bool includeCountryCode) {
    ///VALIDATE PHONE NUMBER FIRST
    if (!checkPhoneNumber(text)) {
      throw 'PhoneNumberValidationError';
    }

    String formattedPhoneNumber = "";

    if (text.length == 10) {
      if (includeCountryCode) {
        formattedPhoneNumber = '+61${text.substring(1)}';
      } else {
        formattedPhoneNumber = text.substring(1);
      }
    }

    if (text.length == 9) {
      if (includeCountryCode) {
        formattedPhoneNumber = '+61$text';
      } else {
        formattedPhoneNumber = text;
      }
    }

    return formattedPhoneNumber;
  }

  static bool checkPhoneNumber(String? text) {
    if (text == null) return false;
    bool isPhoneValid = false;

    if (text.length == 10) {
      if (text.startsWith("0")) {
        isPhoneValid = true;
      }
    }

    if (text.length == 9) {
      if (text.startsWith("0")) {
        isPhoneValid = false;
      } else {
        isPhoneValid = true;
      }
    }

    return isPhoneValid;
  }

  static handleError(dynamic e) {
    if (e is DioException) {
      final response = e.response;

      // Check if the response data is not null and is a Map
      if (response != null && response.data is Map) {
        final data = response.data;

        final message = data['message'];

        // Now you can use the message, error, and statusCode as needed
        AppToasts.showError('$message');
      } else {
        // If the response data is null or is not a Map,
        // show the original error message
      }
    } 
  }
}

class AmharicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Check if the new value contains any non-Amharic characters
    if (newValue.text.contains(RegExp(r'[^ሀ-፿]'))) {
      // Non-Amharic characters found, return the old value to preserve it
      return oldValue;
    }

    // No non-Amharic characters found, accept the new value
    return newValue;
  }
}

class NoNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Check if the new value contains any numeric characters, spaces, or special characters
    if (newValue.text.contains(RegExp(r'[0-9\s\W]'))) {
      // Numeric characters, spaces, or special characters found, return the old value to preserve it
      return oldValue;
    }

    // No numeric characters, spaces, or special characters found, accept the new value
    String newText = newValue.text;
    if (newText.isNotEmpty) {
      newText = newText[0].toUpperCase() + newText.substring(1);
    }
    return TextEditingValue(text: newText, selection: newValue.selection);
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    // Check if the new text is empty
    if (newText.isEmpty) {
      return newValue;
    }

    // Check if the new text matches the 'MM/DD/YYYY' format
    final regExp = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regExp.hasMatch(newText)) {
      // If the new text doesn't match the format, return the old value
      return oldValue;
    }

    // If the new text matches the format, accept the new value
    return newValue;
  }
}

class HeightInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Check if the new value is empty
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Check if the new value is a valid number
    final double? height = double.tryParse(newValue.text);
    if (height == null) {
      // If the new value is not a valid number, return the old value
      return oldValue;
    }

    // Check if the height is within the valid range (e.g., 50 cm to 250 cm)
    if (height < 50 || height > 250) {
      // If the height is out of range, return the old value
      return oldValue;
    }

    // If the new value is a valid number within the range, accept the new value
    return newValue;
  }
}
