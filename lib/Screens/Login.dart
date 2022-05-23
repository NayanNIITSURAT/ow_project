import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Components/AuthBackground.dart';
import 'package:owlet/Components/AuthButton.dart';
import 'package:owlet/Components/AuthFooter.dart';
import 'package:owlet/Components/Input.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/Screens/NavScreen.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/helpers/validators.dart';
import 'package:owlet/services/auth.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = new GlobalKey<FormState>();
  TextEditingController Emailcontroller = TextEditingController();
  TextEditingController Passwordcontroller = TextEditingController();
  // late String username = 'coolprince', password = 'cool1106';
  String username = '', password = '';
  bool settingUp = false;

  @override
  void initState() {
    if (kDebugMode) {
      // Emailcontroller.text = 'avaiyakirtib1@gmail.com';
      // Passwordcontroller.text = 'apple@123';
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context);

    var doLogin = () {
      final form = formKey.currentState;
      if (form!.validate()) {
        form.save();
        auth
            .login(LoginUser(
          username: username,
          password: password,
        ))
            .then(
          (response) async {
            if (response['status']) {
              setState(() {
                settingUp = true;
              });
              Toast(context, message: response['message']).show();
              await GlobalProvider(context).loadData();
              Navigator.pushNamedAndRemoveUntil(context, NavScreen.routeName, (route) => false);
            } else
              Toast(
                context,
                title: "Login Failed",
                message: response['message'],
              ).show();
          },
        );
      }
    };

    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: settingUp
              ? Loading(
                  message: 'Setting up your account',
                  showWait: false,
                )
              : ScrollConfiguration(
                  behavior: ScrollBehavior().copyWith(overscroll: false),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: AutofillGroup(
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: screenSize(context).width * 0.35,
                                    child: Center(child: Image.asset(logo))),
                                SizedBox(
                                  height: 20,
                                ),

                                Image.asset(
                                  waving_hand,
                                  height: 50,
                                ),
                                // Text(
                                //   "👋",
                                //   style: Theme.of(context)
                                //       .textTheme
                                //       .headlineSmall!
                                //       .copyWith(
                                //           fontSize: 50,
                                //           fontWeight: FontWeight.w600),
                                // ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'Welcome back!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "Let's build something great",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54),
                                ),
                                SizedBox(height: 20),
                                Input(
                                  icon: Icons.person,
                                  label: 'E-mail or phone number',
                                  type: TextInputType.text,
                                  bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                                  elevate: false,
                                  validate: validateEmailOrUsername,
                                  textEditingController: Emailcontroller,
                                  onSaved: (value) => username = value ?? '',
                                  autofill: const <String>[
                                    AutofillHints.username
                                  ],
                                  // initialValue: 'coolprince',
                                ),
                                Input(
                                  icon: Icons.security,
                                  label: 'Password',
                                  textEditingController: Passwordcontroller,
                                  elevate: false,
                                  validate: (value) => Password(
                                    value: value,
                                  ),
                                  bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                                  isPassword: true,
                                  onSaved: (value) => password = value ?? '',
                                  autofill: const <String>[
                                    AutofillHints.password
                                  ],
                                  // initialValue: 'cool1106',
                                ),
                                const SizedBox(height: 25),
                                auth.loggedInStatus == Status.Authenticating
                                    ? Loading(message: 'Authenticating')
                                    : AuthButton(text: 'Login', press: doLogin),
                                AuthFooter(isLogin: true),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
