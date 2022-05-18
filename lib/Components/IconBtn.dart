import 'package:flutter/material.dart';
import 'package:owlet/constants/palettes.dart';

class IconBtn extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;
  final double paddingTop;
  final double paddingBottom;
  final double paddingLeft;
  final double paddingRight;
  final Function()? onPressed;
  final bool? isImage;
  final bool? issvg;
  final String? imagePath;

  const IconBtn({
    required this.icon,
    this.onPressed,
    this.issvg,
    this.isImage,
    this.imagePath,
    this.color: Palette.primaryColor,
    this.size,
    this.paddingTop: 0,
    this.paddingBottom: 0,
    this.paddingLeft: 0,
    this.paddingRight: 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.only(
          top: paddingTop,
          right: paddingRight,
          bottom: paddingBottom,
          left: paddingLeft,
        ),
        child:isImage==true?
        IconButton(

          icon: Container(
            child: Image(
              height: 22,
              image: AssetImage(
                imagePath!,

              ),
              fit: BoxFit.cover,
            ),

          ),
          onPressed: onPressed,
        ):
        Icon(icon, color: color, size: size),
      ),
      onTap: onPressed,
    );
  }
}
