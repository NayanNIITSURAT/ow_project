import 'package:flutter/material.dart';

import '../constants/images.dart';

class SettingsListTile extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback callback;

  const SettingsListTile(
      {Key? key,
      required this.text,
      required this.icon,
      required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: InkWell(
      onTap: callback,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
              width: 30,
            ),
            Image.asset(
              icon,
              height: 25,
            ),
            SizedBox(
              width: 25,
            ),
            Flexible(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    ));
  }
}

class HelpTile extends StatelessWidget {
  final String text;

  final VoidCallback callback;

  const HelpTile({Key? key, required this.text, required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        width: MediaQuery.of(context).size.width * 0.90,
        child: InkWell(
          onTap: callback,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 18, child: Image.asset(right_arrow))
            ],
          ),
        ));
  }
}
