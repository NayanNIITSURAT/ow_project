import 'package:flutter/material.dart';

class CustomTabIndicator extends Decoration {
  final double radius;

  final Color color;


  final double indicatorHeight;

  const CustomTabIndicator({
    this.radius = 3,
    this.indicatorHeight = 8,
    this.color = Colors.blue,
  });

  @override
  _CustomPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomPainter(
      this,
      onChanged,
      radius,
      color,
      indicatorHeight,
    );
  }
}

class _CustomPainter extends BoxPainter {
  final CustomTabIndicator decoration;
  final double radius;
  final Color color;
  final double indicatorHeight;

  _CustomPainter(
      this.decoration,
      VoidCallback? onChanged,
      this.radius,
      this.color,
      this.indicatorHeight,
      ) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    final Paint paint = Paint();
    double xAxisPos = offset.dx + configuration.size!.width / 2;
    double yAxisPos = offset.dy + configuration.size!.height;
    paint.color = color;

    RRect fullRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(xAxisPos, yAxisPos),
        width: configuration.size!.width*0.70,
        height: indicatorHeight,
      ),
      Radius.circular(radius),
    );

    canvas.drawRRect(fullRect, paint);
  }
}
