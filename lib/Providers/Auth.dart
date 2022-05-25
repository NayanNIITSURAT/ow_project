import 'dart:async';

import 'package:flutter/material.dart';
import 'package:owlet/Preferences/UserPreferences.dart';
import 'package:owlet/helpers/firebase.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/auth.dart';

enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut,
  Requesting,
  RequestSent,
  RequestNotSent,
  Processing,
  Completed,
  Failed,
  Idle,
  Adding,
  Updating,
  Deleting,
  Searching,
  ChangingAvatar,
  Blocking,
  Resetting,
  Solved,
}

class AuthProvider with ChangeNotifier {
  User? _authProfile;
  Status _loggedInStatus = Status.Idle;
  Status _verifyOtpStatus = Status.Idle;
  Status _registeredStatus = Status.NotRegistered;
  Status _resetStatus = Status.RequestNotSent;
  Status _problemStatus = Status.RequestNotSent;
  Status _moneyStatus = Status.RequestNotSent;
  String? _resetToken;
  String? _resetId;

  bool get isLoggedIn {
    return _authProfile != null;
  }

  User? get authProfile => _authProfile;

  set authProfile(User? user) {
    UserPreferences().saveUser(user!);
    _authProfile = user;
    notifyListeners();
  }

  void logout() {
    UserPreferences().removeUser();
    resetFCMInstance();
    _authProfile = null;
    notifyListeners();
  }

  String? get resetToken => _resetToken;
  String? get resetId => _resetId;
  Status get loggedInStatus => _loggedInStatus;
  Status get registeredStatus => _registeredStatus;
  Status get resetStatus => _resetStatus;
  Status get reportStatus => _problemStatus;
  Status get moneyStatus => _moneyStatus;
  set registeredStatus(Status status) {
    _registeredStatus = status;
    notifyListeners();
  }

  Status get verifyOtpStatus => _verifyOtpStatus;

  Future<Map<String, dynamic>> validate() async {
    _loggedInStatus = Status.Authenticating;
    notifyListeners();
    try {
      authProfile = await authenticateUser(null);
      var result = {
        'status': true,
        'message': 'Login Successful',
        'data': authProfile
      };

      _loggedInStatus = Status.LoggedIn;
      notifyListeners();

      return result;
    } catch (error) {
      print("the error is $error .detail");

      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }

  Future<Map<String, dynamic>> login(LoginUser user) async {
    _loggedInStatus = Status.Authenticating;
    notifyListeners();
    try {
      if(user.username.isEmpty && user.password.isEmpty){
        authProfile = await authenticateUser(null);
      }else{
        authProfile = await authenticateUser(user);
      }

      var result = {
        'status': true,
        'message': 'Login Successful',
        'data': authProfile
      };

      _loggedInStatus = Status.LoggedIn;
      notifyListeners();

      return result;
    } catch (error) {
      print("the error is $error .detail");

      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }

  Future<Map<String, dynamic>> changePasswordData(ChangePassword change) async {
    _resetStatus = Status.Requesting;
    notifyListeners();
    try {
      var res = await changepassword(change);
      var result = {
        'status': true,
        'message': res['message'],
      };

      _resetToken = res['token'];
      _resetStatus = Status.RequestSent;
      notifyListeners();

      return result;
    } catch (error) {
      print("the error is $error .detail");

      _resetStatus = Status.RequestNotSent;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }


  Future<Map<String, dynamic>> forgotPassword(String email) async {
    _resetStatus = Status.Requesting;
    _resetId = email;
    notifyListeners();
    try {
      var res = await forgotPass(email);
      var result = {
        'status': true,
        'message': res['message'],
      };

      _resetToken = res['token'];
      _resetStatus = Status.RequestSent;
      notifyListeners();

      return result;
    } catch (error) {
      print("the error is $error .detail");

      _resetStatus = Status.RequestNotSent;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }

  Future<Map<String, dynamic>> resendForgotPassword() async {
    _resetStatus = Status.Requesting;
    notifyListeners();
    try {
      var res = await forgotPass(resetId!);
      var result = {
        'status': true,
        'message': res['message'],
      };

      _resetToken = res['token'];
      _resetStatus = Status.RequestSent;
      notifyListeners();

      return result;
    } catch (error) {
      print("the error is $error .detail");

      _resetStatus = Status.RequestNotSent;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }

  Future<Map<String, dynamic>> verifyOTP(String otp) async {
    _verifyOtpStatus = Status.Processing;
    notifyListeners();
    try {
      var res = await verifyOtp(otp, resetToken!);
      var result = {
        'status': true,
        'message': res['message'],
      };

      _resetToken = res['token'];
      _verifyOtpStatus = Status.Completed;
      notifyListeners();

      return result;
    } catch (error) {
      print("the error is $error .detail");

      _verifyOtpStatus = Status.RequestNotSent;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }

  Future<dynamic> resetPassword(String password) async {
    _resetStatus = Status.Resetting;
    notifyListeners();
    try {
      var res = await passwordReset(password, resetToken!);
      var result = {
        'status': true,
        'message': res['message'],
      };

      _resetStatus = Status.Completed;
      notifyListeners();

      return result;
    } catch (error) {
      print("the error is $error .detail");

      _resetStatus = Status.RequestNotSent;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }

  Future<dynamic> register(NewUser user) async {
    _registeredStatus = Status.Registering;
    notifyListeners();
    try {
      authProfile = await createUser(user);
      var result = {
        'status': true,
        'message': 'Successfully registered',
        'data': authProfile
      };

      _registeredStatus = Status.Registered;
      notifyListeners();

      return result;
    } catch (error) {
      _registeredStatus = Status.NotRegistered;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }

  Future<dynamic> ReportProblem(Problem user) async {
    _problemStatus = Status.Processing;
    notifyListeners();
    try {
      authProfile = await reportproblem(user);
      var result = {
        'status': true,
        'message': 'Data Successful',
        'data': authProfile
      };

      _problemStatus = Status.Solved;
      notifyListeners();

      return result;
    } catch (error) {
      // print("the error is $error .detail");

      _problemStatus = Status.Failed;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }

  Future<dynamic> Transation(
      TextEditingController walletcontroller, Update user) async {
    _moneyStatus = Status.Processing;
    notifyListeners();
    try {
      authProfile = await tansationData(walletcontroller, user);
      var result = {
        'status': true,
        'message': 'Data Successful',
        'data': authProfile
      };

      _moneyStatus = Status.Solved;
      notifyListeners();

      return result;
    } catch (error) {
      // print("the error is $error .detail");

      _moneyStatus = Status.Failed;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }
}
