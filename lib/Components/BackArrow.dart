import 'package:flutter/material.dart';

class BackArrow extends StatelessWidget {
  const BackArrow({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.arrow_back, color: color);
  }
}
