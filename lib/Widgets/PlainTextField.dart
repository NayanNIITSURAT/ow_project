import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class PlainTextField extends StatefulWidget {
  const PlainTextField({
    this.text,
    this.onChange,
    this.keyboardType = TextInputType.name,
  });

  final String? text;
  final Function(String val)? onChange;
  final TextInputType keyboardType;

  @override
  State<PlainTextField> createState() => _PlainTextFieldState();
}

class _PlainTextFieldState extends State<PlainTextField> {
  late final _textController;
  @override
  void initState() {
    _textController = TextEditingController()..text = widget.text ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: InputBorder.none,
      ),
      onChanged: widget.onChange,
      controller: _textController,
      keyboardType: widget.keyboardType,
      textInputAction: TextInputAction.newline,
    ).px8();
  }
}
