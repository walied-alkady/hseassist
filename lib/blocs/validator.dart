import 'package:easy_localization/easy_localization.dart';

mixin Validator {
  // Email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "errorMessages.emailRequired".tr();
    } else if (!RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value)) {
      return "errorMessages.emailInvalid".tr();
    }
    return null;
  }

  // Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "errorMessages.passwordRequired".tr();
    } else if (value.length < 6) {
      return "errorMessages.passwordInvalid".tr();
    }
    return null;
  }

  // Confirm password validation
  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return "errorMessages.confirmPasswordRequired".tr();
    } else if (value != password) {
      return "errorMessages.passwordMismatch".tr();
    }
    return null;
  }

  // Name validation
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "errorMessages.Required".tr();
    }
    return null;
  }

  // Address validation
  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return "errorMessages.Required".tr();
    }
    return null;
  }

  String? validateDetailsIsNotEmpty(String? value) {
    if (value == null) {
      return "errorMessages.Required".tr();
    }
    return null;
  }

  String? validateDropdownSelection(dynamic value) {
    if (value == null) {
        return "errorMessages.Required".tr();
    }
    return null; // Return null if the selection is valid
}
}