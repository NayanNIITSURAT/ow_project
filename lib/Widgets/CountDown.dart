import 'package:flutter/material.dart';

class CountDown extends StatelessWidget {
  final double from;
  final double to;
  final Widget Function(BuildContext context, double value, Widget? child)?
      builder;
  final Function()? onFinish;
  final TextStyle style;
  const CountDown(
      {required this.from,
      this.to = 0.0,
      this.onFinish,
      this.style = const TextStyle(color: Colors.white),
      this.builder});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(
        begin: from,
        end: to,
      ),
      duration: Duration(seconds: to > from ? to.toInt() : from.toInt()),
      builder: builder ??
          (_, double value, __) => Text(
                "0:${value < 10 ? 0 : ''}${value.toInt()}",
                style: style,
              ),
      onEnd: onFinish,
    );
  }
}
