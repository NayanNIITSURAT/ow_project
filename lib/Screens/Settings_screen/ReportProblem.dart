import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Components/Input.dart';
import '../../Components/Loading.dart';
import '../../Components/Toast.dart';
import '../../Components/bottomsheetbutton.dart';
import '../../Providers/Auth.dart';
import '../../Providers/GlobalProvider.dart';
import '../../Widgets/SettingsBar.dart';
import '../../Widgets/SettingsTextField.dart';
import '../../helpers/validators.dart';
import '../../services/auth.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({Key? key}) : super(key: key);

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final formKey = new GlobalKey<FormState>();
  bool isloading = false;
  String email = '', subject = '', fullName = '', description = '';
  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    var doSubmit = () {
      setState(() {
        isloading = true;
      });
      final form = formKey.currentState;
      form!.save();
      if (form.validate()) {
        auth.ReportProblem(Problem(
          email: email,
          subject: subject,
          fullName: fullName,
          description: description,
        )).then(
          (response) {
            setState(() {
              isloading = false;
            });

            print("Hello" + response.toString());
            if (response['status'] == 200) {
              Toast(context, message: response['message']).show();
              Navigator.pop(context, true);
            } else {
              Toast(
                context,
                title: "Report Problem Failed",
                message: response['message'],
              ).show();
              // Navigator.pop(context, true);
            }
          },
        );
      }
    };
    return Form(
      key: formKey,
      child: SettingsBar(
        trailing: false,
        isappbar: true,
        Title: "Report Problem",
        child: SingleChildScrollView(
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
                    // SettingsTextField(
                    //   icon: Icons.security,
                    //   width: MediaQuery.of(context).size.width * 0.90,
                    //
                    //   label: 'Email',
                    //   // isPassword: true,
                    //   elevate: false,
                    //   bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                    //
                    //   // validate: (value) => validateBasic(
                    //   //   fieldName: 'Password',
                    //   //   value: value,
                    //   //   minLength: 8,
                    //   // ),
                    //   validate: validateEmail,
                    //   onSaved: (value) => email = value!.trim(),
                    //   autofill: const <String>[AutofillHints.newPassword],
                    //   // initialValue: 'cool1106',
                    // ),
                    Input(
                      icon: Icons.email,
                      elevate: false,
                      label: 'Email or phone number',
                      bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                      type: TextInputType.emailAddress,
                      validate: validateEmail,
                      onSaved: (value) => email = value!.trim(),
                      autofill: const <String>[AutofillHints.email],
                      // initialValue: 'ebukanwosu45@gmail.com',
                    ),
                    // SettingsTextField(
                    //   icon: Icons.security,
                    //   width: MediaQuery.of(context).size.width * 0.90,
                    //
                    //   label: 'Full Name',
                    //   // isPassword: true,
                    //   elevate: false,
                    //   bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                    //
                    //   // validate: (value) => validateBasic(
                    //   //   fieldName: 'Password',
                    //   //   value: value,
                    //   //   minLength: 8,
                    //   // ),
                    //   validate: validateUsername,
                    //   onSaved: (value) => fullName = value!.trim(),
                    //   autofill: const <String>[AutofillHints.newPassword],
                    //   // initialValue: 'cool1106',
                    // ),

                    Input(
                      icon: Icons.person,
                      label: 'Subject',
                      elevate: false,
                      bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                      type: TextInputType.name,
                      validate: validateUsername,
                      onSaved: (value) => subject = value!.trim(),
                      autofill: const <String>[AutofillHints.newUsername],
                      // initialValue: 'coolprince',
                    ),
                    Input(
                      icon: Icons.person,
                      label: 'Full name',
                      elevate: false,
                      bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                      type: TextInputType.name,
                      validate: validateUsername,
                      onSaved: (value) => fullName = value!.trim(),
                      autofill: const <String>[AutofillHints.newUsername],
                      // initialValue: 'coolprince',
                    ),
                    // SettingsTextField(
                    //   icon: Icons.security,
                    //   width: MediaQuery.of(context).size.width * 0.90,
                    //
                    //   label: 'Subject',
                    //   // isPassword: true,
                    //   elevate: false,
                    //   bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                    //
                    //   // validate: (value) => validateBasic(
                    //   //   fieldName: 'Password',
                    //   //   value: value,
                    //   //   minLength: 8,
                    //   // ),
                    //   validate: validateUsername,
                    //   onSaved: (value) => subject = value!.trim(),
                    //   autofill: const <String>[AutofillHints.newPassword],
                    //   // initialValue: 'cool1106',
                    // ),
                    Input(
                      icon: Icons.person,
                      label: 'Description',
                      elevate: false,
                      bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                      type: TextInputType.multiline,
                      lines: 2,
                      isdescription: true,
                      maxlines: 3,
                      validate: validateUsername,
                      onSaved: (value) => description = value!.trim(),
                      autofill: const <String>[AutofillHints.newUsername],
                      // initialValue: 'coolprince',
                    ),
                    // SettingsTextField(
                    //   icon: Icons.security,
                    //   width: MediaQuery.of(context).size.width * 0.90,
                    //
                    //   label: 'Description',
                    //   isPassword: false,
                    //   lines: 2,
                    //   elevate: false,
                    //
                    //   bgColor: Color(0xffEDF2F7).withOpacity(0.5),
                    //
                    //   // validate: (value) => validateBasic(
                    //   //   fieldName: 'Password',
                    //   //   value: value,
                    //   //   minLength: 8,
                    //   // ),
                    //   validate: validateUsername,
                    //   onSaved: (value) => description = value!.trim(),
                    //   autofill: const <String>[AutofillHints.newPassword],
                    //   // initialValue: 'cool1106',
                    // ),
                    SizedBox(
                      height: 20,
                    ),
                    isloading
                        ? Loading(message: 'Authenticating')
                        : bottomsheetbutton(text: "Submit", press: doSubmit)
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
