import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Widgets/SettingsBar.dart';

import '../../Components/Input.dart';
import '../../Components/ProfileAvatar.dart';
import '../../Components/bottomsheetbutton.dart';
import '../../Widgets/SettingsTextField.dart';
import '../../helpers/validators.dart';

class Security extends StatelessWidget {
  const Security({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsBar(
      trailing: false,
      isappbar: true,
      Title: "Security",
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
                bottomsheetbutton(text: "Save", press: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
