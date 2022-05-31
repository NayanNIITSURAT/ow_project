import 'package:flutter/material.dart';
import 'package:owlet/Widgets/SettingsBar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Widgets/SettingsListTile.dart';
import '../Faq_Screen.dart';
import 'ReportProblem.dart';

class HelpScren extends StatelessWidget {
  const HelpScren({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsBar(
      trailing: false,
      isappbar: true,
      Title: "Help",
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HelpTile(
              text: 'Report a Problem',
              callback: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ReportProblemScreen()));
              },
            ),
            HelpTile(
              text: 'Help Center',
              callback: () {
                _launchURL();
              },
            ),
            HelpTile(
              text: 'Privacy and Security Help',
              callback: () {
                // _launchURL();

                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const faq_screen(),
                  ),
                );
              },
            ),
            HelpTile(
              text: 'Support Requests',
              callback: () {
                _launchURL();
              },
            ),
          ],
        ),
      ),
    );
  }

  _launchURL() async {
    const url = 'https://www.google.com/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
