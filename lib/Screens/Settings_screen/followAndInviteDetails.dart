import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Providers/UtilsProvider.dart';
import '../../Widgets/SettingsListTile.dart';
import '../../Widgets/SettingsBar.dart';
import '../../constants/images.dart';
import '../../helpers/helpers.dart';

class FollowAndInviteDetailsScreen extends StatefulWidget {
  const FollowAndInviteDetailsScreen({Key? key}) : super(key: key);

  @override
  State<FollowAndInviteDetailsScreen> createState() =>
      _FollowAndInviteDetailsScreenState();
}

class _FollowAndInviteDetailsScreenState
    extends State<FollowAndInviteDetailsScreen> {
  _textMe() async {
    if (Platform.isAndroid) {
      const uri =
          'sms:?body=Hi, I am Using this Application You can Download from it https://play.google.com/store/apps/details?id=com.owlet.app';
      await launch(uri);
    } else if (Platform.isIOS) {
      // iOS
      const uri = 'sms:0039-222-060-888&body=hello%20there';
      await launch(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final utility = Provider.of<UtilsProvider>(context);

    var seller = utility.currentSellerProfile;
    final whatsAppCaption = Uri.encodeComponent(
        // '*New Chat From The Owlet* \n\n Hello ${seller != null ? seller.fullName : 'Seller'}, are you available for a chat?'
        'Hi, I am using  owlet App you can download from it https://play.google.com/store/apps/details?id=com.owlet.app ');
    return SettingsBar(
      trailing: false,
      Title: 'Follow and invite friends',
      isappbar: true,
      child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          SettingsListTile(
              text: 'Invite friends via Whatsapp',
              icon: Whatsapp,
              callback: () {
                customLaunch('https://wa.me/?text=${whatsAppCaption}');
              }),
          SizedBox(
            height: 30,
          ),
          SettingsListTile(
              text: 'Invite friends via SMS',
              icon: comments,
              callback: () {
                _textMe();
              }),
          SizedBox(
            height: 30,
          ),
          SettingsListTile(
              text: 'Invite friends via email',
              icon: inbox,
              callback: () {
                sendemail();
              }),
          SizedBox(
            height: 30,
          ),
          SettingsListTile(
              text: 'Invite friends via...',
              icon: export,
              callback: () {
                Share.share(
                    "Hi, I am Using this Application You can Download from it https://play.google.com/store/apps/details?id=com.owlet.app",
                    subject: "Share app");
              }),
        ],
      ),
    );
  }

  void sendemail() async {
    final Email email = Email(
      body:
          'Hi, I am Using this Application You can Download from it https://play.google.com/store/apps/details?id=com.owlet.app',
      subject: '',
      recipients: [],
      // cc: ['cc@example.com'],
      // bcc: ['bcc@example.com'],
      // attachmentPaths: ['/path/to/attachment.zip'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }
}
