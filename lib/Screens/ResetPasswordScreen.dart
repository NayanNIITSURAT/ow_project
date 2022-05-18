import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owlet/Components/AuthBackground.dart';
import 'package:owlet/Components/AuthButton.dart';
import 'package:owlet/Components/AuthFooter.dart';
import 'package:owlet/Components/Input.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/helpers/validators.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const routeName = '/reset-password';

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final formKey = new GlobalKey<FormState>();

  // String phone = '08107539186',
  //     email = 'ebukanwosu45@gmail.com',
  //     username = 'coolprince',
  //     password = 'cool1106',
  //     confirmPassword = 'cool1106';

  String password = '', confirmPassword = '';

  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => initPlugin());
  }

  Future<void> initPlugin() async {
    try {
      if (await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } on PlatformException {
      Toast(context, message: 'PlatformException was thrown').show();
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    // auth.registeredInStatus = Status.NotRegistered;

    var resetPass = () {
      final form = formKey.currentState;
      form!.save();
      String message = '';
      if (form.validate()) {
        auth.resetPassword(password).then(
          (res) {
            message = res['message'];
            if (res['status']) Navigator.pop(context);
            Toast(context, message: message).show();
          },
        );
      }
    };

    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Register',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 20),
                    Input(
                      icon: Icons.security,
                      label: 'Enter new password',
                      isPassword: true,
                      onSaved: (value) => password = value!,
                      validate: (value) => validateBasic(
                        fieldName: 'Password',
                        value: value,
                        minLength: 8,
                      ),
                      // initialValue: 'cool1106',
                    ),
                    Input(
                      icon: Icons.security_outlined,
                      label: 'Confirm password',
                      isPassword: true,
                      onSaved: (value) => confirmPassword = value!,
                      validate: (value) => validateConfirmPassword(
                          value: value, password: password),
                      // initialValue: 'cool1106',
                    ),
                    SizedBox(height: 10),
                    auth.registeredStatus == Status.Registering
                        ? Loading(
                            message: 'Resetting password',
                          )
                        : AuthButton(
                            text: 'RESET PASSWORD',
                            press: resetPass,
                          ),
                    AuthFooter(isResetPassword: true),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
