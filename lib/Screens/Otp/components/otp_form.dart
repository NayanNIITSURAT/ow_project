import 'package:flutter/material.dart';
import 'package:owlet/Components/AuthButton.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Screens/Otp/constants.dart';
import 'package:owlet/helpers/helpers.dart';

class OtpForm extends StatefulWidget {
  OtpForm({required this.onSubmit, this.loading = false, this.otpLength = 4});

  final Function(String otp) onSubmit;
  final bool loading;
  final int otpLength;

  @override
  _OtpFormState createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  List<TextEditingController>? _controllers;
  List<FocusNode>? _pinFocusNodes;
  List<int> fields = [];
  String? error;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.otpLength; i++) {
      fields.add(i);
    }
    _controllers = fields.map((e) => TextEditingController()).toList();
    _pinFocusNodes = fields.map((e) => FocusNode()).toList();
  }

  @override
  void dispose() {
    super.dispose();
    for (var i = 0; i < _controllers!.length; i++) {
      _controllers![i].dispose();
      _pinFocusNodes![i].dispose();
    }
  }

  void onChange(String value, int index) {
    final valLen = value.length;
    if (index >= fields.length - 1 && valLen > 0) {
      if (valLen > 1)
        _controllers![index]..text = value.substring(valLen - 1, valLen);
      _pinFocusNodes![index].unfocus();
    } else if (valLen < 2)
      _pinFocusNodes![valLen == 0
              ? index < 1
                  ? index
                  : index - 1
              : index + 1]
          .requestFocus();
    else {
      int idx = index;
      for (var i = 0; i < valLen && idx < fields.length; i++) {
        _controllers![idx]..text = value.substring(i, i + 1);
        idx++;
      }
      _pinFocusNodes![idx - 1].requestFocus();
    }
  }

  void onFocusChange(bool focus, int index) {
    if (focus &&
        index > 0 &&
        _controllers![index - 1].text.length < 1 &&
        _controllers![index].text.length < 1)
      _pinFocusNodes![index - 1].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final onSubmit = () {
      var otp = '';
      for (var i = 0; i < fields.length; i++) {
        otp += _controllers![i].text;
      }
      otp = otp.trim().replaceAll(' ', '');
      if (otp.length < fields.length)
        Toast(context, message: 'Incomplete OTP').show();
      else
        widget.onSubmit(otp);
    };
    return Form(
      child: Column(
        children: [
          SizedBox(
            width: screenSize(context).width * 0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: fields.map((field) => pinInput(field)).toList(),
            ),
          ),
          SizedBox(height: screenSize(context).height * 0.15),
          widget.loading
              ? Loading(
                  message: 'Resetting password',
                )
              : AuthButton(
                  text: 'RESET PASSWORD',
                  press: onSubmit,
                ),
        ],
      ),
    );
  }

  SizedBox pinInput(int index) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Focus(
        onFocusChange: (focus) => onFocusChange(focus, index),
        child: TextFormField(
          controller: _controllers![index],
          focusNode: _pinFocusNodes![index],
          autofocus: true,
          obscureText: true,
          style: TextStyle(fontSize: 18),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: otpInputDecoration,
          onChanged: (value) => onChange(value, index),
        ),
      ),
    );
  }
}
