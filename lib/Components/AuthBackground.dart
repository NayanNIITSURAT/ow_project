import 'package:flutter/material.dart';
import 'package:owlet/Components/CircleButton.dart';
import 'package:owlet/constants/images.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: SafeArea(
        child: Stack(
          children: [child],
        ),
      ),
    );
  }
}
