import 'package:flutter/material.dart';
import 'package:owlet/constants/palettes.dart';

class CircleButton extends StatelessWidget {
  final IconData? icon;
  final double iconSize;
  final EdgeInsets margin;
  final Color color;
  final Color bgColor;
  final Function()? onPressed;
  final bool withBlur;
  final Border? border;
  final bool? imageIcon;
  final String? imagePath;

  const CircleButton({
    this.icon,
    this.iconSize: 25,
     this.imageIcon,
    this.imagePath,
    this.color: Palette.primaryColor,
    this.bgColor: const Color(0xFFEEEEEE),
    this.onPressed,
    this.withBlur: false,
    this.margin: const EdgeInsets.all(10),
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: iconSize * 1.7,
      height: iconSize * 1.7,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          if (withBlur)
            BoxShadow(
              color: Palette.primaryColorLight,
              spreadRadius: 10,
              offset: Offset(0, 0), // changes position of shadow
            ),
        ],
        border: border,
      ),
      child:
      imageIcon==true?
      IconButton(

        icon: Container(
          child: Image(
            image: AssetImage(
              imagePath!,
            ),
            fit: BoxFit.cover,
          ),

        ),
        onPressed: onPressed,
      ):
      IconButton(

        icon: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
