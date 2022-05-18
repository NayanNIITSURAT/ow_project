import 'package:flutter/material.dart';

class IconTextBtn extends StatelessWidget {
  const IconTextBtn({
    this.icon,
    this.iconColor,
    required this.text,
    required this.onPressed,
  });

  final IconData? icon;
  final Color? iconColor;
  final String text;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Row(
        children: [
          ...(icon != null
              ? [
                  Icon(
                    icon,
                    size: 13,
                    color: iconColor ?? Colors.grey,
                  ),
                  SizedBox(
                    width: 5,
                  )
                ]
              : []),
          Text(
            '$text',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      onPressed: onPressed,
    );
  }
}
