import 'package:flutter/material.dart';

class Pipe extends StatelessWidget {
  final double height;
  final double width;
  final Color color;
  const Pipe({
    this.height: 20,
    this.width: 0.2,
    this.color: Colors.black38,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: color,
      alignment: Alignment.center,
    );
  }
}
