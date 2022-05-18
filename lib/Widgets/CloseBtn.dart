import 'package:flutter/material.dart';
import 'package:owlet/Components/IconBtn.dart';

class CloseBtn extends StatelessWidget {
  const CloseBtn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconBtn(
      icon: Icons.close,
      color: Colors.white,
      onPressed: () => Navigator.pop(context),
    );
  }
}
