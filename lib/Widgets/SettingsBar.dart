import 'package:flutter/material.dart';

import '../constants/images.dart';

class SettingsBar extends StatelessWidget {
  final String? Title;
  final Widget child;
  final bool isappbar;
  final bool trailing;
  final VoidCallback? trailingTap;

  const SettingsBar(
      {Key? key,
      this.Title,
        this.trailingTap,
      required this.child,
      required this.isappbar,
      required this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isappbar == true
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              actions: [
                trailing == true
                    ? Padding(
                      padding:  EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05),
                      child: InkWell(
                          onTap:trailingTap,

                          child: Image.asset(export_passbook,height: 25,width: 18,)),
                    )
                    : SizedBox.shrink()
              ],
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              centerTitle: true,
              title: Text(
                Title!,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 18),
              ),
            ),
            body: child,
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: child,
          );
  }
}
