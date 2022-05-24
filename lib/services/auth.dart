import 'dart:convert';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:owlet/constants/constants.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/apiUrl.dart';
import 'package:owlet/services/utils.dart';
import 'dart:convert' as convert;

import '../Components/Toast.dart';

class NewUser {
  String username;
  String email;
  String phone;
  String fullName;
  String password;

  NewUser({
    required this.username,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.password,
  });
}

class ChangePassword {
  String userId;
  String oldPassword;
  String newPassword;


  ChangePassword({
    required this. userId,
    required this.oldPassword,
    required this.newPassword,

  });
}

class LoginUser {
  String username;
  String password;

  LoginUser({
    required this.username,
    required this.password,
  });
}

class Problem {
  String email;
  String subject;
  String fullName;
  String description;

  Problem({
    required this.email,
    required this.subject,
    required this.fullName,
    required this.description,
  });
}

class Update {
  int senderUserId;
  int receiverUserId;
  int walletAmount;
  // int id;
  String email;
  String username;
  String phone;
  String fullName;
  String avartar;
  String fname;
  String bio;
  String password;
  String lname;
  String website;
  String status;
  String message;
  String confirmation_token;
  String lastQueryAt;
  String createdAt;
  String updatedAt;
  String deletedAt;
  String countryIso;
  String lastWalletUpdate;
  String transferMessage;
  int walletTransferAmount;

  Update({
    required this.senderUserId,
    required this.receiverUserId,
    required this.walletAmount,
    required this.status,
    required this.email,
    required this.username,
    required this.phone,
    required this.fullName,
    required this.avartar,
    required this.fname,
    required this.bio,
    required this.password,
    required this.lname,
    required this.website,
    required this.message,
    required this.confirmation_token,
    required this.lastQueryAt,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.countryIso,
    required this.lastWalletUpdate,
    required this.transferMessage,
    required this.walletTransferAmount,
  });
}

final headers = Global.jsonHeaders;

final FirebaseMessaging _messaging = FirebaseMessaging.instance;

