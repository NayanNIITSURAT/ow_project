import 'package:flutter/material.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:velocity_x/velocity_x.dart';

class InputContainer extends StatelessWidget {
  final Widget child;
  final String? label;
  final bool showButton;
  final Function()? onTapBtn;

  const InputContainer({
    Key? key,
    required this.child,
    this.label,
    this.showButton: false,
    this.onTapBtn,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return VxAnimatedBox(
      child: VStack([
        if (label != null) label!.text.make(),
        HStack([
          VxBox(child: child).make().expand(),
          if (showButton)
            HStack([
              5.widthBox,
              ResendCode(
                buttonText: 'Send Code',
                onTap: onTapBtn,
              ),
            ]).px8().onInkTap(onTapBtn ?? () {})
        ]).backgroundColor(Colors.blue.shade50).cornerRadius(10),
      ]),
    ).animDuration(500.milliseconds).make().expand();
  }
}

class ResendCode extends StatefulWidget {
  const ResendCode({
    Key? key,
    required this.buttonText,
    this.onTap,
  }) : super(key: key);

  final String buttonText;
  final Function()? onTap;

  @override
  State<ResendCode> createState() => _ResendCodeState();
}

class _ResendCodeState extends State<ResendCode> {
  int counter = 0;
  int prevCounterVal = 0;
  @override
  void initState() {
    counter = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: counter < 2
          ? [
              widget.buttonText.text
                  .color(Colors.black87)
                  .medium
                  .bold
                  .make()
                  .onInkTap(() {
                counter = 60;
                setState(() {});
                (widget.onTap ?? () => null)();
              }),
            ]
          : [
              "resend in ".text.italic.coolGray400.make(),
              TweenAnimationBuilder(
                tween: Tween(
                  begin: counter,
                  end: 1.0,
                ),
                duration: Duration(seconds: counter),
                builder: (_, dynamic value, child) =>
                    "${value.toInt()}".text.italic.coolGray400.make(),
                onEnd: () => setState(() {
                  counter = 0;
                }),
              ),
            ],
    );
  }
}
