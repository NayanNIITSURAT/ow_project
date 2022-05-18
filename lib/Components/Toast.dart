import 'package:flutter/material.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

enum ToastType { DEFAULT, ERROR, SUCCESS, WARNING }

class Toast {
  String? title;
  String message;
  Color? bgColor;
  Duration duration;
  BuildContext context;
  ToastType? type;
  Toast(
    this.context, {
    this.title,
    required this.message,
    this.bgColor = Palette.primaryColor,
    this.duration = const Duration(seconds: 3),
    this.type,
  }) {
    type == ToastType.SUCCESS
        ? bgColor = Colors.green
        : type == ToastType.ERROR
            ? bgColor = Colors.red
            : type == ToastType.WARNING
                ? bgColor = Colors.orange.shade700
                : bgColor = bgColor;
  }

  show() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: bgColor ?? Palette.primaryColor,
      ),
    );
  }

  showTop() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    showTopSnackBar(
      context,
      type == ToastType.SUCCESS
          ? CustomSnackBar.success(
              message: message,
              icon: Icon(
                Icons.error_outline_sharp,
                size: 70,
                color: Colors.grey.shade200.withOpacity(0.3),
              ),
            )
          : type == ToastType.ERROR
              ? CustomSnackBar.error(
                  message: message,
                  icon: Icon(
                    Icons.error_outline_sharp,
                    size: 70,
                    color: Colors.grey.shade200.withOpacity(0.3),
                  ),
                )
              : CustomSnackBar.success(
                  message: message,
                  icon: Icon(
                    Icons.error_outline_sharp,
                    size: 70,
                    color: Colors.grey.shade200.withOpacity(0.3),
                  ),
                ),
      displayDuration: duration,
    );
  }
}
