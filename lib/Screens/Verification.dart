import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owlet/Components/Button.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/Confirmation.dart';
import 'package:owlet/Widgets/InputContainer.dart';
import 'package:owlet/Widgets/PlainTextField.dart';
import 'package:owlet/models/Company.dart';
import 'package:owlet/services/utils.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class VerificationScreen extends StatefulWidget {
  static const routeName = '/verification-screen';
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  UserProvider? userData;
  Company company =
      Company(name: '', publications: '', category: BusinessCategory(name: ''));
  bool loading = true;
  File? certificate;
  List<BusinessCategory> industries = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, initData);
    super.initState();
  }

  initData() async {
    userData = Provider.of<UserProvider>(context, listen: false);
    final profile = userData!.profile;
    if (!profile.confirmed) {
      Toast(context,
              message:
                  'Your need need to confirm your account before you can proceed to this stage',
              type: ToastType.WARNING)
          .showTop();
      return Navigator.pushReplacementNamed(
          context, ConfirmationScreen.routeName);
    }
    if (profile.company != null) {
      Toast(context, message: 'A company associated to your profile exists')
          .show();
      return Navigator.pop(context);
    }
    try {
      final res = await fetchIndustries();
      industries = List.from(res['data'])
          .map((e) => BusinessCategory.fromMap(e))
          .toList();
    } catch (e) {
      Toast(context, message: 'An error occured fetching industries').show();
      return;
    }
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    onVerify() async {
      final data = {
        'name': company.name.toString(),
        'publications': company.publications.toString(),
        'industryId': company.category!.id,
      };
      if (data['name'].toString().length < 1 ||
          data['publications'].toString().length < 1 ||
          data['industryId'].toString().length < 1 ||
          certificate == null)
        return Toast(context, message: 'All fields are required').show();

      loading = true;
      setState(() {});
      final res = await userData!.verifyBusiness(data, certificate!);

      Toast(
        context,
        message: res['message'],
        type: res['ok'] ? ToastType.SUCCESS : ToastType.ERROR,
      ).showTop();

      if (res['ok']) {
        Navigator.pop(context);
      }

      loading = false;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: 'Account Verification'.text.make(),
        elevation: 0.2,
      ),
      body: ZStack(
        [
          SingleChildScrollView(
            child: VxBox(
              child: VStack([
                'Complete these few steps to get verified. Kindly note that it may take 30 - 45 working to verify your account'
                    .text
                    .semiBold
                    .make()
                    .centered(),
                HStack([
                  'Company Details '.text.sm.gray400.make(),
                  Divider().expand(),
                ]).box.padding(EdgeInsets.only(top: 20, bottom: 10)).make(),
                HStack([
                  InputContainer(
                    label: 'Company Name',
                    child: PlainTextField(
                      text: company.name,
                      onChange: (val) => company.name = val,
                    ),
                  ),
                ]),
                10.heightBox,
                HStack([
                  InputContainer(
                    label: 'Select business type',
                    child: DropdownSearch<String>(
                      mode: Mode.MENU,
                      // showSelectedItem: true,
                      items: industries.map((e) => e.name).toList(),
                      onChanged: (val) => company.category =
                          industries.firstWhere((e) => e.name == val),
                      showSearchBox: true,
                      dropdownSearchDecoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  )
                ]),
                10.heightBox,
                HStack([
                  InputContainer(
                    label: 'Online publications URL separated by commas(,)',
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => company.publications = val,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      minLines: 2,
                      maxLines: 3,
                    ).px8(),
                  ),
                ]),
                10.heightBox,
                HStack([
                  InputContainer(
                    label: 'Upload business registration document',
                    child: VxBox(
                      child: certificate == null
                          ? Center(
                              child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.insert_drive_file_rounded,
                                  size: 100,
                                  color: Vx.gray400,
                                ),
                                'Upload document image (jpg | png)'
                                    .text
                                    .gray600
                                    .make()
                              ],
                            ))
                          : Image.file(
                              certificate!,
                              fit: BoxFit.cover,
                              height: 500,
                            ),
                    ).rounded.height(150).make().p4().onInkTap(() async {
                      XFile? result = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (result != null)
                        setState(() {
                          certificate = File(result.path);
                        });
                    }),
                  )
                ]),
                30.heightBox,
                HStack([
                  Button(
                    loading: loading,
                    text: 'COMPLETE',
                    press: onVerify,
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