Future<User> createUser(NewUser newUser) async {
  final response = await post(
    Uri.parse(AppUrlV3.registerUrl),
    headers: headers,
    body: jsonEncode(<String, String>{
      "username": newUser.username,
      "fullName": newUser.fullName,
      "email": newUser.email,
      "password": newUser.password,
      "phone": newUser.phone,
      "deviceToken": (await _messaging.getToken()) ?? '',
      "deviceType": Platform.isAndroid ? 'ANDROID' : 'IOS'
    }),
  );

  if (response.statusCode == 201) {
    final res = jsonDecode(response.body);
    return User.fromJson(res);
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<User> authenticateUser(LoginUser? user) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await post(
    Uri.parse(AppUrlV3.loginUrl),
    headers: headers,
    body: user != null
        ? jsonEncode(<String, String>{
            "usernameOrEmail": user.username,
            "password": user.password,
            "deviceToken": (await _messaging.getToken()) ?? '',
            "deviceType": Platform.isAndroid ? 'ANDROID' : 'IOS'
          })
        : jsonEncode(<String, String>{
            "deviceToken": (await _messaging.getToken()) ?? '',

            "deviceType": Platform.isAndroid ? 'ANDROID' : 'IOS'
          }),
  );

  if (response.statusCode == 201)
    return User.fromJson(jsonDecode(response.body));
  else {
    await _messaging.deleteToken();
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

// Future<User> validateUser() async {
//   final response =
//       await post(Uri.parse(AppUrl.loginUrl), headers: <String, String>{
//     'Content-Type': 'application/json; charset=UTF-8',
//     HttpHeaders.authorizationHeader: 'Bearer ${await getToken}',
//   });

//   if (response.statusCode == 201)
//     return User.fromJson(jsonDecode(response.body));
//   else {
//     var data = jsonDecode(response.body);
//     print(data['message']);
//     throw HttpException(data['message']);
//   }
// }

Future<Map<String, dynamic>> forgotPass(String usernameOrEmail) async {
  final response = await post(
    Uri.parse(AppUrl.forgotPassword),
    headers: headers,
    body: jsonEncode(<String, String>{
      "usernameOrEmail": usernameOrEmail,
    }),
  );

  if (response.statusCode == 200)
    return jsonDecode(response.body);
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<Map<String, dynamic>> changepassword(
    ChangePassword change) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await post(
    Uri.parse("https://api.the-owlette.com/v4/users/changePassword"),

    headers: headers,
    body: jsonEncode(<String, String>{
      "userId": change.userId,
      "oldPassword": change.oldPassword,
      "newPassword": change.newPassword,
    }),
  );

  if (response.statusCode == 200)
    return jsonDecode(response.body);
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<Map<String, dynamic>> verifyOtp(String otp, String resetToken) async {
  final response = await post(
    Uri.parse(AppUrl.verifyOtp),
    headers: headers,
    body: jsonEncode(<String, String>{
      "otp": otp,
      "resetToken": resetToken,
    }),
  );

  if (response.statusCode == 200)
    return jsonDecode(response.body);
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<Map<String, dynamic>> passwordReset(
    String password, String token) async {
  final response = await post(
    Uri.parse(AppUrl.resetPass),
    headers: headers,
    body: jsonEncode(<String, String>{
      "password": password,
      "token": token,
    }),
  );

  if (response.statusCode == 200)
    return jsonDecode(response.body);
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<User> reportproblem(Problem? user) async {
  //headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await post(
    Uri.parse("https://api.the-owlette.com/v4/users/reportProblem"),
    headers: {"Content-type": "application/json"},
    body: user != null
        ? jsonEncode(<String, String>{
            "Email": user.email,
            "fullName": user.fullName,
            "subject": user.subject,
            "description": user.description,
          })
        : jsonEncode(<String, String>{
            "deviceToken": (await _messaging.getToken()) ?? '',
            "deviceType": Platform.isAndroid ? 'ANDROID' : 'IOS'
          }),
  );

  if (response.statusCode == 201)
    return User.fromJson(jsonDecode(response.body));
  else {
    await _messaging.deleteToken();
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<User> tansationData(
    TextEditingController controller, Update? user) async {
  // headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await post(
    Uri.parse("https://api.the-owlette.com/v4/wallet/addTransaction"),
    headers: {"Content-type": "application/json"},
    // encoding: convert.Encoding.getByName("utf-8"),
    body: user != null
        ? jsonEncode(<String, int>{
            "senderUserId": 37431,
            "receiverUserId": 1,
            "walletAmount": int.parse(controller.text),
            // "status": int.parse(user.status),
            // "message": int.parse(user.message),
            // "senderUserId": 12,
            // "receiverUserId": 1,
            // "walletAmount": 5,
            // "status": int.parse("abc"),
            // "message": int.parse("test"),
          })
        : jsonEncode(<String, String>{
            "deviceToken": (await _messaging.getToken()) ?? '',
            "deviceType": Platform.isAndroid ? 'ANDROID' : 'IOS'
          }),
  );

  if (response.statusCode == 201)
    return User.fromJson(jsonDecode(response.body));
  else {
    await _messaging.deleteToken();
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

// Future<Map<String, dynamic>> tansationData(
//     String senderUserId,
//     String receiverUserId,
//     String walletAmount,
//     String status,
//     String message) async {
//   // var dataInput = {
//   //   "senderUserId": senderUserId,
//   //   "receiverUserId": receiverUserId,
//   //   "walletAmount": walletAmount,
//   //   "status": status,
//   //   "message": message
//   // };
//   final response = await post(
//     Uri.parse("http://api.the-owlette.com/v4/wallet/addTransaction"),
//     headers: {"Content-type": "application/row"},
//     encoding: convert.Encoding.getByName("utf-8"),
//     body: jsonEncode(<String, String>{
//       "senderUserId": senderUserId,
//       "receiverUserId": receiverUserId,
//       "walletAmount": walletAmount,
//       "status": status,
//       "message": message
//     }),
//   );
//   if (response.statusCode == 200)
//     return jsonDecode(response.body);
//   else {
//     var data = jsonDecode(response.body);
//     throw HttpException(data['message']);
//   }
// }
