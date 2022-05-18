import 'package:flutter_email_sender/flutter_email_sender.dart';

final RegExp emailRegExp = new RegExp(
    r'^([A-Z|a-z|0-9](\.|_){0,1})+[A-Z|a-z|0-9]\@([A-Z|a-z|0-9])+((\.){0,1}[A-Z|a-z|0-9]){2}\.[a-z]{2,3}$');

final RegExp usernameRegExp =
    new RegExp(r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,29}$');

final RegExp mobilenumberRegExp = new RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');

String? validateEmail(String? value) {
  String? _msg;
  if (value!.trim().isEmpty) {
    _msg = "Email is required";
  } else if (!emailRegExp.hasMatch(value.trim())) {
    _msg = "Please provide a valid email address";
  }
  return _msg;
}

String? validateUsername(String? value) {
  String? _msg;
  if (value!.length > 30) {
    _msg = "Username must be with 3 - 30 characters";
  } else if (value.trim().isEmpty) {
    _msg = "Username is required";
  } else if (!usernameRegExp.hasMatch(value.trim())) {
    _msg =
        "Username can only contain: letters A-Z, numbers 0-9 and the symbols _";
  }
  return _msg;
}

String? validateEmailOrUsername(String? value) {
  String? _msg;
  if (value!.trim().isEmpty) {
    _msg = "Email is required";
  } else if (!usernameRegExp.hasMatch(value.trim()) &&
      !emailRegExp.hasMatch(value.trim())) {
    _msg = "Invalid email! or phone number";
  }
  return _msg;
}

String? validateMobile(String? value) {
  if (value!.length != 10) return 'Mobile Number must be of 10 digit';
  return null;
}

// String? validateEmailOrMobile(String? value) {
//   String? _msg;
//   if (value!.trim().isEmpty) {
//     _msg = "Email or phone number is required";
//   } else if (!mobilenumberRegExp.hasMatch(value.trim()) ||
//       !emailRegExp.hasMatch(value.trim())) {
//     _msg = "Invalid email! or Phone number";
//   }
//   return _msg;
// }

String? validateBasic(
    {String? value, required String fieldName, int? minLength}) {
  if (value!.trim().trim().isEmpty) {
    return 'Password is required';
  }
  if (minLength != null && value.trim().trim().length < minLength) {
    return '$fieldName must be at least $minLength characters in length';
  }
  // Return null if the entered username is valid
  return null;
}

String? validateConfirmPassword({String? value, required String password}) =>
    value!.trim().isEmpty
        ? 'This field is required'
        : value.trim() != password
            ? 'Password does not match'
            : null;

String? Password({String? value}) {
  {
    if (value == null) {
      return "Please enter your  password";
    }

    if (value.isEmpty) {
      return "Please enter your password";
    }
    if (value.length >= 15) {
      return "Password should not be greater than 15 characters";
    }
    if (value.length < 8) {
      return "Password should be at least 8 characters";
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Password should be Contains Special characters";
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Password should be Contains Special characters";
    }
    if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) {
      return "Password should be Contains Uppercase characters";
    }
    if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(value)) {
      return "Please enter a valid password";
    }
    return null;
  }
}
