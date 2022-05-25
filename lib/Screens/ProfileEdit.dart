import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:owlet/Components/BackArrow.dart';
import 'package:owlet/Components/CircleButton.dart';
import 'package:owlet/Components/ProfileAvatar.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Widgets/SettingsBar.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../Components/Input.dart';
import '../Components/bottomsheetbutton.dart';
import '../constants/palettes.dart';
import '../constants/palettes.dart';
import '../helpers/helpers.dart';
import '../helpers/validators.dart';

class ProfileEdit extends StatefulWidget {
  static const routeName = '/edit-profile';

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  Map<String, String> changes = {};

  void onChange(String name, String val) {
    changes[name] = val;
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context);
    var profile = user.profile;

    onSave() async {
      if (changes.isEmpty)
        Navigator.pop(context);
      else {
        final res = await user.updateProfile(changes);
        Toast(context, message: res['message']).show();
        if (res['status']) Navigator.pop(context);
      }
    }

    const white = Colors.white;
    return Scaffold(
        body: SettingsBar(
      trailing: false,
      isappbar: true,
      Title: "Edit Profile",
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Expanded(
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      alignment: Alignment.center,
                      child: MyProfileImage(user: user),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                        width: screenSize(context).width * 0.9,
                        child: Divider()),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 20),
                    child: Column(
                      children: [
                        EditInput(
                          onChange: (val) => onChange('username', val),
                          label: 'Full name',
                          initialValue: profile.username,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        EditInput(
                          onChange: (val) => onChange('fullName', val),
                          label: 'User name',
                          initialValue: profile.fullName,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        EditInput(
                          onChange: (val) => onChange('email', val),
                          label: 'Email Address',
                          initialValue: profile.email,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        EditInput(
                          onChange: (val) => onChange('phone', val),
                          label: 'Phone',
                          isMultiLine: false,
                          maxlengh: 10,
                          keybordtype: TextInputType.number,
                          initialValue: profile.phone,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        EditInput(
                          onChange: (val) => onChange('website', val),
                          label: 'Website Address',
                          initialValue: profile.website,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        EditInput(
                          onChange: (val) => onChange('bio', val),
                          label: 'Bio',
                          isMultiLine: true,
                          keybordtype: TextInputType.multiline,
                          initialValue: profile.bio,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        SaveButton(context, onSave, user)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Container SaveButton(
      BuildContext context, Future<Null> onSave(), UserProvider user) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment(0.04, 5.5),
          colors: <Color>[
            Color(0xffee0000),
            Color(0xffF33909),
            Color(0xffFE6D0A).withOpacity(0.8)
          ], // red to yellow
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TextButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 40),
          ),
          onPressed: onSave,
          child: user.status == Status.Processing
              ? CircularProgressIndicator(
                  color: Colors.white,
                )
              : Text(
                  'Done ',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}

class EditInput extends StatelessWidget {
  const EditInput({
    this.onChange,
    this.label,
    this.padding,
    this.margin,
    this.initialValue,
    this.isMultiLine: false,
    this.keybordtype,
    this.validate,
    this.maxlengh,
  });
  final Function(String)? onChange;
  final String? label;
  final String? initialValue;
  final bool isMultiLine;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final String? Function(String?)? validate;
  final int? maxlengh;

  final TextInputType? keybordtype;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        !isMultiLine
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(label!,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: screenSize(context).width * 0.92,
                    height: 45,
                    margin: margin ?? EdgeInsets.symmetric(vertical: 8),
                    padding: padding ??
                        EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Color(0xffEDF2F7).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      maxLength: maxlengh,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          counterText: "",
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          labelStyle:
                              TextStyle(fontSize: 20, color: Colors.black45)),

                      scrollPadding: EdgeInsets.all(10),
                      keyboardType: keybordtype,
                      onChanged: onChange,
                      // maxLengthEnforcement: ,
                      textInputAction: TextInputAction.next,
                      initialValue: initialValue,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(label!,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w400)),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    padding: EdgeInsets.only(
                      right: 10,
                      left: 10,
                      bottom: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xffEDF2F7).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none, counterText: "",
                        // enabledBorder: border,
                        // focusedBorder: border,
                      ),

                      scrollPadding: EdgeInsets.all(10),

                      onChanged: onChange,
                      // maxLengthEnforcement: ,
                      minLines: 5,
                      maxLines: 15,
                      maxLength: 200,

                      keyboardType: keybordtype,
                      textInputAction: TextInputAction.newline,
                      initialValue: initialValue,
                    ),
                  ),
                ],
              ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}

class MyProfileImage extends StatelessWidget {
  MyProfileImage({required this.user});

  final UserProvider user;

  @override
  Widget build(BuildContext context) {
    void _cropImage(File image) async {
      File? cropped = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        maxHeight: 200,
        maxWidth: 200,
      );

      if (cropped != null) {
        Navigator.pop(context);
        final res = await user.updateProfileImage(cropped);
        Toast(context, message: res['message']);
      }
    }

    void _loadPicker(ImageSource source) async {
      XFile? picked = await ImagePicker().pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
      );
      if (picked != null) _cropImage(File(picked.path));
    }

    void _showPickOptionDialog(BuildContext ctx) {
      showDialog(
          context: ctx,
          builder: (ctx) => AlertDialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                content: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          'Pick from Gallery',
                          textAlign: TextAlign.center,
                        ),
                        onTap: () => _loadPicker(ImageSource.gallery),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          'Turn on Camera',
                          textAlign: TextAlign.center,
                        ),
                        onTap: () => _loadPicker(ImageSource.camera),
                      )
                    ],
                  ),
                ),
              ));
    }

    return Column(
      children: [
        ProfileAvatar(
          avatar: user.profile.avartar,
          size: 130,
        ),
        SizedBox(
          height: 10,
        ),
        InkWell(
            onTap: () {
              _showPickOptionDialog(context);
            },
            child: Text("Change profile photo",
                style:
                    TextStyle(color: kErrorColor, fontWeight: FontWeight.w600)))
      ],
    );
  }
}
