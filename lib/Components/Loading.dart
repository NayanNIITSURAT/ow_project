import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String message;
  final bool showWait;

  const Loading({Key? key, this.message: 'Loading', this.showWait: true})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CupertinoActivityIndicator(),
        Text(" $message ${showWait ? '... Please wait' : ''}")
      ],
    );
  }
}
