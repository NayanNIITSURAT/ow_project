import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class StoryBgColor extends StatelessWidget {
  final Color color;
  final bool glow;
  final Function()? onPress;
  const StoryBgColor({
    Key? key,
    required this.color,
    this.glow = false,
    this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      glowColor: color,
      endRadius: 30.0,
      duration: 2.seconds,
      repeat: glow,
      repeatPauseDuration: 100.milliseconds,
      child: VxCircle(backgroundColor: color).h(25),
    ).onInkTap(onPress ?? () {});
  }
}
