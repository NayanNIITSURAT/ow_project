import 'package:flutter/material.dart';

class BounceBtn extends StatefulWidget {
  final Widget child;
  final int zoomPercentage;
  final Function? press;

  const BounceBtn({
    required this.child,
    this.zoomPercentage: 30,
    this.press,
  });

  @override
  _BounceBtnState createState() => _BounceBtnState();
}

class _BounceBtnState extends State<BounceBtn>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 50,
      ),
      lowerBound: 0.0,
      upperBound: (widget.zoomPercentage < 101
              ? widget.zoomPercentage / 100
              : widget.zoomPercentage)
          .toDouble(),
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 + _controller.value;
    return GestureDetector(
        onTap: _tap,
        // onTapUp: _tapUp,
        child: Transform.scale(
          scale: _scale,
          child: widget.child,
        ));
  }

  void _tap() {
    (widget.press != null ? widget.press : () => null)!();
    _controller.forward();
    Future.delayed(Duration(milliseconds: 200), () => _controller.reverse());
  }
}
