import 'package:flutter/material.dart';
import 'package:owlet/helpers/helpers.dart';

class BottomModalLayout extends StatelessWidget {
  const BottomModalLayout({
    Key? key,
    required this.children,
    this.bgColor,
  }) : super(key: key);

  final List<Widget> children;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, left: 10, right: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Divider(
                color: Colors.grey.shade400,
                thickness: 5,
                indent: screenSize(context).width * 0.46,
                endIndent: screenSize(context).width * 0.46,
              ),
            ),
            SizedBox(height: 10),
            ...children,
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom)
          ],
        ),
      ),
    );
  }
}
