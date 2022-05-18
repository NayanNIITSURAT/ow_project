import 'package:flutter/material.dart';
import 'package:owlet/constants/palettes.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.text,
    required this.press,
    this.color = Palette.primaryColor,
    this.padding = const EdgeInsets.all(kDefaultPadding * 0.75),
  });

  final String text;
  final VoidCallback press;
  final color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(40)),
      ),
      padding: padding,
      color: color,
      minWidth: double.infinity,
      onPressed: press,
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
