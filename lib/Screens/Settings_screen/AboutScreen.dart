import 'package:flutter/material.dart';
import 'package:owlet/Widgets/SettingsBar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Widgets/SettingsListTile.dart';

class AboutScren extends StatelessWidget {
  const AboutScren({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsBar(
      isappbar: true,
      Title: "About",
      trailing: false,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HelpTile(
              text: 'Data Policy',
              callback: () {},
            ),
            HelpTile(
              text: 'Terms of Use',
              callback: () {
                _launchURL();
              },
            ),
            HelpTile(
              text: 'Open source libraries',
              callback: () {},
            ),
          ],
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
