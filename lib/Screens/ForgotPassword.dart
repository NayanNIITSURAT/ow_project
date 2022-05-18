import 'package:flutter/material.dart';
import 'package:owlet/Components/AuthBackground.dart';
import 'package:owlet/Components/AuthButton.dart';
import 'package:owlet/Components/AuthFooter.dart';
import 'package:owlet/Components/Input.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Screens/Otp/OtpScreen.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:provider/provider.dart';

import '../helpers/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot-password';

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final formKey = new GlobalKey<FormState>();
  // late String username = 'coolprince';
  String username = '';

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context);

    var doReset = () {
      final form = formKey.currentState;
      if (form!.validate()) {
        form.save();
        auth.forgotPassword(username).then(
          (response) {
            if (response['status']) {
              Toast(context, message: response['message']).show();

              Navigator.pushReplacementNamed(context, OtpScreen.routeName);
            } else
              Toast(
                context,
                title: "Request Failed",
                message: response['message'],
              ).show();
          },
        );
      }
    };
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: screenSize(context).width * 0.35,
                        child: Center(child: Image.asset(logo))),
                    SizedBox(
                      height: screenSize(context).height * 0.1,
                    ),
                    Text(
                      'Forgot Password',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Please enter you email",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontSize: 18, color: Colors.black54),
                    ),
                    SizedBox(
                      height: screenSize(context).height * 0.1,
                    ),
                    Input(
                      icon: Icons.person,
                      label: 'Email',
                      type: TextInputType.emailAddress,
                      validate: validateEmail,
                      onSaved: (value) => username = value ?? '',
                      // initialValue: 'coolprince',
                    ),
                    SizedBox(height: 10),
                    auth.resetStatus == Status.Requesting
                        ? Loading(message: 'Sending request')
                        : AuthButton(text: 'SEND RESET LINK', press: doReset),
                    AuthFooter(isforget: true),
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
