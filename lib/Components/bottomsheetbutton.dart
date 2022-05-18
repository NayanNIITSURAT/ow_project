import 'package:flutter/material.dart';
import 'package:owlet/constants/palettes.dart';

class bottomsheetbutton extends StatelessWidget {
  final String text;
  final Color color, textColor;
  final Function() press;
  final bool disabled;

  const bottomsheetbutton({
    required this.text,
    this.color = Palette.primaryColor,
    this.textColor = Colors.white,
    required this.press,
    this.disabled: false,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.9,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end:
          Alignment(0.04, 5.5),
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
          onPressed: disabled ? () {} : press,
          child: Text(
            text,
            style: TextStyle(color: textColor,fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
