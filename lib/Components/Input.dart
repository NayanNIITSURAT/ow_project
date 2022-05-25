import 'package:flutter/material.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/palettes.dart';

class Input extends StatelessWidget {
  final IconData? icon;
  final IconData? rightIcon;

  final String? leftIconImage;
  final String? rightIconImage;
  final Widget? preWidget;
  final Widget? postWidget;
  final String? label;
  final String? initialValue;
  final Iterable<String>? autofill;
  final int lines;
  final int maxlines;
  final bool isPassword;
  final bool invalid;
  final bool islable;
  final double? width;
  final bool elevate;
  final TextInputType type;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final EdgeInsets? containtpadding;
  final int? maxlengh;

  final Function(String?)? onSaved;
  final String? Function(String?)? validate;
  final double? radius;
  final Color? bgColor;
  final FocusNode? focusNode;
  final TextEditingController? textEditingController;
  final String? helperText;
  final double? topPadding;
  final String? hintText;
  final VoidCallback? leftimageTap;
  final VoidCallback? rightimageTap;
  final Function()? righticonTap;
  final bool? isrightimage;
  final bool? isdescription;
  final bool? hideshowpassword;

  const Input({
    this.rightIconImage,
    this.isrightimage,
    this.leftIconImage,
    this.rightimageTap,
    this.leftimageTap,
    this.icon,
    this.maxlengh,
    this.rightIcon,
    this.preWidget,
    this.righticonTap,
    this.postWidget,
    this.label = '',
    this.type: TextInputType.text,
    this.isPassword: false,
    this.invalid: false,
    this.elevate: true,
    this.islable: true,
    this.width,
    this.lines: 1,
    this.maxlines: 3,
    this.margin,
    this.padding,
    this.containtpadding,
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
    this.isdescription = false,
    this.hideshowpassword = false
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding ?? 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          islable == true
              ? Text(label!,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500))
              : SizedBox.shrink(),
          Container(
            width: width ?? screenSize(context).width * 0.8,
            margin: margin ?? EdgeInsets.symmetric(vertical: 8),
            padding:
                padding ?? EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: bgColor ?? fieldcolor,
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
              maxLength: maxlengh,
              decoration: InputDecoration(
                  counterText: "",
                  //icon: preWidget ?? (icon != null ? Icon(icon) : null),
                  border: InputBorder.none,
                  contentPadding: containtpadding,
                  //hintText: label,
                  isDense: true,
                  prefixIcon: leftIconImage != null
                      ? InkWell(
                          onTap: leftimageTap,
                          child: Image.asset(
                            leftIconImage!,
                          ),
                        )
                      : null,
                  hintText: hintText ?? "",
                  suffixIcon: isrightimage == true
                      ? rightIconImage != null
                          ? InkWell(
                              onTap: rightimageTap,
                              child: Image.asset(rightIconImage!),
                            )
                          : null
                      : rightIcon != null
                          ? InkWell(
                    onTap: righticonTap,
                            child: Icon(
                                rightIcon,
                                size: 25,
                              ),
                          )
                          : null,),
              keyboardType: type,
              obscureText: isPassword,
              onChanged: onSaved,
              minLines: isPassword ? null : lines,
              maxLines: isdescription == true
                  ? maxlines
                  : isPassword
                      ? 1
                      : lines + 1,
              validator: validate,
              initialValue: initialValue,
              autofillHints: autofill,
              focusNode: focusNode,
              controller: textEditingController,
            ),
          ),
          helperText != null
              ? Text(
                  helperText ?? "",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 12, color: Colors.black54.withOpacity(0.4)),
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }
}
