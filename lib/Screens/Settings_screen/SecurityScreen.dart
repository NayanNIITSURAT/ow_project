import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Widgets/SettingsBar.dart';
import 'package:provider/provider.dart';

import '../../Components/Input.dart';
import '../../Components/Loading.dart';
import '../../Components/ProfileAvatar.dart';
import '../../Components/Toast.dart';
import '../../Components/bottomsheetbutton.dart';
import '../../Providers/Auth.dart';
import '../../Providers/GlobalProvider.dart';
import '../../Widgets/SettingsTextField.dart';
import '../../helpers/validators.dart';
import '../../services/auth.dart';
import '../../services/utils.dart';
import '../NavScreen.dart';

class Security extends StatefulWidget {
  const Security({Key? key}) : super(key: key);

  @override
  State<Security> createState() => _SecurityState();
}

class _SecurityState extends State<Security> {
  late var userId = 1;
  late var token = '';
  @override
  void initState() {
    getidbb();
    super.initState();
  }

  final formKey = new GlobalKey<FormState>();

  String oldPassword = '', newPassword = '', confirmpassword = '';

  bool settingUp = false;



  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context);

    var changepwd = () {
      final form = formKey.currentState;
      if (form!.validate()) {
        form.save();
        auth
            .changePasswordData(ChangePassword(
          userId: userId.toString(),
          oldPassword: oldPassword,
          newPassword: newPassword,

        ))
            .then(
              (response) async {
            if (response['status']) {
              setState(() {
                settingUp = true;
              });
              Toast(context, message: response['message']).show();
              await GlobalProvider(context).loadData();
              Navigator.pushNamedAndRemoveUntil(
                  context, NavScreen.routeName, (route) => false);
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

    return SettingsBar(
      trailing: false,
      isappbar: true,
      Title: "Security",
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Change password",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SettingsTextField(
                      icon: Icons.security,
                      width: MediaQuery.of(context).size.width * 0.90,

                      label: 'Current password',
                      isPassword: true,
                      elevate: false,
                      bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                      onSaved: (value) => oldPassword = value ?? '',

                      validate: (value) => validateBasic(
                        fieldName: 'Password',
                        value: value,
                        minLength: 8,
                      ),
                      autofill: const <String>[AutofillHints.newPassword],
                      // initialValue: 'cool1106',
                    ),
                    SettingsTextField(
                      icon: Icons.security,
                      width: MediaQuery.of(context).size.width * 0.90,

                      label: 'New password',
                      isPassword: true,
                      elevate: false,
                      bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                      onSaved: (value) => newPassword = value ?? '',
                      

                      validate: (value) => validateBasic(
                        fieldName: 'Password',
                        value: value,
                        minLength: 8,
                      ),
                      autofill: const <String>[AutofillHints.newPassword],
                      // initialValue: 'cool1106',
                    ),
                    SettingsTextField(
                      icon: Icons.security,
                      width: MediaQuery.of(context).size.width * 0.90,

                      label: 'Confirm New password',
                      isPassword: true,
                      elevate: false,
                      bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                      onSaved: (value) => confirmpassword = value ?? '',

                      validate: (value) => validateBasic(
                        fieldName: 'Password',
                        value: value,
                        minLength: 8,
                      ),
                      autofill: const <String>[AutofillHints.newPassword],
                      // initialValue: 'cool1106',
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    auth.loggedInStatus == Status.Authenticating
                        ? Loading(message: 'Authenticating')
                        : bottomsheetbutton(text: "Save", press: () {
                          if(confirmpassword!=newPassword)
                            {
                              Toast(
                                context,
                                message: 'Confirm password and new password should be same',
                                type: ToastType.ERROR,
                              ).showTop();

                            }else
                          {
                            changepwd();


                          }
                    }),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getidbb() async{
    userId = await getuserid;

  }
}
