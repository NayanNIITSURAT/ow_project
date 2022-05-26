import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owlet/Components/AuthBackground.dart';
import 'package:owlet/Components/AuthButton.dart';
import 'package:owlet/Components/AuthFooter.dart';
import 'package:owlet/Components/Input.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Screens/NavScreen.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/helpers/validators.dart';
import 'package:owlet/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = new GlobalKey<FormState>();
  bool hidepassword=false;
  // String phone = '08107539186',
  //     email = 'ebukanwosu45@gmail.com',
  //     username = 'coolprince',
  //     password = 'cool1106',
  //     confirmPassword = 'cool1106';

  String phone = '',
      email = '',
      username = '',
      password = '',
      confirmPassword = '';
  bool ischeck = false;

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
    // auth.registeredStatus = Status.NotRegistered;

    var doRegister = () {
      final form = formKey.currentState;
      form!.save();

      if (form.validate()) {
        if (ischeck == true) {
          auth
              .register(NewUser(
            username: username,
            email: email,
            phone: phone,
            fullName: username,
            password: password,
          ))
              .then(
            (response) {
              if (response['status']) {
                Toast(context, message: response['message']).show();

                Navigator.pushReplacementNamed(context, NavScreen.routeName);
              } else
                Toast(
                  context,
                  title: "Registration Failed",
                  message: response['message'],
                ).show();
            },
          );
        } else {
          Toast(
            context,
            title: "Registration Failed",
            message: "Please check Terms and Conditions",
          ).show();
        }
      }
    };

    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: SizedBox(
                  width: screenSize(context).width * 0.8,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: screenSize(context).width * 0.35,
                            child: Center(child: Image.asset(logo))),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Create your account',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                  fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "it's free and easy",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontSize: 18, color: Colors.black54),
                        ),
                        SizedBox(height: 10),
                        Input(
                          icon: Icons.person,
                          label: 'Full name',
                          elevate: false,
                          bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                          type: TextInputType.name,
                          validate: validateUsername,
                          onSaved: (value) => username = value!.trim(),
                          autofill: const <String>[AutofillHints.newUsername],
                          // initialValue: 'coolprince',
                        ),
                        Input(
                          icon: Icons.email,
                          elevate: false,
                          label: 'E-mail',
                          bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                          type: TextInputType.emailAddress,
                          validate: validateEmail,
                          onSaved: (value) {
                            email = value!.trim();
                          },
                          autofill: const <String>[AutofillHints.email],
                          // initialValue: 'ebukanwosu45@gmail.com',
                        ),
                        Input(
                          elevate: false,
                          type: TextInputType.phone,
                          label: 'Phone Number',
                          maxlengh: 10,
                          bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                          // type: TextInputType.emailAddress,
                          validate: validateMobile,
                          onSaved: (value) {
                            phone = value!.trim();
                          },
                          autofill: const <String>[AutofillHints.email],
                          // initialValue: 'ebukanwosu45@gmail.com',
                        ),
                        Input(
                          icon: Icons.security,
                          label: 'Password',
                          isrightimage: false,
                          isPassword: hidepassword,
                          rightIcon:  hidepassword==false?Icons.remove_red_eye:Icons.visibility_off,
                          righticonTap: (){
                            setState(() {
                              hidepassword==true?hidepassword=false:hidepassword=true;
                            });

                          },


                          elevate: false,
                          validate: (value) => Password(
                            value: value,
                          ),
                          bgColor: Color(0xffEDF2F7).withOpacity(0.5),

                          onSaved: (value) => password = value ?? '',
                          autofill: const <String>[
                            AutofillHints.password
                          ],
                          // initialValue: 'cool1106',
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                                value: ischeck,
                                activeColor: Colors.green,
                                onChanged: (newValue) {
                                  setState(() {
                                    ischeck = newValue!;
                                  });
                                  print(ischeck);
                                }),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: SizedBox(
                                width: screenSize(context).width * 0.6,
                                child: RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                      text:
                                          "By creating an account means you agree to the ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(color: Colors.black54)),
                                  TextSpan(
                                      recognizer: new TapGestureRecognizer()
                                        ..onTap = () => _launchURL(),
                                      text: "Terms and Conditions",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w800,
                                          )),
                                  TextSpan(
                                      text: ", and our ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(color: Colors.black54)),
                                  TextSpan(
                                      text: "Privacy Policy",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                              fontWeight: FontWeight.w800))
                                ])),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        auth.registeredStatus == Status.Registering
                            ? Loading(
                                message: 'Creating account',
                              )
                            : AuthButton(
                                text: 'Register',
                                press: doRegister,
                              ),
                        AuthFooter(isRegister: true),
                      ],
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

  _launchURL() async {
    const url = 'https://theowlette.com/terms-and-conditions.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
