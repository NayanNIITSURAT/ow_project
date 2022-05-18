import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:owlet/constants/palettes.dart';

class ImageBtn extends StatelessWidget {
  final String assetString;
  final Color? color;
  final double? size;
  final double paddingTop;
  final double paddingBottom;
  final double paddingLeft;
  final double paddingRight;
  final bool isSvg;
  final Function()? onPressed;
  const ImageBtn({
    required this.assetString,
    this.onPressed,
    this.color: Palette.primaryColor,
    this.size,
    this.paddingTop: 0,
    this.paddingBottom: 0,
    this.paddingLeft: 0,
    this.paddingRight: 0,
    this.isSvg = false,
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
          child: isSvg
              ? SvgPicture.asset(assetString, color: color)
              : Image.asset(assetString, color: color)),
      onTap: onPressed,
    );
  }
}
