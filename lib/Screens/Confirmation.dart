import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Components/Button.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Widgets/InputContainer.dart';
import 'package:owlet/Widgets/PlainTextField.dart';
import 'package:owlet/models/User.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class ConfirmationScreen extends StatefulWidget {
  static const routeName = '/confirmation-screen';
  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  UserProvider? userData;
  User profile = User(id: 0, fullName: '', username: '');
  bool loading = true;
  String phoneCode = '';
  String emailCode = '';

  @override
  void initState() {
    Future.delayed(Duration.zero, initData);
    super.initState();
  }

  initData() {
    setState(() {
      userData = Provider.of<UserProvider>(context, listen: false);
      profile = userData!.profile;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    onConfirm() async {
      loading = true;
      setState(() {});
      final data = {
        'fname': profile.fname ?? '',
        'lname': profile.lname ?? '',
        'country': profile.country ?? '',
        'emailCode': emailCode,
        'phoneCode': phoneCode,
      };
      final res = await userData!.confirmAccount(data);

      Toast(
        context,
        message: res['message'],
        type: res['ok'] ? ToastType.SUCCESS : ToastType.ERROR,
      ).showTop();

      if (res['ok']) Navigator.pop(context);

      loading = false;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: 'Account Confirmation'
            .text
            .color(Colors.black87)
            .size(20)
            .semiBold
            .make(),
        elevation: 0.2,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
        ),
      ),
      body: ZStack(
        [
          SingleChildScrollView(
            child: VxBox(
              child: VStack([
                'Complete these few steps to confirm your account'
                    .text
                    .semiBold
                    .size(18)
                    .make()
                    .centered(),
                10.heightBox,
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        HStack([
                          'Personal Details '.text.medium.gray400.make(),
                          Divider().expand(),
                        ])
                            .box
                            .padding(EdgeInsets.only(top: 20, bottom: 10))
                            .make(),
                        HStack([
                          InputContainer(
                            label: 'First Name',
                            child: PlainTextField(
                              text: profile.fname,
                              onChange: (val) => profile.fname = val,
                            ),
                          ),
                          5.widthBox,
                          InputContainer(
                            label: 'Last Name',
                            child: PlainTextField(
                              text: profile.lname,
                              onChange: (val) => profile.lname = val,
                            ),
                          )
                        ]),
                        10.heightBox,
                        HStack([
                          InputContainer(
                            label: 'Nationality',
                            child: CountryCodePicker(
                              onChanged: (e) => profile.country = e.code,
                              initialSelection: 'NG',
                              favorite: ['+234', '+1'],
                              showCountryOnly: true,
                              showOnlyCountryWhenClosed: true,
                              alignLeft: true,
                              padding: EdgeInsets.symmetric(vertical: 1),
                              showDropDownButton: true,
                            ),
                          )
                        ]),
                      ],
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        HStack([
                          'Contact Details '.text.sm.gray400.make(),
                          Divider().expand(),
                        ])
                            .box
                            .padding(EdgeInsets.only(top: 30, bottom: 10))
                            .make(),
                        HStack([
                          InputContainer(
                            label: 'Email verification code',
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              onChanged: (val) => emailCode = val,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.newline,
                            ).px8(),
                            showButton: true,
                            onTapBtn: () async =>
                                await userData!.sendEmailCode(),
                          ),
                        ]),
                        10.heightBox,
                        HStack([
                          InputContainer(
                            label: 'Phone number verification code',
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              onChanged: (val) => phoneCode = val,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.newline,
                            ).px8(),
                            showButton: true,
                            onTapBtn: () async => await userData!.sendSmsCode(),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
                30.heightBox,
                HStack([
                  Button(
                    loading: loading,
                    text: 'COMPLETE',
                    press: onConfirm,
                    paddingVert: 15,
                  ).expand(),
                ]),
                10.heightBox,
              ]),
            ).padding(EdgeInsets.all(15)).make(),
          ),
          if (loading)
            Container(
              child: Center(child: CupertinoActivityIndicator()),
              color: Colors.white38,
            ),
        ],
      ),
    );
  }
}
