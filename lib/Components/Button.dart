import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:velocity_x/velocity_x.dart';

class Button extends StatelessWidget {
  final String text;
  final Color? color, textColor;
  final Function() press;
  final double paddingHori;
  final double paddingVert;
  final double? width;
  final bool loading;

  const Button({
    required this.text,
    this.color: Palette.primaryColor,
    this.textColor: Colors.white,
    required this.press,
    this.paddingHori: 40,
    this.paddingVert: 20,
    this.width,
    this.loading: false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end:
              Alignment(0.1, 0.0), // 10% of the width, so there are ten blinds.
          colors: <Color>[
            Color(0xffee0000),
            Palette.primaryColor,
            Color.fromARGB(255, 240, 102, 11),
          ], // red to yellow
        ),
      ),
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(10),
        child: TextButton(

          style: ElevatedButton.styleFrom(
            minimumSize: Size(30, 20),
            enableFeedback: true,
            padding: EdgeInsets.symmetric(
                vertical: paddingVert, horizontal: paddingHori),
          ),
          onPressed: loading ? () {} : press,
          child: loading
              ? CircularProgressIndicator(
                  color: Colors.white54,
                  strokeWidth: 2.0,
                )
              : Text(
                  text,
                  style: TextStyle(color: textColor),
                ),
        ),
      ),
      width: width,
    );
  }
}
