import 'package:flutter/material.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:velocity_x/velocity_x.dart';

class SettingsTextField extends StatelessWidget {
  final IconData? icon;
  final IconData? rightIcon;
  final Widget? preWidget;
  final Widget? postWidget;
  final String? label;
  final String? initialValue;
  final Iterable<String>? autofill;
  final int lines;
  final bool isPassword;
  final bool invalid;
  final double? width;
  final bool elevate;
  final TextInputType type;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Function(String?)? onSaved;
  final String? Function(String?)? validate;
  final double? radius;
  final Color? bgColor;
  final FocusNode? focusNode;
  final TextEditingController? textEditingController;
  final String? helperText;
  final double? topPadding;
  final String? hintText;
  const SettingsTextField({
    this.icon,
    this.rightIcon,
    this.preWidget,
    this.postWidget,
    this.label = '',
    this.type: TextInputType.text,
    this.isPassword: false,
    this.invalid: false,
    this.elevate: true,
    this.width,
    this.lines: 1,
    this.margin,
    this.padding,
    this.validate,
    this.onSaved,
    this.initialValue,
    this.autofill,
    this.radius,
    this.bgColor,
    this.focusNode,
    this.textEditingController,
    this.helperText,
    this.topPadding,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding ?? 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(label!,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400)),
          Container(
            width: width ?? screenSize(context).width * 0.8,
            height: 70,
            margin: margin ?? EdgeInsets.symmetric(vertical: 8),
            padding:
                padding ?? EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: bgColor ?? Colors.blue.shade50,
              borderRadius: BorderRadius.circular(radius ?? 10),
              border: invalid ? Border.all(color: Colors.red, width: 1) : null,
              boxShadow: elevate
                  ? [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: Offset(0, 5), // changes position of shadow
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              decoration: InputDecoration(
                  //icon: preWidget ?? (icon != null ? Icon(icon) : null),
                  border: InputBorder.none,
                  //hintText: label,
                  isDense: true,
                  hintText: hintText ?? "",
                  suffixIcon: rightIcon != null
                      ? Icon(
                          rightIcon,
                          size: 25,
                        )
                      : null),
              keyboardType: type,
              obscureText: isPassword,
              onChanged: onSaved,
              minLines: isPassword ? null : lines,
              maxLines: isPassword ? 1 : lines + 1,
              validator: validate,
              initialValue: initialValue,
              autofillHints: autofill,
              focusNode: focusNode,
              controller: textEditingController,
            ),
          ),
          helperText != null
              ? Text(helperText ?? "",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 12, color: Colors.black54.withOpacity(0.4)))
              : SizedBox.shrink()
        ],
      ),
    );
  }
}
