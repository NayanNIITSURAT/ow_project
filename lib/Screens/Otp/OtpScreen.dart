import 'package:flutter/material.dart';
import 'package:owlet/Components/AuthBackground.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Screens/Otp/components/otp_form.dart';
import 'package:owlet/Screens/ResetPasswordScreen.dart';
import 'package:owlet/Widgets/CountDown.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatelessWidget {
  static String routeName = "/otp";
  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<AuthProvider>(context);

    final onSubmit = (String otp) {
      String message = '';
      authData.verifyOTP(otp).then(
        (res) {
          message = res['message'];
          if (res['status'])
            Navigator.pushReplacementNamed(
                context, ResetPasswordScreen.routeName);
          Toast(context, message: message).show();
        },
      );
    };

    return Scaffold(
        appBar: AppBar(
          title: Text("OTP Verification"),
        ),
        body: AuthBackground(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenSize(context).height * 0.05),
                  Text("We sent your code to your email address"),
                  ResendOTP(authData: authData),
                  SizedBox(height: screenSize(context).height * 0.15),
                  OtpForm(
                    onSubmit: onSubmit,
                    loading: authData.verifyOtpStatus == Status.Requesting,
                    otpLength: 6,
                  ),
                  SizedBox(height: screenSize(context).height * 0.1),
                ],
              ),
            ),
          ),
        )

        // SizedBox(
        //   width: double.infinity,
        //   child: Padding(
        //     padding:
        //         EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
        //     child: SingleChildScrollView(
        //       child:
        //     ),
        //   ),
        // ),
        );
  }
}

class ResendOTP extends StatefulWidget {
  const ResendOTP({
    Key? key,
    required this.authData,
  }) : super(key: key);

  final AuthProvider authData;

  @override
  State<ResendOTP> createState() => _ResendOTPState();
}

class _ResendOTPState extends State<ResendOTP> {
  int counter = 0;
  int prevCounterVal = 0;
  @override
  void initState() {
    counter = 30;
    prevCounterVal = 30;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: counter < 1
          ? [
              GestureDetector(
                  child: Text(
                    "Resend OTP Code",
                    style: TextStyle(
                      color: Palette.primaryColor,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () {
                    counter = prevCounterVal > 89
                        ? prevCounterVal
                        : prevCounterVal += 15;

                    widget.authData.resendForgotPassword();
                  })
            ]
          : [
              Text("Resend OTP in..."),
              CountDown(
                from: counter.toDouble(),
                onFinish: () => setState(() => counter = 0),
                builder: (_, dynamic value, child) => Text(
                  "00:${value.toInt()}",
                  style: TextStyle(color: Palette.primaryColor),
                ),
              ),
            ],
    );
  }
}
