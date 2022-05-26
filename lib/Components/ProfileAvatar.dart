import 'dart:math';

import 'package:flutter/material.dart';

import 'package:owlet/constants/images.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileAvatar extends StatelessWidget {
  final bool withBorder;
  final bool showStatusPainter;
  final bool withShadow;
  final bool isOnline;
  final double size;
  final String? avatar;
  final Alignment? align;
  final Function()? onPressed;
  final int? storyNum;
  final int? lastViewdIndex;

  const ProfileAvatar({
    this.withBorder: false,
    this.withShadow: false,
    this.isOnline: false,
    this.showStatusPainter:true,
    this.size: 70,
    this.avatar: logo,
    this.align,
    this.onPressed,
    this.storyNum,
    this.lastViewdIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: size,
        width: size,
        alignment: align ?? Alignment.center,
        padding: withBorder ? EdgeInsets.all(3) : null,
        margin: EdgeInsets.only(top: 2, bottom: 2),
        decoration: BoxDecoration(

          shape: BoxShape.circle,
          border: withBorder
              ? Border.all(width: 1, color: Palette.primaryColor)
              : null,
          boxShadow: withShadow
              ? [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: CustomPaint(
                size: Size.fromHeight(20),
                painter:
                showStatusPainter==true?
                storyNum != null
                    ? StatusPainter(
                        storyNum: storyNum!,
                        lastSeenIndex: lastViewdIndex ?? storyNum!)
                    : null:null,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: CircleAvatar(
                    backgroundColor: Colors.white30,
                    backgroundImage: AssetImage(loadingGif),
                    foregroundImage: NetworkImage(avatar==null?"null":avatar!),
                    radius: size,
                  ),
                ),
              ),
            ),
            if (isOnline)
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 13,
                    width: 13,
                    decoration: BoxDecoration(
                      color: Palette.online,
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 3, color: Palette.primaryColorLight),
                    ),
                  ))
          ],
        ),
      ),
    );
  }
}

class StatusPainter extends CustomPainter {
  bool isSeen;
  Color color;
  int storyNum;
  int lastSeenIndex;
  StatusPainter({
    this.isSeen: false,
    this.color: Palette.primaryColor,
    this.storyNum: 1,
    this.lastSeenIndex: -1,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 2
      ..color = isSeen ? color : Colors.grey
      ..style = PaintingStyle.stroke;
    drawArc(canvas, size, paint);
  }

  void drawArc(Canvas canvas, Size size, Paint paint) {
    if (storyNum == 1)
      canvas.drawArc(
          Rect.fromCircle(
      center: new Offset(size.width*0.5,size.height*0.5),
            radius: size.height*0.6,
    ),
        degreeToAngle(0),
        degreeToAngle(360),
        false,
        lastSeenIndex >= 0
            ? (paint..color = Colors.grey)
            : (paint..color = Palette.primaryColor),
      );

    else if (storyNum > 1) {
      double degree = -90;
      double arc = 360 / storyNum;
      final gap = (arc / 100) *
          (arc > 179
              ? 2
              : arc > 36
                  ? 4
                  : 10);
      for (var i = 0; i < storyNum; i++) {
        canvas.drawArc(
          Rect.fromCircle(
            center: new Offset(size.width*0.5,size.height*0.5),
            radius: size.height*0.6,
          ),
          degreeToAngle(degree + gap),
          degreeToAngle(arc - gap * 2),
          false,
          lastSeenIndex >= i
              ? (paint..color = Colors.grey)
              : (paint..color = Palette.primaryColor),
        );
        degree += arc;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
