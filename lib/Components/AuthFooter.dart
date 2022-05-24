import 'package:flutter/material.dart';
import 'package:owlet/Screens/ForgotPassword.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Screens/Register.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/helpers/helpers.dart';

class AuthFooter extends StatelessWidget {
  final bool isRegister;
  final bool isResetPassword;
  final bool isLogin;
  final bool isforget;

  const AuthFooter({
    this.isRegister = false,
    this.isResetPassword = false,
    this.isLogin = false,
    this.isforget = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenSize(context).width * 0.8,
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isLogin)
            Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    ),
                    onTap: () => Navigator.of(context)
                        .pushNamed(ForgotPasswordScreen.routeName),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          if (isLogin || isRegister)
            Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: screenSize(context).width * 0.15,
                      child: Divider(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      "or do it via other accounts",
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    SizedBox(
                      width: screenSize(context).width * 0.15,
                      child: Divider(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 80,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            spreadRadius: 0,
                            blurRadius: 1,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Image.asset(google_logo),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            spreadRadius: 0,
                            blurRadius: 1,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Image.asset(apple_logo),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            spreadRadius: 0,
                            blurRadius: 1,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          facebook_logo,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          if (isLogin || isRegister)
            SizedBox(
              height: 40,
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  '${isRegister ? "Already have an account?" : isforget == true ? "Have an account?" : "Don\'t have an account?"} '),
              GestureDetector(
                child: Text(
                  isResetPassword
                      ? 'Back to login'
                      : isRegister
                          ? 'Login'
                          : isforget == true
                              ? "Login"
                              : 'Register',
                  style: TextStyle(
                    color: Palette.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => isResetPassword
                    ? Navigator.of(context).pop()
                    : Navigator.of(context).pushReplacementNamed(
                        isRegister
                            ? LoginScreen.routeName
                            : isforget == true
                                ? LoginScreen.routeName
                                : RegisterScreen.routeName,
                      ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
